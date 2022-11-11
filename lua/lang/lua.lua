local M = {}
M.language = 'lua'

function M.get_query (selected_node)
  local query_string
  local parent_type = selected_node:parent():type()
  local parent_parent_type = selected_node:parent():parent():type()
  if parent_type == 'dot_index_expression' and parent_parent_type == 'function_call' then
    query_string = '(function_declaration (identifier) @target)'
  elseif parent_type == 'function_call' then
    query_string = '(function_declaration (identifier) @target)'
  end

  return query_string
end

return M
