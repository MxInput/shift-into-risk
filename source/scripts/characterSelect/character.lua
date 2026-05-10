local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

local maxLevel = 2

CHARACTERS = {
	FORTUNE = {
        name = "Fortune Teller",
        skill1 = {
            name = "Extraordinary Luck",
            level = 1
        },
        skill2 = {
            name = "Telepathy",
            level = 1
        },
        desc1 = "Active Skill:\nExtraordinary\n Luck; Halves\n the number\n of risk\n spaces\n present.",
        desc2 = "Passive Skill:\nTelepathy;\nSometimes\ncreates a\ndo-over token."
    },
    BUSINESS = {
        name = "Business Man",
        skill1 = {
            name = "Tryhard",
            level = 1
        },
        skill2 = {
            name = "Success Story",
            level = 1
        },
        desc1 = "Active Skill:\nTryhard;\nJumps\nforward many\nspaces, but\nends on a\nrisk space.",
        desc2 = "Passive Skill:\nSuccess\nStory; Moves\nforward one\nadditional\nspace each\nturn."
    }
}

class('Character').extends(GFX.sprite)
	
function Character:init(c, t)
	Character.super.init(self)

	self.character = c
    self.tokens = t

    self:add()
end

local function findSkill(tbl, name)
    for i, value in pairs(tbl) do
        if value.name == name then
            return i
        end
    end
    return nil
end

function Character:levelUp(name)
    local skillNum = findSkill(self.c, name)
    self.c[skillNum].level += 1
end

function Character:useToken()
    self.tokens -= 1
end

function Character:gainToken()
    self.tokens += 1
end
