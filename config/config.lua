Config = {}

Config.LogWebhook = "https://discord.com/api/webhooks/1172271210562863214/5KZ_xlB5mOcrEBsIZCqOk0laWtduB0-T9mi5O-5x12DLdyEmy-IVeC-2xDBkxGiayauE"

Config.blacklists = {
    explosions = { -- Get explosion names from https://altv.stuyk.com/docs/articles/tables/explosions.html
        "EXPLOSION_GRENADE",
        "EXPLOSION_STICKYBOMB",
        "EXPLOSION_MOLOTOV"
    },
    
    weapons = {
        "WEAPON_RPG",
        "WEAPON_RAILGUN",
        "WEAPON_FIREWORK"
    },

    vehicles = {
        "asbo",
        "baller",
        "police"
    },

    peds = {
        "a_f_m_beach_01",
        "a_f_o_soucent_01",
        "a_f_y_bevhills_01"
    },
}

Config.punishments = {
    -- The punishments are either kick, ban, delete or nil which does nothing (Delete just either deletes the event/entity/vehicle or removes the weapon ect)
    -- There is also a punishment called "fuckthem" which will teleport them to 5 points in the map continuously untill they crash 
    blacklisted_explosion = "kick",
    blacklisted_weapon = "delete",
    blacklisted_vehicle = "delete"
}

return Config
