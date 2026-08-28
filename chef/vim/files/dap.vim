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

  -- lldb-dap implements DAP restart but doesn't advertise support.
  dap.listeners.after["initialize"]["fastrestart"] = function(session)
    session.capabilities.supportsRestartRequest = true
  end

  -- <leader>d restarts an existing DAP session rather than starting fresh.
  vim.keymap.set("n", "<leader>d", function()
    local session = dap.session()
    if session and session.initialized and not session.stopped_thread_id then
      dap.restart()
    else
      dap.continue()
    end
  end)

  -- <leader>D intercept lldb-dap termination so that the session stays loaded.
  local Session = require("dap.session")
  local keep_target_warm = false
  local event_terminated = Session.event_terminated
  Session.event_terminated = function(self, body)
    if keep_target_warm then
      keep_target_warm = false
      return
    end
    return event_terminated(self, body)
  end

  vim.keymap.set("n", "<leader>D", function()
    local session = dap.session()
    if not session then return end
    keep_target_warm = true
    vim.defer_fn(function() keep_target_warm = false end, 3000) -- Don't swallow an unrelated exit later.
    session:request("evaluate", { expression = "`process kill", context = "repl" }, function(err)
      if err then keep_target_warm = false end
    end)
  end)

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
      stdio = { vim.NIL, vim.NIL, '/tmp/game.log' },
      initCommands = {
        "settings set target.inline-breakpoint-strategy always",
        "settings set stop-disassembly-display never",
      },
    }
  }
  dap.configurations.sh = {
    {
      name = 'lldb',
      type = 'lldb',
      request = 'launch',
      program = function() return vim.fn.getcwd() .. '/build/debug/main' end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
      stdio = { vim.NIL, vim.NIL, '/tmp/game.log' },
      initCommands = {
        "settings set target.inline-breakpoint-strategy always",
        "settings set stop-disassembly-display never",
      },
    }
  }

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
    ['<Up>'] = entity_key('entity_bump_up', function() vim.cmd('normal! ' .. vim.v.count1 .. 'k') end),
    ['<Down>'] = entity_key('entity_bump_down', function() vim.cmd('normal! ' .. vim.v.count1 .. 'j') end),
    ['<S-Up>'] = entity_key('entity_grow', function() vim.api.nvim_feedkeys(page_up, 'n', false) end),
    ['<S-Down>'] = entity_key('entity_shrink', function() vim.api.nvim_feedkeys(page_down, 'n', false) end),
    ['<Left>'] = function() vim.cmd('normal! ' .. vim.v.count1 .. 'h') end,
    ['<Right>'] = function() vim.cmd('normal! ' .. vim.v.count1 .. 'l') end,
    ['<S-Left>'] = function() vim.cmd('normal! ' .. vim.v.count1 .. 'b') end,   -- move cursor left as normal.
    ['<S-Right>'] = function() vim.cmd('normal! ' .. vim.v.count1 .. 'w') end,  -- move cursor right tas normal.
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
      dapui.open({ layout = 1 })
      dapui_is_open = true
      right_layout = 1
    end
  end
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
    dapui_is_open = false
    right_layout = 1
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
    dapui_is_open = false
    right_layout = 1
  end

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
  end, { noremap = true, silent = true })

  vim.keymap.set('n', '<leader>x', function() dapui.toggle({ layout = 3 }) end, { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>a', function() dapui.toggle({ layout = 4 }) end, { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>s', function()
    dapui.toggle({ layout = right_layout })
    dapui_is_open = not dapui_is_open
  end, { noremap = true, silent = true })

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

  vim.api.nvim_set_hl(0, "DapLightBlue", { ctermfg = 12 })
  vim.api.nvim_set_hl(0, "DapDarkBlue",  { ctermbg = 17 })

  vim.fn.sign_define("DapBreakpoint",         { text = "", texthl = "", linehl = "",          numhl = "DapLightBlue" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "", linehl = "",          numhl = "DapLightBlue" })
  vim.fn.sign_define("DapStopped",             { text = "", texthl = "", linehl = "DapDarkBlue", numhl = ""           })
  vim.fn.sign_define("DapBreakpointRejected",  { text = "", texthl = "", linehl = "",          numhl = "DapLightBlue" })

  vim.notify = (function()
    local notify = vim.notify
    return function(msg, ...)
      if type(msg) == "string" and msg:match("Cursor position outside buffer") then return end
      notify(msg, ...)
    end
  end)()
EOF
