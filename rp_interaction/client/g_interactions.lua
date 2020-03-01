INTERACTIONS = {
    ["vehicle"] = { -- interakcja z pojazdami.
        {
            name = "mask",
            action = "Maska",
            clientFunct = function(element)
                --[[exports["rp_hud"]:showNotification("Interakcja niedostępna.", "error");
                triggerEvent("onClientInteractionClear", resourceRoot); -- czyszczenie interakcji]]
                triggerServerEvent("envInteraction", resourceRoot, element, "openVehicleMask");
            end
        },
        {
            name = "trunk",
            action = "Bagażnik",
            clientFunct = function(element)
                triggerServerEvent("envInteraction", resourceRoot, element, "openVehicleTrunk"); -- wykonywanie interakcji
            end
        },
        {
            name = "quit",
            action = "Wyjdź",
            clientFunct = function()
                return triggerEvent("onClientInteractionClear", resourceRoot);
            end
        },
    },
    ["player"] = { -- interakcja z graczami.
        {
            name = "add_friend",
            action = "Dodaj jako znajomego",
            clientFunct = function(element)
                -- tutaj bedzie funkcja
                triggerServerEvent("onPlayerInvitePlayerToFriends", localPlayer, localPlayer, element);
            end
        },
        {
            name = "quit",
            action = "Wyjdź",
            clientFunct = function(element)
                return triggerEvent("onClientInteractionClear", resourceRoot);
            end
        },
    }
};