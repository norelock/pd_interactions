local zoom = exports["rp_gui"]:getInterfaceZoom();
local screen = Vector2(guiGetScreenSize());

local interaction = {};
local tabs = {};
local tab_hover = nil;
local wall_shader = {};
local colorize = {};
local shader = nil;
local power = 0;
local is_irt = false;
local is_irt_enabled = false;
local post_aura = false;
local effect_enabled = false;
local render_target = nil;
local wall_timer = nil;
local wall_effect = nil;

local INTERACTION_DISTANCE = 8.2;

local isMouseInPosition = function(x, y, w, h)
    if not isCursorShowing() then return end;

    local cursorX, cursorY = getCursorPosition();
    cursorX, cursorY = (cursorX * screen.x), (cursorY * screen.y);

    if cursorX >= x and cursorX <= (x + w) and cursorY >= y and cursorY <= (y + h) then
        return true;
    end;

    return false;
end;

addEvent("switchWall", true);
addEvent("onInteractionClickTab", true);
addEvent("onClientInteractionClear", true);

interaction.onLoad = function()
    interaction.textures = {
        vignette = dxCreateTexture("assets/images/vignette.png"),
        interactions = {
            object = dxCreateTexture("assets/images/object_interaction.png"),
            ped = dxCreateTexture("assets/images/ped_interaction.png"),
            player = dxCreateTexture("assets/images/player_interaction.png"),
            vehicle = dxCreateTexture("assets/images/vehicle_interaction.png")
        }
    };
    interaction.fonts = {
        bold_big = exports["rp_gui"]:getGUIFont("bold_big"),
        light = exports["rp_gui"]:getGUIFont("light_small"),
        light_tip = exports["rp_gui"]:getGUIFont("light"),
        normal = exports["rp_gui"]:getGUIFont("normal")
    };
    interaction.animations = {
        vig_alpha = 255,
        vig_anim = nil
    };

    interaction.enabled = false;
    interaction.interact_type = nil;
    interaction.interact_element = nil;
    interaction.cursorX, interaction.cursorY = 0, 0;

    --colorize = {0/255, 119/255, 179/255, 1};
    power = 0.7;
    post_aura = true;

    is_irt = false;
    if dxGetStatus().VideoCardNumRenderTargets > 1 then 
        is_irt = true;
    end;
    triggerEvent("switchWall", resourceRoot, true, is_irt);

    addEventHandler("onClientVehicleEnter", root, function(player, seat)
        if interaction.enabled and player == localPlayer and seat then
            interaction.enabled = false;
            effect_enabled = false;

            if not exports["rp_hud"]:getRadarState() then
                exports["rp_hud"]:setRadarState(true);
            end;

            showChat(true);
            showCursor(false);

            removeEventHandler("onClientRender", root, interaction.onRender);
            removeEventHandler("onClientRender", root, interaction.renderInteractions);
            removeEventHandler("onClientPreRender", root, interaction.onPreRender);
            removeEventHandler("onClientClick", root, interaction.onElementClick);
            removeEventHandler("onClientClick", root, interaction.onTabClick);
        end;
    end);

    interaction.key_bind = "e";
    bindKey(interaction.key_bind, "down", function()
        if not getElementData(localPlayer, "player:logged") or not getElementData(localPlayer, "character:spawned") then return end;
        if getPedOccupiedVehicle(localPlayer) then return end;
        if isChatBoxInputActive() or isMainMenuActive() or isTransferBoxActive() or isConsoleActive() then return end;

        if not interaction.enabled then
            exports["2dfog"]:reload();

            showChat(false);
            showCursor(true);

            setSoundVolume(playSound("assets/sounds/interaction.mp3"), 0.6);

            interaction.enabled = true;
            effect_enabled = true;

            interaction.animations.vig_anim = createAnimation(255, 90, "Linear", 500, function(x)
                interaction.animations.vig_alpha = x;
            end);

            if exports["rp_hud"]:getRadarState() then
                exports["rp_hud"]:setRadarState(false);
            end;

            addEventHandler("onClientRender", root, interaction.onRender);
            addEventHandler("onClientRender", root, interaction.renderInteractions);
            addEventHandler("onClientPreRender", root, interaction.onPreRender);
            addEventHandler("onClientClick", root, interaction.onElementClick);
            addEventHandler("onClientClick", root, interaction.onTabClick);
        else
            showChat(true);
            showCursor(false);

            interaction.interact_type = nil;
            interaction.interact_element = nil;
            interaction.cursorX, interaction.cursorY = 0, 0;
            interaction.enabled = false;
            effect_enabled = false;

            if not exports["rp_hud"]:getRadarState() then
                exports["rp_hud"]:setRadarState(true);
            end;

            removeEventHandler("onClientRender", root, interaction.onRender);
            removeEventHandler("onClientRender", root, interaction.renderInteractions);
            removeEventHandler("onClientPreRender", root, interaction.onPreRender);
            removeEventHandler("onClientClick", root, interaction.onElementClick);
            removeEventHandler("onClientClick", root, interaction.onTabClick);
        end;
    end);
