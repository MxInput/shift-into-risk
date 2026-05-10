import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "scripts/risk/riskOption"
import "scripts/gameHandler"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local container = GFX.image.new("images/skillMenu")

local titleImg = GFX.image.new("images/riskTitle")
local title

class('RiskMenu').extends(GFX.sprite)

function RiskMenu:init(x, y, char)
    RiskMenu.super.init(self)
    self:moveTo(x, y)
    self:setImage(container)
    self:setIgnoresDrawOffset(true)

    title = GFX.sprite.new(titleImg)
    title:add()

    self:setZIndex(2)

    title:moveTo(200, 30)

    title:setZIndex(3)
    title:setIgnoresDrawOffset(true)

    self.op1 = RiskOption(125, 115)
    self.op1Img = GFX.image.new(self.op1.width, self.op1.height)
    self.op1Text = GFX.sprite.new(self.op1Img)
    self.op1Text:moveTo(self.op1.x, self.op1.y)

    self.op2 = RiskOption(275, 115)
    self.op2Img = GFX.image.new(self.op2.width, self.op2.height)
    self.op2Text = GFX.sprite.new(self.op2Img)
    self.op2Text:moveTo(self.op2.x, self.op2.y)

    self.index = 2

    self.op1Text:setZIndex(4)
    self.op2Text:setZIndex(4)

    self.op1Text:setIgnoresDrawOffset(true)
    self.op2Text:setIgnoresDrawOffset(true)

    self:add()
    self.op1Text:add()
    self.op2Text:add()
end

function RiskMenu:changeSelected()
    if self.index == 1 then
        self.index = 2

        self.op2:select()
        self.op1:deselect()
    else
        self.index = 1
        self.op2:deselect()
        self.op1:select()
    end
end

function RiskMenu:drawRiskText(riskNum)
    local spacesBack = 0

    if riskNum == 1 then
        spacesBack = 2
    elseif riskNum == 2 then
        spacesBack = 4
    elseif riskNum == 3 then
        spacesBack = 7
    elseif riskNum == 4 then
        spacesBack = 10
    elseif riskNum == 5 then
        spacesBack = 13
    elseif riskNum == 6 then
        spacesBack = 15
    end

    local desc1 = "Take a detour\nGo back " .. spacesBack .. "\nspaces."
    local desc2 = ""
    local gameHandler = getGameHandler()
    if gameHandler:getChar().name == CHARACTERS.BUSINESS.name then
        desc2 = "Take a risk\n" .. riskNum .. " space(s) ahead\nof you become\nrisk spaces."
    elseif gameHandler:getChar().skill1.level == 1 then
        local actualNum = math.ceil(riskNum / 2)
        desc2 = "Take a risk\n" ..
            actualNum ..
            " space(s) ahead\nof you become\nrisk spaces\ninstead of " .. riskNum .. " due\nto your ability."
    elseif gameHandler:getChar().skill1.level == 2 then
        local actualNum = math.ceil(riskNum / 3)
        desc2 = "Take a risk\n" ..
            actualNum ..
            " space(s) ahead\nof you become\nrisk spaces\ninstead of " .. riskNum .. " due\nto your ability."
    end

    self.op1Img:clear(GFX.kColorClear)
    self.op2Img:clear(GFX.kColorClear)

    if self.index == 2 then
        GFX.lockFocus(self.op2Img)
        GFX.setImageDrawMode(GFX.kDrawModeFillWhite)
        GFX.drawTextAligned(desc2, self.op2Text.width / 2, 5, kTextAlignment.center)
        GFX.setImageDrawMode(GFX.kDrawModeCopy)
        GFX.unlockFocus()

        GFX.lockFocus(self.op1Img)
        GFX.drawTextAligned(desc1, self.op1Text.width / 2, 5, kTextAlignment.center)
        GFX.unlockFocus()
    else
        GFX.lockFocus(self.op1Img)
        GFX.setImageDrawMode(GFX.kDrawModeFillWhite)
        GFX.drawTextAligned(desc1, self.op1Text.width / 2, 5, kTextAlignment.center)
        GFX.setImageDrawMode(GFX.kDrawModeCopy)
        GFX.unlockFocus()

        GFX.lockFocus(self.op2Img)
        GFX.drawTextAligned(desc2, self.op2Text.width / 2, 5, kTextAlignment.center)
        GFX.unlockFocus()
    end
end

function RiskMenu:chooseOption(gH, n)
    local spacesBack = 0
    local currentSpace = GetSpaces()[getCar().currentSpace]

    if n == 1 then
        spacesBack = 2
    elseif n == 2 then
        spacesBack = 4
    elseif n == 3 then
        spacesBack = 7
    elseif n == 4 then
        spacesBack = 10
    elseif n == 5 then
        spacesBack = 13
    elseif n == 6 then
        spacesBack = 15
    end

    if self.index == 1 then
        gH.doing = GAMETYPES.STANDARD
        getCar():move(GetSpaces()[getCar().currentSpace - spacesBack])
    elseif self.index == 2 then
        gH.doing = GAMETYPES.RISKY
    end

    currentSpace:change(SPACESTYPE.NORM)

    self:remove()
    self.op1:remove()
    self.op1Text:remove()
    self.op2:remove()
    self.op2Text:remove()
    title:remove()
end
