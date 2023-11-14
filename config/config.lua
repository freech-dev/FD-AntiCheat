Config = {}

Config.blacklists = {
    explosions = { -- Get explosion names from https://altv.stuyk.com/docs/articles/tables/explosions.html
        "EXPLOSION_GRENADE",
        "EXPLOSION_STICKYBOMB",
        "EXPLOSION_MOLOTOV",
    },
    
    weapons = {

    },
}

Config.punishments = {
    -- The punishments are either kick, ban, delete or nil which does nothing (Delete just either deletes the event/entity/vehicle or removes the weapon ect)
    blacklisted_explosion = "kick",
    blacklisted_weapon = "delete",
    blacklisted_vehicle = "delete"
}

return Config
