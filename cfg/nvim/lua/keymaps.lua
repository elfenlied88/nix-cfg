local map = vim.keymap.set

--[[
-- Basic keymaps
--]]

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

--[[
-- Window navigation
-- Ctrl+h/j/k/l : normal mode and terminal mode
-- Alt+h/j/k/l  : normal, insert and terminal mode
--]]

for _, k in ipairs({ "h", "j", "k", "l" }) do
	map("n", "<C-" .. k .. ">", "<C-w>" .. k, { desc = "Window " .. k })
	map("t", "<C-" .. k .. ">", "<C-\\><C-n><C-w>" .. k, { desc = "Window " .. k })
	map("n", "<A-" .. k .. ">", "<C-w>" .. k, { desc = "Window " .. k })
	map("i", "<A-" .. k .. ">", "<Esc><C-w>" .. k, { desc = "Window " .. k })
	map("t", "<A-" .. k .. ">", "<C-\\><C-n><C-w>" .. k, { desc = "Window " .. k })
end
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

--[[
-- Terminals
-- Esc Esc      : terminal mode          leave terminal mode
-- <leader>tt   : normal mode            toggle bottom terminal
-- Alt+t        : normal and terminal mode   toggle bottom terminal
-- <leader>tv   : normal mode            open terminal in a right split
--]]

-- One group for all terminal autocmds. Create it ONCE in your config:
-- creating it again with clear = true removes the autocmds registered before.
local term_group = vim.api.nvim_create_augroup("UserTerminal", { clear = true })

-- Clean look inside terminals: no line numbers, no sign column
vim.api.nvim_create_autocmd("TermOpen", {
	group = term_group,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.opt_local.scrolloff = 0
		vim.bo.buflisted = false -- keep terminals out of the tab line and out of :bnext
		vim.bo.bufhidden = "hide" -- hiding the window keeps the shell running
	end,
})

-- Auto insert mode whenever you enter a terminal window
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter", "WinEnter" }, {
	group = term_group,
	callback = function()
		if vim.bo.buftype == "terminal" then
			vim.cmd.startinsert()
		end
	end,
})

-- One persistent bottom terminal you can show/hide with <leader>tt or Alt+t
local bottom_term = { buf = nil, win = nil }

local function toggle_bottom_term()
	-- Already visible: hide the window, keep the shell running in the buffer
	if bottom_term.win and vim.api.nvim_win_is_valid(bottom_term.win) then
		vim.api.nvim_win_hide(bottom_term.win)
		bottom_term.win = nil
		return
	end

	-- Open a split at the bottom and remember its window
	vim.cmd("botright 15split")
	bottom_term.win = vim.api.nvim_get_current_win()

	-- Reuse the old terminal buffer if it is still alive, otherwise start a new shell
	if bottom_term.buf and vim.api.nvim_buf_is_valid(bottom_term.buf) then
		vim.api.nvim_win_set_buf(bottom_term.win, bottom_term.buf)
	else
		vim.cmd.terminal()
		bottom_term.buf = vim.api.nvim_get_current_buf()
	end
	vim.cmd.startinsert()
end

-- When the shell in that terminal exits, forget it and close its window
vim.api.nvim_create_autocmd("TermClose", {
	group = term_group,
	callback = function(ev)
		if ev.buf == bottom_term.buf then
			bottom_term.buf = nil
			bottom_term.win = nil
			vim.schedule(function()
				pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
			end)
		end
	end,
})

map("n", "<leader>tt", toggle_bottom_term, { desc = "Toggle bottom terminal" })
map("n", "<A-t>", toggle_bottom_term, { desc = "Toggle bottom terminal" })
-- Inside the terminal you are in terminal mode, so leave it first, then toggle
map("t", "<A-t>", function()
	vim.cmd.stopinsert()
	toggle_bottom_term()
end, { desc = "Toggle bottom terminal" })
map("n", "<leader>tv", "<cmd>vsplit | terminal<CR>", { desc = "Terminal (right split)" })

--[[
-- File Explorer (Neo-tree)
-- <leader>e    : normal mode            toggle file explorer
--
-- Inside the tree (plugin defaults, press ? in the tree for the full list)
-- a / A        add file / add directory
-- d / r / m    delete / rename / move
-- y / x / p    copy / cut / paste
-- s / S        open in vertical / horizontal split
-- H            toggle hidden files
-- /            fuzzy find
-- q            close the tree
--]]

