local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local optionImg = GFX.image.new("images/skillOption")
local selectOpImg = GFX.image.new("images/selectedSkillOption")

class('SkillOption').extends(GFX.sprite)

function SkillOption:init(x, y)
	SkillOption.super.init(self)

    self:setImage(optionImg)
    self:setIgnoresDrawOffset(true)
    self:moveTo(x, y)

    self:setZIndex(3)

    self:add()
end

function SkillOption:select()
    self:setImage(selectOpImg)
end

function SkillOption:deselect()
    self:setImage(optionImg)
end