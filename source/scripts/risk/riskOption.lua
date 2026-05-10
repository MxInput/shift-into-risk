local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local optionImg = GFX.image.new("images/skillOption")
local selectOpImg = GFX.image.new("images/selectedSkillOption")

class('RiskOption').extends(GFX.sprite)

function RiskOption:init(x, y)
	RiskOption.super.init(self)

    self:setImage(optionImg)
    self:setIgnoresDrawOffset(true)
    self:moveTo(x, y)

    self:setZIndex(3)

    self:add()
end

function RiskOption:select()
    self:setImage(selectOpImg)
end

function RiskOption:deselect()
    self:setImage(optionImg)
end