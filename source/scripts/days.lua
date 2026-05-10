import "CoreLibs/sprites"
import "CoreLibs/graphics"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

class('Days').extends(GFX.sprite)

function Days:init(x, y, num)
	Days.super.init(self)
    self:moveTo(x, y)
    self:setSize(100,50)

	self.daysLeft = num  
    self:add()
end

function Days:turnEnd()
    self.daysLeft -= 1
end

function Days:inc()
    self.daysLeft += 1
end