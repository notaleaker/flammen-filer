AddEventHandler('cd_drawtextui:ShowUI', function(action, text)
	SendNUIMessage({
		invokingResource = GetInvokingResource(),
		action = action,
		text = text
	})
end)

AddEventHandler('cd_drawtextui:HideUI', function()
	SendNUIMessage({
		invokingResource = GetInvokingResource(),
		action = 'hide'
	})
end)