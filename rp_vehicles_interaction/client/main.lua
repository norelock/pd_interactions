local zoom = exports["rp_gui"]:getInterfaceZoom() or 1;
local screen = Vector2(guiGetScreenSize());

-- events
addEvent("onClientVehicleInteractionUse3DSound", true);

-- utils
local utils = {};

utils.play3DSound = function(vehicle, sound)
    if not vehicle or getElementType(vehicle) ~= "vehicle" then return end;
    if not sound then return end;

    local vehicle_position = Vector3(getElementPosition(vehicle));

    local snd = playSound3D(sound, vehicle_position.x, vehicle_position.y, vehicle_position.z, false);

    setSoundMaxDistance(snd, 50);
    setElementInterior(snd, getElementInterior(vehicle));
    setElementDimension(snd, getElementDimension(vehicle));
end;
addEventHandler("onClientVehicleInteractionUse3DSound", root, utils.play3DSound);

utils.isTableEmpty = function(a)
    if type(a) ~= "table" then
        return false;
    end;

    return next(a) == nil;
end;

utils.searchRotation = function(x1, y1, x2, y2)
    local t = -math.deg(math.atan2(x2 - x1, y2 - y1));

    return t < 0 and t + 360 or t;
end;

-- interaction
local interaction = {};

-- assets path
local ASSETS_PATH = {
    TEXTURES = "assets/images/",
    SOUNDS = "assets/sounds/"
};

