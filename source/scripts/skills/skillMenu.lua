import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "scripts/skills/skillOption"
import "scripts/skills/skills"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local container = GFX.image.new("images/skillMenu")

local titleImg = GFX.image.new("images/skillTitle")
local title 

class('SkillMenu').extends(GFX.sprite)

function SkillMenu:init(x, y)
	SkillMenu.super.init(self)
    self:moveTo(x, y)
    self:setImage(container)
    self:setIgnoresDrawOffset(true)

    title = GFX.sprite.new(titleImg)
    title:add() 

    self:setZIndex(2)

    title:moveTo(200, 30)

    title:setZIndex(3)
    title:setIgnoresDrawOffset(true)

    self.op1 = SkillOption(125, 115)
    self.op1Img = GFX.image.new(self.op1.width, self.op1.height)
    self.op1Text = GFX.sprite.new(self.op1Img)
    self.op1Text:moveTo(self.op1.x, self.op1.y)

    self.op2 = SkillOption(275, 115)
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

local function findDesc(character)
    local matchedSkill1 = character.character.skill1.name
    local matchedSkill2 = character.character.skill2.name

    local level1 = character.character.skill1.level
    local level2 = character.character.skill2.level

    local matchedDesc1 = SKILLS[matchedSkill1].upgradeDesc
    local matchedDesc2 = SKILLS[matchedSkill2].upgradeDesc

    return matchedDesc1, matchedDesc2, level1, level2
end

function SkillMenu:changeSelected()
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

function SkillMenu:drawSkillText(character)
    local desc1, desc2, lvl1, lvl2 = findDesc(character)

    self.op1Img:clear(GFX.kColorClear)
    self.op2Img:clear(GFX.kColorClear)

    if self.index == 2 then
        if lvl2 == 1 then
            GFX.lockFocus(self.op2Img)
                GFX.setImageDrawMode(GFX.kDrawModeFillWhite)
                GFX.drawTextAligned(desc2, self.op2Text.width/2, 5, kTextAlignment.center)
                GFX.setImageDrawMode(GFX.kDrawModeCopy)
            GFX.unlockFocus()
        else
            GFX.lockFocus(self.op2Img)
                GFX.setImageDrawMode(GFX.kDrawModeFillWhite)
                GFX.drawTextAligned("You fully\nupgraded\nyour passive\nskill!", self.op2Text.width/2, 5, kTextAlignment.center)
                GFX.setImageDrawMode(GFX.kDrawModeCopy)
            GFX.unlockFocus()
        end

        if lvl1 == 1 then
            GFX.lockFocus(self.op1Img)
                GFX.drawTextAligned(desc1, self.op1Text.width/2, 5, kTextAlignment.center)
            GFX.unlockFocus()
        else
            GFX.lockFocus(self.op1Img)
                GFX.drawTextAligned("You fully\nupgraded\nyour active\nskill!", self.op1Text.width/2, 5, kTextAlignment.center)
            GFX.unlockFocus()
        end    
    else
        if lvl1 == 1 then
            GFX.lockFocus(self.op1Img)
                GFX.setImageDrawMode(GFX.kDrawModeFillWhite)
                GFX.drawTextAligned(desc1, self.op1Text.width/2, 5, kTextAlignment.center)
                GFX.setImageDrawMode(GFX.kDrawModeCopy)
            GFX.unlockFocus()
        else
            GFX.lockFocus(self.op1Img)
                GFX.setImageDrawMode(GFX.kDrawModeFillWhite)
                GFX.drawTextAligned("You fully\nupgraded\nyour active\nskill!", self.op1Text.width/2, 5, kTextAlignment.center)
                GFX.setImageDrawMode(GFX.kDrawModeCopy)
            GFX.unlockFocus()
        end

        if lvl2 == 1 then
            GFX.lockFocus(self.op2Img)
                GFX.drawTextAligned(desc2, self.op2Text.width/2, 5, kTextAlignment.center)
            GFX.unlockFocus()
        else
            GFX.lockFocus(self.op2Img)
                GFX.drawTextAligned("You fully\nupgraded\nyour passive\nskill!", self.op2Text.width/2, 5, kTextAlignment.center)
            GFX.unlockFocus()
        end       
    end
end

function SkillMenu:upgradeSkill(character)
    local desc1, desc2, lvl1, lvl2 = findDesc(character)

    if self.index == 1 and lvl1 == 1 then
        character.character.skill1.level += 1

        self:remove()
        self.op1:remove()
        self.op1Text:remove()
        self.op2:remove()
        self.op2Text:remove()
        title:remove()

        self = nil

        return true
    elseif self.index == 2 and lvl2 == 1 then
        character.character.skill2.level += 1

        self:remove()
        self.op1:remove()
        self.op1Text:remove()
        self.op2:remove()
        self.op2Text:remove()
        title:remove()

        self = nil
        return true
    end

    return false
end