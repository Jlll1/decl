local M = {}
M.language = 'c_sharp'

local utils = require('utils')

function M.get_scopes_for_node(root, content, selected_node)
  local function does_node_contain(containing_node, contained_node)
    local containing_start_row, containing_start_col, containing_end_row, containing_end_col = containing_node:range()
    local contained_start_row, contained_start_col, contained_end_row, contained_end_col = contained_node:range()
    return utils.does_range_contain(
      {containing_start_row, containing_start_col, containing_end_row, containing_end_col},
      {contained_start_row, contained_start_col, contained_end_row, contained_end_col})
  end

  local imported_modules = {}
  local module = nil
  local ctype = nil
  local method = nil
  local scopes_query = [[([
    (using_directive (identifier) @import)
    (file_scoped_namespace_declaration (identifier) @module)
    ((class_declaration) @ctype)
    ((struct_declaration) @ctype)
    ((method_declaration) @method)
    ((block) @block)
  ])]]

  local query = vim.treesitter.parse_query(M.language, scopes_query)
  local matches = query:iter_captures(root, content, 0, -1)
  for id, node, metadata in matches do
    local capture = query.captures[id]
    if capture == 'import' then
      imported_modules[vim.treesitter.query.get_node_text(node, content)] = true
    elseif capture == 'module' then
      module = vim.treesitter.query.get_node_text(node, content)
    end
    local parent_type = selected_node:parent():type()
    local type_node = selected_node:parent():field('type')[1]
    if not (type_node == selected_node or parent_type == 'base_list' or parent_type == 'generic_name') then
      if capture == 'ctype' then
        if does_node_contain(node, selected_node) then
         ctype = vim.treesitter.query.get_node_text(node:field('name')[1], content)
        end
      elseif capture == 'method' then
        if does_node_contain(node, selected_node) then
          method = vim.treesitter.query.get_node_text(node:field('name')[1], content)
        end
      elseif capture == 'block' then
        if does_node_contain(node, selected_node) then
          local sr, sc, er, ec = node:range()
          block = sr .. ', ' .. sc .. ' : ' .. er .. ', ' .. ec
        end
      end
    end
  end

  return {
    imported_modules = imported_modules,
    module = module,
    ctype = ctype,
    method = method,
    block = block,
  }
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
