local test = require('test/test-helper').test

test("Test number one", function ()
  vim.cmd('e ' .. vim.fn.fnameescape('test/lang/csharp/files/second.cs'))
  vim.api.nvim_win_set_cursor(0, { 5, 9 })
  local results = require('decl').go_to()
  for _, v in ipairs(results) do
    print(v)
  end
end)
