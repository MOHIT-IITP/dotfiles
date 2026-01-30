-- set leader key to space
vim.g.mapleader = ","

local keymap = vim.keymap -- for conciseness
local map = vim.keymap.set

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>vs", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>hs", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

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