map("n", "<leader>e", "<Cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })

local tree_width = 40

local ok, neotree = pcall(require, "neo-tree")
if ok then
	close_if_last_window =
		true, neotree.setup({
			window = {
				position = "left",
				width = tree_width,
			},
			filesystem = {
				filtered_items = {
					hide_dotfiles = false, -- show .gitignore, .envrc, ... (press H in the tree to toggle)
				},
				follow_current_file = { enabled = false },
				use_libuv_file_watcher = true, -- refresh when files or git state change on disk
			},
			buffers = {
				follow_current_file = { enabled = true },
				group_empty_dirs = true,
			},
			git_status = {
				window = { position = "float" },
			},
			event_handlers = {
				{
					-- After a file is opened from the tree, put the tree back to its normal width.
					-- (If the tree was the only window it was full width and squeezed the new one.)
					event = "file_opened",
					handler = function()
						for _, win in ipairs(vim.api.nvim_list_wins()) do
							local buf = vim.api.nvim_win_get_buf(win)
							if vim.bo[buf].filetype == "neo-tree" then
								vim.api.nvim_win_set_width(win, tree_width)
							end
						end
					end,
				},
			},
		})
end

--[[
-- Buffers / tabs (barbar.nvim), all in normal mode
-- Alt+,  / Alt+.        : previous / next buffer
-- Alt+<  / Alt+>        : move buffer left / right in the tab line
-- Alt+1..9              : go to buffer number 1..9
-- Alt+0                 : go to the last buffer
-- Alt+p                 : pin / unpin buffer
-- Alt+c                 : close buffer
-- Ctrl+p                : pick a buffer by letter
-- Ctrl+Shift+p          : pick a buffer by letter and close it
-- <leader>bb/bn/bd/bl/bw: sort tabs by number / name / directory / language / window
--
-- Commands without a key (run with :Command)
-- :BufferGotoPinned / :BufferGotoUnpinned
-- :BufferWipeout
-- :BufferCloseAllButCurrent / :BufferCloseAllButPinned / :BufferCloseAllButCurrentOrPinned
-- :BufferCloseBuffersLeft / :BufferCloseBuffersRight
-- :BarbarEnable   (on by default)
--]]

-- Move to previous/next
map("n", "<A-,>", "<Cmd>BufferPrevious<CR>", { desc = "Previous buffer" })
map("n", "<A-.>", "<Cmd>BufferNext<CR>", { desc = "Next buffer" })

-- Re-order to previous/next
map("n", "<A-<>", "<Cmd>BufferMovePrevious<CR>", { desc = "Move buffer left" })
map("n", "<A->>", "<Cmd>BufferMoveNext<CR>", { desc = "Move buffer right" })

-- Goto buffer in position...
for i = 1, 9 do
	map("n", "<A-" .. i .. ">", "<Cmd>BufferGoto " .. i .. "<CR>", { desc = "Buffer " .. i })
end
map("n", "<A-0>", "<Cmd>BufferLast<CR>", { desc = "Last buffer" })

-- Pin/unpin buffer
map("n", "<A-p>", "<Cmd>BufferPin<CR>", { desc = "Pin buffer" })

-- Close buffer
local function close_buffer()
	if vim.bo.filetype == "neo-tree" then
		vim.cmd("Neotree close") -- Alt+c inside the tree just closes the tree
		return
	end

	local cur = vim.api.nvim_get_current_buf()
	local listed = vim.fn.getbufinfo({ buflisted = 1 })

	if #listed <= 1 then
		-- already an empty, unmodified buffer: nothing to close
		if vim.api.nvim_buf_get_name(cur) == "" and not vim.bo[cur].modified then
			return
		end
		vim.cmd("enew") -- empty buffer takes over the window
		vim.cmd("bdelete " .. cur) -- then remove the old one (asks to save if modified)
	else
		vim.cmd("BufferClose") -- normal case: barbar handles it
	end
end

map("n", "<A-c>", close_buffer, { desc = "Close buffer" })

-- Magic buffer-picking mode
map("n", "<C-p>", "<Cmd>BufferPick<CR>", { desc = "Pick buffer" })
map("n", "<C-S-p>", "<Cmd>BufferPickDelete<CR>", { desc = "Pick buffer to close" })

-- Sort automatically by...
map("n", "<leader>bb", "<Cmd>BufferOrderByBufferNumber<CR>", { desc = "Sort tabs by number" })
map("n", "<leader>bn", "<Cmd>BufferOrderByName<CR>", { desc = "Sort tabs by name" })
map("n", "<leader>bd", "<Cmd>BufferOrderByDirectory<CR>", { desc = "Sort tabs by directory" })
map("n", "<leader>bl", "<Cmd>BufferOrderByLanguage<CR>", { desc = "Sort tabs by language" })
map("n", "<leader>bw", "<Cmd>BufferOrderByWindowNumber<CR>", { desc = "Sort tabs by window" })

-- :q closes the tab (buffer) instead of just the window
vim.api.nvim_create_user_command("Q", function()
	vim.cmd("BufferClose")
end, {})
vim.cmd([[cabbrev q <c-r>=(getcmdtype()==':' && getcmdline()=='q') ? 'Q' : 'q'<CR>]])
