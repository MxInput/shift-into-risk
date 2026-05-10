import "CoreLibs/sprites"
import "CoreLibs/crank"
import "CoreLibs/graphics"
import "CoreLibs/timer"

import "scripts/setupBoard"
import "scripts/car"
import "scripts/dice"
import "scripts/characterSelect/character"
import "scripts/days"
import "scripts/doOver"
import "scripts/active"
import "scripts/skills/skillMenu"
import "scripts/risk/riskMenu"
import "scripts/risk/punishment"
import "scripts/alert"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local maxTurns = 30
local playerTurn = true

local spaces
local firstSpace

local car
local dice
local character

local days
local dTImg
local daysText

local tokImg
local tokens

local doOver
local doOverStatus = "Do Over"
local doOverImg
local doOverText

local active
local aStatus
local activeImg
local activeText

local skillMenu
local riskMenu

local temps = {}
local tempTypes = {}

local numRisk = 0

local plus1Img = GFX.image.new("images/plus1")
local plus2Img = GFX.image.new("images/plus2")
local plus = GFX.sprite.new(plus1Img)

local tokenAlert = GFX.image.new("images/tokenAlert")
local tASprite = GFX.sprite.new(tokenAlert)
tASprite:setIgnoresDrawOffset(true)

local menu = PLAYDATE.getSystemMenu()

local riskLose = GFX.image.new("images/screens/loseScreen1")
local daysLose = GFX.image.new("images/screens/loseScreen2")
local winScreen = GFX.image.new("images/screens/winScreen")

local loseSound = PLAYDATE.sound.sampleplayer.new("samples/lose")
local pushbackSound = PLAYDATE.sound.sampleplayer.new("samples/pushback")
local skillSound = PLAYDATE.sound.sampleplayer.new("samples/skill")
local winSound = PLAYDATE.sound.sampleplayer.new("samples/win")
local tokenSound = PLAYDATE.sound.sampleplayer.new("samples/token")

local finalScreen

local endTimer

class('GameHandler').extends(GFX.sprite)

GAMETYPES = {
    SKILL = "SKILL",
    STANDARD = "STANDARD",
    RISKY = "RISKY",
    CHOOSE = "CHOOSE",
    PUNISHMENT = "PUNISHMENT",
    LOSE = "LOSE",
    WIN = "WIN",
    WAIT = "WAIT"
}

local function clear(tbl)
    for i, v in ipairs(tbl) do table.remove(tbl, i) end
end

function GameHandler:init(c)
    InitializeSpaces()

    spaces = GetSpaces()
    firstSpace = spaces[1]

    car = Car(firstSpace)

    dice = Dice(30, 30, 1)

    days = Days(320, 40, 30)
    days:setIgnoresDrawOffset(true)
    dTImg = GFX.image.new(days.width, days.height)
    daysText = GFX.sprite.new(dTImg)
    daysText:setIgnoresDrawOffset(true)
    daysText:add()
    daysText:moveTo(days.x, days.y)

    doOver = DoOver(100, 215)

    character = c

    tokImg = GFX.image.new(dTImg.width, dTImg.height)
    tokens = GFX.sprite.new(tokImg)
    tokens:setIgnoresDrawOffset(true)
    tokens:add()
    tokens:moveTo(daysText.x - 250, daysText.y)

    doOverImg = GFX.image.new(doOver.width, doOver.height)
    doOverText = GFX.sprite.new(doOverImg)
    doOverText:setIgnoresDrawOffset(true)
    doOverText:add()
    doOverText:moveTo(doOver.x, doOver.y)

    if character.character.name == CHARACTERS.BUSINESS.name then
        active = Active(300, 215)

        activeImg = GFX.image.new(active.width, active.height)
        activeText = GFX.sprite.new(activeImg)
        activeText:setIgnoresDrawOffset(true)
        activeText:add()
        activeText:moveTo(active.x, active.y)

        self.selected = 2
        self:changeSelected()
    else
        self.selected = 1
    end

    aStatus = character.character.skill1.name

    self.turnsLeft = maxTurns

    self.doing = GAMETYPES.STANDARD
    self.waitedSpace = nil
    self.waitingOn = nil
    self.usedAbility = false

    self.alert = nil

    self:add()

    self.justUsed = false

    if character.character == CHARACTERS.BUSINESS then
        plus:add()
    end
    tASprite:moveTo(275, days.y + 10)
