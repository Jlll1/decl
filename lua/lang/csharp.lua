local M = {}
M.language = 'c_sharp'

local utils = require('utils')

function M.get_scopes_for_node(root, content, selected_node)
  local result = {
    imported_modules = {},
    module = nil,
    ctype = nil,
    method = nil,
    block = nil,
  }

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
      result.imported_modules[vim.treesitter.query.get_node_text(node, content)] = true
    elseif capture == 'module' then
      result.module = vim.treesitter.query.get_node_text(node, content)
    end

    local parent_node = selected_node:parent()
    local parent_type = parent_node:type()
    local type_node = parent_node:field('type')[1]
    if not (
        type_node == selected_node or
        parent_type == 'base_list' or
        parent_type == 'generic_name' or
        -- @INCOMPLETE remove this when scoping is implemented for member access (if ever :))
        (parent_type == 'member_access_expression' and parent_node:field('name')[1] == selected_node)
      ) then
      if capture == 'ctype' then
        if utils.does_node_contain(node, selected_node) then
         result.ctype = vim.treesitter.query.get_node_text(node:field('name')[1], content)
        end
      elseif capture == 'method' then
        if utils.does_node_contain(node, selected_node) then
          result.method = vim.treesitter.query.get_node_text(node:field('name')[1], content)
        end
      elseif capture == 'block' then
        if utils.does_node_contain(node, selected_node) then
          local sr, sc, er, ec = node:range()
          result.block = sr .. ', ' .. sc .. ' : ' .. er .. ', ' .. ec
        end
      end
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
