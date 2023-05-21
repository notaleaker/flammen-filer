---@param msg 		string	Message to show
---@param thisFrame boolean	Show only this frame
---@param beep 		boolean	Play sound
---@param duration 	number	Duration of help text
--- from https://esx-framework.github.io/es_extended/client/functions/showhelpnotification/
function showHelpText(msg, thisFrame, beep, duration)
	AddTextEntry('rcore-tattoos-help', msg)

	if thisFrame then
		DisplayHelpTextThisFrame('rcore-tattoos-help', false)
	else
		if beep == nil then beep = true end
		BeginTextCommandDisplayHelp('rcore-tattoos-help')
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end

---@param title 	string	Title of notification
---@param message 	string	Notification text
---@param style 	string	Style of notification (success, error)
function addNotification(title,message,style)
	title = title or _U('notification')
	message = message or _U('message')

    SendNUIMessage({
        type = "notification",
        title = title,
        message = message,
        style = style
    })
end
