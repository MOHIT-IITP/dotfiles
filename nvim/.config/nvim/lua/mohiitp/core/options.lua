local opt = vim.opt -- for conciseness
vim.g.mapleader = ","
vim.g.maplocalleader = ","
-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- appearance

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true

-- dynamic theme 
-- vim.cmd("source ~/.cache/wal/colors-wal.vim")
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false




-- Compile & Run C / C++ (FULLY FIXED, space-safe)
function Compile_and_run_cpp()
  local src = vim.fn.expand("%:p")
  local input_file = "input.txt"
  local output_file = "output.txt"
  local exe = "/tmp/nvim_cpp_run"

  -- Validate
  if not (src:match("%.c$") or src:match("%.cpp$")) then
    vim.api.nvim_err_writeln("❌ Not a C/C++ file")
    return
  end

  -- Ensure I/O files
  io.open(input_file, "a+"):close()
  io.open(output_file, "a+"):close()

  -- Layout
  if vim.fn.bufnr(input_file) == -1 then
    vim.cmd("vsplit " .. vim.fn.fnameescape(input_file))
  end
  if vim.fn.bufnr(output_file) == -1 then
    vim.cmd("split " .. vim.fn.fnameescape(output_file))
  end
  vim.cmd("wincmd h")
  vim.cmd("vertical resize 70")
  vim.cmd("buffer " .. vim.fn.bufnr(src))

  -- Compile (quoted paths)
  local compile_cmd = string.format(
    'g++ "%s" -O2 -std=c++17 -o "%s"',
    src, exe
  )

  local compile_out = vim.fn.system(compile_cmd)
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_err_writeln("❌ Compilation failed:\n" .. compile_out)
    return
  end

  -- Run (stdout + stderr)
  local run_cmd = string.format(
    '"%s" < "%s" 2>&1',
    exe, input_file
  )

  local run_output = vim.fn.system(run_cmd)

  -- Write output
  local f = io.open(output_file, "w")
  f:write(run_output)
  f:close()

  vim.cmd("checktime " .. output_file)
  print("✅ Run successful")
end

-- Keybind
vim.keymap.set("n", "<C-b>", Compile_and_run_cpp, { noremap = true, silent = true })
