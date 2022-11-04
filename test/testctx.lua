local M = {}

local function is_equivalent(v1, v2)
  local t = type(v1)
  if t ~= type(v2) then return false end
  if t ~= 'table' then return v1 == v2 end
  for k, v in pairs(v1) do
    if not is_equivalent(v, v2[k]) then return false end
  end
  return true
end

M.assert = {
  contains = function (collection, expected, target)
    if not target then target = 'target' end
    local found = false
    for _, v in ipairs(collection) do
      if is_equivalent(v, expected) then
        found = true
        break
      end
    end
    if not found then
      print('    Test failed')
      print('    Expected ' .. target .. ' to contain: ' .. vim.inspect(expected))
      print('    But got: ' .. vim.inspect(collection))
      return false
    end
    return true
  end,
  count = function (collection, expected, target)
    if not target then target = 'target' end
    if #collection ~= expected then
      print('    Test failed')
      print('    Expected ' .. target .. ' to have count: ' .. expected)
      print('    But got: ' .. #collection)
      return false
    end
    return true
  end,
  equal = function (actual, expected, target)
    if not target then target = 'target' end
    if actual ~= expected then
      print('    Test failed')
      print('    Expected ' .. target .. ' to be: ' .. expected)
      print('    But got: ' .. actual)
      return false
    end
    return true
  end,
  equivalent = function (actual, expected, target)
    if not target then target = 'target' end
    if not is_equivalent(actual, expected) then
      print('    Test failed')
      print('    Expected ' .. target .. ' to be equivalent to: ' .. expected)
      print('    But got: ' .. actual)
      return false
    end
    return true
  end,
  not_nil = function (actual, target)
    if actual == nil then
      print('    Test failed')
      print('    Expected ' .. target .. ' to not be nil')
      print('    But got: nil')
      return false
    end
    return true
  end
}

local registered_tests = {}

function M.test(name, callback)
  registered_tests[#registered_tests + 1] = { name = name, callback = callback }
end

function M.execute(test_id)
  if test_id then
    local test = registered_tests[test_id]
    print(test_id .. '  ' .. test.name)
    test.callback()
  else
    for i, v in ipairs(registered_tests) do
      print(i .. ' ' .. v.name)
      v.callback()
    end
  end
end

return M
