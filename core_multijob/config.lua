Config = {

MaxJobs = 7, -- Maximum amount of jobs avalable for every player (Only applies to jobs that are auto savable)
AllowAutoJobSavining = true, -- When the script detects a new job it will add it to your jobs Ex. You get police job and it saves that job (if maximum not reached) to your job list

OpenJobUIKey = '', -- The key used to open the UI (Leave blank if you do not want to use key)
OpenJobUICommand = '', -- Command used to open the UI (MUST NOT BE BLANK!!)

--Set up blip info (https://docs.fivem.net/docs/game-references/blips/)
--BLIPS FOR MANAGEMENT LOCATIONS
BlipSprite = 457,
BlipColor = 3,
BlipText = 'Job Managment',

--BLIPS FOR JOB CENTERS
BlipCenterSprite = 498,
BlipCenterColor = 3,
BlipCenterText = 'Job Center',

MarkerSprite = 27,
MarkerColor = {66, 135, 245},
MarkerSize = 1.5,

LocationsJobCenters = { -- If you want you can setup locations to change jobs (Leave without entiries if you dont want locations) (ADDS 0.02 MS)
	{coords = vector3(-261.82537841797,-965.21392822266,31.22407531738), blip = true}
},


LocationsToChangeJobs = { -- If you want you can setup locations to change jobs (Leave without entiries if you dont want locations) (ADDS 0.02 MS)
	{coords = vector3(-267.58975219727,-958.55718994141,31.22312927246), blip = false},
	{coords = vector3(466.12969970703,-1021.2487792969,28.086708068848), blip = false},
	{coords = vector3(-353.1587,-131.1687,39.0172), blip = false},
	{coords = vector3(542.2349,-184.0834,54.4932), blip = false},
	{coords = vector3(-39.1130,-1041.3005,28.5954), blip = false},
	{coords = vector3(150.4154,-3011.6531,7.0409), blip = false},
	{coords = vector3(-205.0793,-1333.2238,30.9068), blip = false},
	{coords = vector3(873.5978, -2096.0078, 29.4595), blip = false},
	{coords = vector3(-1558.6140, -570.8824, 107.5229), blip = false},
	{coords = vector3(541.9181, -198.4678, 53.4932), blip = false},
	{coords = vector3(1160.8701, -785.5889, 57.6052), blip = false},
	{coords = vector3(815.7338, -749.2269, 26.7272), blip = false},
	{coords = vector3(287.1350, -1165.2566, 29.0867), blip = false},
	{coords = vector3(-677.3662, -798.6058, 25.1230), blip = false},
	{coords = vector3(131.5524, -1089.2571, 29.1950), blip = false},
	{coords = vector3(-874.2633, -202.9258, 36.8372), blip = false},
	{coords = vector3(268.9960, -1824.6627, 26.9142), blip = false},
	{coords = vector3(1769.6025, 3323.7043, 41.4385), blip = false},
	{coords = vector3(-1352.5366, -1068.4056, 6.9857), blip = false},
	{coords = vector3(-1429.2235, -455.0284, 35.9097), blip = false},
	{coords = vector3(-1382.9124, -464.6880, 72.0421), blip = false},
	{coords = vector3(310.8529, -596.9124, 43.2841), blip = false},
},

OffdutyForEveryone = false, -- Everyone can go into offduty job
JobsThatCanUseOffduty = { -- Jobs that can use offduty if option above is false
	'police',
	'exotic',
	'benny',
	'ambulance',
	'mechanic',
	'cardealer',
	'antonio',
	'sjlaw',
	'lsc',
	'realestateagent',
	'revisor',
	'g4s',
	'autorepair',
	'mcdealer',
	'hauto',
	'aj',
	'mr',
	'casino',
	'lux'
},

DefaultJobsInJobCenter = { -- Jobs that can be added by going to the job center. For icons use https://fontawesome.com/
	
	{job = 'garbage', label = "Skraldemand", icon = "fas fa-trash", description = "Du samler skrald ind, måske er du heldig og finde noget?"},
	{job = 'tailor', label = "Designer", icon = "fa fa-user", description = "Er du bedre til designe tøj end de andre?"},
	{job = 'lumberjack', label = "Træhugger", icon = "fa fa-user", description = "Er du bedre til at hugge træ end de andre?"},
	{job = 'butcher', label = "Slagter", icon = "fa fa-user", description = "Har du nogle høns at plukke?"},
	{job = 'miner', label = "Miner", icon = "fa fa-user", description = "Måske finder du en diamand hvem ved?"},
	{job = 'technician', label = "Elektriker", icon = "fa fa-user", description = "Kan du lide strøm?"},
	{job = 'mail', label = "Postnord", icon = "fas fa-envelope", description = "Kan du levere posten hurtigere end de andre?"},
	{job = 'taxi', label = "Taxa", icon = "fas fa-taxi", description = "Fragt folk frem og tilbage, de mangler dig!"},

},

DefaultJobs = { -- Jobs that will be added in menu by default and wont be removable
	
	{job = 'unemployed', grade = 0}
},

Text = {

	['cant_offduty'] = 'Du kan ikke gå af arbejde!',
	['open_ui_hologram'] = '[~b~E~w~] Åben Job muligheder',
	['open_jobcenter_ui_hologram'] = '[~b~E~w~] Åben Job Center',
	['wrong_usage'] = 'Forkert command',
	['job_added'] = 'Job tilføjet!',

}
	

}

-- Only change if you know what are you doing!
function SendTextMessage(msg)

		SetNotificationTextEntry('STRING')
		AddTextComponentString(msg)
		DrawNotification(0,1)

		--EXAMPLE USED IN VIDEO
		--exports['mythic_notify']:SendAlert('error', msg)

end
