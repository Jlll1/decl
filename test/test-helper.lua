local M = {}

local registered_tests = {}

function M.test(name, callback)
  registered_tests[#registered_tests + 1] = name
end

function M.execute()
  for i, v in ipairs(registered_tests) do
    print(i .. ' ' .. v)
  end
end

return M
