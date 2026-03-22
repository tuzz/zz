" DAP keybindings
nmap <leader>B :DapClearBreakpoints<cr>
nmap <leader>b :DapToggleBreakpoint<cr>
nmap <leader>d :DapContinue<cr>
nmap <leader>D :DapTerminate<cr>
nmap =ov :DapVirtualTextToggle<cr>

hi NvimDapVirtualText ctermfg=97
hi NvimDapVirtualTextChanged ctermfg=yellow

lua << EOF
  local dap = require('dap')
  local dapui = require("dapui")
  local virtual = require("nvim-dap-virtual-text")
  local disasm = require("dap-disasm")

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
    }
  }

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

  local function set_dap_keys()
    for k, fn in pairs(dap_keys) do
      vim.keymap.set('n', k, fn, {silent = true})
    end
  end

  local function restore_keys()
    for k, _ in pairs(dap_keys) do
      pcall(vim.keymap.del, 'n', k)
    end
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

  dap.listeners.after.event_stopped.dapui_config = function()
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

  dap.listeners.after.event_initialized['custom_keymaps'] = set_dap_keys
  dap.listeners.before.event_terminated['custom_keymaps'] = restore_keys
  dap.listeners.before.event_exited['custom_keymaps'] = restore_keys

  -- Toggle watches in the bottom of the scopes panel
  vim.keymap.set('n', '<leader>W', function()
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
