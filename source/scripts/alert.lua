import "CoreLibs/sprites"
import "CoreLibs/graphics"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local container = GFX.image.new("images/alert")

class('Alert').extends(GFX.sprite)

function Alert:init(x, y, d)
    Alert.super.init(self)
    self:moveTo(x, y)
    self:setImage(container)
    self:setIgnoresDrawOffset(true)

    self.textImg = GFX.image.new(self.width, self.height)
    self.text = GFX.sprite.new(self.textImg)
    self.text:moveTo(x, y)
    self.dialog = d

    self:setZIndex(2)
    self.text:setZIndex(3)

    self:setIgnoresDrawOffset(true)
    self.text:setIgnoresDrawOffset(true)

    self:add()
    self.text:add()
end

function Alert:update()
    GFX.lockFocus(self.textImg)
    GFX.drawTextAligned(self.dialog, self.text.width / 2, self.text.height / 4, kTextAlignment.center)
    GFX.unlockFocus()
end

function Alert:rid()
    self:remove()
    self.text:remove()
end
