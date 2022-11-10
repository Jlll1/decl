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

  -- @TODO hardcoded filetype
  lang_handler = filetype_to_languagehandler['cs']
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
  local selected_node_scopes = lang_handler.get_scopes_for_node(curr_root, bufnr, selected_node)

  local rgcmd = "rg --vimgrep --no-heading " .. vim.fn.shellescape(selected_node_text)
  -- Since we iterate over all declarations in a file, we don't need to include any file more than once.
  local filenames = {}
  for line in io.popen(rgcmd):lines() do
    local filename = string.match(line, '(.-):.*')
    filenames[filename] = true
  end

  local level0_results = {} -- Same block as the node
  local level1_results = {} -- One level higher
  local level2_results = {} -- One level higher
  for filename, _ in pairs(filenames) do
    -- The declaration must be in a language that matches the current one.
    local file_extension = string.match(filename, '.*%.(.*)')
    -- @TODO hardcoded filetype
    if file_extension ~= 'cs' then goto continue end

    local file = io.open(filename, "r")
    local file_content = file:read("*all")
    file:close()

    local parser = vim.treesitter.get_string_parser(file_content, language)
    parser:parse()

    parser:for_each_tree(function (tstree, tree)
      local root = tstree:root()
      local query = vim.treesitter.parse_query(language, query_string)
      local matches = query:iter_captures(root, file_content, 0, -1)
      for id, node, metadata in matches do
        local node_scopes = lang_handler.get_scopes_for_node(root, file_content, node)
        local node_text = vim.treesitter.query.get_node_text(node, file_content)
        -- @IMPROVEMENT can matching be done with a query?
        if node_text == selected_node_text then
          -- @IMPROVEMENT This shouldn't be hardcoded like it is now
          -- Instead, it should dynamically adapt to different scope results,
          -- to be more flexible for differnet language implementations
          if (selected_node_scopes == nil) then
            local row, col, _ = node:start()
            local result = { filename = filename, row = row + 1, col = col }
            level0_results[#level0_results + 1] = result
          elseif (selected_node_scopes.module == node_scopes.module or
                selected_node_scopes.imported_modules[node_scopes.module]) and
              selected_node_scopes.ctype == node_scopes.ctype then
            local row, col, _ = node:start()
            local result = { filename = filename, row = row + 1, col = col }
            if selected_node_scopes.block == node_scopes.block then
              level0_results[#level0_results + 1] = result
            elseif selected_node_scopes.method == node_scopes.method then
              level1_results[#level1_results + 1] = result
            else
              level2_results[#level1_results + 1] = result
            end
          end
        end
      end
    end)

    ::continue::
  end

  -- If no results are found in the most local scope, go one scope higher
  -- This obviously has a limit, where you can't go over a certain scope (like class scope)
  if #level0_results > 0 then
    results = level0_results
  elseif #level1_results > 0 then
    results = level1_results
  else
    results = level2_results
  end

  return results
end

return M
