fontData = {}

local anim8 = require "libraries/anim8"

gFontSpriteSheet = love.graphics.newImage("levelPNG/CFKI_gFontSpriteSheetV2.png") 
gFontGrid = anim8.newGrid(233, 176, gFontSpriteSheet:getWidth(), gFontSpriteSheet:getHeight(), 0, 0, 1)
gFontAnimation = anim8.newAnimation(gFontGrid('1-18', 1), 0.1) 

function fontData.load()
    
    --gameFont = love.graphics.newImage("levelPNG/gameFontPH.png") --debug
end


function fontData.update(dt)
    
    if gameState == "playing" then

        gFontAnimation:update(dt)
    end
end


function fontData.draw()

    if gameState == "playing" then

        gFontAnimation:draw(gFontSpriteSheet, 2.5, 0, 0, 3.45, 3.44)
    end
end


return fontData