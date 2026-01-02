vim.g.mapleader = ","

local map = vim.keymap.set

map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })

map("n", "te", ":tabedit")
map("n", "<tab>", ":tabnext<Return>", opts)
map("n", "<s-tab>", ":tabprev<Return>", opts)
map("n", "tw", ":tabclose<Return>", opts)

vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.wrap = true
vim.opt.showbreak = "↪ "

vim.opt.title = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.showmode = false
vim.opt.cmdheight = 0
vim.opt.laststatus = 0
vim.opt.scrolloff = 10
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.breakindent = true
vim.opt.path:append({ "**" })
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"
vim.opt.mouse = ""

vim.opt.formatoptions:append({ "r" })

vim.cmd("let g:netrw_liststyle = 3")

vim.api.nvim_set_keymap("n", "<leader>yy", "ggVGy", { noremap = true, silent = true })

local opt = vim.opt

-- new line warping and folding config
vim.o.linebreak = true
vim.keymap.set("n", "<leader>ww", ":set wrap!<CR>")

opt.relativenumber = true
opt.number = true
opt.scrolloff = 8

-- tabs & indentation
opt.tabstop = 4 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 4 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
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

vim.opt.listchars:append("space:·")

vim.opt.linespace = 2
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<Leader>Y", [["+Y]])
vim.keymap.set("n", "<Leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.opt.updatetime = 50
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<D-d>", "<C-d>zz")
vim.keymap.set("n", "<D-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- navigate left and right with vim mode
-- Normal Mode Navigation
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

-- for macos
vim.api.nvim_set_keymap("n", "<D-h>", "<C-w>h", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<D-j>", "<C-w>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<D-k>", "<C-w>k", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<D-l>", "<C-w>l", { noremap = true, silent = true })

-- Terminal Navigation
vim.api.nvim_set_keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })

