Config = {}

Config.departments = {
    -- Template Start
    ['SAST'] = {
        type = "LEO", -- Must be LEO or STAFF or it wont work
        shortName = "SAST", -- Abbreviated Name
        longName = "San Andreas State Troopers", -- Full name
        webHook = "https://discord.com/api/webhooks/1071477149246177340/OAmoKuHASM7-8JStJxASICUqtAhMF4UmNeYbRKs1pjYrzZesTzFS2X3pnmScScPgyEaw", -- Discord webhook
        ace_perm = "sast.duty", -- Ace perm for who is allowed to go on duty 
        restricted_vehicles = { -- Vehicle spawncodes restricted to onduty players that are onduty as this dept
            "police",
            "fbi",
            "sheriff"
        }
    },
    -- Template End
}

return Config
