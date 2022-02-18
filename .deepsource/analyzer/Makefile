build:
	apt-get update
	cp -r ../../. /app
	apt-get install lua5.3	-y
	apt-get install luarocks
	cd /app
	luarocks install luafilesystem
	luarocks install luacheck
	luarocks install lua-path
	luarocks path --bin >> ~/.bash_profile
