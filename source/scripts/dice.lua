import "CoreLibs/sprites"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local images = GFX.imagetable.new("images/dice/dice")

class('Dice').extends(GFX.sprite)

local car

function Dice:init(x, y, num)
	Dice.super.init(self)
	self:moveTo(x, y)

	self.number = num

	self:setImage(images:getImage(num))

	self:add()

    car = getCar()
end

function Dice:roll()
    local randNum = math.random(1, 6)

    self.number = randNum
    self:setImage(images:getImage(randNum))
end

function Dice:update()
    self:moveTo(car.x, self.y)
end