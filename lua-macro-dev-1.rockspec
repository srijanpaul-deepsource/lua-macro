package = "lua-macro"
version = "dev-1"
source = {
   url = "https://deepsource.io"
}
description = {
   homepage = "https://deepsource.io",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, <= 5.4",
   "luacheck",
   "luafilesystem",
   "lua-path"
}
build = {
   type = "builtin",
   modules = {
      main = "src/main.lua"
   }
}
