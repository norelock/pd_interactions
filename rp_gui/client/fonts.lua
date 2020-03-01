GUI_FONTS = {} 

function loadGUIFonts()
	GUI_FONTS = {
		["normal_small"] = dxCreateFont("assets/fonts/normal.ttf", 15, false, "antialiased"),
		["normal"] = dxCreateFont("assets/fonts/normal.ttf", 20, false, "antialiased"),
		["normal_big"] = dxCreateFont("assets/fonts/normal.ttf", 30, false, "antialiased"),
		["bold_small"] = dxCreateFont("assets/fonts/bold.ttf", 15, false, "antialiased"),
		["bold"] = dxCreateFont("assets/fonts/bold.ttf", 20, false, "antialiased"),
		["bold_big"] = dxCreateFont("assets/fonts/bold.ttf", 30, false, "antialiased"),
		["light_small"] = dxCreateFont("assets/fonts/light.ttf", 15, false, "antialiased"),
		["light"] = dxCreateFont("assets/fonts/light.ttf", 20, false, "antialiased"),
		["light_big"] = dxCreateFont("assets/fonts/light.ttf", 30, false, "antialiased"),
		["gtav"] = dxCreateFont("assets/fonts/gtav.ttf", 23, false, "antialiased")
	}
end 

function getGUIFont(font)
	return GUI_FONTS[font] or "default-bold"
end