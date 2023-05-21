
Config = {}

-- if the script should be enabled for everyone on startup
Config.defaultEnabled = true

-- maximum speed of a transport with its ramp deployed (in meters per second)
Config.deployedRampSpeed = 3.0

-- maximum speed difference when trying to attach/detach a vehicle (in meters per second)
Config.maxAttachSpeedDiff = 3.0

-- controls (https://docs.fivem.net/docs/game-references/controls/)
Config.Controls = {
	attach		= 73,
	toggleRamp	= 51
}

-- translation
Config.Strings = {
	detachHelpText			= "Press ~INPUT_VEH_DUCK~ to detach this vehicle.",
	attachHelpText			= "Press ~INPUT_VEH_DUCK~ to attach this vehicle.",
	toggleRampHelpText		= "Press ~INPUT_CONTEXT~ to deploy/retract the ramp.",

	vehicleAttachedNotif	= "Vehicle successfully attached!",
	vehicleDetachedNotif	= "Vehicle detached!",
	vehicleTooFastNotif		= "Slow down before attaching!",
	vehicleLockedNotif		= "The vehicle is locked!"
}
