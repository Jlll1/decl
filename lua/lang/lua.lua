local M = {}
M.language = 'lua'

function M.get_scopes_for_node(root, content, selected_node)
  local result = {
    imported_modules = {},
    module = nil,
    ctype = nil,
    method = nil,
    block = nil,
  }

  return result
end

function M.get_query(selected_node)
  local query_string

  local node_type = selected_node:type()
  query_string = [[([
    (function_declaration (identifier) @target)
    (assignment_statement (variable_list (identifier) @target))
  ])]]

  return query_string
end

return M
