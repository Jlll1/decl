local function run(test_id)
  local test = require('test/testctx')

  -- @TODO since filetype is hardcoded for now, disabling csharp tests
  -- print('=================')
  -- print('csharp tests')
  -- print('=================')
  -- require('test/lang/csharp/test')
  -- test.execute(test_id)
  print('=================')
  print('lua tests')
  print('=================')
  require('test/lang/lua/test')
  test.execute(test_id)
end

return {
  run = run,
}
