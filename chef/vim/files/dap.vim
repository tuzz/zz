" DAP keybindings
nmap <leader>B :DapClearBreakpoints<cr>
nmap <leader>b :DapToggleBreakpoint<cr>
nmap =ov :DapVirtualTextToggle<cr>

hi NvimDapVirtualText ctermfg=97
hi NvimDapVirtualTextChanged ctermfg=yellow

lua << EOF
  local dap = require('dap')
  local dapui = require("dapui")
  local virtual = require("nvim-dap-virtual-text")
  local disasm = require("dap-disasm")
  local game_job, game_pid

  -- lldb-dap implements DAP restart but doesn't advertise support.
  dap.listeners.after["initialize"]["fastrestart"] = function(session)
    session.capabilities.supportsRestartRequest = true
  end

  -- <leader>r runs the game without the debugger, restarts it if it's running, with or without the debugger
  -- <leader>d runs the game with the debugger, restarts it if it's running, with or without the debugger, continues if stopped
  -- <leader>R or <Leader>D kills the game, whether or not it's running under the debugger
  -- <leader>b toggle a breakpoint on the line under the cursor
  -- <leader>B remove all breakpoints
  -- <leader>s toggles the scopes window which shows variables in scope
  -- <leader>S toggles the watch window which allows adding custom expressions
  -- <leader>x toggles the stacks window which also shows breakpoints and the repl
  -- <leader>a toggles the disassembly window
  -- up/down/left/right to step through the debugger: up continues until the next breakpoint
  -- shift-up/down/left/right can be used to step through the disassembly

  local function game_is_running(pid)
    pid = pid or game_pid
    if not pid then return false end
    if pid == game_pid and game_job and vim.fn.jobwait({ game_job }, 0)[1] == -1 then return true end

    local comm = vim.fn.system({ "ps", "-o", "comm=", "-p", tostring(pid) })
    return vim.v.shell_error == 0 and comm:find("build/debug/main", 1, true) ~= nil
  end

  local function start_game()
    game_job = vim.fn.jobstart({ "sh", "-c", "exec ./build/debug/main > /tmp/game.log 2>&1" }, {
      cwd = vim.fn.getcwd(),
      on_exit = function(id) if id == game_job then game_job, game_pid = nil, nil end end,
    })
    game_pid = game_job > 0 and vim.fn.jobpid(game_job) or nil
  end

  local function stop_game()
    local pid = game_pid
    if dap.session() then dap.terminate({}, { terminateDebuggee = true }) end
    if game_job and vim.fn.jobwait({ game_job }, 0)[1] == -1 then vim.fn.jobstop(game_job) end

    vim.defer_fn(function()
      if pid and game_is_running(pid) then vim.fn.system({ "kill", tostring(pid) }) end
      if game_pid == pid then game_pid = nil end
    end, 300)
  end

  dap.listeners.after.event_process["game"] = function(_, body)
    if body and body.systemProcessId then game_pid = body.systemProcessId end
  end

  -- Stop the game, with or without the debugger, then call start once it has exited so that two games never run at the same time.
  local function restart_game(start)
    local old_pid = game_pid
    stop_game()

    local function start_when_exited(attempts_left)
      if not game_is_running(old_pid) then return start() end
      if attempts_left > 0 then vim.defer_fn(function() start_when_exited(attempts_left - 1) end, 50) end -- Give up after ~5s, e.g. if it hung.
    end
    vim.defer_fn(function() start_when_exited(100) end, 350) -- After stop_game's deferred kill, which would otherwise kill the new game.
  end

  -- Rebuild game.o without sanitizers if the last full build added them for better performance.
  local function start_fast_game()
    vim.fn.system("nm -u build/debug/game.dylib | grep -q ___asan_")
    if vim.v.shell_error == 0 then
      vim.fn.delete("build/debug/game.o")
      if not _G.build_now("fast.") then return end -- Leave the errors in the quickfix list rather than launching the old build.
    end
    start_game()
  end

  vim.keymap.set("n", "<leader>d", function()
    local session = dap.session()

    if session then
      if session.stopped_thread_id then
        dap.continue()
      else
        dap.restart() -- Restarting keeps lldb-dap and its target warm so the game re-stops in ~1s.
      end
    elseif game_is_running() then
      restart_game(function() dap.continue() end) -- Swap the fast game for one under the debugger.
    else
      dap.continue()
    end
  end)

  vim.keymap.set("n", "<leader>r", function()
    if dap.session() or game_is_running() then
      restart_game(start_fast_game) -- Swap a game under the debugger for a fast one, or restart the fast one.
    else
      start_fast_game()
    end
  end)

  vim.keymap.set("n", "<leader>R", stop_game)

  vim.keymap.set("n", "<leader>D", stop_game)

  dap.adapters.lldb = {
    type = 'executable',
    command = '/opt/homebrew/opt/llvm/bin/lldb-dap',
    name = 'lldb'
  }

  dap.configurations.c = {
    {
      name = 'lldb',
      type = 'lldb',
      request = 'launch',
      program = function() return vim.fn.getcwd() .. '/build/debug/main' end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
      env = { NVIM = vim.v.servername }, -- So the game can load clicked entities into the quickfix list.
      stdio = { vim.NIL, vim.NIL, '/tmp/game.log' },
      initCommands = {
        "settings set stop-disassembly-display never",
      },
    }
  }
  dap.configurations.sh = dap.configurations.c

  -- use up/down/left/right for controlling the debugger/disassembler.
  local dap_keys = {
    ['<Up>'] = dap.continue,
    ['<Right>'] = dap.step_into,
    ['<Down>'] = dap.step_over,
    ['<Left>'] = dap.step_out,
    ['<S-Up>'] = disasm.continue,
    ['<S-Right>'] = disasm.step_into,
    ['<S-Down>'] = disasm.step_over,
    ['<S-Left>'] = dap.step_out,
  }

  -- use up/down/left/right for entities.vim keys when the debugger isn't running.
  local page_up = vim.api.nvim_replace_termcodes('<C-b>', true, false, true)
  local page_down = vim.api.nvim_replace_termcodes('<C-f>', true, false, true)
  local function entity_key(name, fallback)
    return function()
      if vim.api.nvim_buf_get_name(0):find('/src/entities/', 1, true) then return _G[name]() end
      return fallback()
    end
  end

  local idle_keys = {
    ['<Up>'] = entity_key('entity_increment_number', function() vim.cmd('normal! ' .. vim.v.count1 .. 'k') end),
    ['<Down>'] = entity_key('entity_decrement_number', function() vim.cmd('normal! ' .. vim.v.count1 .. 'j') end),
    ['<S-Up>'] = entity_key('entity_grow', function() vim.api.nvim_feedkeys(page_up, 'n', false) end),
    ['<S-Down>'] = entity_key('entity_shrink', function() vim.api.nvim_feedkeys(page_down, 'n', false) end),
    ['<Left>'] = function() vim.cmd('normal! ' .. vim.v.count1 .. 'h') end,
    ['<Right>'] = function() vim.cmd('normal! ' .. vim.v.count1 .. 'l') end,
    ['<S-Left>'] = function() vim.cmd('normal! ' .. vim.v.count1 .. 'b') end,   -- move cursor left as normal.
    ['<S-Right>'] = function() vim.cmd('normal! ' .. vim.v.count1 .. 'w') end,  -- move cursor right as normal.
  }

  local function debugger_is_stopped()
    local session = dap.session()
    return session ~= nil and session.stopped_thread_id ~= nil
  end

  for key, idle_fn in pairs(idle_keys) do
    local debug_fn = dap_keys[key]
    vim.keymap.set('n', key, function()
      if debug_fn and debugger_is_stopped() then return debug_fn() end
      return idle_fn()
    end, {silent = true})
  end

  if not disasm._registered then
    disasm.setup({
      dapui_register = true,
      repl_commands = true,
      winbar = false,
      sign = "DapStopped",
      ins_before_memref = 1000,
      ins_after_memref = 1000,
      columns = { "address", "instruction" },
    })
    disasm._registered = true
  end

  local dapui_is_open = false
  local right_layout = 1 -- 1 = scopes only, 2 = scopes + watches

  dapui.setup({
    expand_lines = false,
    controls = { element = "repl", enabled = false },
    layouts = {
      { -- 1: scopes only (default)
        elements = { { id = "scopes", size = 1 } },
        position = "right", size = 80,
      },
      { -- 2: scopes + watches
        elements = { { id = "scopes", size = 0.7 }, { id = "watches", size = 0.3 } },
        position = "right", size = 80,
      },
      { -- 3: stacks + breakpoints + repl
        elements = {
          { id = "stacks",      size = 0.5  },
          { id = "breakpoints", size = 0.25 },
          { id = "repl",        size = 0.25 },
        },
        position = "right", size = 60,
      },
      { -- 4: disassembly
        elements = { { id = "disassembly", size = 1 } },
        position = "right", size = 80,
      },
    },
  })

  dap.listeners.after.event_stopped.dapui_config = function(session, body)
    if not dapui_is_open then
      dapui.open({ layout = right_layout })
      dapui_is_open = true
    end
  end

  dap.listeners.after["continue"]["dapui_config"] = function()
    if dapui_is_open then
      dapui.close({ layout = right_layout })
      dapui_is_open = false
    end
  end

  local function close_dapui()
    dapui.close()
    dapui_is_open = false
    right_layout = 1
  end
  dap.listeners.before.event_terminated.dapui_config = close_dapui
  dap.listeners.before.event_exited.dapui_config = close_dapui

  -- Jump to the line in src/ that actually failed, not the libc, SDL and assert_fail
  -- frames that sit above it — nvim-dap stops on the topmost frame that has source.
  local project_src = vim.fn.getcwd() .. '/src/'
  local stop_reason = nil
  local assert_plumbing = { assert_fail = true }
  dap.listeners.before.event_stopped['skip_library_frames'] = function(_, stopped)
    stop_reason = stopped.reason
  end
  dap.listeners.before.stackTrace['skip_library_frames'] = function(_, err, response)
    if err or stop_reason ~= 'exception' then return end

    local frames = response and response.stackFrames or {}
    local ours = nil
    for i, frame in ipairs(frames) do
      local path = frame.source and frame.source.path
      local name = frame.name and frame.name:match('^[%w_]+') or ''
      if path and vim.startswith(path, project_src) and not assert_plumbing[name] then
        ours = i
        break
      end
    end

    for i = 1, (ours or 1) - 1 do
      frames[i].source = nil
    end
  end

  -- Toggle watches in the bottom of the scopes panel.
  vim.keymap.set('n', '<leader>S', function()
    if right_layout == 1 then
      dapui.close({ layout = 1 })
      dapui.open({ layout = 2 })
      right_layout = 2
    else
      dapui.close({ layout = 2 })
      dapui.open({ layout = 1 })
      right_layout = 1
    end
    dapui_is_open = true
  end, { silent = true })

  vim.keymap.set('n', '<leader>x', function() dapui.toggle({ layout = 3 }) end, { silent = true })
  vim.keymap.set('n', '<leader>a', function() dapui.toggle({ layout = 4 }) end, { silent = true })
  vim.keymap.set('n', '<leader>s', function()
    dapui.toggle({ layout = right_layout })
    dapui_is_open = not dapui_is_open
  end, { silent = true })

  virtual.setup({
    all_frames = true,
    virt_text_pos = 'eol',
    display_callback = function(variable, buf, stackframe, node, options)
      if variable.value:match("^%u[%w_]*$") then return nil end
      if variable.value:match("^[%w_]+ [%w_]+$") then return nil end
      if variable.value:match("^0x%x+$") then return nil end
      if variable.value:match("^[%w_]+%[") then return nil end
      if options.virt_text_pos == 'inline' then
        return ' = ' .. variable.value:gsub("%s+", " ")
      else
        return variable.name .. ' = ' .. variable.value:gsub("%s+", " ")
      end
    end,
  })

  local vt_stack_trace = dap.listeners.after.stackTrace["nvim-dap-virtual-text"]
  if vt_stack_trace then
    dap.listeners.after.stackTrace["nvim-dap-virtual-text"] = function(session, err, ...)
      if err then return end
      return vt_stack_trace(session, err, ...)
    end
  end

  vim.api.nvim_set_hl(0, "DapLightBlue", { ctermfg = 12 })
  vim.api.nvim_set_hl(0, "DapDarkBlue",  { ctermbg = 17 })
  vim.api.nvim_set_hl(0, "DapLightRed",  { ctermbg = 9  })

  vim.fn.sign_define("DapBreakpoint",          { text = "", texthl = "", linehl = "",            numhl = "DapLightBlue" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "", linehl = "",            numhl = "DapLightBlue" })
  vim.fn.sign_define("DapStopped",             { text = "", texthl = "", linehl = "DapDarkBlue", numhl = ""             })
  vim.fn.sign_define("DapBreakpointRejected",  { text = "", texthl = "", linehl = "",            numhl = "DapLightRed"  })

  vim.notify = (function()
    local notify = vim.notify
    return function(msg, ...)
      if type(msg) == "string" and msg:match("Cursor position outside buffer") then return end
      notify(msg, ...)
    end
  end)()
EOF
