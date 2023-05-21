whitelist = {
    ['steam:110000105d61b48'] = {'s_m_y_grip_01'},
    ['steam:11000014c53a835'] = {'a_m_o_genstreet_01'},
    ['steam:110000142e4421d'] = {'a_m_y_downtown_01'},
    ['steam:110000133ad907c'] = {'ig_lamardavis', 'g_m_y_mexgoon_03', 'g_m_m_mexboss_01'},
    ['steam:110000146fc2aa1'] = {'s_m_y_dealer_01', 'g_m_y_mexgoon_01'},
    ['steam:1100001467b9580'] = {'u_m_m_partytarget'},
    ['steam:11000013edff49e'] = {'a_m_y_eastsa_01'},
    ['steam:11000014426fa76'] = {'ig_nervousron'},
    ['steam:11000010e69b460'] = {'a_m_m_farmer_01'},
    ['steam:11000014bbc810a'] = {'a_m_m_fatlatin_01'},
    ['steam:11000013f88c609'] = {'g_m_m_armboss_01'},
    ['steam:11000014a50d598'] = {'a_m_m_og_boss_01'},
    ['steam:110000143785617'] = {'a_m_m_fatlatin_01'},
    ['steam:11000014a8b53ef'] = {'g_m_importexport_01'},
    ['steam:110000155e7acd9'] = {'u_m_m_partytarget', 'a_m_m_genfat_02'},
    ['steam:110000154a9431f'] = {'a_m_y_soucent_02'},
    ['steam:1100001555c286f'] = {'a_f_m_ktown_02'},
    ['steam:11000011ab1b8e5'] = {'a_m_y_yoga_01'},
    ['steam:1100001163b28f8'] = {'s_m_o_busker_01'},
    ['steam:110000142f1049b'] = {'ig_stretch'},
    ['steam:11000013d5c8a2b'] = {'a_m_y_soucent_02'},
    ['steam:110000154f3b9df'] = {'a_m_y_soucent_03'},
    ['steam:11000014a4cc3c0'] = {'u_m_m_filmdirector'},
    ['steam:1100001334b8e91'] = {'ig_claypain'}
}

menu_options = {
    {name = "Ped Muligheder", f = customise, param = nil},
    {name = "Ped Tilbehør", f = accessories, param = nil},
    {name = "Ped Ansigt", f = overlays, param = nil},
}

player_data = {
    model = `mp_m_freemode_01`,
    new = true,
    clothing = {
        drawables = {},
        textures = {
            1, 1, 1
        },
        palette = {},
    },
    props = {
        drawables = {},
        textures = {},
    },
    overlays = {
        drawables = {},
        opacity = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0},
        colours = {
            {colourType = 0, colour = 0},
            {colourType = 0, colour = 0},
            {colourType = 0, colour = 0},
            {colourType = 0, colour = 0},
            {colourType = 0, colour = 0},
            {colourType = 0, colour = 0},
            {colourType = 0, colour = 0},
            {colourType = 0, colour = 0},
            {colourType = 0, colour = 0},
            {colourType = 0, colour = 0},
            {colourType = 0, colour = 0},
            {colourType = 0, colour = 0},
            {colourType = 0, colour = 0},
        },
    },
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if clothing_menu then
            Menu.DisplayCurMenu()
        end
    end
end)


RegisterNetEvent('frp_peds:openMenu')
AddEventHandler('frp_peds:openMenu', function(id)
    openPedMenu(id)
end)


openPedMenu = function(identifier)
    local isWhitelisted = false
    for steamId, peds in pairs(whitelist) do
        if steamId == identifier then
            isWhitelisted = true
            table.insert(menu_options, {
                name = 'Dine Ped Modeller',
                f = listModels,
                param = peds
            })
        end
    end

    if not isWhitelisted then return end

    GUI.maxVisOptions = 20
    titleTextSize = {0.85, 0.80} ------------ {p1, Size}                                      
    titleRectSize = {0.23, 0.085} ----------- {Width, Height}                                 
    optionTextSize = {0.5, 0.5} ------------- {p1, Size}                                      
    optionRectSize = {0.23, 0.035} ---------- {Width, Height}           
    menuX = 0.845 ----------------------------- X position of the menu                          
    menuXOption = 0.11 --------------------- X postiion of Menu.Option text                  
    menuXOtherOption = 0.06 ---------------- X position of Bools, Arrays etc text            
    menuYModify = 0.1500 -------------------- Default: 0.1174   ------ Top bar                
    menuYOptionDiv = 4.285 ------------------ Default: 3.56   ------ Distance between buttons 
    menuYOptionAdd = 0.21 ------------------ Default: 0.142  ------ Move buttons up and down
    clothing_menu = true
    OpenClothes()
end