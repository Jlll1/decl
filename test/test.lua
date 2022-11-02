local function run()
  local test = require('test/test-helper')
  print('csharp tests')
  require('test/lang/csharp/test')
  test.execute()
end

return {
  run = run,
}
