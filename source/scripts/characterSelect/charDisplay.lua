import "CoreLibs/graphics"

local PLAYDATE <const> = playdate
local GFX <const> = PLAYDATE.graphics

import "scripts/characterSelect/charButton"
import "scripts/gameHandler"

class('CharDisplay').extends(GFX.sprite)

local buttons
local images = {}
local sprites = {}

local tImg = GFX.image.new("images/characterTitle")
local title

local cDImg = GFX.image.new("images/CharacterDesc")
local charDesc

local charImg
local charText


local function count()
	local count = 0
	for key, value in pairs(buttons) do
		count += 1
	end
	return count
end

function CharDisplay:init()
	CharDisplay.super.init(self)
	self.currentButton = 1

	buttons = {
		c1 = CharButton(125, 95, CHARACTERS.BUSINESS),
		c2 = CharButton(125, 180, CHARACTERS.FORTUNE)
	}

	title = GFX.sprite.new(tImg)
	title:add()
	title:moveTo(200, 25)

	charDesc = GFX.sprite.new(cDImg)
	charDesc:add()
	charDesc:moveTo(300, 140)

	charImg = GFX.image.new(charDesc.width, charDesc.height)
	charText = GFX.sprite.new(charImg)
	charText:add()
	charText:moveTo(charDesc.x, charDesc.y)

	self.desc = 1

	for key, value in pairs(buttons) do
		local image = GFX.image.new(value.width, value.height)

		local sprite = GFX.sprite.new(image)

		table.insert(images, image)
		table.insert(sprites, sprite)
	end

	buttons["c" .. self.currentButton]:select()

	self:add()
end

function CharDisplay:update()
	local temps = {}
	local count = 1

	for key, value in pairs(buttons) do
		local image = images[count]
		local sprite = sprites[count]

		if key == "c" .. self.currentButton then
			buttons[key]:select()

			sprite:add()
			sprite:moveTo(value.x, value.y)

			image:clear(GFX.kColorClear)

			GFX.lockFocus(image)
			GFX.setImageDrawMode(GFX.kDrawModeFillWhite)
			GFX.drawTextAligned(value.character.name, value.width / 2, value.height / 2, kTextAlignment.center)
			GFX.setImageDrawMode(GFX.kDrawModeCopy)
			GFX.unlockFocus()

			charImg:clear(GFX.kColorClear)
			GFX.lockFocus(charImg)
			GFX.drawText(value.character["desc" .. self.desc], 10, charDesc.height / 10)
			GFX.unlockFocus()

			table.insert(temps, sprite)
			table.insert(temps, image)
		else
			buttons[key]:deselect()

			GFX.drawTextAligned(buttons.c2.character.name, 175, 160, kTextAlignment.center)

			sprite:add()
			sprite:moveTo(value.x, value.y)

			image:clear(GFX.kColorClear)

			GFX.lockFocus(image)
			GFX.drawTextAligned(value.character.name, value.width / 2, value.height / 2, kTextAlignment.center)
			GFX.unlockFocus()

			table.insert(temps, sprite)
			table.insert(temps, image)
		end
		count += 1
	end
end

function CharDisplay:incButton()
	if self.currentButton < count() then
		self.currentButton += 1
	else
		self.currentButton = 1
	end
end

function CharDisplay:decButton()
	if self.currentButton > 1 then
		self.currentButton -= 1
	else
		self.currentButton = count()
	end
end

function CharDisplay:changeDescription()
	if self.desc == 1 then
		self.desc = 2
	else
		self.desc = 1
	end
end

function CharDisplay:chooseCharacter()
	local char = Character(buttons["c" .. self.currentButton].character, 1)
	local GameHandler = GameHandler(char)
	if self ~= nil then
		self:remove()
	end

	local count = 1

	for key, value in pairs(buttons) do
		buttons[key]:remove()

		sprites[count]:remove()
		count += 1
	end

	title:remove()
	charDesc:remove()
	charText:remove()

	return GameHandler
end
