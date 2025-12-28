local anim8 = require "libraries/anim8"

enemyData = {}

enemyConfig = {
    maxEnemies = 24,
    spawnRangeY = {500, 500},
    speed = 100,
    spriteWidth = 19,
    spriteHeight = 19,
    hitBoxWidth = 40,
    hitBoxHeight = 40,
    health = 15,
    score = 0,
    maxScore = 99
}

local spriteSheet = love.graphics.newImage("enemyPNG/KSpriteSheetV2.png")

enemyConfig.spriteSheet = spriteSheet

enemies = {}

function enemyData.load(physEnv)

    enemies = {}

    for i = 1, enemyConfig.maxEnemies do

        enemies[i] = {
            alive = false,
            x = 0,
            y = 0,
            health = enemyConfig.health,
            speed = enemyConfig.speed,
            hitBox = nil,
            currentAnim = nil,
            state = "moving",
            attackTimer = 0,
            dieTimer = 0,
            blurr = false
        }

        enemies[i].grid = anim8.newGrid(20, 20, 201, 121)

        enemies[i].animations = {
            left = anim8.newAnimation(enemies[i].grid("1-10", 2), 0.1),
            right = anim8.newAnimation(enemies[i].grid("1-10", 1), 0.1),
            attackLeft = anim8.newAnimation(enemies[i].grid("1-10", 4), 0.05),
            attackRight = anim8.newAnimation(enemies[i].grid("1-10", 3), 0.05),
            dieLeft = anim8.newAnimation(enemies[i].grid("1-10", 6), 0.1),
            dieRight = anim8.newAnimation(enemies[i].grid("1-10", 5), 0.1)
        }

        enemies[i].currentAnim = enemies[i].animations.right -- Initialise currentAnim
    end
end


function enemyData.spawnEnemy(physEnv)

    if enemyConfig.score > 98 then

        enemyConfig.score = 99
    end

    local playerX = player.x
    local playerY = player.y

    -- Actives enemies count
    activeEnemies = 0

    for _, enemy in ipairs(enemies) do

        if enemy.alive then

            activeEnemies = activeEnemies + 1
        end
    end

    if activeEnemies >= enemyConfig.maxEnemies then

        return nil
    end

    if isPaused == true or gameState == "gameOver" then

        return nil
    end

    -- find dead enemies for respawn
    for i, enemy in ipairs(enemies) do

        if not enemy.alive then
            
            local validPosition = false
            local attempts = 0
            local maxAttempts = 10
            local spawnDistance = 900

            while not validPosition and attempts < maxAttempts do

                -- Alternate between left and right spawns
                if math.random(2) == 1 then
                    -- left
                    enemy.x = love.math.random(playerX - spawnDistance - 200, playerX - 150)
                else
                    -- right
                    enemy.x = love.math.random(playerX + 150, playerX + spawnDistance + 200)
                end

                enemy.y = love.math.random(enemyConfig.spawnRangeY[1], enemyConfig.spawnRangeY[2]) -- useless now

                -- check if spawn is not too close from player
                local dx = enemy.x - playerX
                local distance = math.abs(dx)

                if distance > 150 then
                    validPosition = true
                end

                attempts = attempts + 1
            end

            if not validPosition then

                return nil
            end

            enemy.health = enemyConfig.health

            -- New hitbox
            enemy.hitBox = physEnv:newBSGRectangleCollider(enemy.x, enemy.y, enemyConfig.hitBoxWidth, enemyConfig.hitBoxHeight, 5)
            enemy.hitBox:setFixedRotation(true)
            enemy.hitBox:setLinearVelocity(0, 0)
            enemy.hitBox:setCollisionClass('Enemy')

            enemy.state = "moving"

            enemy.alive = true

            enemy.currentAnim = enemy.animations.right -- Initialize currentAnim

            return enemy
        end
    end

    return nil
end


