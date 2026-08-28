lua << EOF
local build_qf_open = false
local build_job, build_pending

-- Show build errors in the quickfix list or close it again once a build succeeds.
local function finish(flag, code, output)
  build_job = nil
  if code == 0 then
    vim.api.nvim_echo({{"  Built ", "Normal"}, {flag, "Normal"}}, false, {})
    if build_qf_open then
      vim.cmd("cclose")
      build_qf_open = false
    end
  else
    vim.fn.setqflist({}, "r", { title = "Build errors", lines = vim.split(output, "\n") })
    local items = vim.fn.getqflist()
    local valid = vim.tbl_filter(function(e) return e.valid == 1 end, items)
    vim.fn.setqflist({}, "r", { title = "Build errors", items = valid })

    vim.cmd("copen")
    vim.cmd("wincmd p")
    build_qf_open = true
  end
end

local function build_now(flag)
  vim.cmd("write")

  build_pending = nil                               -- This supersedes anything the arrow keys queued.
  if build_job then vim.fn.jobwait({build_job}) end -- Never run two build_debug processes at once.

  local output = vim.fn.system("./scripts/build_debug " .. vim.fn.shellescape(flag) .. " 2>&1") -- Compiler errors go to stderr.
  finish(flag, vim.v.shell_error, output)
end

local function build(flag)
  vim.cmd("write")
  if build_job then build_pending = flag return end -- One build at a time, debounce the rest.
  build_pending = nil

  local output = {}
  local function collect(_, data) for _, line in ipairs(data or {}) do table.insert(output, line) end end

  build_job = vim.fn.jobstart({"./scripts/build_debug", flag}, {
    on_stdout = collect,
    on_stderr = collect,
    on_exit = function(_, code)
      finish(flag, code, table.concat(output, "\n"))
      if build_pending then build(build_pending) end
    end,
  })
end

vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    if vim.bo.filetype == "qf" then
      build_qf_open = false
    end
  end,
})

_G.build_project = build -- entities.vim rebuilds after each edit.

vim.keymap.set("n", "<leader>w", function() build_now("minimal.") end)
vim.keymap.set("n", "<leader>W", function() vim.fn.delete("build/debug/main") build_now("default.") end)
vim.keymap.set("n", "<leader>F", function() vim.fn.delete("build/debug/main") vim.fn.delete("assets/shaders", "rf") build_now("full.") end)
EOF

nmap <leader>p :7split \| terminal bash -c './scripts/flamegraph; exit'<cr>
nmap <leader>P :7split \| terminal bash -c './scripts/instruments; exit'<cr>
au TermClose * if !v:event.status | close | endif
