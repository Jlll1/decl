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
    ((function_call (identifier) @import_opt (#eq? @import_opt "require")) @import)
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
    elseif capture == 'import' then
      local import_arg = vim.treesitter.query.get_node_text(node:field('arguments')[1], content)
      local import = string.match(import_arg, [[%(*'*"*(.+[^'*"*%)*])]])
      -- @NEXT concat import with correct path to match how lua modules work
      local path = string.match(filename, '(.*)%/')
      result.imported_modules[path .. '/' .. import] = true
      result.imported_modules[path .. '/' .. import .. '.lua'] = true
      result.imported_modules['/usr/local/lua/' .. import .. '/' .. import .. '.lua'] = true
    end
  end

  return result
end

function M.get_query(selected_node, selected_node_text)
  local query_string

  local node_type = selected_node:type()
  query_string = [[([
    (function_declaration (identifier) @target)
    (function_declaration (dot_index_expression (identifier) @target))
    (parameters (identifier) @target)
    (assignment_statement (variable_list (identifier) @target))
    (assignment_statement (variable_list (dot_index_expression (identifier) @target)))
    (#eq? @target "]] .. selected_node_text .. [[")
  ])]]

  return query_string
end

return M
