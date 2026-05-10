import "CoreLibs/sprites"

import "scripts/Space"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local TOTALSPACES <const> = 100

local spacesNum = {
    choose = {
        7, 
        11, 16, 
        23, 27, 
        33, 37, 39, 
        41, 46, 47, 
        50, 55, 56, 59, 
        62, 63, 65, 68,
        71, 72, 74, 75, 76,
        83, 84, 85, 86, 87,
        91, 92, 93, 94, 95, 96
    },
    skill = {
        4,
        9,
        12,
        21,
        34,
        44,
        52,
        61,
        77,
        82,
        90
    },
    redo = {
        2,
        14,
        29,
        35,
        48,
        54,
        64
    }
}

local function checkSpace(num, tbl)
    for i, val in ipairs(tbl) do
        if num == val then
            return true
        end
    end
    return nil
end

local spaces = {}

local begPos = {
    x = 100,
    y = 120
}

function InitializeSpaces()
    for i = 1, TOTALSPACES do
        local type = SPACESTYPE.NORM

        local inChoose = checkSpace(i, spacesNum.choose)
        local inSkill = checkSpace(i, spacesNum.skill)
        local inRedo = checkSpace(i, spacesNum.redo)

        if inChoose then
            type = SPACESTYPE.CHOOSE
        elseif inSkill then
            type = SPACESTYPE.SKILL
        elseif inRedo then
            type = SPACESTYPE.REPEAT
        end

        local space = Space(begPos.x + (95 * (i-1)), begPos.y, i, type)

    end
end

function GetSpaces()
	return spaces
end

function insertSpace(space)
    table.insert(spaces, space)
end
