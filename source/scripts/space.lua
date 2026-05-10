import "CoreLibs/sprites"

import "scripts/setupBoard"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local sImg = GFX.imagetable.new("images/spaces")

SPACESTYPE = {
    NORM = {
		category = "Normal",
		img = sImg:getImage(2)
	},
	SKILL = {
		category = "Skill",
		img = sImg:getImage(3)
	},
	REPEAT = {
		category = "Do-over",
		img = sImg:getImage(4)
	},
	RISK = {
		category = "Risk",
		img = sImg:getImage(1)
	},
	CHOOSE = {
		category = "Choose",
		img = sImg:getImage(5)
	}
}

class('Space').extends(GFX.sprite)

function Space:init(x, y, num, type)
	Space.super.init(self)
	self:moveTo(x, y)
	
	self.number = num
	self.type = type

	self:setImage(type.img)

	self:add()

	insertSpace(self)
end

function Space:change(type)
	self.type = type
	self:setImage(type.img)
end

function GetType(num)
	return GetSpaces()[num].type
end
