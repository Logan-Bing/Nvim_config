return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    {
      "saghen/blink.cmp",
      version = "*",
      opts = {
		keymap = {
		  preset = "none", -- on part de zéro
		  ["<C-space>"] = { "show", "fallback" },           -- ouvrir manuellement
		  ["<C-e>"]     = { "cancel", "fallback" },          -- fermer
		  ["<Tab>"]     = { "select_next", "fallback" },     -- suivant
		  ["<S-Tab>"]   = { "select_prev", "fallback" },     -- précédent
		  ["<CR>"]      = { "accept", "fallback" },          -- confirmer
		  ["<C-k>"]     = { "show_documentation", "fallback" }, -- doc à la demande
		  ["<C-b>"]     = { "scroll_documentation_up", "fallback" },
		  ["<C-f>"]     = { "scroll_documentation_down", "fallback" },
		},
        appearance = { nerd_font_variant = "mono" },
        completion = { documentation = { auto_show = false} },
		menu = { auto_show = true },
		signature = { enabled = true }, -- affiche les paramètres attendus (ex: Zombie(const std::string&))
      },
    },
    {
      "mason-org/mason.nvim",
      opts = {
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      },
    },
    "mason-org/mason-lspconfig.nvim",
  },
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = { "clangd", "lua_ls", "html", "cssls", "pyright", "neocmake", "dockerls", "docker_compose_language_service" },
    })

    local servers = { "clangd", "lua_ls", "html", "cssls", "pyright", "neocmake", "dockerls", "docker_compose_language_service" }
    for _, server in ipairs(servers) do
      vim.lsp.config(server, {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })
    end

    -- clangd ecrit tout son bavardage sur stderr, et nvim log stderr en ERROR
    -- quel que soit le log level -> lsp.log grossissait sans fin (1.1 Go).
    vim.lsp.config("clangd", {
      cmd = { "clangd", "--log=error" },
    })

    -- neocmakelsp : autocompletion des commandes CMake (add_executable, target_link_libraries, ...)
    -- Les root_markers par defaut ({ ".neocmake.toml", ".git", "build", "cmake" }) ne matchent
    -- pas un dossier CMake sans depot git ni build/ -> on ajoute CMakeLists.txt pour que
    -- le serveur s'attache quand meme.
    vim.lsp.config("neocmake", {
      root_markers = { ".neocmake.toml", "CMakePresets.json", "CMakeLists.txt", ".git", "build", "cmake" },
    })

    -- dockerls / docker_compose_language_service : meme souci que neocmake, les
    -- root_markers par defaut ("Dockerfile", "docker-compose.yml", ...) resolvent
    -- vers le sous-dossier du service (srcs/requirements/nginx/) au lieu de la
    -- racine du projet -> on ajoute .git.
    vim.lsp.config("dockerls", {
      root_markers = { ".git", "Dockerfile", "Containerfile" },
    })

    vim.lsp.config("docker_compose_language_service", {
      root_markers = { ".git", "docker-compose.yaml", "docker-compose.yml", "compose.yaml", "compose.yml" },
    })

    vim.lsp.enable(servers)
  end,
}
