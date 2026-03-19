-- set leader key to space
vim.g.mapleader = ","

local km = vim.keymap.set -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
km("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
km("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
km("n", "x", '"_x')

-- increment/decrement numbers
km("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
km("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
km("n", "=", [[<cmd>vertical resize +5<cr>]])
km("n", "-", [[<cmd>vertical resize -5<cr>]])
km("n", "+", [[<cmd>horizontal resize +5<cr>]])
km("n", "^", [[<cmd>horizontal resize +5<cr>]])
km("n", "<leader>vs", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
km("n", "<leader>hs", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
km("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
km("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

km("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
km("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
km("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
km("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
km("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-------------------------------------------------
-- BASIC KEYMAPS
-------------------------------------------------
km("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
km("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

km("n", "te", "<cmd>tabedit<cr>")
km("n", "<tab>", "<cmd>tabnext<cr>")
km("n", "<s-tab>", "<cmd>tabprev<cr>")
km("n", "tw", "<cmd>tabclose<cr>")

km("n", "<leader>yy", "ggVGy")
km("n", "<leader>ww", "<cmd>set wrap!<cr>")

-------------------------------------------------
-- BETTER MOVEMENT
-------------------------------------------------
km("n", "<C-d>", "<C-d>zz")
km("n", "<C-u>", "<C-u>zz")
km("n", "n", "nzzzv")
km("n", "N", "Nzzzv")

km("v", "J", ":m '>+1<CR>gv=gv")
km("v", "K", ":m '<-2<CR>gv=gv")

-------------------------------------------------
-- WINDOW NAV
-------------------------------------------------
km("n", "<C-h>", "<C-w>h")
km("n", "<C-j>", "<C-w>j")
km("n", "<C-k>", "<C-w>k")
km("n", "<C-l>", "<C-w>l")

-------------------------------------------------
-- SPLITS
-------------------------------------------------
km("n", "<leader>vs", "<cmd>vsplit<cr>")
km("n", "<leader>hs", "<cmd>split<cr>")

-------------------------------------------------
-- DIAGNOSTIC
-------------------------------------------------

km("n", "[e", vim.diagnostic.goto_next)
km("n", "]e", vim.diagnostic.goto_next)

-------------------------------------------------
-- SYSTEM CLIPBOARD
-------------------------------------------------
km("n", "<leader>y", 'ggVG"+y')
km("n", "<leader>v", 'ggVG')

-------------------------------------------------
-- SEARCH REPLACE WORD
-------------------------------------------------
km("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-------------------------------------------------
-- C++ TOOL (CLEAN)
-----------------------------------------------
function CompileAndRunCpp()
  local file = vim.fn.expand("%:p:r")
  local cmd = string.format("g++ -std=c++17 %s.cpp -o %s && ./%s", file, file, file)
  vim.cmd("split | terminal " .. cmd)
end

km("n", "<leader>r", CompileAndRunCpp)
