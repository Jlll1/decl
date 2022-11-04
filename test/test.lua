local function run(test_id)
  local test = require('test/testctx')
  print('csharp tests')
  require('test/lang/csharp/test')
  test.execute(test_id)
end

return {
  run = run,
}
