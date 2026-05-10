local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

class('CharButton').extends(GFX.sprite)

local img = GFX.image.new("images/charContainer")
local selectedImg = GFX.image.new("images/charContainerSelected")

function CharButton:init(x, y, c)
	CharButton.super.init(self)
	self:setImage(img)
	self:moveTo(x, y)
	self.character = c

	self:add()
end

function CharButton:select()
	self:setImage(selectedImg)
end

function CharButton:deselect()
	self:setImage(img)
end
