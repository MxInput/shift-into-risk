import "CoreLibs/sprites"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

class('Car').extends(GFX.sprite)

local image = GFX.image.new("images/car")

function Car:init(space)
    Car.super.init(self)
    self:setImage(image)
    self:moveTo(space.x + 6, space.y - 30)

    self.xVelocity = 0
    self.target = nil
    self.direction = "f"

    self.currentSpace = 1

    self:add()
end

function Car:move(space)
    self.currentSpace = space.number
    self.target = space
    if self.x > space.x then
        self.direction = "r"
        self.xVelocity = -5
    else
        self.direction = "f"
        self.xVelocity = 5
    end
end

function Car:update()
    if self.target ~= nil then
        if self.direction == "f" then
            if self.x >= self.target.x + 6 then
                self.xVelocity = 0
                self:moveTo(self.target.x + 6, self.y)
                self.target = nil
            else
                if self.xVelocity > 0 then
                    self:moveBy(self.xVelocity, 0)
                end
            end
        else
            if self.x <= self.target.x + 6 then
                self.xVelocity = 0
                self:moveTo(self.target.x + 6, self.y)
                self.target = nil
            else
                if self.xVelocity < 0 then
                    self:moveBy(self.xVelocity, 0)
                end
            end
        end
    end
end