end;
addEventHandler("onClientResourceStart", resourceRoot, interaction.onLoad);

interaction.onStop = function()
    for key, texture in ipairs(interaction.textures) do
        if isElement(texture) then
            destroyElement(texture);
        end;
    end;
    if interaction.enabled then
        exports["rp_hud"]:setRadarState(true);
        showChat(true);
    end;
    interaction.textures = {};
    interaction.fonts = {};
end;
addEventHandler("onClientResourceStop", resourceRoot, interaction.onStop);

interaction.onInteractionClear = function()
    if interaction.enabled then
        interaction.interact_type = nil;
        interaction.interact_element = nil;
        interaction.cursorX, interaction.cursorY = 0, 0;
        tabs.clicked = nil;
        tabs.hovered = nil;
    end;
end;
addEventHandler("onClientInteractionClear", resourceRoot, interaction.onInteractionClear);

local enableWallTimer = function(isIRT)
    if wall_timer then return end;

    wall_timer = setTimer(function()
        local player_pos = Vector3(getElementPosition(localPlayer));
        local camera = Vector3(getCameraMatrix());

        for _, vehicle in ipairs(getElementsWithinRange(player_pos.x, player_pos.y, player_pos.z, INTERACTION_DISTANCE, "vehicle")) do
            if isElement(vehicle) then
                interaction.createWallEffect(vehicle, isIRT);

                local position = Vector3(getElementPosition(localPlayer));
                local distance = getDistanceBetweenPoints2D(camera.x, camera.y, player_pos.x, player_pos.y);

                if distance < INTERACTION_DISTANCE and effect_enabled then
                    interaction.createWallEffect(vehicle, isIRT);
                end;
                if distance > INTERACTION_DISTANCE or not effect_enabled then
                    interaction.destroyShader(vehicle);
                end;
            end;
        end;

        for _, player in ipairs(getElementsWithinRange(player_pos.x, player_pos.y, player_pos.z, INTERACTION_DISTANCE, "player")) do
            if isElementStreamedIn(player) and isElement(player) then
                interaction.createWallEffect(player, isIRT);

                local position = Vector3(getElementPosition(localPlayer));
                local distance = getDistanceBetweenPoints3D(camera.x, camera.y, camera.z, player_pos.x, player_pos.y, player_pos.z);

                if distance < INTERACTION_DISTANCE and effect_enabled then
                    interaction.createWallEffect(player, isIRT);
                end;
                if distance > INTERACTION_DISTANCE or not effect_enabled then
                    interaction.destroyShader(player);
                end;
            end;
        end;

    end, 100, 0);
end;

local disableWallTimer = function()
    if wall_timer then
        killTimer(wall_timer);
        wall_timer = nil;
    end;
end;

local onClickInteraction = function(button)
    if interaction.interact_type then
        if INTERACTIONS[interaction.interact_type] == nil then
            return;
        end;
        for key, interact in ipairs(INTERACTIONS[interaction.interact_type]) do
            if button == interact.name then
                interaction.selected_interact = interact.name;
                if (interact.clientFunct ~= nil and type(interact.clientFunct) == "function") then
                    return interact.clientFunct(interaction.interact_element);
                end;
            end;
        end;
    end;
