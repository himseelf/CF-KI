-- love.load() is called at game start only once
-- love.update() is called every frame, dt stands for delta time
-- love.draw() is called every frame after .update()

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- pixel scaling without blurr
love.graphics.setDefaultFilter("nearest", "nearest")

love.keyboard.setKeyRepeat(false)

-- animation library
local anim8 = require "libraries/anim8"

-- states ("title", "playing", "gameOver")
gameState = "title"

-- enemy spawn timer
local spawnTimer = 0
local spawnInterval = 1

local titleSpriteSheet = love.graphics.newImage("levelPNG/CFKI-titleSpriteSheetV2.png")
local titleGrid = anim8.newGrid(233, 176, titleSpriteSheet:getWidth(), titleSpriteSheet:getHeight(), 0, 0, 1)
local titleAnimation = anim8.newAnimation(titleGrid('1-18', 1), 0.1) -- (grid(raw, line), framerate)

function love.load()

    require "font"
    fontData.load()

    require "level"
    levelData.load()

    require "player"

    require "projectile"
    projectileData.load()

    require "loot"
    lootData.load()

    require "enemy"

    require "audio"
    audioData.load()
end


function love.update(dt)

    -- title screen 
    if gameState == "title" then

        love.audio.play(soundtrack)

        titleAnimation:update(dt) 

        return
    end

    fontData.update(dt)
    levelData.update(dt)
    playerData.update(dt)
    projectileData.update(dt)
    lootData.update(dt)

    -- enemy spawn timer
    spawnTimer = spawnTimer + dt

    if spawnTimer >= spawnInterval then

        spawnTimer = 0
        enemyData.spawnEnemy(physEnv, player.x, player.y)
    end

    enemyData.update(player.x, player.y, dt)
    audioData.update(dt)
end


function love.keypressed(key)

    if gameState == "title" then

        if key == "return" then
            
            gameState = "playing"

            love.audio.stop(soundtrack) 

            love.audio.play(playerLoots)

            playerData.load(physEnv) -- localy manages most of the audio (UI, music) and IsPaused state code

            enemyData.load(physEnv)  
             
            enemyData.spawnEnemy(physEnv) -- Spawn first 

        elseif key == "escape" then

            love.event.quit()  
        end

        return
    end
end


function love.draw()

    if gameState == "title" then
        
        titleAnimation:draw(titleSpriteSheet, 2.5, 0, 0, 3.44, 3.44)

        return
    end

    fontData.draw()
    playerData.draw()
    projectileData.draw()
    lootData.draw()
    enemyData.draw()
    audioData.draw()
end