--
vim.keymap.set("n", "<C-j>", ":m +1<CR>==")
vim.keymap.set("n", "<C-k>", ":m -2<CR>==")
vim.keymap.set("i", "jj", "<ESC>")
vim.keymap.set("i", "kk", "<Esc>A")

-- Format the current file and reload it automatically
vim.keymap.set("n", "<leader>nf", function()
  vim.cmd("write")
  vim.cmd("silent !c_formatter_42 " .. vim.fn.expand("%"))
  vim.cmd("edit!") -- Force reload to show changes
end, { desc = "Format current file with c_formatter_42" })

-- Format all .c files in subdirectories
vim.keymap.set("n", "<leader>na", function()
  vim.cmd('silent !find . -name "*.c" -exec c_formatter_42 {} +')
  vim.cmd("checktime") -- Tells Neovim to check if files changed on disk
end, { desc = "Format all .c files in project" })
