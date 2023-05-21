--------------------------------
------- Created by Lund -------
-------------------------------- 

Config = {

	MarkerSprite = 27, -- drawmarker https://docs.fivem.net/docs/game-references/markers/
	MarkerColor = {250, 0, 0}, -- hex farven på drawmarkeren
	MarkerSize = 1.1, -- størelsen på drawmarkeren
	
	BossMenuL = {
	
		{coords = vector3(287.7026,-1160.4099,29.2915), job = "mcdealer"}
	
		--EXAMPLE
		-- {coords = vector3(coords), job = "rank"} -- husk , efter ellers duer det ikke
	},
	
	
	BossMenuU = {
		['boss'] = {canWithdraw = true, canDeposit = true, canHire = true, canRank = true, canFire = true}, -- skift til false / true hvis du vil disabel noget eller fjerne noget, (false) fjerner, (true) tilføjer 
	},
	
	
	-- texten til SendTextMessage
	
	Text = {
		['promoted'] = 'Du er blevet forfremmet',
		['promoted_other'] = 'Du er blevet forfremmet til et andet job!',
		['fired'] = 'Du er blevet fyret',
		['fired_other'] = 'Du er blevet fyret',
		['hired'] = 'Du er blevet ansat',
		['bossmenu_hologram'] = '[~r~E~w~] Åbn Boss Menu',
		['action_success'] = 'Handling vellykket',
		['action_unsuccessful'] = 'Handling mislykket',
		['cant_access_bossmenu'] = 'Du kan ikke få adgang til bossmenuen',
		['insufficent_balance'] = 'Insufficent balance',
	
	}
	}
	
	-- skift ved egen sikkerhed -- hjælper ikke hvis du fucker noget op, og ikke ved hvordan du fixer det efter
	function SendTextMessage()
	
			SetNotificationTextEntry('STRING')
			AddTextComponentString(msg)
			DrawNotification(0,1)
	
			--EXAMPLE 
			--exports['mythic_notify']:SendAlert('error', msg)
	
	end

	Config.DiscordWebHook = {
		Webhook = "https://discord.com/api/webhooks/1044643513511444521/08PpUqHlT4ByzW_04WqNuxElttX_qVpPzS1VJi_MeTCsz654ENsNmqrlmTN5ilLR2Gnx", -- discord webhook 
		Color = "4355573", -- skal være Decimal nummer - tag farven her fra https://convertingcolors.com/hex-color-4275F5.html?search=4275f5
		Head = "FlammenRP",
	
		SetRank = { 
			Forfremet = "Er lige blevet forfremet",
			HasSetRank = "har lige forfremet en anden spiller",
		},

		Fire = { 
			HasFire = "Er lige blevet forfremet",
			HasBinFired = "har lige Fyret en Anden fra",
		},
 
		Hire = { 
			HiredANew = "har lige Andsat en ny til ",
		},

	}
