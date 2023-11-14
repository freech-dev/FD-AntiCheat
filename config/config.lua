Config = {}

Config.blacklists = {
    explosions = { -- Get explosion names from https://altv.stuyk.com/docs/articles/tables/explosions.html
        "EXPLOSION_GRENADE",
        "EXPLOSION_STICKYBOMB",
        "EXPLOSION_MOLOTOV",
    },
    
    weapons = {

    },

    vehicles = {

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
