-- Bascule entre le fichier source et son header correspondant (Person.cpp <-> Person.hpp)
-- 1) demande a clangd (precis, connait la vraie paire du projet)
-- 2) sinon, cherche sur le disque : meme dossier, puis src/ <-> include/

local M = {}

-- extension actuelle -> extensions candidates, dans l'ordre de preference
local pairs_map = {
  cpp = { "hpp", "h", "hh", "hxx" },
  cc  = { "hh", "hpp", "h", "hxx" },
  cxx = { "hxx", "hpp", "h", "hh" },
  c   = { "h", "hpp" },
  tpp = { "hpp", "h" },
  ipp = { "hpp", "h" },

  hpp = { "cpp", "cc", "cxx", "tpp", "ipp", "c" },
  h   = { "c", "cpp", "cc", "cxx" },
  hh  = { "cc", "cpp", "cxx" },
  hxx = { "cxx", "cpp", "cc" },
}

-- dossiers frere a essayer quand la paire n'est pas dans le meme repertoire
local dir_swaps = {
  { "src", "include" },
  { "src", "inc" },
  { "source", "include" },
  { "srcs", "includes" },
}

local function file_exists(path)
  return vim.uv.fs_stat(path) ~= nil
end

-- renvoie la liste des dossiers ou chercher le fichier oppose
local function candidate_dirs(dir)
  local dirs = { dir }
  for _, swap in ipairs(dir_swaps) do
    for i = 1, 2 do
      local from, to = swap[i], swap[3 - i]
      -- remplace le dernier segment /from/ du chemin par /to/
      local swapped = dir:gsub("([/\\])" .. from .. "$", "%1" .. to)
      if swapped ~= dir then
        table.insert(dirs, swapped)
      end
      -- ou un segment /from/ au milieu du chemin
      swapped = dir:gsub("([/\\])" .. from .. "([/\\])", "%1" .. to .. "%2")
      if swapped ~= dir then
        table.insert(dirs, swapped)
      end
    end
  end
  return dirs
end

-- cherche le fichier oppose sur le disque, renvoie son chemin ou nil
local function find_on_disk(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  local stem = vim.fn.fnamemodify(path, ":t:r")
  local ext = vim.fn.fnamemodify(path, ":e")

  local candidates = pairs_map[ext]
  if not candidates then
    return nil
  end

  for _, d in ipairs(candidate_dirs(dir)) do
    for _, e in ipairs(candidates) do
      local candidate = d .. "/" .. stem .. "." .. e
      if file_exists(candidate) then
        return candidate
      end
    end
  end
  return nil
end

-- demande la paire a clangd, renvoie son chemin ou nil
local function ask_clangd(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })
  local client = clients[1]
  if not client then
    return nil
  end

  local params = { uri = vim.uri_from_bufnr(bufnr) }
  local ok, res = pcall(function()
    return client:request_sync("textDocument/switchSourceHeader", params, 1000, bufnr)
  end)
  if not ok or not res or res.err or type(res.result) ~= "string" or res.result == "" then
    return nil
  end

  local target = vim.uri_to_fname(res.result)
  if file_exists(target) then
    return target
  end
  return nil
end

-- resout le fichier oppose du buffer courant, ou nil (+ notification)
local function resolve_target()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)

  if path == "" then
    vim.notify("cppswitch: buffer sans nom de fichier", vim.log.levels.WARN)
    return nil
  end

  local target = ask_clangd(bufnr) or find_on_disk(path)

  if not target then
    vim.notify(
      "cppswitch: aucun fichier correspondant pour " .. vim.fn.fnamemodify(path, ":t"),
      vim.log.levels.WARN
    )
    return nil
  end

  return target
end

--- Ouvre le fichier oppose (.cpp <-> .hpp) dans la fenetre courante.
function M.switch()
  local target = resolve_target()
  if not target then
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(target))
end

--- Ouvre le fichier oppose dans un split vertical.
--- Si le fichier est deja visible dans un split, on saute dedans
--- au lieu d'ouvrir un doublon.
function M.switch_vsplit()
  local target = resolve_target()
  if not target then
    return
  end

  local target_real = vim.fn.resolve(target)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.fn.resolve(vim.api.nvim_buf_get_name(buf)) == target_real then
      vim.api.nvim_set_current_win(win)
      return
    end
  end

  -- splitright = true dans options.lua -> le nouveau split part a droite
  vim.cmd.vsplit(vim.fn.fnameescape(target))
end

return M
