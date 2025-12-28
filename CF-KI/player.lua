playerData = {}

isPaused = false

local anim8 = require "libraries/anim8"

local pauseFontSpriteSheet = love.graphics.newImage("levelPNG/CFKI-pauseSpriteSheetV2.png") 
local pauseFontGrid = anim8.newGrid(233, 176, pauseFontSpriteSheet:getWidth(), pauseFontSpriteSheet:getHeight(), 0, 0, 1)
local pauseFontAnimation = anim8.newAnimation(pauseFontGrid('1-18', 1), 0.1) 

local gameOverSpriteSheet = love.graphics.newImage("levelPNG/CFKI-GameOverSpriteSheetV2.png") 
local gameOverGrid = anim8.newGrid(233, 176, gameOverSpriteSheet:getWidth(), gameOverSpriteSheet:getHeight(), 0, 0, 1)
local gameOverAnimation = anim8.newAnimation(gameOverGrid('1-18', 1), 0.1)

local gameWinSpriteSheet = love.graphics.newImage("levelPNG/CFKI-WinSpriteSheet.png") 
local gameWinGrid = anim8.newGrid(233, 176, gameWinSpriteSheet:getWidth(), gameWinSpriteSheet:getHeight(), 0, 0, 1)
local gameWinAnimation = anim8.newAnimation(gameWinGrid('1-18', 1), 0.1)


