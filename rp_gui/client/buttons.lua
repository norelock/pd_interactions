local buttonID = 0 
local activeButton, prevActiveButton = false, false
local clickedButton = false

addEvent("onClientClickButton", true)
addEvent("onClientHoverButton", true)

local isTriangleMouse = function(x1, y1, x2, y2, x3, y3, px, py)
	local areaOrig = math.abs( (x2-x1)*(y3-y1) - (x3-x1)*(y2-y1) )
	local area1 = math.abs( (x1-px)*(y2-py) - (x2-px)*(y1-py) );
	local area2 = math.abs( (x2-px)*(y3-py) - (x3-px)*(y2-py) );
	local area3 = math.abs( (x3-px)*(y1-py) - (x1-px)*(y3-py) );
	if (area1 + area2 + area3 == areaOrig) then
		return true
	else
		return false
	end
end

local hexagonColission = function(posX, posY, Size, Angel)
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	local lastX = nil
	local lastY = nil
	local points = {}
	for i=0,6 do
		local angle = Angel+(2 * math.pi / 6 * (i + 0.5) )
		local x = posX + Size * math.cos(angle)
		local y = posY + Size * math.sin(angle)
		if i > 0 then
			--dxDrawText(i, lastX, lastY, 100, 100, tocolor(255, 255, 255, 255) )
			--dxDrawLine(lastX, lastY, x, y, tocolor(255, 0, 0, 255))
		end
		points[i+1] = { Vector2(lastX, lastY), Vector2(x, y) }
		lastX = x
		lastY = y
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cursor = Vector2(cx * sx, cy * sy)
	local toggle = false
	if isTriangleMouse(points[6][2].x, points[6][2].y, points[2][2].x, points[2][2].y, points[3][2].x, points[3][2].y, cursor.x, cursor.y) or isTriangleMouse(points[3][2].x, points[3][2].y, points[4][2].x, points[4][2].y, points[5][2].x, points[5][2].y, cursor.x, cursor.y) or isTriangleMouse(points[2][2].x, points[2][2].y, points[6][2].x, points[6][2].y, points[1][2].x, points[1][2].y, cursor.x, cursor.y) or isTriangleMouse(points[6][2].x, points[6][2].y, points[3][2].x, points[3][2].y, points[5][2].x, points[5][2].y, cursor.x, cursor.y) then
		toggle = true
	end
	--dxDrawLine(points[3][2].x, points[3][2].y, points[4][2].x, points[4][2].y, toggle and tocolor(255, 0, 0, 255) or tocolor(0, 255, 0, 255), 2.0)
	--dxDrawLine(points[4][2].x, points[4][2].y, points[5][2].x, points[5][2].y, toggle and tocolor(255, 0, 0, 255) or tocolor(0, 255, 0, 255), 2.0)
	--dxDrawLine(points[5][2].x, points[5][2].y, points[3][2].x, points[3][2].y, toggle and tocolor(255, 0, 0, 255) or tocolor(0, 255, 0, 255), 2.0)
	--dxDrawLine(points[6][2].x, points[6][2].y, points[3][2].x, points[3][2].y, toggle and tocolor(255, 0, 0, 255) or tocolor(0, 255, 0, 255), 2.0)
	--dxDrawLine(points[3][2].x, points[3][2].y, points[5][2].x, points[5][2].y, toggle and tocolor(255, 0, 0, 255) or tocolor(0, 255, 0, 255), 2.0)
	--dxDrawLine(points[5][2].x, points[5][2].y, points[6][2].x, points[6][2].y, toggle and tocolor(255, 0, 0, 255) or tocolor(0, 255, 0, 255), 2.0)
	--dxDrawLine(points[2][2].x, points[2][2].y, points[6][2].x, points[6][2].y, toggle and tocolor(255, 0, 0, 255) or tocolor(0, 255, 0, 255), 2.0)
	--dxDrawLine(points[1][2].x, points[1][2].y, points[2][2].x, points[2][2].y, toggle and tocolor(255, 0, 0, 255) or tocolor(0, 255, 0, 255), 2.0)
	--dxDrawLine(points[1][2].x, points[1][2].y, points[6][2].x, points[6][2].y, toggle and tocolor(255, 0, 0, 255) or tocolor(0, 255, 0, 255), 2.0)
	--dxDrawLine(points[2][2].x, points[2][2].y, points[3][2].x, points[3][2].y, toggle and tocolor(255, 0, 0, 255) or tocolor(0, 255, 0, 255), 2.0)
	--dxDrawLine(points[3][2].x, points[3][2].y, points[6][2].x, points[6][2].y, toggle and tocolor(255, 0, 0, 255) or tocolor(0, 255, 0, 255), 2.0)
	--dxDrawLine(points[6][2].x, points[6][2].y, points[2][2].x, points[2][2].y, toggle and tocolor(255, 0, 0, 255) or tocolor(0, 255, 0, 255), 2.0)
	return toggle
end

function createButton(text, x, y, w, h)
	if text and x and y and w and h then 
		buttonID = buttonID + 1
		local el = createElement("button", "button"..tostring(buttonID)) 
		setElementData(el, "data", {text=text, 
													x=x, 
													y=y,
													w=w, 
													h=h,
													colission="mouse",
													postgui = false,
													font="default-bold",
													fontSize=1.0,
													enabled=true}, false)
		return el
	end
end

function destroyButton(button)
	if isElement(button) and getElementType(button) == "button" then 
		destroyElement(button)
	end
end 

