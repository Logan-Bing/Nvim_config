-- Affichage des images (png, jpg, gif, webp…) et PDF dans le buffer
-- via le protocole graphique Kitty (Ghostty). PDF : nécessite magick + gs.
-- PDF : ]p / [p page suivante / precedente, [count]gp aller a une page, gg / G.

local function human_size(bytes)
  if bytes < 1024 then
    return bytes .. " o"
  elseif bytes < 1024 * 1024 then
    return ("%.1f Ko"):format(bytes / 1024)
  end
  return ("%.1f Mo"):format(bytes / 1024 / 1024)
end

-- Remplit b:image_info (dimensions, poids, nb de pages) affiché dans la winbar
local function set_image_info(buf)
  local file = vim.api.nvim_buf_get_name(buf)
  vim.system({ "magick", "identify", "-format", "%w %h\n", file }, { text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 or not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      local frames = vim.split(vim.trim(res.stdout), "\n")
      local w, h = frames[1]:match("(%d+) (%d+)")
      vim.b[buf].image_info = (" %s × %s px  ·  %s"):format(w, h, human_size(vim.fn.getfsize(file)))
      if #frames > 1 then
        vim.b[buf].pdf_pages = #frames
        vim.b[buf].page_info = ("  ·  page %d / %d"):format(vim.b[buf].pdf_page or 1, #frames)
      end
      vim.cmd.redrawstatus({ bang = true })
    end)
  end)
end

-- Affiche la page `page` du PDF. snacks ne rend que la page 1 a l'ouverture,
-- mais comprend la syntaxe "fichier.pdf#page=N" : on remplace donc l'image
-- placee dans le buffer par celle de la page voulue.
local function show_pdf_page(buf, page)
  local pages = vim.b[buf].pdf_pages
  if not pages then
    return -- nb de pages pas encore connu (magick identify en cours)
  end
  page = math.max(1, math.min(page, pages))
  vim.b[buf].pdf_page = page
  vim.b[buf].page_info = ("  ·  page %d / %d"):format(page, pages)

  local file = vim.api.nvim_buf_get_name(buf)
  Snacks.image.placement.clean(buf)
  Snacks.image.placement.new(buf, file .. "#page=" .. page, { conceal = true, auto_resize = true })
  vim.cmd.redrawstatus({ bang = true })
end

-- Touches de navigation, locales au buffer PDF (le count marche : 3]p, 12gp)
local function set_pdf_keymaps(buf)
  local function map(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { buffer = buf, desc = desc })
  end
  local function current()
    return vim.b[buf].pdf_page or 1
  end
  map("]p", function() show_pdf_page(buf, current() + vim.v.count1) end, "PDF : page suivante")
  map("[p", function() show_pdf_page(buf, current() - vim.v.count1) end, "PDF : page precedente")
  map("gp", function() show_pdf_page(buf, vim.v.count1) end, "PDF : aller a la page [count]")
  map("G", function() show_pdf_page(buf, vim.b[buf].pdf_pages or 1) end, "PDF : derniere page")
  map("gg", function() show_pdf_page(buf, 1) end, "PDF : premiere page")
end

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    image = {
      enabled = true,
      wo = { winbar = "%{get(b:, 'image_info', '')}%{get(b:, 'page_info', '')}" },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "image",
      callback = function(ev)
        set_image_info(ev.buf)
        if vim.api.nvim_buf_get_name(ev.buf):lower():match("%.pdf$") then
          set_pdf_keymaps(ev.buf)
        end
      end,
    })
  end,
}
