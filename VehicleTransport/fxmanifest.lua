
fx_version "cerulean"
games { "gta5" }

author "Philipp Decker"
description "Attach vehicles to other vehicles!"
version "2.1.0"

lua54 "yes"

escrow_ignore {
	"Log.lua",
	"config.lua",
	"server/server.lua",
	"client/TransportCreator.lua",
	"client/client.lua"
}

dependencies {
	"/onesync"
}

files {
	"transportData.json"
}

server_scripts {
	"versionChecker.lua",
	"Log.lua",

	"server/server_encrypted.lua",
	"server/server.lua"
}

client_scripts {
	"Log.lua",

	"config.lua",

	"client/TransportCreator.lua",
	"client/client_encrypted.lua",
	"client/client.lua"
}

dependency '/assetpacks'