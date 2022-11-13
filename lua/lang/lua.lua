local M = {}
M.language = 'lua'

local utils = require('utils')

-- @TODO majority of this is common code and should be in decl.lua
-- The only real issue is the problem of handling modules
-- For example c# uses namespaces and lua uses filenames
function M.get_scopes_for_node(root, content, selected_node, filename)
  local result = {
    imported_modules = {},
    module = filename,
    ctype = nil,
    method = nil,
    block = nil,
  }

  local scopes_query = [[([
    ((function_declaration) @method)
    ((block) @block)
  ])]]

  local query = vim.treesitter.parse_query(M.language, scopes_query)
  local matches = query:iter_captures(root, content, 0, -1)
  for id, node, metadata in matches do
    local capture = query.captures[id]
    if capture == 'method' then
      if utils.does_node_contain(node, selected_node) then
        result.method = vim.treesitter.query.get_node_text(node:field('name')[1], content)
      end
    elseif capture == 'block' then
      local x = node:range()
      if utils.does_node_contain(node, selected_node) then
        local sr, sc, er, ec = node:range()
        if result.block ~= nil then
          local esr, esc, eer, eec = string.match(result.block, '(%d+),(%d+):(%d+),(%d+)')
          if utils.does_range_contain(
              { tonumber(esr), tonumber(esc), tonumber(eer), tonumber(eec) },
              { tonumber(sr), tonumber(sc), tonumber(er), tonumber(ec) }) then
            result.block = sr .. ',' .. sc .. ':' .. er .. ',' .. ec
          end
        else
          result.block = sr .. ',' .. sc .. ':' .. er .. ',' .. ec
        end
      end
    end
  end

  return result
end

function M.get_query(selected_node, selected_node_text)
  local query_string

  local node_type = selected_node:type()
  query_string = [[([
    (function_declaration (identifier) @target)
    (assignment_statement (variable_list (identifier) @target))
    (#eq? @target "]] .. selected_node_text .. [[")
  ])]]

  return query_string
end

return M
