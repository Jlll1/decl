local ctx = require('test/testctx')
local test = ctx.test
local assert = ctx.assert

-- Test finding local variables declared in the same file
do
  local inputs = {
    { 'declared in the same scope',            { 9, 15 }, { 8, 8 } },
    { 'declared one scope higher',             { 13, 17 }, { 8, 8 } },
    { 'declared in the same scope in a block', { 13, 23 }, { 12, 10 } },
    { 'declared in the same scope with the same name as variable in another block',
                                               { 17, 21 }, { 16, 8 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to variable ' .. v[1], function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/lua/files/local_variables.lua'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/lua/files/local_variables.lua', 'filename')
        assert.equal(result.row, v[3][1], 'row')
        assert.equal(result.col, v[3][2], 'col')
      end
    end)
  end
end

-- Test finding local functions declared in the same file
do
  local inputs = {
    { 'declared in the same scope',            { 25, 3 }, { 21, 17 } },
    { 'declared one scope higher',             { 28, 5 }, { 21, 17 } },
    { 'declared in the same scope in a block', { 32, 5 }, { 29, 20 } },
    { 'declared in the same scope with the same name as variable in another block',
                                               { 38, 3 }, { 35, 17 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to function ' .. v[1], function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/lua/files/local_variables.lua'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/lua/files/local_variables.lua', 'filename')
        assert.equal(result.row, v[3][1], 'row')
        assert.equal(result.col, v[3][2], 'col')
      end
    end)
  end
end

-- Test finding local variables declared in the same file in tuples
do
  local inputs = {
    { 'from an expression #1',            { 3, 11 }, { 1, 6 } },
    { 'from an expression #2',            { 4, 11 }, { 1, 11 } },
    { 'from another tuple expression #1', { 6, 16 }, { 1, 11 } },
    { 'from another tuple expression #2', { 6, 21 }, { 1, 6 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to variable declared in a tuple ' .. v[1], function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/lua/files/tuples.lua'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/lua/files/tuples.lua', 'filename')
        assert.equal(result.row, v[3][1], 'row')
        assert.equal(result.col, v[3][2], 'col')
      end
    end)
  end
end

-- Test finding function parameters when they redeclare variables
do
  local inputs = {
    { '', { 10, 13 }, { 9, 23 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to function parameter that redeclares other variable ' .. v[1], function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/lua/files/function_params.lua'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/lua/files/function_params.lua', 'filename')
        assert.equal(result.row, v[3][1], 'row')
        assert.equal(result.col, v[3][2], 'col')
      end
    end)
  end
end


-- Test finding global variables declared in the same file
do
  local inputs = {
    { 'local variable definition in file scope',                          { 1, 13 } },
    { 'local variable definition in a function #1',                       { 9, 9 } },
    { 'local variable definition in a function #2',                       { 16, 13 } },
    { 'local variable definition in a function in a block',               { 13, 17 } },
    { 'local variable definition in a function in a function',            { 22, 17 } },
    { 'local variable definition in a function in a block in a function', { 31, 13 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to global variable definition from ' .. v[1], function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/lua/files/global_variables.lua'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') then
        assert.count(results, 6, 'results')
        assert.contains(results, { filename = 'test/lang/lua/files/global_variables.lua',
          row = 4, col = 2 })
        assert.contains(results, { filename = 'test/lang/lua/files/global_variables.lua',
          row = 8, col = 2 })
        assert.contains(results, { filename = 'test/lang/lua/files/global_variables.lua',
          row = 12, col = 4 })
        assert.contains(results, { filename = 'test/lang/lua/files/global_variables.lua',
          row = 21, col = 4 })
        assert.contains(results, { filename = 'test/lang/lua/files/global_variables.lua',
          row = 30, col = 7 })
        assert.contains(results, { filename = 'test/lang/lua/files/global_variables.lua',
          row = 37, col = 5 })
      end
    end)
  end
end

-- Test finding global functions declared in the same file
do
  local inputs = {
    { 'local variable definition in file scope (function call)',       { 42, 14 } },
    { 'local variable definition in file scope (function assignment)', { 42, 14 } },
    { 'local variable definition in a function',                       { 25, 18 } },
    { 'function call in a block',                                      { 28, 5 } },
    { 'function call in a function',                                   { 39, 3 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to global function definition from ' .. v[1], function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/lua/files/global_variables.lua'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') then
        assert.count(results, 4, 'results')
        assert.contains(results, { filename = 'test/lang/lua/files/global_variables.lua',
          row = 20, col = 11 })
        assert.contains(results, { filename = 'test/lang/lua/files/global_variables.lua',
          row = 29, col = 14 })
        assert.contains(results, { filename = 'test/lang/lua/files/global_variables.lua',
          row = 36, col = 12 })
        assert.contains(results, { filename = 'test/lang/lua/files/global_variables.lua',
          row = 45, col = 10 })
      end
    end)
  end
end

-- Test finding global definitions in another file
-- Test ignoring local definitions with the same name (global_declarations_ignore)
-- Test ignoring object members with the same name (modules_declarations_to)
do
  local inputs = {
    { 'variable', { 1, 11 }, { 1, 0 } },
    { 'function', { 2, 11 }, { 3, 9 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to global ' .. v[1] .. ' definition across multiple files', function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/lua/files/global_declarations_from.lua'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/lua/files/global_declarations_to.lua', 'filename')
        assert.equal(result.row, v[3][1], 'row')
        assert.equal(result.col, v[3][2], 'col')
      end
    end)
  end
end

-- Test finding module members defined in another file
-- Test ignoring local definitions with the same name (global_declarations_ignore)
-- Test ignoring global definitions with the same name (global_declarations_to)
do
  local inputs = {
    { 'variable', { 3, 16 }, { 3, 3 } },
    { 'function', { 4, 11 }, { 5, 12 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to ' .. v[1] .. ' definited in module in another file', function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/lua/files/modules_declarations_from.lua'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/lua/files/modules_declarations_to.lua', 'filename')
        assert.equal(result.row, v[3][1], 'row')
        assert.equal(result.col, v[3][2], 'col')
      end
    end)
  end
end
