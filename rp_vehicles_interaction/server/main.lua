addEvent("onVehicleInteractionUse", true);
addEventHandler("onVehicleInteractionUse", root, function(vehicle, type)
    if not vehicle or getElementType(vehicle) ~= "vehicle" then return end;
    if not type then return end;

    if type == "engine" then
        if not getVehicleEngineState(vehicle) then
            if getElementHealth(vehicle) <= 320 then
                local randomDamages = math.random(1, 10);
                if (randomDamages == 1 or randomDamages < 9) then
                    triggerClientEvent(getVehicleController(vehicle), "onClientAddRadarNotification", getVehicleController(vehicle), "Silnik w pojeździe nie chce się uruchomić, ponieważ jest uszkodzony.", "error");
                    triggerClientEvent(root, "onClientVehicleInteractionUse3DSound", root, vehicle, "assets/sounds/engine_fail.mp3");
                    return;
                else
                    setVehicleEngineState(vehicle, not getVehicleEngineState(vehicle));
                    if getVehicleEngineState(vehicle) then
                        triggerClientEvent(root, "onClientVehicleInteractionUse3DSound", root, vehicle, "assets/sounds/engine.mp3");
                    end;
                    return;
                end;
            else
                setVehicleEngineState(vehicle, not getVehicleEngineState(vehicle));
                if getVehicleEngineState(vehicle) then
                    triggerClientEvent(root, "onClientVehicleInteractionUse3DSound", root, vehicle, "assets/sounds/engine.mp3");
                end;
                return;
            end;
        else
            setVehicleEngineState(vehicle, not getVehicleEngineState(vehicle));
            return;
        end;
    elseif type == "lights" then
        triggerClientEvent(root, "onClientVehicleInteractionUse3DSound", root, vehicle, "assets/sounds/lights.mp3");
        if getVehicleOverrideLights(vehicle) ~= 2 then
            setVehicleOverrideLights(vehicle, 2)
            return;
        else
            setVehicleOverrideLights(vehicle, 1)
            return;
        end;
    elseif type == "handbrake" then
        triggerClientEvent(root, "onClientVehicleInteractionUse3DSound", root, vehicle, "assets/sounds/handbrake.mp3");
        if isElementFrozen(vehicle) then
            setElementFrozen(vehicle, not isElementFrozen(vehicle));
            return;
        else
            setElementFrozen(vehicle, not isElementFrozen(vehicle));
            return;
        end;
    end;

end);

addEventHandler("onVehicleExit", root, function(player, seat)
    if seat ~= 0 then return end;
    --if player ~= client then return end;

    setVehicleEngineState(source, false);
end);

addEventHandler("onVehicleEnter", root, function(player, seat)
    if seat ~= 0 then return end;
    --if player ~= client then return end;
    setVehicleEngineState(source, false);
end);

addEventHandler("onVehicleDamage", root, function(loss)
    if getElementHealth(source) <= 320 then
        setElementHealth(source, 318);
    end;
end);