function getButtonPosition(button)
	if isElement(button) then 
		data = getElementData(button, "data")
		return data.x, data.y, data.w, data.h
	end
end

function getButtonTextures(button)
	if isElement(button) then
		data = getElementData(button, "data")
		return data.textures
	end
end

function setButtonColission(button, colission)
	if isElement(button) and type(colission) == "string" then
		data = getElementData(button, "data")
		data.colission = colission
		setElementData(button, "data", data, false)
	end
end

function setButtonText(button, text)
	if isElement(button) and type(text) == "string" then
		data = getElementData(button, "data")
		data.text = text
		setElementData(button, "data", data, false)
	end
end

function setButtonPostGui(button, state)
	if isElement(button) and type(state) == "boolean" then
		data = getElementData(button, "data")
		data.postgui = state
		setElementData(button, "data", data, false)
	end
end

function setButtonEnabled(button, state)
	if isElement(button) and type(state) == "boolean" then 
		data = getElementData(button, "data")
		data.enabled = state
		setElementData(button, "data", data, false)
	end
end 

function setButtonTextures(button, textures)
	if isElement(button) and type(textures) == "table" then
		data = getElementData(button, "data")
		data.textures = textures 
		setElementData(button, "data", data, false)
	end
end

function setButtonTexturesColor(button, color)
	if isElement(button) and color then
		data = getElementData(button, "data")
		data.texturesColor = color 
		setElementData(button, "data", data, false)
	end
end 

function setButtonFont(button, font, fontSize)
	if isElement(button) and font and fontSize then 
		data = getElementData(button, "data")
		data.font = font 
		data.fontSize = fontSize
		setElementData(button, "data", data, false)
	end
end

function setButtonPosition(button, x, y, w, h)
	if isElement(button) and x then 
		data = getElementData(button, "data")
		data.x = x 
		if y then data.y = y end
		if w then data.w = w end 
		if h then data.h = h end 
		setElementData(button, "data", data, false)
	end
end 

function isButtonHovered(button)
	return activeButton == button
end

function isButtonClicked(button)
	return clickedButton == button
end

function renderButton(button)
	if isElement(button) then
		local buttonData = getElementData(button, "data")

		if buttonData.enabled then
			if buttonData.colission == "mouse" then
				if isCursorOnElement(buttonData.x, buttonData.y, buttonData.w, buttonData.h) then 
					activeButton = button
					if activeButton ~= prevActiveButton then 
						playHoverSound()
						triggerEvent("onClientHoverButton", button)
					end 
					
					prevActiveButton = button
				else 
					if activeButton == button then 
						activeButton = false
						prevActiveButton = false
					end
				end
			elseif buttonData.colission == "hexagon" then
				if hexagonColission(buttonData.x + buttonData.w/2, buttonData.y + buttonData.h/2, buttonData.w/2, 55) then
					activeButton = button
					if activeButton ~= prevActiveButton then 
						playHoverSound()
						triggerEvent("onClientHoverButton", button)
					end 
					
					prevActiveButton = button
				else
					if activeButton == button then 
						activeButton = false
						prevActiveButton = false
					end
				end
			end
		end
		local type = "default"
		if activeButton == button then 
			type = "hover"
		end 
		if clickedButton == button then 
			type = "press"
		end 
		if buttonData.enabled == false then 
			type = "default"
		end 
		if buttonData.textures then
			dxDrawImage(buttonData.x, buttonData.y, buttonData.w, buttonData.h, buttonData.textures[type], 0, 0, 0, buttonData.texturesColor or tocolor(255, 255, 255, 255))
		end 
		dxDrawText(buttonData.text, buttonData.x, buttonData.y, buttonData.x+buttonData.w, buttonData.y+buttonData.h, buttonData.texturesColor or tocolor(255, 255, 255, 255), buttonData.fontSize, buttonData.font, "center", "center", false, false, buttonData.postgui or false)
	end
end 

function onClientClickButton(button, state)
	if button == "left" and state == "up" then
		if isElement(clickedButton) then 
			local buttonData = getElementData(clickedButton, "data")
			if buttonData.enabled then
				if buttonData.colission == "mouse" then
					if isCursorOnElement(buttonData.x, buttonData.y, buttonData.w, buttonData.h) then 
						triggerEvent("onClientClickButton", clickedButton)
						clickedButton = false
						
						playClickSound()
					else 
						activeButton = false 
						clickedButton = false
					end
				elseif buttonData.colission == "hexagon" then
					if hexagonColission(buttonData.x + buttonData.w/2, buttonData.y + buttonData.h/2, buttonData.w/2, 55) and buttonData.colission == "hexagon" and buttonData.enabled then 
						triggerEvent("onClientClickButton", clickedButton)
						clickedButton = false
						
						playClickSound()
					else 
						activeButton = false 
						clickedButton = false
					end
				end
			end
		end
	elseif button == "left" and state == "down" then
		if isElement(activeButton) then 
			local buttonData = getElementData(activeButton, "data")
			if buttonData.colission == "mouse" then
				if isCursorOnElement(buttonData.x, buttonData.y, buttonData.w, buttonData.h) then 
					clickedButton = activeButton
				else 
					activeButton = false 
					clickedButton = false
				end
			elseif buttonData.colission == "hexagon" then
				if hexagonColission(buttonData.x + buttonData.w/2, buttonData.y + buttonData.h/2, buttonData.w/2, 55) then 
					clickedButton = activeButton
				else 
					activeButton = false 
					clickedButton = false
				end
			end
		end 
	end 
end