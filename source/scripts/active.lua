import "CoreLibs/sprites"
import "CoreLibs/graphics"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local container = GFX.image.new("images/container")
local selectedContainer = GFX.image.new("images/selectedContainer")

class('Active').extends(GFX.sprite)

function Active:init(x, y)
	Active.super.init(self)
    self:moveTo(x, y)
    self:setImage(container)
    self:setIgnoresDrawOffset(true)

	self.done = false
    self:add()
end

function Active:activate()
    if not self.done then
        self.done = true
    else
       
    end
end

function Active:select()
    self:setImage(selectedContainer)
end

function Active:deselect()
    self:setImage(container)
end