-- for macos
vim.api.nvim_set_keymap("t", "<D-h>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-j>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-k>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-l>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })

-- for macos
-- Normal Mode Navigation with Tab
vim.api.nvim_set_keymap("n", "<Tab>h", "<C-w>h", { noremap = true, silent = true }) -- Tab + H to move left
vim.api.nvim_set_keymap("n", "<Tab>j", "<C-w>j", { noremap = true, silent = true }) -- Tab + J to move down
vim.api.nvim_set_keymap("n", "<Tab>k", "<C-w>k", { noremap = true, silent = true }) -- Tab + K to move up
vim.api.nvim_set_keymap("n", "<Tab>l", "<C-w>l", { noremap = true, silent = true }) -- Tab + L to move right

-- Terminal Mode Navigation with Tab
vim.api.nvim_set_keymap("t", "<Tab>h", "<C-\\><C-n><C-w>h", { noremap = true, silent = true }) -- Tab + H to move left
vim.api.nvim_set_keymap("t", "<Tab>j", "<C-\\><C-n><C-w>j", { noremap = true, silent = true }) -- Tab + J to move down
vim.api.nvim_set_keymap("t", "<Tab>k", "<C-\\><C-n><C-w>k", { noremap = true, silent = true }) -- Tab + K to move up
vim.api.nvim_set_keymap("t", "<Tab>l", "<C-\\><C-n><C-w>l", { noremap = true, silent = true }) -- Tab + L to move right

-- Copy entire buffer contents to system clipboard
vim.api.nvim_set_keymap("n", "<Leader>y", 'ggVG"+y', { noremap = true })

--Compile and run C++ code
vim.api.nvim_set_keymap(
	"n",
	"<Leader>rr",
	':w<CR>:! printf "Mohiittt your output is\n----------------------\n" && g++ -std=c++17 -o test %:r.cpp && ./test && printf "---------------------\n"<CR>',
	{ noremap = true, silent = true }
)

-- input.txt => fill input
vim.api.nvim_set_keymap("n", "<Leader>r", "<cmd>lua CompileAndRunCpp()<CR>", { noremap = true, silent = true })

-- Function to compile and run C++ file with input redirection
function CompileAndRunCpp()
	-- Get full path without extension
	local filepath = vim.fn.expand("%:p:r")
	local cpp_file = filepath .. ".cpp"
	local output_file = filepath .. ".out"
	local input_file = vim.fn.expand("%:p:h") .. "/input.txt"

	-- Compile the C++ file
	local compile_cmd = string.format("g++ -std=c++17 -o '%s' '%s'", output_file, cpp_file)
	vim.fn.system(compile_cmd)

	if vim.v.shell_error ~= 0 then
		print("❌ Compilation failed!")
		return
	end

	print("✅ Compilation succeeded!")

	-- Escape spaces and run the output file with input redirection
	local run_cmd = string.format("split | terminal bash -c '%s < %s; exec bash'", output_file, input_file)
	vim.cmd(run_cmd)
end

-- --  Compile and run C++ code with input from file
-- vim.api.nvim_set_keymap(
-- 	"n",
-- 	"<Leader>r",
-- 	':w<CR>:! printf "24kgold_nnn your output from file is\\n---------------\\n" &&  g++ -std=c++17 -o test %:r.cpp && ./test < input.txt && printf "----------\\n"<CR>',
-- 	{ noremap = true, silent = true }
-- )
--
-- -- Compile and run C++ code with timing
-- vim.api.nvim_set_keymap(
-- 	"n",
-- 	"<Leader>p",
-- 	':w<CR>:! printf "24kgold_n your time of execution file is\n*************\n" &&  g++ -std=c++17 -o test %:r.cpp && time ./test < input.txt && printf "*************\n"<CR>',
-- 	{ noremap = true }
-- )

-- keybinds
function VerticalSplit()
	vim.cmd("vsplit")
end
vim.api.nvim_set_keymap("n", "<leader>vs", "<cmd>lua VerticalSplit()<CR>", { noremap = true, silent = true })

--horizontal split
--keybinds
function HorizontalSplit()
	vim.cmd("split")
end
vim.api.nvim_set_keymap("n", "<leader>hs", "<cmd>lua HorizontalSplit()<CR>", { noremap = true, silent = true })

-- Detect OS
if not vim.g.os then
	if vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 or vim.fn.has("win16") == 1 then
		vim.g.os = "Windows"
	else
		vim.g.os = vim.fn.system("uname"):gsub("\n", "")
	end
end

-- Important option that should already be set!
vim.opt.hidden = true

-- Function to wrap terminal commands
function TermWrapper(command)
	-- Set default split style if not already set
	if not vim.g.split_term_style then
		vim.g.split_term_style = "vertical"
	end

	local buffercmd
	if vim.g.split_term_style == "vertical" then
		buffercmd = "vnew"
	elseif vim.g.split_term_style == "horizontal" then
		buffercmd = "new"
	else
		vim.api.nvim_err_writeln(
			"ERROR! g:split_term_style is not a valid value (must be 'horizontal' or 'vertical' but is currently set to '"
				.. vim.g.split_term_style
				.. "')"
		)
		error("ERROR! g:split_term_style is not a valid value (must be 'horizontal' or 'vertical')")
	end

	-- Execute the buffer command
	vim.cmd(buffercmd)

	-- Resize the terminal if a resize command is set
	if vim.g.split_term_resize_cmd then
		vim.cmd(vim.g.split_term_resize_cmd)
	end

	-- Execute the terminal command
	vim.cmd("term " .. command)
	vim.cmd("setlocal nornu nonu")
	vim.cmd("startinsert")

	-- Automatically enter insert mode on buffer enter
	vim.api.nvim_create_autocmd("BufEnter", {
		buffer = 0,
		callback = function()
			vim.cmd("startinsert")
		end,
	})
end

-- Command to compile and run the current C++ file
vim.api.nvim_create_user_command("CompileAndRun", function()
	local command = string.format("g++ -std=c++11 %s && ./a.out", vim.fn.expand("%"))
	TermWrapper(command)
end, { nargs = 0 })

-- Command to compile and run with a specified input file
vim.api.nvim_create_user_command("CompileAndRunWithFile", function(opts)
	local command = string.format("g++ -std=c++11 %s && ./a.out < %s", vim.fn.expand("%"), opts.args)
	TermWrapper(command)
end, { nargs = 1, complete = "file" })

-- Key mappings for C++ file types
vim.api.nvim_create_autocmd("FileType", {
	pattern = "cpp",
	callback = function()
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>fw", ":CompileAndRun<CR>", { noremap = true, silent = true })
	end,
})

-- C++ toolkit commands for macOS
vim.api.nvim_create_augroup("CppToolkit", { clear = true })

if vim.g.os == "Darwin" then
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			vim.api.nvim_buf_set_keymap(
				0,
				"n",
				"<leader>fn",
				":!g++ -std=c++11 -o %:r % && open -a Terminal './a.out'<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_buf_set_keymap(
				0,
				"n",
				"<leader>fb",
				":!g++ -std=c++11 % && ./a.out<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_buf_set_keymap(0, "n", "<leader>fr", ":!./a.out<CR>", { noremap = true, silent = true })
		end,
	})
end

-- Options for terminal split style and resizing

vim.g.split_term_style = "horizontal" -- Choose between 'vertical' and 'horizontal'
vim.g.split_term_resize_cmd = "resize 15" -- Command to resize the terminal window