end;
addEventHandler("onInteractionClickTab", resourceRoot, onClickInteraction);

local drawInteractionTab = function(name, text, x, y, w, h, normal, hover, select, alignX, alignY)
    if tab_hover and not isMouseInPosition(tab_hover[1], tab_hover[2], tab_hover[3], tab_hover[4]) then
        tab_hover = nil;
    end;

    local color = normal or tocolor(62, 62, 62, 170);

    if isMouseInPosition(x, y, w, h) then
        tabs.hovered = name;

        if tab_hover == nil then
            playSound(":rp_gui/assets/sounds/hover.wav");
            tab_hover = {x, y, w, h};
        end;

        if getKeyState("mouse1") then
            tabs.clicked = name;
        else
            tabs.clicked = nil;
        end;

        color = getKeyState("mouse1") and select or tocolor(62, 62, 62, 205) or hovered or tocolor(255, 204, 110, 230);
        if getKeyState("mouse1") and tabs.click ~= true then
            tabs.click = true;
            playSound(":rp_gui/assets/sounds/click.wav");
        elseif not getKeyState("mouse1") and tabs.click == true then
            tabs.click = false;
        end;
    end;

    dxDrawRectangle(x, y, w, h, color);
    dxDrawText(text, x + 4, y, x + w, y + h, tocolor(255, 255, 255, 255), 1.06/zoom, interaction.fonts.light, alignX, alignY, false, false, true);
end;

interaction.getElementIcon = function(element)
    return interaction.textures.interactions[element];
end;

interaction.switchWall = function(object, isIRT)
    if object then
        interaction.enableWall(isIRT);
    else
        interaction.disableWall();
    end;
end;
addEventHandler("switchWall", resourceRoot, interaction.switchWall);

interaction.enableWall = function(isIRT)
    if isIRT and post_aura then
        render_target = dxCreateRenderTarget(screen.x, screen.y, true);
        shader = dxCreateShader("assets/fx/post_edge.fx");
        if not render_target or not shader then
            is_irt_enabled = false;
            return;
        else
            dxSetShaderValue(shader, "sTex0", render_target);
            dxSetShaderValue(shader, "sRes", screen.x, screen.y);
            is_irt_enabled = true; 
        end;
    else
        is_irt_enabled = false;
    end;
    wall_effect = true;
    enableWallTimer(is_irt_enabled);
end;

interaction.disableWall = function()
    disableWallTimer();
    wall_effect = false;
    if isElement(render_target) then
        destroyElement(render_target);
    end;
end;

interaction.createWallEffect = function(object, isIRT)
    if getElementType(object) == "player" and object == localPlayer then return end;
    if not wall_shader[object] then
        if isIRT then
            wall_shader[object] = dxCreateShader("assets/fx/ped_wall_mrt.fx", 1, 0, true, "all");
        else
            wall_shader[object] = dxCreateShader("assets/fx/ped_wall.fx", 1, 0, true, "all");
        end;
        if not wall_shader[object] then
            return false;
        else
            if render_target then
                dxSetShaderValue(wall_shader[object], "secondRT", render_target);
            end;
            if getElementType(object) == "vehicle" then
                dxSetShaderValue(wall_shader[object], "sColorizePed", {50/255, 142/255, 184/255, 1});
            elseif getElementType(object) == "player" then
                dxSetShaderValue(wall_shader[object], "sColorizePed", {50/255, 157/255, 184/255, 1});
            end;
            dxSetShaderValue(wall_shader[object], "sSpecularPower", power);
            engineApplyShaderToWorldTexture(wall_shader[object], "*", object);
            return true;
        end;
    end;
end;

interaction.destroyShader = function(object)
    if wall_shader[object] then
        engineRemoveShaderFromWorldTexture(wall_shader[object], "*", object);
        destroyElement(wall_shader[object]);
        wall_shader[object] = nil;
    end;
