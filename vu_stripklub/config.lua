Config = {}

Config.DrawDistance = 25.0
Config.Locale = 'da'

Config.JobName = 'vanilla'

Config.MarkerColor = {63, 102, 4, 200}
Config.BossMenu = vector3(94.12, -1292.56, 29.26)

--================
--==    Blip    ==
--================
Config.Blip = {}

Config.Blip.enable = true

Config.Blip.coords = vector3(117.85, -1289.4, 28.26)
Config.Blip.sprite = 121
Config.Blip.display = 4
Config.Blip.scale = 0.8

Config.Locations = {
    Bar = vector3(130.42, -1282.9, 29.27),
    Vehicle = {
        spawner = vector3(136.64, -1275.74, 29.30),
        spawnPoint = vector3(144.68, -1275.74, 29.0),
        heading = 208.65,
        deleter = vector3(142.12, -1269.84, 28.10),
    },
}

Config.Vehicles = {
   -- {label = 'Klassisk Limosine', model = 'stretch'},
}

Config.Bar = {
    ["wine"] = 0,
    ["water"] = 0,
    ["vodkaredbull"] = 0,
    ["vodkacranberry"] = 0,
    ["tequila"] = 0,
    ["icetea"] = 0,
    ["vodka"] = 0,
    ["beer"] = 0,
    ["whisky"] = 0,
}