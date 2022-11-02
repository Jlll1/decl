local M = {}
M.language = 'c_sharp'

local utils = require('utils')

-- content can be either bufnr or text
function M.get_providing_scopes(root, content, selected_node)
  local namespace_scopes = {}
  do
    -- @INCOMPLETE handle nested qualified names - Foo.Bar etc.
    local namespace_scopes_query = [[([
      (using_directive (identifier) @target)
      (file_scoped_namespace_declaration (identifier) @target)
    ])]]
    local query = vim.treesitter.parse_query(M.language, namespace_scopes_query)
    local matches = query:iter_captures(root, content, 0, -1)
    for id, node, metadata in matches do
      namespace_scopes[vim.treesitter.query.get_node_text(node, content)] = true
    end
  end

  -- @INCOMPLETE structs, records etc
  local class_scopes = {}
  do
    local query = vim.treesitter.parse_query(M.language, '((class_declaration) @declaration)')
    local matches = query:iter_captures(root, content, 0, -1)
    for id, node, metadata in matches do
      -- Check if selected_node is in range of node - if it is, then add it to property scopes
      local node_start_row, node_start_col, node_end_row, node_end_col = node:range()
      local selected_start_row, selected_start_col, selected_end_row, selected_end_col = selected_node:range()
      if utils.does_range_contain(
        {node_start_row, node_start_col, node_end_row, node_end_col},
        {selected_start_row, selected_start_col, selected_end_row, selected_end_col}) then
        local name = vim.treesitter.query.get_node_text(node:field('name')[1], content)
        class_scopes[name] = true
      end
    end
  end

  return {
    namespace_scopes = namespace_scopes,
    class_scopes = class_scopes,
  }
end

-- @INCOMPLETE support other scopes
-- @INCOMPLETE handle classic namespaces with brackets
-- @INCOMPLETE this is terrible
function M.get_covering_scopes(root, content)
  local query_string = [[([
    (file_scoped_namespace_declaration (identifier) @namespace)
    ((class_declaration) @class)
  ])]]
  local query = vim.treesitter.parse_query(M.language, query_string)
  local matches = query:iter_captures(root, content, 0, -1)
  local result = { class_scopes = {} }
  for id, node, metadata in matches do
    if query.captures[id] == 'namespace' then
      local name = vim.treesitter.query.get_node_text(node, content)
      result.namespace_scope = name
    elseif query.captures[id] == 'class' then
      local name = vim.treesitter.query.get_node_text(node:field('name')[1], content)
      local node_start_row, node_start_col, node_end_row, node_end_col = node:range()
      result.class_scopes[#result.class_scopes + 1] = {
        name = name,
        start = { node_start_row, node_start_col },
        finish = { node_end_row, node_end_col },
      }
    end
  end

  return result
end

function M.get_query(selected_node)
  local query_string
  local parent_type = selected_node:parent():type()
  local type_node = selected_node:parent():field('type')[1]
  if type_node == selected_node or parent_type == 'base_list' or parent_type == 'generic_name' then
    query_string = [[([
      (class_declaration (identifier) @target)
      (interface_declaration (identifier) @target)
      (struct_declaration (identifier) @target)
      (enum_declaration (identifier) @target)
      (record_declaration (identifier) @target)
      (record_struct_declaration (identifier) @target)
      (class_declaration (base_list (identifier) @target))
      (interface_declaration (base_list (identifier) @target))
      (struct_declaration (base_list (identifier) @target))
    ])]]
  elseif parent_type == "member_access_expression" then
    local name_node = selected_node:parent():field('name')[1]
    if name_node == selected_node then
      query_string = [[([
        (property_declaration (identifier) @target)
        (field_declaration (variable_declaration (variable_declarator (identifier) @target)))
        (method_declaration (identifier) @target)
        (enum_member_declaration (identifier) @target)
        (record_declaration (parameter_list (parameter name: (identifier) @target)))
      ])]]
    else
      query_string = [[([
        (property_declaration (identifier) @target)
        (variable_declaration (variable_declarator (identifier) @target))
        (class_declaration (identifier) @target)
        (enum_declaration (identifier) @target)
      ])]]
    end
  elseif selected_node:type() == 'identifier' then
    query_string = [[([
      (property_declaration (identifier) @target)
      (variable_declaration (variable_declarator (identifier) @target))
      (method_declaration (identifier) @target)
      (parameter_list (parameter name: (identifier) @target))
      (local_function_statement name: (identifier) @target)
    ])]]
  end
  return query_string
end

return M
