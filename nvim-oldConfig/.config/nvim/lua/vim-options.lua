vim.g.mapleader = ","
local map = vim.keymap.set
local opt = vim.opt

vim.scriptencoding = "utf-8"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.termguicolors = true
opt.background = "dark"

opt.wrap = false
opt.linebreak = true
opt.showbreak = "↪ "
opt.breakindent = true

opt.smartindent = true
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.autoindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

opt.splitbelow = true
opt.splitright = true
opt.hidden = true
opt.swapfile = false

opt.clipboard:append("unnamedplus")
opt.backspace = "indent,eol,start"

opt.updatetime = 50
opt.listchars:append("space:·")
opt.linespace = 2

-------------------------------------------------
-- BASIC KEYMAPS
-------------------------------------------------
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

map("n", "te", "<cmd>tabedit<cr>")
map("n", "<tab>", "<cmd>tabnext<cr>")
map("n", "<s-tab>", "<cmd>tabprev<cr>")
map("n", "tw", "<cmd>tabclose<cr>")

map("n", "<leader>yy", "ggVGy")
map("n", "<leader>ww", "<cmd>set wrap!<cr>")

-------------------------------------------------
-- BETTER MOVEMENT
-------------------------------------------------
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-------------------------------------------------
-- WINDOW NAV
-------------------------------------------------
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-------------------------------------------------
-- SPLITS
-------------------------------------------------
map("n", "<leader>vs", "<cmd>vsplit<cr>")
map("n", "<leader>hs", "<cmd>split<cr>")

-------------------------------------------------
-- SYSTEM CLIPBOARD
-------------------------------------------------
map("n", "<leader>y", 'ggVG"+y')
map("n", "<leader>Y", '"+Y')

-------------------------------------------------
-- SEARCH REPLACE WORD
-------------------------------------------------
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-------------------------------------------------
-- C++ TOOL (CLEAN)
-----------------------------------------------
function CompileAndRunCpp()
  local file = vim.fn.expand("%:p:r")
  local cmd = string.format("g++ -std=c++17 %s.cpp -o %s && ./%s", file, file, file)
  vim.cmd("split | terminal " .. cmd)
end

map("n", "<leader>r", CompileAndRunCpp)
