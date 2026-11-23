vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.termguicolors = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.winborder = "rounded"
opt.confirm = true
opt.expandtab = true
opt.scrolloff = 8
opt.cursorline = true
opt.inccommand = "split"
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.updatetime = 250
opt.timeoutlen = 400
opt.splitright = true
opt.splitbelow = true
opt.swapfile = false
opt.backup = false
opt.smoothscroll = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		error("Failed to clone lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

require("plugins")
require("keymaps")
require("lsp")

-- Refresh git status when nvim regain focus when leave a terminal
vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave" }, {
	group = vim.api.nvim_create_augroup("UserNeotreeRefresh", { clear = true }),
	callback = function()
		local ok_ev, events = pcall(require, "neo-tree.events")
		if ok_ev then
			events.fire_event(events.GIT_EVENT)
		end
	end,
})
