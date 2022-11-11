local function run(test_id)
  local test = require('test/testctx')
  print('=================')
  print('csharp tests')
  print('=================')
  require('test/lang/csharp/test')
  test.execute(test_id)
  print('*****************************')
  print('=================')
  print('lua tests')
  print('=================')
  require('test/lang/lua/test')
  test.execute(test_id)
  print('*****************************')
end

return {
  run = run,
}
