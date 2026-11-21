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
 
local term_group = vim.api.nvim_create_augroup("UserTerminal", { clear = true })
 
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
 
-- Clean look inside terminals: no line numbers, no sign column
vim.api.nvim_create_autocmd("TermOpen", {
  group = term_group,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.scrolloff = 0
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
 
local ok, neotree = pcall(require, "neo-tree")
if ok then
  neotree.setup({
    window = {
      position = "left",
      width = 40,
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false, -- show .gitignore, .envrc, ... (press H in the tree to toggle)
      },
      follow_current_file = { enabled = false },
    },
    buffers = {
      follow_current_file = { enabled = true },
      group_empty_dirs = true,
    },
    git_status = {
      window = { position = "float" },
    },
  })
end
