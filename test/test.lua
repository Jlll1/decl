local function run()
  local csharp = require('test/lang/csharp/test')
  csharp.test()
end

return {
  run = run,
}
