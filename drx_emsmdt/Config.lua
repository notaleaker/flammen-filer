Config = {
    -- Required job to open the tablet
    Permission = 'ambulance',
    Command = 'emstablet',

    Notifications = {
        -- Citizens
        CallSubmitted = 'Lægerne har modtaget dit opkald',
        ReceivedRespond = '112:',
        -- EMS
        NewCall = 'Et nyt opkald er kommer herfra',
        AttachedCall = 'Du har nu taget det valgte opkald',
        DetachCall = 'Du er gået fra det valgte opkald',
        DeleteCall = 'Du har slettet opkaldet med ulykke id: #',
        RespondedCall = 'Borgeren som mangler hjælp har fået dit opkald her: #', 
        NoTarget = 'Målet er ikke online',
        NoMessage = 'Du skrev ikke noget i beskeden',
        NewCase = 'Du afleverede en ny sag til databasen',
        DeletedCase = 'Du slettede sagen: #',
        SavedCase = 'Du gemte sagen:  #',

        -- Developer / Administrator
        UserNotFound = 'Your identifier was not found in the database, contact the servers developer or administrator!',
    }
}
