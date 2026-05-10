import "CoreLibs/sprites"
import "CoreLibs/graphics"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

PUNISHMENTS = {
    END = {1, 3, 5, 7, 10, 16},
    GOBACK = {60, 58, 54, 50, 47, 43},
    LOSELEVEL = {10, 12, 19, 24, 27, 29}, 
    TOKEN = {29, 27, 22, 19, 16, 12}
}

function generatePunishment(numRisk)
    local total = 100
    local start = 1
    local chance = math.random(start, total)

    if chance <= PUNISHMENTS.END[numRisk] then
        return PUNISHMENTS.END
    elseif chance > PUNISHMENTS.END[numRisk] and chance <= PUNISHMENTS.END[numRisk] + PUNISHMENTS.GOBACK[numRisk] then
        return PUNISHMENTS.GOBACK
    elseif chance > PUNISHMENTS.END[numRisk] + PUNISHMENTS.GOBACK[numRisk] and chance <= PUNISHMENTS.END[numRisk] + PUNISHMENTS.LOSELEVEL[numRisk] + PUNISHMENTS.GOBACK[numRisk] then
        return PUNISHMENTS.LOSELEVEL
    elseif chance > PUNISHMENTS.END[numRisk] + PUNISHMENTS.LOSELEVEL[numRisk] + PUNISHMENTS.GOBACK[numRisk] and chance <= total then
        return PUNISHMENTS.TOKEN
    end
end