end;

interaction.onElementClick = function(button, state, _, _, _, _, _, element)
    if not interaction.enabled then return end;
    if element == localPlayer then return end;

    if element and state == "up" then
        if isElement(element) then
            if interaction.interact_type == nil then
                local elementPosition = Vector3(getElementPosition(element));
                local playerPosition = Vector3(getElementPosition(localPlayer));
                local distance = getDistanceBetweenPoints2D(playerPosition.x, playerPosition.y, elementPosition.x, elementPosition.y);

                if distance < INTERACTION_DISTANCE then
                    if getElementType(element) == "vehicle" and isVehicleBlown(element) then
                        exports["rp_hud"]:showNotification("Ten pojazd uległ całkowitego zniszczenia i nie podlega mu interakcja.", "error");    
                        triggerEvent("onClientInteractionClear", resourceRoot);
                        return
                    end;

                    interaction.interact_type = getElementType(element);
                    interaction.interact_element = element;
                    interaction.cursorX, interaction.cursorY = getCursorPosition();
                end;
            end;
        end;
    elseif element == nil or element == false then
        triggerEvent("onClientInteractionClear", resourceRoot);
    end;
end;

interaction.onTabClick = function(button, state)
    if button == "left" then
        if state == "up" then
            triggerEvent("onInteractionClickTab", resourceRoot, tabs.clicked);
        end;
    end;
end;

interaction.onPreRender = function()
    if not wall_effect then return end;
    if not is_irt_enabled then return end;
    if not effect_enabled then return end;

    dxSetRenderTarget(render_target, true);
    dxSetRenderTarget();
end;

interaction.onRender = function()
    if not interaction.enabled then return end;

    exports["rp_gui"]:drawBWRectangle(0, 0, screen.x, screen.y);
    exports["2dfog"]:render();
    exports["2dfog"]:color(111, 111, 111, 30);

    dxDrawImage(0, 0, screen.x, screen.y, interaction.textures.vignette, 0, 0, 0, tocolor(255, 255, 255, interaction.animations.vig_alpha));
    dxDrawImage(0, 0, screen.x, screen.y, shader, 0, 0, 0, tocolor(255, 255, 255, 255));

    dxDrawText("TRYB INTERAKCJI Z OTOCZENIEM", 0, screen.y - 160/zoom, screen.x, screen.y - 160/zoom, tocolor(222, 222, 222, 255), 1/zoom, interaction.fonts.bold_big, "center", "center");
    dxDrawText("Kliknij lewym przyciskiem myszy na podświetlony\nobiekt, aby wykonać z nim interakcję.", 0, screen.y - 100/zoom, screen.x, screen.y - 100/zoom, tocolor(222, 222, 222, 255), 1/zoom, interaction.fonts.light_tip, "center", "center");
end;

interaction.renderInteractions = function()
    if not interaction.enabled then return end;
    if interaction.interact_type == nil then return end;
    if INTERACTIONS[interaction.interact_type] == nil then return end;

    for key, interact in ipairs(INTERACTIONS[interaction.interact_type]) do
        offset = ((key - 1)) * (50/zoom);

        drawInteractionTab(interact.name, interact.action, screen.x * interaction.cursorX + 45/zoom, screen.y * interaction.cursorY + offset + 0.1/zoom, 190/zoom, 45/zoom, tocolor(51, 51, 51, 200), tocolor(81, 81, 81, 225), tocolor(100, 100, 100, 255), "left", "center");
        dxDrawRectangle(screen.x * interaction.cursorX - 0.3/zoom, screen.y * interaction.cursorY + 0.19/zoom + offset, 45/zoom, 45/zoom, tocolor(84, 80, 80, 130));
        dxDrawImage(screen.x * interaction.cursorX - 0.3/zoom, screen.y * interaction.cursorY + 0.19/zoom + offset, 45/zoom, 45/zoom, interaction.getElementIcon(interaction.interact_type), 0, 0, 0, tocolor(255, 255, 255, 255));
    end;
end;