end

function GameHandler:update()
    plus:moveTo(car.x + 40, dice.y)

    local ticksPerRevolution = 1
    local crankTicks = PLAYDATE.getCrankTicks(ticksPerRevolution)

    GFX.setDrawOffset(-car.x + 140, 0)

    local offX, offY = GFX.getDrawOffset()

    if car.currentSpace == 1 or character.tokens <= 0 or self.usedAbility then
        doOverStatus = "Cannot Use"
    end

    dTImg:clear(GFX.kColorClear)
    GFX.lockFocus(dTImg)
    GFX.drawText("Days: " .. days.daysLeft, 0, 0)
    GFX.unlockFocus()

    tokImg:clear(GFX.kColorClear)
    GFX.lockFocus(tokImg)
    GFX.drawText("Tokens: " .. character.tokens, 0, 0)
    GFX.unlockFocus()

    if character.character.name == CHARACTERS.BUSINESS.name then
        doOverImg:clear(GFX.kColorClear)
        GFX.lockFocus(doOverImg)
        if self.selected == 1 then
            GFX.setImageDrawMode(GFX.kDrawModeFillWhite)
            GFX.drawTextAligned(doOverStatus, doOverText.width / 2, doOverText.height / 3, kTextAlignment.center)
            GFX.setImageDrawMode(GFX.kDrawModeCopy)
        else
            GFX.drawTextAligned(doOverStatus, doOverText.width / 2, doOverText.height / 3, kTextAlignment.center)
        end
        GFX.unlockFocus()

        activeImg:clear(GFX.kColorClear)
        GFX.lockFocus(activeImg)
        if self.selected == 2 then
            GFX.setImageDrawMode(GFX.kDrawModeFillWhite)
            GFX.drawTextAligned(aStatus, activeText.width / 2, activeText.height / 3, kTextAlignment.center)
            GFX.setImageDrawMode(GFX.kDrawModeCopy)
        else
            GFX.drawTextAligned(aStatus, activeText.width / 2, activeText.height / 3, kTextAlignment.center)
        end
        GFX.unlockFocus()
    else
        doOver:select()
        doOverImg:clear(GFX.kColorClear)
        GFX.lockFocus(doOverImg)
        GFX.setImageDrawMode(GFX.kDrawModeFillWhite)
        GFX.drawTextAligned(doOverStatus, doOverText.width / 2, doOverText.height / 3, kTextAlignment.center)
        GFX.setImageDrawMode(GFX.kDrawModeCopy)
        GFX.unlockFocus()
    end

    if days.daysLeft > 0 then
        if playerTurn then
            if crankTicks == 1 or crankTicks == -1 then
                tASprite:remove()

                self.usedAbility = false

                doOverStatus = "Do Over"

                self.justUsed = false
                playerTurn = false
                dice:roll()

                local newNum = car.currentSpace + dice.number

                if character.character == CHARACTERS.BUSINESS and character.character.skill2.level == 1 then
                    newNum += 1
                elseif character.character == CHARACTERS.BUSINESS and character.character.skill2.level == 2 then
                    local chance = math.random(1, 100)
                    if chance <= 30 then
                        newNum += 2
                        plus:setImage(plus2Img)
                    else
                        newNum += 1
                        plus:setImage(plus1Img)
                    end
                end

                if character.character == CHARACTERS.FORTUNE and character.character.skill2.level == 1 then
                    local chance = math.random(1, 100)
                    if chance <= 33 then
                        if character.tokens < 3 then
                            tokenSound:play(1)

                            character.tokens += 1
                            tASprite:add()
                        end
                    end
                elseif character.character == CHARACTERS.FORTUNE and character.character.skill2.level == 2 then
                    local chance = math.random(1, 100)
                    if chance <= 50 then
                        if character.tokens < 3 then
                            tokenSound:play(1)

                            character.tokens += 1
                            tASprite:add()
                        end
                    end
                end

                local newSpace = spaces[newNum]

                if self.alert ~= nil then
                    self.alert:rid()
                    self.alert = nil
                end

                if newNum <= #spaces then
                    car:move(newSpace)
                else
                    newSpace = spaces[#spaces]
                    newNum = 100
                    car:move(newSpace)
                end

                if car.currentSpace == 1 or character.tokens <= 0 then
                    doOverStatus = "Cannot Use"
                end

                if newNum == 100 then
                    self.doing = GAMETYPES.WAIT
                    self.waitingOn = GAMETYPES.WIN
                end

                if #temps > 0 then
                    doOverStatus = "Cannot Use"

                    self.doing = GAMETYPES.WAIT
                    self.waitingOn = SPACESTYPE.RISK
                    self.waitedSpace = GetType(newNum)
                elseif self.doing ~= GAMETYPES.WAIT then
                    if GetType(newNum) == SPACESTYPE.CHOOSE then
                        doOverStatus = "Cannot Use"

                        self.doing = GAMETYPES.WAIT
                        self.waitingOn = SPACESTYPE.CHOOSE
                        self.waitedSpace = newNum
                    elseif GetType(newNum) == SPACESTYPE.SKILL then
                        if character.character.skill1.level < 2 or character.character.skill2.level < 2 then
                            doOverStatus = "Cannot Use"

                            self.doing = GAMETYPES.WAIT
                            self.waitingOn = SPACESTYPE.SKILL
                        end
                    elseif GetType(newNum) == SPACESTYPE.REPEAT then
                        if character.tokens < 3 then
                            doOverStatus = "Cannot Use"

                            self.doing = GAMETYPES.WAIT
                            self.waitingOn = SPACESTYPE.REPEAT
                            self.waitedSpace = newSpace
                        end
                    end
                end
            end
        elseif car.target == nil and car.xVelocity == 0 and self.doing == GAMETYPES.STANDARD then
            days:turnEnd()
            playerTurn = true
        end
    elseif self.doing ~= GAMETYPES.LOSE then
        if car.target == nil and car.xVelocity == 0 then
            if endTimer == nil then
                endTimer = PLAYDATE.timer.new(1000, function()
                    inGameMusic:stop()

                    loseSound:play(1)
                    self.doing = GAMETYPES.LOSE

                    finalScreen = GFX.sprite.new(daysLose)
                    finalScreen:setIgnoresDrawOffset(true)
                    finalScreen:moveTo(200, 120)
                    finalScreen:add()
                end)
            end
        end
    end

    if self.doing == GAMETYPES.SKILL then
        doOverStatus = "Cannot Use"

        skillMenu:drawSkillText(character)
    elseif self.doing == GAMETYPES.PUNISHMENT then
        pushbackSound:play(1)
        doOverStatus = "Cannot Use"

        local punishment = self:findPunishment()

        if punishment == PUNISHMENTS.END then
            inGameMusic:stop()

            loseSound:play(1)
            self.doing = GAMETYPES.LOSE

            finalScreen = GFX.sprite.new(riskLose)
            finalScreen:setIgnoresDrawOffset(true)
            finalScreen:moveTo(200, 120)
            finalScreen:add()
        elseif punishment == PUNISHMENTS.GOBACK then
            local spacesBack = 0

            if numRisk == 1 then
                spacesBack = 4
            elseif numRisk == 2 then
                spacesBack = 6
            elseif numRisk == 3 then
                spacesBack = 9
            elseif numRisk == 4 then
                spacesBack = 12
            elseif numRisk == 5 then
                spacesBack = 15
            elseif numRisk == 6 then
                spacesBack = 18
            end

            local finalSpace = getCar().currentSpace - spacesBack
            if finalSpace < 1 then
                finalSpace = 1
            end
            self.alert = Alert(200, 175, "Moved back " .. spacesBack .. " spaces")

            car:move(spaces[finalSpace])
            self.doing = GAMETYPES.STANDARD
        elseif punishment == PUNISHMENTS.LOSELEVEL then
            self.alert = Alert(200, 175, "Skill level down (only if already upgraded)")
            if character.character.skill1.level > 1 then
                character.character.skill1.level -= 1
            elseif character.character.skill2.level > 1 then
                character.character.skill2.level -= 1
            end
            self.doing = GAMETYPES.STANDARD
        elseif punishment == PUNISHMENTS.TOKEN then
            self.alert = Alert(200, 175, "Lost a token (if you had any)")
            if character.tokens > 0 then
                character.tokens -= 1
            end
            self.doing = GAMETYPES.STANDARD
        end
    elseif self.doing == GAMETYPES.WAIT then
        if self.waitingOn == SPACESTYPE.REPEAT then
            doOverStatus = "Cannot Use"
            if car.target == nil and car.xVelocity == 0 then
                tokenSound:play(1)
                character:gainToken()
                self.waitedSpace:change(SPACESTYPE.NORM)

                self.waitingOn = nil
                self.waitedSpace = nil
                self.doing = GAMETYPES.STANDARD
            end
        elseif self.waitingOn == SPACESTYPE.SKILL then
            doOverStatus = "Cannot Use"
            if car.target == nil and car.xVelocity == 0 then
                skillSound:play(1)
                skillMenu = SkillMenu(200, 100)
                skillMenu:changeSelected(character)
                self.doing = GAMETYPES.SKILL
            end
        elseif self.waitingOn == SPACESTYPE.CHOOSE then
            doOverStatus = "Cannot Use"
            if car.target == nil and car.xVelocity == 0 then
                local newNum = self.waitedSpace
                riskMenu = RiskMenu(200, 100)
                riskMenu:changeSelected()
                self.doing = GAMETYPES.CHOOSE

                clear(temps)
                clear(tempTypes)

                if newNum >= 1 and newNum <= 20 then
                    numRisk = 1
                elseif newNum >= 21 and newNum <= 34 then
                    numRisk = 2
                elseif newNum >= 35 and newNum <= 50 then
                    numRisk = 3
                elseif newNum >= 51 and newNum <= 72 then
                    numRisk = 4
                elseif newNum >= 73 and newNum <= 81 then
                    numRisk = 5
                elseif newNum >= 82 and newNum <= 98 then
                    numRisk = 6
                end
                self.waitingOn = nil
                self.waitedSpace = nil
            end
        elseif self.waitingOn == GAMETYPES.WIN then
            if car.target == nil and car.xVelocity == 0 then
                inGameMusic:stop()
                winSound:play(1)
                self.doing = GAMETYPES.WIN

                finalScreen = GFX.sprite.new(winScreen)
                finalScreen:setIgnoresDrawOffset(true)
                finalScreen:moveTo(200, 120)
                finalScreen:add()
            end
        elseif type(self.waitingOn) == "number" then
            if car.target == nil and car.xVelocity == 0 then
                if self.waitingOn < self.waitedSpace then
                    inGameMusic:stop()
                    loseSound:play(1)
                    self.doing = GAMETYPES.LOSE

                    finalScreen = GFX.sprite.new(riskLose)
                    finalScreen:setIgnoresDrawOffset(true)
                    finalScreen:moveTo(200, 120)
                    finalScreen:add()
                else
                    self.doing = GAMETYPES.STANDARD
                end
            end
        elseif self.waitingOn == SPACESTYPE.RISK then
            doOverStatus = "Cannot Use"
            if car.target == nil and car.xVelocity == 0 then
                for i = 1, #temps do
                    local riskSpace = temps[1]
                    riskSpace:change(tempTypes[i])
                    table.remove(temps, 1)
                end

                if self.waitedSpace == SPACESTYPE.REPEAT then
                    if character.tokens < 3 then
                        self.waitingOn = SPACESTYPE.REPEAT
                        self.waitedSpace = spaces[car.currentSpace]
                    else
                        self.doing = GAMETYPES.STANDARD
                    end
                elseif self.waitedSpace == SPACESTYPE.SKILL then
                    if character.character.skill1.level == 1 or character.character.skill2.level == 1 then
                        self.waitingOn = SPACESTYPE.SKILL
                    else
                        self.doing = GAMETYPES.STANDARD
                    end
                elseif self.waitedSpace == SPACESTYPE.RISK then
                    self.doing = GAMETYPES.PUNISHMENT
                else
                    self.doing = GAMETYPES.STANDARD
                end
            end
        end
    elseif self.doing == GAMETYPES.CHOOSE then
        doOverStatus = "Cannot Use"
        riskMenu:drawRiskText(numRisk)
    elseif self.doing == GAMETYPES.RISKY then
        doOverStatus = "Cannot Use"
        local newNum = car.currentSpace

        local minimum = 93

        if character.character.name == CHARACTERS.FORTUNE.name then
            if character.character.skill1.level == 1 then
                minimum = 96
            elseif character.character.skill1.level == 2 then
                minimum = 97
            end
        end

        if newNum >= minimum then
            local finalRiskCount = 99 - newNum

            for i = 1, finalRiskCount do
                local nextNum = i + newNum
                table.insert(temps, spaces[nextNum])
                table.insert(tempTypes, spaces[nextNum])
                spaces[nextNum]:change(SPACESTYPE.RISK)
            end
        else
            local count = 0

            if character.character.name == CHARACTERS.BUSINESS.name then
                while count < numRisk do
                    local pos = math.random(1, 6)
                    local notFound = true

                    local riskNum = newNum + pos
                    local riskSpace = spaces[riskNum]

                    for i, val in ipairs(temps) do
                        if val == riskSpace then
                            notFound = false
                            break;
                        end
                    end

                    if notFound then
                        table.insert(temps, riskSpace)
                        table.insert(tempTypes, GetType(riskNum))

                        riskSpace:change(SPACESTYPE.RISK)
                        count += 1
                    end
                end
            elseif character.character.skill1.level == 1 then
                while count < math.ceil(numRisk / 2) do
                    local pos = math.random(1, 6)
                    local notFound = true

                    local riskNum = newNum + pos
                    local riskSpace = spaces[riskNum]

                    for i, val in ipairs(temps) do
                        if val == riskSpace then
                            notFound = false
                            break;
                        end
                    end

                    if notFound then
                        table.insert(temps, riskSpace)
                        table.insert(tempTypes, GetType(riskNum))

                        riskSpace:change(SPACESTYPE.RISK)
                        count += 1
                    end
                end
            elseif character.character.skill1.level == 2 then
                while count < math.ceil(numRisk / 3) do
                    local pos = math.random(1, 6)
                    local notFound = true

                    local riskNum = newNum + pos
                    local riskSpace = spaces[riskNum]

                    for i, val in ipairs(temps) do
                        if val == riskSpace then
                            notFound = false
                            break;
                        end
                    end

                    if notFound then
                        table.insert(temps, riskSpace)
                        table.insert(tempTypes, GetType(riskNum))

                        riskSpace:change(SPACESTYPE.RISK)
                        count += 1
                    end
                end
            end
        end
        self.doing = GAMETYPES.STANDARD
    end
end

function getCar()
    return car
end

function GameHandler:removeAllItems()
    clear(temps)
    clear(tempTypes)

    GFX.setDrawOffset(0, 0)

    if skillMenu ~= nil then
        skillMenu:remove()
        skillMenu = nil
    elseif riskMenu ~= nil then
        riskMenu:remove()
        riskMenu = nil
    end

    self:remove()

    tASprite:remove()
    plus:remove()

    for i = 1, #GetSpaces() do
        GetSpaces()[i]:remove()
        GetSpaces()[i] = nil
    end

    firstSpace = nil

    car:remove()

    dice:remove()

    days:remove()
    daysText:remove()

    doOver:remove()

    tokens:remove()

    doOverText:remove()

    if active ~= nil then
        active:remove()
        activeText:remove()
    end

    menu:removeMenuItem(menu:getMenuItems()[1])

    if finalScreen ~= nil then
        finalScreen:remove()
        finalScreen = nil
    end

    endTimer = nil
    character = nil
    playerTurn = true
end

function GameHandler:setDoOverStatus(s)
    doOverStatus = s
end

function GameHandler:executeDoOver()
    doOver:DoOver(car, dice, days)
end

function GameHandler:changeSelected()
    if self.selected == 1 then
        self.selected = 2
        active:select()
        doOver:deselect()
    else
        self.selected = 1
        active:deselect()
        doOver:select()
    end
end

function GameHandler:swapSkill()
    skillMenu:changeSelected(character)
end

function GameHandler:swapRiskOp()
    riskMenu:changeSelected()
end

function GameHandler:upgradeSkill()
    local s = skillMenu:upgradeSkill(character)
    if s then
        skillMenu = nil
        self.doing = GAMETYPES.STANDARD
    end
end

function GameHandler:chooseRisk()
    riskMenu:chooseOption(self, numRisk)
    riskMenu = nil
end

function GameHandler:findPunishment()
    return generatePunishment(numRisk)
end

function GameHandler:useToken()
    if self.doing == GAMETYPES.STANDARD then
        if car.currentSpace ~= 1 then
            if GetType(car.currentSpace) == SPACESTYPE.NORM then
                if character.tokens > 0 and self.justUsed == false and doOverStatus == "Do Over" then
                    days.daysLeft += 1
                    doOverStatus = "Cannot Use"

                    self.justUsed = true
                    character:useToken()

                    local back = car.currentSpace - dice.number
                    if character.character.name == CHARACTERS.BUSINESS.name then
                        if plus:getImage() == plus1Img then
                            back -= 1
                        elseif plus:getImage() == plus2Img then
                            back -= 2
                        end
                    end

                    car:move(spaces[back])
                end
            end
        end
    end
end

function GameHandler:useAbility()
    if self.doing == GAMETYPES.STANDARD then
        if car.currentSpace < 99 then
            if self.usedAbility == false then
                self.usedAbility = true
                local move = 1
                local endChance = 1

                if character.character.skill1.level == 1 then
                    if character.character.name == CHARACTERS.BUSINESS.name then
                        endChance = 30
                        move = math.random(7, 9)
                    end
                elseif character.character.skill1.level == 2 then
                    if character.character.name == CHARACTERS.BUSINESS.name then
                        endChance = 50
                        move = math.random(10, 15)
                    end
                end

                local madeNum = car.currentSpace + move

                if madeNum > 99 then
                    madeNum = 99
                end

                local madeSpace = spaces[madeNum]

                car:move(madeSpace)

                table.insert(temps, madeSpace)
                table.insert(tempTypes, GetType(madeNum))

                madeSpace:change(SPACESTYPE.RISK)

                local chance = math.random(1, 100)

                self.doing = GAMETYPES.WAIT
                self.waitingOn = chance
                self.waitedSpace = endChance
            end
        end
    end
end

function GameHandler:getChar()
    return character.character
end
