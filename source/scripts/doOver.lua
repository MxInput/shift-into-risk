import "CoreLibs/sprites"
import "CoreLibs/graphics"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local container = GFX.image.new("images/container")
local selectedContainer = GFX.image.new("images/selectedContainer")

class('DoOver').extends(GFX.sprite)

function DoOver:init(x, y)
	DoOver.super.init(self)
    self:moveTo(x, y)
    self:setImage(container)
    self:setIgnoresDrawOffset(true)

	self.done = false
    self:add()
end

function DoOver:doOver(car, dice, days)
    if not self.done then
        self.done = true

        car.currentSpace = car.currentSpace - dice.number
        car:move(GetSpaces()[car.currentSpace])
        days:inc()

        setDoOverStatus("Already Done")
    else
        setDoOverStatus("Do Over")
    end
end

function DoOver:select()
    self:setImage(selectedContainer)
end

function DoOver:deselect()
    self:setImage(container)
end