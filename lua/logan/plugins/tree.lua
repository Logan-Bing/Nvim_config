return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  init = function()
    -- désactiver netrw
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- couleurs
    vim.opt.termguicolors = true
  end,

  config = function()
    -- devicons ne connait pas l'extension .tpp -> on reprend l'icone des .hpp
    local devicons = require("nvim-web-devicons")
    local hpp_icon, hpp_color = devicons.get_icon_color("x.hpp", "hpp")
    devicons.set_icon({
      tpp = { icon = hpp_icon, color = hpp_color, name = "Tpp" },
    })

    require("nvim-tree").setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    })
  end,
}
