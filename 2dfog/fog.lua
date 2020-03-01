local classInstance = nil

FogC = {}

r, g, b, a = 115, 115, 115, 0

function FogC:constructor(parent, fogTexture)
	self.parent = parent
	self.screenWidth, self.screenHeight = guiGetScreenSize()
	self.fogTexture = fogTexture
	self.size = self.screenHeight * 2.3
	self.x = math.random(0 - self.size, self.screenWidth + self.size)
	self.y = math.random(0 - self.size, self.screenHeight + self.size)
	self.moveSpeed = math.random(0, 100) / (900 / self.parent.fogSpeed)
	self.moveXDirection = 2
	self.moveYDirection = 1
	self.rotation = math.random(0, 360)
	self.rotSpeed = math.random(0, 50) / (900 / self.parent.fogSpeed)
	self.rotDirection = 2
end

function FogC:update()
	if (self.fogTexture) then
		if (self.rotDirection == 1) then
			self.rotation = self.rotation + self.rotSpeed
			if (self.rotation > 360) then
				self.rotation = 0
			end
		elseif (self.rotDirection == 2) then
			self.rotation = self.rotation - self.rotSpeed
			if (self.rotation < 0) then
				self.rotation = 360
			end
		end
		if (self.moveXDirection == 1) then
			self.x = self.x + self.moveSpeed
			if (self.x > self.screenWidth) then
				self.x = 0 - self.size
			end
		elseif (self.moveXDirection == 2) then
			self.x = self.x - self.moveSpeed
			if (self.x < 0 - self.size) then
				self.x = self.screenWidth + self.size
			end
		end
		if (self.moveYDirection == 1) then
			self.y = self.y + self.moveSpeed
			if (self.y > self.screenHeight) then
				self.y = 0 - self.size
			end
		elseif (self.moveYDirection == 2) then
			self.y = self.y - self.moveSpeed
			if (self.y < 0 - self.size) then
				self.y = self.screenHeight + self.size
			end
		end
		dxSetBlendMode("modulate_add")
		dxDrawImage(self.x/2, self.y/2, self.size, self.size, self.fogTexture, self.rotation, 0, 0, tocolor(r, g, b, a))
		dxSetBlendMode("blend")
	end
end

function FogC:destructor()

end

function color(a1, a2, a3, a4)
	r, g, b, a = a1, a2, a3, a4
end
