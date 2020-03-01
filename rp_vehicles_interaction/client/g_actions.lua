local zoom = exports["rp_gui"]:getInterfaceZoom() or 1;
local screen = Vector2(guiGetScreenSize());

g_vehicle_interactions = {
    {
        type = "engine",
        icon = "engine",
        pos = {
            x = (screen.x - 64/zoom)/2,
            y = screen.y/2 - 300/zoom
        },
        action = function(vehicle, sounds)
            if not vehicle or getElementType(vehicle) ~= "vehicle" then return end;
            if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end;

            triggerServerEvent("onVehicleInteractionUse", localPlayer, vehicle, "engine");
        end,
    },
    {
        type = "lights",
        icon = "lights",
        pos = {
            x = screen.x/2 + 156/zoom,
            y = screen.y/2 - 232/zoom
        },
        action = function(vehicle, sounds)
            if not vehicle or getElementType(vehicle) ~= "vehicle" then return end;
            if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end;

            triggerServerEvent("onVehicleInteractionUse", localPlayer, vehicle, "lights");
        end,
    },
    {
        type = "handbrake",
        icon = "handbrake",
        pos = {
            x = screen.x/2 + 236/zoom,
            y = screen.y/2 - 53/zoom
        },
        action = function(vehicle, sounds)
            if not vehicle or getElementType(vehicle) ~= "vehicle" then return end;
            if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end;

            triggerServerEvent("onVehicleInteractionUse", localPlayer, vehicle, "handbrake");
        end,
    }
};