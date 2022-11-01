-- Currently we take any node that could represent some node (e. g. identifiers) and search for any node that matches expected type and the identifier
-- Possibly could be expanded with scope awareness to a certain degree (especially useful in the case of variables)
-- The first degree of scope awareness would be file scope, differentiating between global nodes and nodes in the currently opened buffer

local M = {}

local utils = require('utils')

local filetype_to_languagehandler = { }
filetype_to_languagehandler['cs'] = require('lang/csharp')
filetype_to_languagehandler['lua'] = require('lang/lua')

-- @IMPROVEMENT consider renaming, it doesn't go anywhere - it finds. Maybe find_implementations?
-- @CLEANUP start separating this into blocks
function M.go_to()
  local results = {}

  lang_handler = filetype_to_languagehandler[vim.bo.filetype]
  -- @INCOMPLETE provide error message
  if not lang_handler then return end

  local language = lang_handler.language

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]
  local curr_parser = vim.treesitter.get_parser(bufnr, language)
  local selected_node = curr_parser:named_node_for_range({ row, col, row, col })
  local selected_node_text = vim.treesitter.query.get_node_text(selected_node, bufnr)

  local query_string = lang_handler.get_query(selected_node)
  if not query_string then return results end

  local curr_root = curr_parser:tree_for_range({ row, col, row, col }):root()
  providing_scopes = lang_handler.get_providing_scopes(curr_root, bufnr, selected_node)

  local rgcmd = "rg --vimgrep --no-heading " .. vim.fn.shellescape(selected_node_text)

  -- Since we iterate over all declarations in a file, we don't need to include any file more than once.
  local filenames = {}
  for line in io.popen(rgcmd):lines() do
    local filename = string.match(line, '(.-):.*')
    filenames[filename] = true
  end

  for filename, _ in pairs(filenames) do
    -- The declaration must be in a language that matches the current one.
    local file_extension = string.match(filename, '.*%.(.*)')
    if file_extension ~= vim.bo.filetype then goto continue end

    local file = io.open(filename, "r")
    local file_content = file:read("*all")
    file:close()

    local parser = vim.treesitter.get_string_parser(file_content, language)
    parser:parse()

    parser:for_each_tree(function (tstree, tree)
      local root = tstree:root()
      local covering_scopes = lang_handler.get_covering_scopes(root, file_content)
      if providing_scopes.namespace_scopes[covering_scopes.namespace_scope] then
        local query = vim.treesitter.parse_query(language, query_string)
        local matches = query:iter_captures(root, file_content, 0, -1)
        for id, node, metadata in matches do
          for _, scope in pairs(covering_scopes.class_scopes) do
            local node_start_row, node_start_col, node_end_row, node_end_col = node:range()
            if utils.does_range_contain(
              { scope.start[1], scope.start[2], scope.finish[1], scope.finish[2] },
              { node_start_row, node_start_col, node_end_row, node_end_col }) then
              if providing_scopes.class_scopes[scope.name] then
                local node_text = vim.treesitter.query.get_node_text(node, file_content)
                -- @IMPROVEMENT can matching be done with a query?
                if node_text == selected_node_text then
                  local row, col, _ = node:start()
                  results[#results + 1] = { filename = filename, row = row + 1, col = col }
                end
              end
            end
          end
        end
      end
    end)

    ::continue::
  end

  return results
end

return M
