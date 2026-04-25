lua << EOF
local build_qf_open = false

local function build(flag)
  vim.cmd("write")
  local output = vim.fn.system("./scripts/build_debug " .. flag .. " 2>&1")
  if vim.v.shell_error == 0 then
    vim.api.nvim_echo({{"  Built ", "Normal"}, {flag, "Normal"}}, false, {})
    if build_qf_open then
      vim.cmd("cclose")
      build_qf_open = false
    end
  else
    vim.fn.setqflist({}, "r", {
      title = "Build errors",
      lines = vim.split(output, "\n"),
    })
    local items = vim.fn.getqflist()
    local valid = vim.tbl_filter(function(e) return e.valid == 1 end, items)
    vim.fn.setqflist({}, "r", { title = "Build errors", items = valid })

    vim.cmd("copen")
    vim.cmd("wincmd p")
    build_qf_open = true
  end
end

vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    if vim.bo.filetype == "qf" then
      build_qf_open = false
    end
  end,
})

vim.keymap.set("n", "<leader>w", function() build("--minimal") end)
vim.keymap.set("n", "<leader>W", function() build("--default") end)
vim.keymap.set("n", "<leader>F", function() build("--full") end)
EOF

nmap <leader>p :7split \| terminal bash -c './scripts/flamegraph; exit'<cr>
nmap <leader>P :7split \| terminal bash -c './scripts/instruments; exit'<cr>
au TermClose * if !v:event.status | close | endif
