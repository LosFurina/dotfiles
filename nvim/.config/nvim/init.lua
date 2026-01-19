-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- 在 init.lua 中
-- 切换窗口
vim.keymap.set('n', '<A-h>', '<C-w>h')
vim.keymap.set('n', '<A-j>', '<C-w>j')
vim.keymap.set('n', '<A-k>', '<C-w>k')
vim.keymap.set('n', '<A-l>', '<C-w>l')

-- 快速调整大小
vim.keymap.set('n', '<A-Up>', ':resize +2<CR>')
vim.keymap.set('n', '<A-Down>', ':resize -2<CR>')

-- 让 Nvim 的剪贴板和系统剪贴板打通
vim.opt.clipboard = "unnamedplus"