function enemyData.update(playerX, playerY, dt)

    for _, enemy in ipairs(enemies) do

        if enemy.alive then

            if enemy.currentAnim then

                enemy.currentAnim:update(dt)

            else

                enemy.currentAnim = enemy.animations.right
            end

            -- Manage enemy death timer 
            if enemy.state == "dying" then

                enemy.dieTimer = enemy.dieTimer - dt

                if enemy.dieTimer <= 0 then

                    enemy.alive = false

                    if enemy.hitBox then

                        enemy.hitBox:destroy()
                    end
                end

            else

                -- Manage enemy attack timer
                if enemy.state == "attacking" then

                    enemy.attackTimer = enemy.attackTimer - dt

                    if enemy.attackTimer <= 0 then

                        enemy.state = "moving"
                    end
                end

                -- Verify enemy death conditions
                if enemy.y < 0 or enemy.y > love.graphics.getHeight() or enemy.health <= 0 then

                    if enemy.state ~= "dying" then -- let die animation time to play before clear

                        enemy.alive = false

                        if enemy.hitBox then

                            enemy.hitBox:destroy()
                        end
                    end

                else

                    -- Enemies movements
                    local dx = playerX - enemy.x
                    local dy = playerY - enemy.y
                    local distance = math.sqrt(dx * dx)

                    if distance > 0 and enemy.state ~= "dying" then

                        local vx = (dx / distance) * enemy.speed
                        local vy = (dy / distance) * enemy.speed -- player jump boosting enemy speed

                        if player.alive then

                            enemy.hitBox:setLinearVelocity(vx, 0)
                        end

                    else

                        enemy.hitBox:setLinearVelocity(0, 0)
                    end

                    if enemy.state == "moving" then

                        if dx < 0 then

                            enemy.currentAnim = enemy.animations.left

                        elseif dx > 0 then

                            enemy.currentAnim = enemy.animations.right
                        end
                    end

                    if player.alive then

                        enemy.x = enemy.hitBox:getX() - 20
                        enemy.y = enemy.hitBox:getY() - 35
                    end

                    -- Damages
                    enemy.hitBox:setCollisionClass('Enemy')

                    if enemy.hitBox:enter('Player') then

                        love.audio.play(playerDmgs)

                        player.health = player.health - 5

                        local dx = playerX - enemy.x

                        if dx < 0 then

                            enemy.currentAnim = enemy.animations.attackLeft
                        else

                            enemy.currentAnim = enemy.animations.attackRight
                        end

                        enemy.state = "attacking"
                        enemy.attackTimer = 0.25

                        if dx < 0 then

                            enemy.hitBox:applyLinearImpulse(3000, -100)

                        else

                            enemy.hitBox:applyLinearImpulse(-3000, -100)
                        end
                    end

                    if enemy.hitBox:enter('pProjectile') then

                        enemy.health = enemy.health - 15

                        love.audio.play(enemyDeaths)

                        enemyConfig.score = enemyConfig.score + 1

                        local dx = playerX - enemy.x

                        if dx < 0 then

                            enemy.currentAnim = enemy.animations.dieLeft
                        else

                            enemy.currentAnim = enemy.animations.dieRight
                        end

                        enemy.state = "dying"
                        enemy.dieTimer = 0.25
                        enemy.hitBox:setLinearVelocity(0, 0)
                    end
                    
                    if enemy.x <= 46 or enemy.x >= 742 then -- base coordonates from leftWall and rightWall in level.lua

                        enemy.blurr = true
                    else

                        enemy.blurr = false
                    end
                end
            end
        end
    end
end


function enemyData.draw()

    if gameState == "gameOver" then

        love.graphics.setColor(0, 0.8, 1)

        love.graphics.print({enemyConfig.score}, UIfont, 390, 320, nil, 2, 2) --move gameover score on changed position

        love.graphics.setColor(1, 1, 1)

    else

        if enemyConfig.score > 9 then

            love.graphics.setColor(0, 0.8, 1)

            love.graphics.print({enemyConfig.score}, UIfont, 390, -20, nil, 1, 3)

            love.graphics.setColor(1, 1, 1)

        else

            love.graphics.setColor(0, 0.8, 1)

            love.graphics.print({enemyConfig.score}, UIfont, 392, -4, nil, 2, 2)

            love.graphics.setColor(1, 1, 1)
        end
    end

    for _, enemy in ipairs(enemies) do

        if enemy.alive and enemy.currentAnim and enemy.blurr == false then

            enemy.currentAnim:draw(enemyConfig.spriteSheet, enemy.x - (enemyConfig.hitBoxWidth / 2), enemy.y - (enemyConfig.hitBoxHeight / 1.70), nil, 4)
        end
    end
end


return enemyData