lootData = {}

local anim8 = require "libraries/anim8"

lootConfig = {
    lspawnTime = 10,
    lspeed = 200,
    lx = 0,
    ly = 0,
    hitBox = nil,
    timer = 30,
    types = {"heal", "invincibility"},
    shield = false,
    heal = false,
    shieldTimer = 0,
    healTimer = 0,
    invincibilityTimer = 0,
    lootAnimation = nil,
    lspriteSheet = nil,
    shieldSpriteSheet = nil,
    shieldAnimation = nil,
    healVisualCue = nil,
    shieldVisualCue = nil
}

function lootData.load()

    lootConfig.lspriteSheet = love.graphics.newImage("playerPNG/PowerUpV1.png")
    local lgrid = anim8.newGrid(25, 25, lootConfig.lspriteSheet:getWidth(), lootConfig.lspriteSheet:getHeight())
    lootConfig.lootAnimation = anim8.newAnimation(lgrid("1-4", 4), 0.2)

    lootConfig.shieldSpriteSheet = love.graphics.newImage("playerPNG/FulguroShieldV1.png")
    local shieldGrid = anim8.newGrid(33, 33, 199, 34)
    lootConfig.shieldAnimation = anim8.newAnimation(shieldGrid("1-6", 1), 0.1)

    lootConfig.healVisualCue = anim8.newAnimation(lgrid("1-4", 1), 0.1)

    lootConfig.shieldVisualCue = anim8.newAnimation(lgrid("1-4", 2), 0.1)

    lootConfig.timer = lootConfig.lspawnTime

    lootData.spawnLoot()
end


function lootData.spawnLoot()

    if isPaused == true or gameState == "gameOver" then

        return nil
    end
    
    if lootConfig.hitBox then

        lootConfig.hitBox:destroy()
    end

    -- loot random pos
    lootConfig.lx = love.math.random(100, 700)
    lootConfig.ly = love.math.random(395, 395) -- decided to not change y axis

    lootConfig.hitBox = physEnv:newCircleCollider(lootConfig.lx, lootConfig.ly, 20)
    lootConfig.hitBox:setCollisionClass("Loot")
    lootConfig.hitBox:setType("kinematic")

    lootConfig.type = lootConfig.types[love.math.random(1, #lootConfig.types)]
end


function lootData.update(dt)

    if isPaused == true then

        return
    end

    if lootConfig.lootAnimation and lootConfig.hitBox then

        lootConfig.lootAnimation:update(dt)
    end

    if lootConfig.shield and lootConfig.shieldAnimation then

        lootConfig.shieldAnimation:update(dt)
    end

    if lootConfig.heal then

        lootConfig.healVisualCue:update(dt)
    end

    if lootConfig.shield then

        lootConfig.shieldVisualCue:update(dt)
    end

    -- Visual cue timer updates
    if lootConfig.shieldTimer > 0 then

        lootConfig.shieldTimer = lootConfig.shieldTimer - dt

        if lootConfig.shieldTimer <= 0 then

            lootConfig.shield = false
        end
    end

    if lootConfig.healTimer > 0 then

        lootConfig.healTimer = lootConfig.healTimer - dt

        if lootConfig.healTimer <= 0 then

            lootConfig.heal = false
        end
    end

    -- invincible timer update
    if player and player.invincible and lootConfig.invincibilityTimer > 0 then

        lootConfig.invincibilityTimer = lootConfig.invincibilityTimer - dt

        if lootConfig.invincibilityTimer <= 0 then

            player.invincible = false

            if player.hitBox then

                player.hitBox:destroy()

                -- when shield timer ends, create default hitbox
                player.hitBox = physEnv:newBSGRectangleCollider(player.x + 40, player.y + 45, 50, 75, 10)
                player.hitBox:setCollisionClass("Player")
                player.hitBox:setType("dynamic")
                player.hitBox:setFixedRotation(true)
            end
        end
    end

    -- player collides with loot hitbox
    if lootConfig.hitBox and player and player.hitBox then

        if lootConfig.hitBox:enter("Player") then

            if lootConfig.type == "heal" then

                love.audio.play(playerHeals)

                lootConfig.heal = true
                lootConfig.healTimer = 3

                player.health = player.health + 10

            elseif lootConfig.type == "invincibility" then

                love.audio.play(playerShields)

                lootConfig.shield = true
                lootConfig.shieldTimer = 3

                player.invincible = true
                lootConfig.invincibilityTimer = 3

                if player.hitBox then

                    player.hitBox:destroy()
                    player.hitBox = physEnv:newCircleCollider(player.x + 40, player.y + 45, 42)
                    player.hitBox:setCollisionClass("pProjectile")
                    player.hitBox:setType("dynamic")
                end
            end

            lootConfig.hitBox:destroy()
            lootConfig.hitBox = nil
            -- Respawn new loot
            lootConfig.timer = 10
        end
    end

    -- loot respawn timer update
    lootConfig.timer = lootConfig.timer - dt

    if lootConfig.timer <= 0 then

        lootData.spawnLoot()
        
        lootConfig.timer = lootConfig.lspawnTime

        if isPaused == false and gameState ~= "gameOver" then

            love.audio.play(giftSpawns)
        end
    end
end


function lootData.draw()

    -- LOOT
    if lootConfig.hitBox and gameState == "playing" then

        if isPaused == false then

            lootConfig.lootAnimation:draw(lootConfig.lspriteSheet, lootConfig.hitBox:getX() - 26, lootConfig.hitBox:getY() - 26, nil, 2, 2)
        end
    end

    -- SHIELD
    if lootConfig.shield and player and player.hitBox then

        lootConfig.shieldAnimation:draw(lootConfig.shieldSpriteSheet, player.hitBox:getX() - 50, player.hitBox:getY() - 50, nil, 3, 3)
    end

    -- HEAL visual
    if lootConfig.heal and isPaused == false then

        lootConfig.healVisualCue:draw(lootConfig.lspriteSheet, player.x + 20, player.y - 50, nil, 2, 2)
    end

    -- SHIELD visual
    if lootConfig.shield and isPaused == false then

        lootConfig.shieldVisualCue:draw(lootConfig.lspriteSheet, player.x + 20, player.y - 50, nil, 2, 2)
    end
end


return lootData