import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/ui"
import "CoreLibs/timer"

import "scripts/gameHandler"
import "scripts/days"
import "scripts/characterSelect/charDisplay"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local display = CharDisplay()
local GameHandler = nil

local confirmSound = PLAYDATE.sound.sampleplayer.new("samples/confirm")

local font = playdate.graphics.font.new("/System/Fonts/Asheville-Sans-14-Bold.pft")
GFX.setFont(font)

local menu = PLAYDATE.getSystemMenu()

titleMusic = PLAYDATE.sound.fileplayer.new("samples/titleMusic")
inGameMusic = PLAYDATE.sound.fileplayer.new("samples/inGameMusic")

titleMusic:play(0)

function PLAYDATE.update()
    PLAYDATE.timer.updateTimers()
    GFX.sprite.update()
end

function PLAYDATE.AButtonDown()
    confirmSound:play(1)

    if display ~= nil then
        titleMusic:stop()
        inGameMusic:play(0)
        GameHandler = display:chooseCharacter()
        display = nil
    elseif GameHandler ~= nil then
        if GameHandler.doing == GAMETYPES.SKILL then
            GameHandler:upgradeSkill()
        elseif GameHandler.doing == GAMETYPES.CHOOSE then
            GameHandler:chooseRisk()
        elseif GameHandler.selected == 1 then
            GameHandler:useToken()
        elseif GameHandler.selected == 2 then
            GameHandler:useAbility()
        end
    end
end

function PLAYDATE.upButtonDown()
    if display ~= nil then
        display:incButton()
    end
end

function PLAYDATE.downButtonDown()
    if display ~= nil then
        display:decButton()
    end
end

function PLAYDATE.leftButtonDown()
    if display ~= nil then
        display:changeDescription()
    end
    if GameHandler ~= nil then
        if GameHandler.doing == GAMETYPES.SKILL then
            GameHandler:swapSkill()
        elseif GameHandler.doing == GAMETYPES.CHOOSE then
            GameHandler:swapRiskOp()
        else
            if GameHandler:getChar().name == CHARACTERS.BUSINESS.name then
                GameHandler:changeSelected()
            end
        end
    end
end

function PLAYDATE.rightButtonDown()
    if display ~= nil then
        display:changeDescription()
    end
    if GameHandler ~= nil then
        if GameHandler.doing == GAMETYPES.SKILL then
            GameHandler:swapSkill()
        elseif GameHandler.doing == GAMETYPES.CHOOSE then
            GameHandler:swapRiskOp()
        else
            if GameHandler:getChar().name == CHARACTERS.BUSINESS.name then
                GameHandler:changeSelected()
            end
        end
    end
end

function playdate.gameWillPause()
    if GameHandler ~= nil and #menu:getMenuItems() == 0 then
        local restart, error = menu:addMenuItem("Restart Game", function()
            confirmSound:play(1)
            if inGameMusic:isPlaying() then
                inGameMusic:stop()
            end
            titleMusic:play(0)
            display = CharDisplay()
            GameHandler:removeAllItems()
            GameHandler = nil
        end)
    end
end

function getGameHandler()
    if GameHandler ~= nil then
        return GameHandler
    end
end
