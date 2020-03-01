local classInstance = nil

CoreClassC = {}

function CoreClassC:constructor()

	self.maxParticles = 16
	self.fogSpeed = 5.3

	self.fogInstances = {}
	self.screenWidth, self.screenHeight = guiGetScreenSize()
	self.fogTexture = dxCreateTexture("textures/pfx_smoke_b.dds")

	for i = 1, self.maxParticles, 1 do
		if (not self.fogInstances[i]) then
			self.fogInstances[i] = new(FogC, self, self.fogTexture)
		end
	end
end

function CoreClassC:changeFogSpeed(speed)
	self.fogSpeed = speed;
	for i = 1, self.maxParticles, 1 do
		if (self.fogInstances[i]) then
			self.fogInstances[i]:update()
		end
	end
end

function CoreClassC:renderFog(x, y, w, h, color, postgui)
	for i = 1, self.maxParticles, 1 do
		if (self.fogInstances[i]) then
			self.fogInstances[i]:update()
		end
	end
	--dxSetBlendMode("modulate_add")
	--dxSetBlendMode("blend")
end

function CoreClassC:destructor()
	for i = 1, self.maxParticles, 1 do
		if (self.fogInstances[i]) then
			delete(self.fogInstances[i])
			self.fogInstances[i] = nil
		end
	end
	if (self.fogTexture) then
		self.fogTexture:destroy()
		self.fogTexture = nil
	end
end

addEventHandler("onClientResourceStart", resourceRoot,
function()
	classInstance = new(CoreClassC)
end)

function speed(c)
	return classInstance:changeFogSpeed(c)
end

function render()
	return classInstance:renderFog()
end

function reload()
	if (classInstance) then
		delete(classInstance)
		classInstance = nil
	end
	classInstance = new(CoreClassC)
end

addEventHandler("onClientResourceStop", resourceRoot,
function()
	if (classInstance) then
		delete(classInstance)
		classInstance = nil
	end
end)
