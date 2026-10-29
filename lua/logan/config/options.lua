vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.list = true
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
}

-- Repli de code. En "manual" (le defaut) aucun pli n'existe tant qu'on n'en
-- fabrique pas a la main avec zf : c'est pour ca que za/zc/zo semblaient morts.
-- "indent" deduit les plis de l'indentation. Il ignore la syntaxe, donc il
-- replie aussi bien un if ou une boucle qu'un corps de fonction.
vim.opt.foldmethod = "indent"
-- Sans ca, chaque fichier s'ouvre integralement replie.
vim.opt.foldlevelstart = 99


-- nvim ne detecte pas les fichiers compose comme "yaml.docker-compose" (il les
-- voit en simple "yaml"), or docker_compose_language_service ne s'attache qu'a
-- ce filetype la -> sans ca le serveur ne demarre jamais.
vim.filetype.add({
  -- nvim voit les .tpp (implementation de templates C++) comme filetype "tpp",
  -- or clangd ne s'attache qu'a c/cpp/... -> pas d'autocompletion sans ca.
  extension = {
    tpp = "cpp",
  },
  filename = {
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
  },
})
