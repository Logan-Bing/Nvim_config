-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.keymaps")
require("config.lsp")

vim.opt.expandtab = false -- désactive les espaces
vim.opt.tabstop = 4 -- taille visuelle d’un tab
vim.opt.shiftwidth = 4 -- indentation
vim.opt.softtabstop = 4 -- comportement du Tab