-- on starting resource, creating textures, sound list, fonts, buttons for interaction
interaction.onLoad = function()
    interaction.showing = false;

    interaction.textures = {
        background = dxCreateTexture(ASSETS_PATH.TEXTURES .. "background.png"),
        circle_background = dxCreateTexture(ASSETS_PATH.TEXTURES .. "circle_background.png"),
        pointer = dxCreateTexture(ASSETS_PATH.TEXTURES .. "pointer.png"),
        pointer_light = dxCreateTexture(ASSETS_PATH.TEXTURES .. "pointer_light.png"),
        vignette = dxCreateTexture(ASSETS_PATH.TEXTURES .. "vignette.png"),

        engine = dxCreateTexture(ASSETS_PATH.TEXTURES .. "engine.png"),
        lights = dxCreateTexture(ASSETS_PATH.TEXTURES .. "lights.png"),
        handbrake = dxCreateTexture(ASSETS_PATH.TEXTURES .. "handbrake.png"),
        lock = dxCreateTexture(ASSETS_PATH.TEXTURES .. "lock.png"),
        passanger_out = dxCreateTexture(ASSETS_PATH.TEXTURES .. "passanger_out.png"),
        car_belt = dxCreateTexture(ASSETS_PATH.TEXTURES .. "car_belt.png")
    };

    interaction.sounds_list = {
        interaction = ASSETS_PATH.SOUNDS .. "interaction.mp3",
        engine = ASSETS_PATH.SOUNDS .. "engine.mp3",
        engine_fail = ASSETS_PATH.SOUNDS .. "engine_fail.mp3",
        handbrake = ASSETS_PATH.SOUNDS .. "handbrake.mp3",
        lights = ASSETS_PATH.SOUNDS .. "lights.mp3",
        lock = ASSETS_PATH.SOUNDS .. "lock.mp3"
    };

    interaction.fonts = {
        bold_big = exports["rp_gui"]:getGUIFont("bold_big"),
        bold = exports["rp_gui"]:getGUIFont("bold"),
        light_tip = exports["rp_gui"]:getGUIFont("light")
    };

    interaction.click_tick = getTickCount();

    interaction.buttons = {};
    if not utils.isTableEmpty(g_vehicle_interactions) then
        for key, interact_button in ipairs(g_vehicle_interactions) do
            interaction.buttons[key] = {
                button = exports["rp_gui"]:createButton("", 0, 0, 60/zoom, 60/zoom),
                type = interact_button.type
            };
            exports["rp_gui"]:setButtonPosition(interaction.buttons[key].button, interact_button.pos.x, interact_button.pos.y);
            exports["rp_gui"]:setButtonTextures(interaction.buttons[key].button, {
                default = interaction.textures[interact_button.icon],
                hover = interaction.textures[interact_button.icon],
                press = interaction.textures[interact_button.icon]
            });
            exports["rp_gui"]:setButtonTexturesColor(interaction.buttons[key].button, tocolor(222, 222, 222, 200));

            addEventHandler("onClientClickButton", interaction.buttons[key].button, function()
                if not getPedOccupiedVehicle(localPlayer) then return end;
                if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end;

                local speed = math.floor((Vector3(getElementVelocity(getPedOccupiedVehicle(localPlayer))) * 170).length);
                if speed > 0 then
                    exports["rp_hud"]:showNotification("Podczas jazdy nie można używać interakcji!", "error");
                    return;
                end;

                interaction.click_tick = getTickCount();

                if (interact_button.action ~= nil and type(interact_button.action) == "function") then
                    return interact_button.action(getPedOccupiedVehicle(localPlayer), interaction.sounds_list);
                end;
            end);
        end;
    end;

    interaction.animations = {
        vig_alpha = 255,
        vig_anim = nil
    };

    interaction.selected = nil; 
    interaction.hovered = false;

    interaction.key = "lshift";
    bindKey(interaction.key, "both", function()
        if not getElementData(localPlayer, "player:logged") or not getElementData(localPlayer, "character:spawned") then return end;
        if not getPedOccupiedVehicle(localPlayer) then return end;
        if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end;
        if isChatBoxInputActive() or isMainMenuActive() or isTransferBoxActive() or isConsoleActive() then return end;

        if not interaction.showing then
            exports["2dfog"]:reload();

            showChat(false);
            showCursor(true, false);

            interaction.showing = true;
            interaction.animations.vig_anim = createAnimation(255, 90, "Linear", 500, function(x)
                interaction.animations.vig_alpha = x;
            end);

            setSoundVolume(playSound(interaction.sounds_list.interaction), 0.6);

            if exports["rp_hud"]:getRadarState() then
                exports["rp_hud"]:setRadarState(false);
            end;

            addEventHandler("onClientRender", root, interaction.onRender);
        else
            showChat(true);
            showCursor(false);

            interaction.showing = false;
            interaction.selected = nil;
            interaction.hovered = false;

            if not exports["rp_hud"]:getRadarState() then
                exports["rp_hud"]:setRadarState(true);
            end;

            removeEventHandler("onClientRender", root, interaction.onRender);
        end;
    end);

    addEventHandler("onClientVehicleExit", root, function(player, seat)
        if player ~= localPlayer then return end;
        if seat ~= 0 then return end;

        if interaction.showing then
            showChat(true);
            showCursor(false);

            interaction.showing = false;
            interaction.selected = nil;
            interaction.hovered = false;

            if not exports["rp_hud"]:getRadarState() then
                exports["rp_hud"]:setRadarState(true);
            end;

            removeEventHandler("onClientRender", root, interaction.onRender);
        end;
    end);
end;
addEventHandler("onClientResourceStart", resourceRoot, interaction.onLoad);

-- on resource stop, unloading interaction stuff, textures.
interaction.onUnload = function()
    if interaction.showing then
        if not exports["rp_hud"]:getRadarState() then
            exports["rp_hud"]:setRadarState(true);
            showChat(true);
            showCursor(false);
        end;
        exports["rp_hud"]:showNotification("Interakcja pojazdu została zrestartowana, za utrudnienia przepraszamy.", "error");
    end;

    toggleAllControls(true);

    for key, texture in ipairs(interaction.textures) do
        if isElement(texture) then
            destroyElement(texture);
        end;
    end;
    interaction.textures = {};
end;
addEventHandler("onClientResourceStop", resourceRoot, interaction.onUnload);

