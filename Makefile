all:
	node compiled/server.js

build:
	# TODO: add the copy/coffeescript step
	node ~/r.js -o client/buildconfig.js

dev:
	node_modules/coffee-script/bin/coffee --watch --compile -o compiled src
