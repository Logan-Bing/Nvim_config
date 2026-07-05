return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },

    keys = {
        {
            "<leader>c",
            function()
                require("harpoon"):list():add()
            end,
            desc = "Harpoon add file",
        },

		{
			"<leader>b",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			desc = "Harpoon menu",
		},

        {
            "<leader>1",
            function()
                require("harpoon"):list():select(1)
            end,
            desc = "Harpoon file 1",
        },
        {
            "<leader>2",
            function()
                require("harpoon"):list():select(2)
            end,
            desc = "Harpoon file 2",
        },
        {
            "<leader>3",
            function()
                require("harpoon"):list():select(3)
            end,
            desc = "Harpoon file 3",
        },
        {
            "<leader>4",
            function()
                require("harpoon"):list():select(4)
            end,
            desc = "Harpoon file 4",
        },
        {
            "<leader>5",
            function()
                require("harpoon"):list():select(5)
            end,
            desc = "Harpoon file 5",
        },
        {
            "<leader>n",
            function()
                require("harpoon"):list():next()
            end,
            desc = "Harpoon next",
        },
		{ "<leader>t1",
			function()
				require("harpoon"):list():select(1, { vsplit = true })
			end,
			desc = "Harpoon 1 vertical split"
		},
		{ "<leader>t2",
			function()
				require("harpoon"):list():select(2, { vsplit = true })
			end,
			desc = "Harpoon 2 vertical split"
		},
		{ "<leader>t3",
			function()
				require("harpoon"):list():select(3, { vsplit = true })
			end,
			desc = "Harpoon 3 vertical split"
		},
		{ "<leader>t4",
			function()
				require("harpoon"):list():select(4, { vsplit = true })
			end,
			desc = "Harpoon 4 vertical split"
		},
		{ "<leader>t5",
			function()
				require("harpoon"):list():select(5, { vsplit = true })
			end,
			desc = "Harpoon 5 vertical split"
		},
		{
		  "<leader>d1",
		  function()
			require("harpoon"):list():remove_at(1)
		  end,
		  desc = "Harpoon remove file 1",
		},
		{
		  "<leader>d2",
		  function()
			require("harpoon"):list():remove_at(2)
		  end,
		  desc = "Harpoon remove file 2",
		},
		{
		  "<leader>d3",
		  function()
			require("harpoon"):list():remove_at(3)
		  end,
		  desc = "Harpoon remove file 3",
		},
		{
		  "<leader>d4",
		  function()
			require("harpoon"):list():remove_at(4)
		  end,
		  desc = "Harpoon remove file 4",
		},
		{
		  "<leader>d5",
		  function()
			require("harpoon"):list():remove_at(5)
		  end,
		  desc = "Harpoon remove file 5",
		},
		{
		  "<leader>dd",
		  function()
			require("harpoon"):list():clear()
		  end,
		  desc = "Harpoon clear all",
		},
		{
		  "<leader>m",
		  function()
			require("harpoon"):list("makefile"):select(1)
		  end,
		  desc = "Harpoon open Makefile",
		},
	},
    config = function()
        local harpoon = require("harpoon")

        -- [Feature 2] Déduit le dossier d'exercice (cppN/exNN) depuis le buffer
        -- courant. Renvoie nil si le fichier n'appartient à aucun exercice.
        local function scope_dir()
            local name = vim.api.nvim_buf_get_name(0)
            local ex = name:match("(.-/cpp%d+/ex%d+)")
            if ex ~= nil and ex ~= "" then
                return ex
            end
            return nil
        end

        -- [Feature 1 + 3] Chaque exercice a sa propre liste harpoon (clé = son
        -- dossier), tout en gardant cwd à la racine cpp/ pour treesitter & co.
        -- Repli : les fichiers hors exercice partagent une liste globale (cwd).
        harpoon:setup({
            settings = {
                key = function()
                    return scope_dir() or vim.loop.cwd()
                end,
            },
        })

        -- Cherche un fichier par nom DANS l'exercice courant : enfant direct
        -- d'abord, sinon en descendant (match le plus proche retenu).
        local function find_file(name)
            local base = scope_dir() or vim.loop.cwd()
            local direct = base .. "/" .. name
            if vim.fn.filereadable(direct) == 1 then
                return vim.fn.fnamemodify(direct, ":.")
            end
            local down = vim.fn.globpath(base, "**/" .. name, false, true)
            if #down > 0 then
                table.sort(down, function(a, b)
                    return #a < #b
                end)
                return vim.fn.fnamemodify(down[1], ":.")
            end
            return ""
        end

        -- Épingle le Makefile de l'exercice dans sa liste dédiée "makefile",
        -- accessible via <leader>m (index réservé, jamais bousculé).
        local function pin_makefile()
            local rel = find_file("Makefile")
            if rel == "" then
                return
            end
            local list = harpoon:list("makefile")
            for _, item in ipairs(list.items) do
                if item and item.value == rel then
                    return -- déjà épinglé
                end
            end
            list:add({ value = rel, context = { row = 1, col = 0 } })
        end

        -- Place main.cpp en tête de la liste de l'exercice (index 1, <leader>1),
        -- sans doublon : on le retire d'abord s'il y figure déjà.
        local function pin_main()
            local rel = find_file("main.cpp")
            if rel == "" then
                return
            end
            local list = harpoon:list()
            for i = #list.items, 1, -1 do
                if list.items[i] and list.items[i].value == rel then
                    table.remove(list.items, i)
                end
            end
            table.insert(list.items, 1, { value = rel, context = { row = 1, col = 0 } })
        end

        -- Rejoue les épinglages à chaque changement d'exercice. cwd restant à la
        -- racine, DirChanged ne suffit pas : on écoute BufEnter et on ne fait le
        -- travail que si le scope a réellement changé.
        local last_scope
        local function refresh_pins()
            local dir = scope_dir()
            if not dir or dir == last_scope then
                return
            end
            last_scope = dir
            pin_makefile()
            pin_main()
        end

        refresh_pins()
        vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
            group = vim.api.nvim_create_augroup("HarpoonPins", { clear = true }),
            callback = refresh_pins,
        })
    end,
}