interaction.onRender = function()
    if not interaction.showing then return end;

    local cursor_position = Vector2(getCursorPosition());
    local rotation = math.floor(utils.searchRotation(screen.x/2, screen.y/2, cursor_position.x * screen.x, cursor_position.y * screen.y)) + 180;

    exports["rp_gui"]:drawBWRectangle(0, 0, screen.x, screen.y);

    exports["2dfog"]:render();
    exports["2dfog"]:color(111, 111, 111, 30);

    dxDrawImage(0, 0, screen.x, screen.y, interaction.textures.vignette, 0, 0, 0, tocolor(255, 255, 255, interaction.animations.vig_alpha));

    dxDrawText("TRYB INTERAKCJI Z POJAZDEM", 0, screen.y - 160/zoom, screen.x, screen.y - 160/zoom, tocolor(222, 222, 222, 255), 1/zoom, interaction.fonts.bold_big, "center", "center");
    dxDrawText("Kliknij lewym przyciskiem myszy na wskazaną\ninterakcję, którą chcesz wykonać z pojazdem.", 0, screen.y - 100/zoom, screen.x, screen.y - 100/zoom, tocolor(222, 222, 222, 255), 1/zoom, interaction.fonts.light_tip, "center", "center");

    dxDrawImage((screen.x - 637/zoom)/2, (screen.y - 637/zoom)/2, 637/zoom, 637/zoom, interaction.textures.background, 0, 0, 0, tocolor(255, 255, 255, 255));
    dxDrawImage((screen.x - 637/zoom)/2, (screen.y - 637/zoom)/2, 637/zoom, 637/zoom, interaction.textures.circle_background, 0, 0, 0, tocolor(255, 255, 255, 255));

    local hovered_icon = nil;

    for key, _ in ipairs(interaction.buttons) do
        exports["rp_gui"]:renderButton(interaction.buttons[key].button);

        if exports["rp_gui"]:isButtonHovered(interaction.buttons[key].button) then
            local opacity = interpolateBetween(225, 0, 0, 0, 0, 0, (getTickCount()/2000), "CosineCurve");
            dxDrawImage((screen.x - 637/zoom)/2, (screen.y - 637/zoom)/2, 637/zoom, 637/zoom, interaction.textures.pointer_light, rotation, 0, 0, tocolor(255, 255, 255, opacity));

            hovered_icon = exports["rp_gui"]:getButtonTextures(interaction.buttons[key].button).default;

            if interaction.buttons[key].type == "engine" then
                dxDrawText(string.format("%s", getVehicleEngineState(getPedOccupiedVehicle(localPlayer)) and "Wyłącz silnik" or "Włącz silnik"), 0, 615/zoom, screen.x, 615/zoom, tocolor(222, 222, 222, 255), 1/zoom, interaction.fonts.bold, "center", "center");
            elseif interaction.buttons[key].type == "lights" then
                dxDrawText(string.format("%s", areVehicleLightsOn(getPedOccupiedVehicle(localPlayer)) and "Wyłącz światła" or "Włącz światła"), 0, 615/zoom, screen.x, 615/zoom, tocolor(222, 222, 222, 255), 1/zoom, interaction.fonts.bold, "center", "center");
            elseif interaction.buttons[key].type == "handbrake" then
                dxDrawText(string.format("%s", isElementFrozen(getPedOccupiedVehicle(localPlayer)) and "Spuść hamulec ręczny" or "Zaciągnij hamulec ręczny"), 0, 615/zoom, screen.x, 615/zoom, tocolor(222, 222, 222, 255), 1/zoom, interaction.fonts.bold, "center", "center");
            end;

            dxDrawImage((screen.x - 105/zoom)/2, (screen.y - 165/zoom)/2, 105/zoom, 105/zoom, hovered_icon, 0, 0, 0, tocolor(255, 255, 255, 255));

            interaction.selected = key;

            exports["rp_gui"]:setButtonTexturesColor(interaction.buttons[key].button, tocolor(255, 255, 255, 255));
            if exports["rp_gui"]:isButtonClicked(interaction.buttons[key].button) then
                exports["rp_gui"]:setButtonTexturesColor(interaction.buttons[key].button, tocolor(222, 222, 222, 200));
            end;
        else
            interaction.selected = nil;

            exports["rp_gui"]:setButtonTexturesColor(interaction.buttons[key].button, tocolor(222, 222, 222, 200));
        end;
    end;

    dxDrawImage((screen.x - 637/zoom)/2, (screen.y - 637/zoom)/2, 637/zoom, 637/zoom, interaction.textures.pointer, rotation, 0, 0, tocolor(255, 255, 255, 255));
end;