local ctx = require('test/testctx')
local test = ctx.test
local assert = ctx.assert

-- Test finding single result in the same namespace
-- Test ignoring matching nodes from unprovided namespace (declarations_ns_*.cs mirrors declarations_*.cs but has different namespace)
do
  local inputs = {
    { 'struct declaration from property type',           { 5, 9 },  { 3, 14 } },
    { 'class declaration from property type',            { 7, 9 },  { 7, 13 } },
    { 'enum declaration from property type',             { 9, 9 },  { 11, 12 } },
    { 'record declaration from property type',           { 11, 9 }, { 15, 14 } },
    { 'record struct declaration from property type',    { 13, 9 }, { 17, 21 } },
    { 'generic class declaration from property type',    { 15, 9 }, { 19, 13 } },
    { 'struct declaration from variable type',           { 19, 5 }, { 3, 14 } },
    { 'class declaration from variable type',            { 20, 5 }, { 7, 13 } },
    { 'enum declaration from variable type',             { 21, 5 }, { 11, 12 } },
    { 'enum accessor',                                   { 21, 23 }, { 11, 12 } },
    { 'record declaration from variable type',           { 22, 5 }, { 15, 14 } },
    { 'record struct declaration from variable type',    { 23, 5 }, { 17, 21 } },
    { 'generic class declaration from variable type',    { 24, 5 }, { 19, 13 } },
    { 'struct declaration from initializer type',        { 19, 5 }, { 3, 14 } },
    { 'class declaration from initializer type',         { 20, 5 }, { 7, 13 } },
    { 'record declaration from initializer type',        { 22, 5 }, { 15, 14 } },
    { 'record struct declaration from initializer type', { 23, 5 }, { 17, 21 } },
    { 'generic class declaration from initializer type', { 24, 5 }, { 19, 13 } },
    { 'struct declaration from return type',             { 32, 10 },  { 3, 14 } },
    { 'class declaration from return type',              { 36, 10 },  { 7, 13 } },
    { 'enum declaration from return type',               { 40, 10 },  { 11, 12 } },
    { 'record declaration from return type',             { 44, 10 }, { 15, 14 } },
    { 'record struct declaration from return type',      { 48, 10 }, { 17, 21 } },
    { 'generic class declaration from return type',      { 52, 10 }, { 19, 13 } },
    { 'struct declaration from argument type',           { 57, 7 },  { 3, 14 } },
    { 'class declaration from argument type',            { 58, 7 },  { 7, 13 } },
    { 'enum declaration from argument type',             { 59, 7 },  { 11, 12 } },
    { 'record declaration from argument type',           { 60, 7 }, { 15, 14 } },
    { 'record struct declaration from argument type',    { 61, 7 }, { 17, 21 } },
    { 'generic class declaration from argument type',    { 62, 7 }, { 19, 13 } },
    { 'enum declaration from argument default type',     { 66, 52 },  { 11, 12 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to ' .. v[1] .. ' in the same namespace', function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/csharp/files/declarations_from.cs'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/csharp/files/declarations_to.cs')
        assert.equal(result.row, v[3][1])
        assert.equal(result.col, v[3][2])
      end
    end)
  end
end

-- Test finding single result in different namespaces
-- declarations_ns_from.cs is in namespace TestNS and has using TestNSTo
-- declarations_ns_to.cs is in namespace TestNSTo
-- Test ignoring matching nodes from unprovided namespace (declarations_*.cs mirrors declarations_ns_*.cs but has different namespace)
do
  local inputs = {
    { 'struct declaration from property type',           { 7, 9 },  { 3, 14 } },
    { 'class declaration from property type',            { 9, 9 },  { 7, 13 } },
    { 'enum declaration from property type',             { 11, 9 },  { 11, 12 } },
    { 'record declaration from property type',           { 13, 9 }, { 15, 14 } },
    { 'record struct declaration from property type',    { 15, 9 }, { 17, 21 } },
    { 'generic class declaration from property type',    { 17, 9 }, { 19, 13 } },
    { 'struct declaration from variable type',           { 21, 5 }, { 3, 14 } },
    { 'class declaration from variable type',            { 22, 5 }, { 7, 13 } },
    { 'enum declaration from variable type',             { 23, 5 }, { 11, 12 } },
    { 'enum accessor',                                   { 23, 23 }, { 11, 12 } },
    { 'record declaration from variable type',           { 24, 5 }, { 15, 14 } },
    { 'record struct declaration from variable type',    { 25, 5 }, { 17, 21 } },
    { 'generic class declaration from variable type',    { 26, 5 }, { 19, 13 } },
    { 'struct declaration from initializer type',        { 27, 5 }, { 3, 14 } },
    { 'class declaration from initializer type',         { 28, 5 }, { 7, 13 } },
    { 'record declaration from initializer type',        { 29, 5 }, { 15, 14 } },
    { 'record struct declaration from initializer type', { 30, 5 }, { 17, 21 } },
    { 'generic class declaration from initializer type', { 31, 5 }, { 19, 13 } },
    { 'struct declaration from return type',             { 34, 10 },  { 3, 14 } },
    { 'class declaration from return type',              { 38, 10 },  { 7, 13 } },
    { 'enum declaration from return type',               { 42, 10 },  { 11, 12 } },
    { 'record declaration from return type',             { 46, 10 }, { 15, 14 } },
    { 'record struct declaration from return type',      { 50, 10 }, { 17, 21 } },
    { 'generic class declaration from return type',      { 54, 10 }, { 19, 13 } },
    { 'struct declaration from argument type',           { 59, 7 },  { 3, 14 } },
    { 'class declaration from argument type',            { 60, 7 },  { 7, 13 } },
    { 'enum declaration from argument type',             { 61, 7 },  { 11, 12 } },
    { 'record declaration from argument type',           { 62, 7 }, { 15, 14 } },
    { 'record struct declaration from argument type',    { 63, 7 }, { 17, 21 } },
    { 'generic class declaration from argument type',    { 64, 7 }, { 19, 13 } },
    { 'enum declaration from argument default type',     { 68, 52 },  { 11, 12 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to ' .. v[1] .. ' inside imported namespace', function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/csharp/files/declarations_ns_from.cs'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/csharp/files/declarations_ns_to.cs')
        assert.equal(result.row, v[3][1])
        assert.equal(result.col, v[3][2])
      end
    end)
  end
end

-- Test finding properties and methods declared in the same class
-- Test prioritizing properties declared in narrower scope
--   (properties_other_class_to.cs contains the same properties and is in the same namespace)
do
  local inputs = {
    { 'property passed as parameter',         { 13, 15 }, { 5, 16 } },
    { 'property asigned to variable',         { 14, 13 }, { 5, 16 } },
    { 'method call asigned to variable',      { 15, 13 }, { 7, 13 } },
    { 'property acccessed in a statement',    { 16, 5 },  { 5, 16 } },
    { 'method call acccessed in a statement', { 17, 5 },  { 7, 13 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to ' .. v[1] .. ' declared inside accessing class', function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/csharp/files/properties_same_class.cs'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/csharp/files/properties_same_class.cs')
        assert.equal(result.row, v[3][1])
        assert.equal(result.col, v[3][2])
      end
    end)
  end
end


-- Test finding properties and methods declared in another class
-- Test ignoring properties declared in narrower scope
--   (properties_other_class_from.cs contains the same properties)
do
  local inputs = {
    { 'property passed as parameter',         { 14, 17 }, { 5, 16 } },
    { 'property asigned to variable',         { 15, 15 }, { 5, 16 } },
    { 'method call asigned to variable',      { 16, 15 }, { 7, 13 } },
    { 'property acccessed in a statement',    { 17, 7 },  { 5, 16 } },
    { 'method call acccessed in a statement', { 18, 7 },  { 7, 13 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to ' .. v[1] .. ' declared outside accessing class', function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/csharp/files/properties_other_class_from.cs'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/csharp/files/properties_other_class_to.cs')
        assert.equal(result.row, v[3][1])
        assert.equal(result.col, v[3][2])
      end
    end)
  end
end

-- Test finding properties and methods declared in another class in imported namespace
-- properties_ns_other_class_from.cs is in namespace PropertiesNS and has using PropertiesNSTo
-- properties_ns_other_class_to.cs is in namespace PropertiesNSTo
-- Test ignoring properties declared in outside imported namespace
--   (properties_same_class_*.cs and properties_other_class_*.cs contain the same properties but are in Properties namespace)
do
  local inputs = {
    { 'property passed as parameter',         { 14, 17 }, { 5, 16 } },
    { 'property asigned to variable',         { 15, 15 }, { 5, 16 } },
    { 'method call asigned to variable',      { 16, 15 }, { 7, 13 } },
    { 'property acccessed in a statement',    { 17, 7 },  { 5, 16 } },
    { 'method call acccessed in a statement', { 18, 7 },  { 7, 13 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to ' .. v[1] .. ' declared outside accessing class in imported namespace', function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/csharp/files/properties_ns_other_class_from.cs'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/csharp/files/properties_ns_other_class_to.cs')
        assert.equal(result.row, v[3][1])
        assert.equal(result.col, v[3][2])
      end
    end)
  end
end

-- Test finding local variable definitions
-- Test ignoring local variable definitions in other methods
-- Test ignoring local variable definitions in other blocks
do
  local inputs = {
    { 'in the same scope',             { 14, 15 }, { 13, 8 } },
    { 'in scope one level up',         { 18, 17 }, { 13, 8 } },
    { 'in the same scope, in a block', { 18, 23 }, { 17, 10 } },
    { 'in the same scope, with the same identifier as variable in another scope', { 22, 21 }, { 21, 8 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to variable declared ' .. v[1], function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/csharp/files/local_variables.cs'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/csharp/files/local_variables.cs')
        assert.equal(result.row, v[3][1])
        assert.equal(result.col, v[3][2])
      end
    end)
  end
end

-- Test finding local function declarations
-- Test ignoring local function declarations in other blocks
do
  local inputs = {
    { 'in the same scope',             { 32, 5 }, { 27, 9 } },
    { 'in scope one level up',         { 35, 7 }, { 27, 9 } },
    { 'in the same scope, in a block', { 41, 7 }, { 37, 11 } },
    { 'in the same scope, with the same identifier as variable in another scope', { 48, 5 }, { 44, 9 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to function declared ' .. v[1], function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/csharp/files/local_variables.cs'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') and assert.count(results, 1, 'results') then
        local result = results[1]
        assert.equal(result.filename, 'test/lang/csharp/files/local_variables.cs')
        assert.equal(result.row, v[3][1])
        assert.equal(result.col, v[3][2])
      end
    end)
  end
end

-- Test finding interface declarations and their implementations in the same namespace
-- Test ignoring matching nodes from unprovided namespace (interfaces_ns_*.cs mirrors interfaces_*.cs but has different namespace)
do
  local inputs = {
    { 'class implementing',   { 3, 31 } },
    { 'property type',        { 5, 10 } },
    { 'variable type',        { 9, 5 } },
    { 'method return type',   { 12, 10 } },
    { 'method argument type', { 12, 29 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to interface declaration and implementations in the same namespace from ' .. v[1], function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/csharp/files/interfaces_from.cs'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') then
        assert.contains(results, { filename = 'test/lang/csharp/files/interfaces_to_interface.cs', row = 3, col = 17 })
        assert.contains(results, { filename = 'test/lang/csharp/files/interfaces_to_implementation.cs', row = 3, col = 29 })
        assert.contains(results, { filename = 'test/lang/csharp/files/interfaces_to_implementation.cs', row = 7, col = 31 })
        assert.contains(results, { filename = 'test/lang/csharp/files/interfaces_to_implementation.cs', row = 11, col = 37 })
      end
    end)
  end
end

-- Test finding interface declarations and their implementations
-- interfaces_ns_from.cs is in namespace InterfacesNS and has using InterfacesNSTo
-- interfaces_ns_to_interface.cs is in namespace InterfacesNSTo
-- interfaces_ns_to_implementation.cs is in namespace InterfacesNSTo
-- Test ignoring matching nodes from unprovided namespace (interfaces_ns_*.cs mirrors interfaces_*.cs but has different namespace)
do
  local inputs = {
    { 'class implementing',   { 5, 31 } },
    { 'property type',        { 7, 10 } },
    { 'variable type',        { 11, 5 } },
    { 'method return type',   { 14, 10 } },
    { 'method argument type', { 14, 29 } },
  }
  for _, v in ipairs(inputs) do
    test('Go to interface declaration and implementations in imported namespace from ' .. v[1], function ()
      vim.cmd('e ' .. vim.fn.fnameescape('test/lang/csharp/files/interfaces_ns_from.cs'))
      vim.api.nvim_win_set_cursor(0, v[2])

      local results = require('decl').go_to()

      if assert.not_nil(results, 'results') then
        assert.contains(results, { filename = 'test/lang/csharp/files/interfaces_ns_to_interface.cs', row = 3, col = 17 })
        assert.contains(results, { filename = 'test/lang/csharp/files/interfaces_ns_to_implementation.cs', row = 3, col = 29 })
        assert.contains(results, { filename = 'test/lang/csharp/files/interfaces_ns_to_implementation.cs', row = 7, col = 31 })
        assert.contains(results, { filename = 'test/lang/csharp/files/interfaces_ns_to_implementation.cs', row = 11, col = 37 })
      end
    end)
  end
end
