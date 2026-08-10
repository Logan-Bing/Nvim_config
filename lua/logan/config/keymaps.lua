local keymap = vim.keymap.set

keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
keymap("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
keymap("n", "<leader>a", "<cmd>wqa<cr>", { desc = "Quit session" })
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
keymap("n", "<leader>x", "<cmd>lua vim.diagnostic.open_float()<CR>")
keymap("n", "<leader>p", "<C-6>", { desc = "alterner entre deux files"})
keymap("n", "<leader>s", function()
  require("logan.util.cppswitch").switch()
end, { desc = "Basculer entre .cpp et .hpp" })
keymap("n", "<leader>ts", function()
  require("logan.util.cppswitch").switch_vsplit()
end, { desc = "Ouvrir le .cpp/.hpp oppose dans un split vertical" })
keymap("i", "kk", "<Esc><S-a>", {desc = "go to end of the line"})
keymap("i","jj", "<Esc>")
keymap("n", "<S-k>", ":move .-2<CR>==", { desc = "Deplacer la ligne vers le haut" })
keymap("n", "<S-j>", ":move .+1<CR>==", { desc = "Deplacer la ligne vers le bas" })
keymap("v", "<S-k>", ":move '<-2<CR>==", { desc = "Deplacer la selection vers le haut" })
keymap("v", "<S-j>", ":move '>+1<CR>==", { desc = "Deplacer la selection vers le bas" })
keymap("n", "<leader>H", ":vertical resize +10<CR>")
keymap("n", "<leader>L", ":vertical resize -10<CR>")
keymap("n", "<leader>K", ":horizontal resize +10<CR>")
keymap("n", "<leader>J", ":horizontal resize -10<CR>")

-- split
keymap("n", "<leader>|", ":vsplit<CR>")
keymap("n", "<leader>-", ":split<CR>")

-- navigation entre fenêtres
keymap("n", "<leader>l", "<C-w>l")
keymap("n", "<leader>j", "<C-w>j", { desc = "Fenetre du bas" })
keymap("n", "<leader>k", "<C-w>k", { desc = "Fenetre du haut" })
keymap("n", "<C-j>", "<C-w>j")
keymap("n", "<C-k>", "<C-w>k")
keymap("n", "<leader>h", "<C-w>h")

-- Tree
keymap("n", "<leader>e","<cmd>NvimTreeOpen<CR>")

-- Telescope
keymap('n', '<leader><leader>', function()
  require('telescope.builtin').find_files()
end, { desc = 'Telescope find files' })

keymap('n', '<leader>/', function()
  require('telescope.builtin').live_grep()
end, { desc = 'Telescope live grep' })

keymap('n', '<leader>fb', function()
  require('telescope.builtin').buffers()
end, { desc = 'Telescope buffers' })

keymap('n', '<leader>fh', function()
  require('telescope.builtin').help_tags()
end, { desc = 'Telescope help tags' })