function playerData.load()

    player = {
        alive = true,
        invincible = false,
        invincibilityTimer = 3, -- see loot.lua
        x = 300, -- horizontal position
        y = 0, -- vertical position
        health = 5,
        maxHealth = 100,
        speed = 400,
        spriteSheet = love.graphics.newImage("playerPNG/CHSpriteSheetV3.png"),
        sprite = love.graphics.newImage("playerPNG/CHSpriteSheetV3.png"),
        hitBox = physEnv:newBSGRectangleCollider(300, 475, 50, 75, 10), 
        lastDirection = 1,  -- 1 for right, -1 for left
        isJumping = false,
        isFiring = false,
        fireTimer = 0
    }

    -- Player SpriteSheet scan
    player.grid = anim8.newGrid(29, 29, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations = {
        left = anim8.newAnimation(player.grid("1-4", 6), 0.1),
        right = anim8.newAnimation(player.grid("1-4", 8), 0.1),
        fireLeft = anim8.newAnimation(player.grid("1-4", 3), 0.1),
        fireRight = anim8.newAnimation(player.grid("1-4", 4), 0.1),
        downLeft = anim8.newAnimation(player.grid("1-4", 1), 0.4),
        downRight = anim8.newAnimation(player.grid("1-4", 2), 0.4),
        upLeft = anim8.newAnimation(player.grid("1-4", 11), 0.1),
        upRight = anim8.newAnimation(player.grid("1-4", 12), 0.1)
    }

    player.currentAnim = player.animations.downRight  -- default anim

    player.hitBox:setFixedRotation(true)
    player.hitBox:setCollisionClass('Player')
end


function playerData.update(dt)

    if isPaused then

        pauseFontAnimation:update(dt)

        love.audio.pause(gameSoundtrack)
                 
        if not pauseSoundtrack:isPlaying() then
            love.audio.play(pauseSoundtrack)
        end

        return  -- if game is paused stop updating other stuff
    end

    if player.health >= player.maxHealth then

        player.health = 100
    end

    local pIsMoving = false
    local vx = 0
    local vy = 0
    
    if player.health < 1 then

        player.alive = false

        gameState = "gameOver"

        love.audio.stop(gameSoundtrack)

    end

    if gameState == "gameOver" then

        love.audio.play(gOverSoundtrack)

        gameOverAnimation:update(dt)

        return
    end

    if enemyConfig.score > 98 then

        gameWinAnimation:update(dt)
    end

    -- movements manager
    if love.keyboard.isDown("q") then

        vx = player.speed * -1
        player.lastDirection = -1

        if player.isJumping then

            player.currentAnim = player.animations.upLeft

        else

            player.currentAnim = player.animations.left
        end

        pIsMoving = true

    elseif love.keyboard.isDown("d") then

        vx = player.speed
        player.lastDirection = 1

        if player.isJumping then

            player.currentAnim = player.animations.upRight

        else

            player.currentAnim = player.animations.right
        end

        pIsMoving = true
    end

    -- fire timer
    if player.isFiring then

        player.fireTimer = player.fireTimer - dt

        if player.fireTimer <= 0 then

            player.isFiring = false
        end
    end

    function love.keypressed(key)

        if gameState == "playing" then

            love.audio.stop(pauseSoundtrack)

            love.audio.play(gameSoundtrack)

            if key == "z" then

                player.isJumping = true

                physEnv:setGravity(0, 0)

                player.hitBox:applyLinearImpulse(0, -50000)

                if player.lastDirection == -1 then

                    player.currentAnim = player.animations.upLeft

                else

                    player.currentAnim = player.animations.upRight
                end

                pIsMoving = true
            end

            if key == "space" and player .isJumping == false then

                projectileData.shoot(player.lastDirection)

                player.isFiring = true
                player.fireTimer = 0.3  

                if player.lastDirection == -1 then

                player.currentAnim = player.animations.fireLeft

                else

                    player.currentAnim = player.animations.fireRight
                end

                pIsMoving = true
            end
        end

        if gameState ~= "title" and gameState ~= "gameOver" then

            if key == "escape" then

                if isPaused then

                    love.event.quit()
                else

                    love.audio.play(playerLoots)

                    isPaused = true    

                    if player.hitBox then

                        player.hitBox:setType('static')
                    end

                    if lootConfig.hitBox then

                        lootConfig.hitBox:setType('static')
                    end

                for _, enemy in ipairs(enemies) do

                    if enemy.alive and enemy.hitBox then

                        enemy.hitBox:setType('static')
                    end
                end
            end

            elseif key == "return" and isPaused then

                love.audio.play(playerLoots)

                isPaused = false      

                if player.hitBox then

                    player.hitBox:setType('dynamic')
                end

                for _, enemy in ipairs(enemies) do

                    if enemy.alive and enemy.hitBox then

                        enemy.hitBox:setType('dynamic')
                    end
                end
            end
        end

        if gameState == "gameOver" then

            player.alive = false

            if key == "return" then

                enemyConfig.score = 0

                love.audio.stop(gOverSoundtrack)

                gameState = "playing"

                player.hitBox:destroy() 
            
                for _, enemy in ipairs(enemies) do

                    if enemy.alive and enemy.hitBox then

                        enemy.hitBox:destroy()
                    end
                end

                playerData.load(physEnv) 
                enemyData.load(physEnv)   
                enemyData.spawnEnemy(physEnv) 

            elseif key == "escape" then

                love.event.quit()
            end
        end
    end

    function love.keyreleased(key)

        if gameState == "playing" then

            if key == "z" then

                player.isJumping = false

                physEnv:setGravity(0, 5000)

                player.hitBox:applyLinearImpulse(0, 50000)
            end
        end
    end

    if player.hitBox then

        player.hitBox:setLinearVelocity(vx, vy)
    end

    if not player.isJumping and not pIsMoving and not player.isFiring then

        if player.lastDirection == -1 then

            player.currentAnim = player.animations.downLeft

        else

            player.currentAnim = player.animations.downRight
        end
    end

    player.currentAnim:update(dt)
    physEnv:update(dt)

    player.x = player.hitBox:getX() - 45
    player.y = player.hitBox:getY() - 45
end


function playerData.draw()

    if gameState == "gameOver" then

        gameOverAnimation:draw(gameOverSpriteSheet, 2.5, 0, 0, 3.44, 3.44)
        
        return
    end

    if enemyConfig.score > 98 then

        gameWinAnimation:draw(gameWinSpriteSheet, 2.5, 0, 0, 3.44, 3.44)
    end

    if isPaused then

        --love.graphics.setColor(0.6, 0.6, 0.6, 0.8) -- blurr when paused 
        pauseFontAnimation:draw(pauseFontSpriteSheet, 2.5, 0, 0, 3.45, 3.44)
    end

    player.currentAnim:draw(player.spriteSheet, player.x, player.y, nil, 3)

    --physEnv:draw() -- debug

    love.graphics.setColor(0, 0.8, 1)

    love.graphics.print({player.health}, UIfont, 578, 47, nil, 1.4, 1.4)

    love.graphics.setColor(1, 1, 1)
end


return playerData