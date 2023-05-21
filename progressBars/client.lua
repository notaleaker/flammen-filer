function startUI(time, text) 
	SendNUIMessage({
		type = "ui",
		display = true,
		time = time,
		text = text
	})
end

function stopUI()
	SendNUIMessage({
		type = "stop",
		display = false,
	})
end

exports('startUI', startUI)
exports('stopUI', stopUI)