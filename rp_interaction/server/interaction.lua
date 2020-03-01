addEvent("envInteraction", true);
addEventHandler("envInteraction", resourceRoot, function(element, action)
    if not element or not isElement(element) then return end;

    -- interakcja pojazdów
    if getElementType(element) == "vehicle" then 
        if action == "openVehicleTrunk" then
            if getVehicleDoorOpenRatio(element, 1) == 0 then
                setVehicleDoorOpenRatio(element, 1, 1, 500);
            else
                setVehicleDoorOpenRatio(element, 1, 0, 500);
            end;
        elseif action == "openVehicleMask" then
            if getVehicleDoorOpenRatio(element, 0) == 0 then
                setVehicleDoorOpenRatio(element, 0, 1, 500);
            else
                setVehicleDoorOpenRatio(element, 0, 0, 500);
            end;
        else

        end;
    else

    end;
end);