build:
	apk update
	cp -r ../../. /app
	apk add lua luarocks
	luarocks install luacheck
	luarocks install luafilesystem
	luarocks install lua-path
