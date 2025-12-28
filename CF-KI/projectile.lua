projectileData = {}

local anim8 = require "libraries/anim8"

function projectileData.load()

    projectiles = {}

    local pspriteSheet = love.graphics.newImage("playerPNG/CFbulletV1.png")

    local grid = anim8.newGrid(24, 24, 121, 25)

    local projectileAnimation = anim8.newAnimation(grid("1-5", 1), 0.1)
    
    projectileData.projectileAnimation = projectileAnimation
    projectileData.pspriteSheet = pspriteSheet
end


function projectileData.shoot(direction)

    if isPaused == true or player.isJumping == true or gameState == "gameOver" then

        return nil
    end

    local px, py = player.hitBox:getPosition()
    local speed = 800
    local vx = speed * direction  

    local projectile = {
        bhitBox = physEnv:newRectangleCollider(px -10, py - 10, 50, 25),
        bx = px,
        by = py,
        alive = true,
        currentAnim = projectileData.projectileAnimation:clone(),
        direction = direction,  
        blurr = false
    }

    projectile.bhitBox:setCollisionClass('pProjectile')
    projectile.bhitBox:setType('kinematic')
    projectile.bhitBox:setLinearVelocity(vx, 0)  -- vy not used

    table.insert(projectiles, projectile)
end


function projectileData.update(dt)

    if isPaused == true or gameState == "gameOver" then

        return nil

    else

        for i = #projectiles, 1, -1 do

            local projectile = projectiles[i]

            if projectile.alive then

                love.audio.play(playerGuns)
                
                projectile.bx, projectile.by = projectile.bhitBox:getPosition()

                if projectile.bx < 0 or projectile.bx > love.graphics.getWidth() then

                    projectile.alive = false
                    projectile.bhitBox:destroy()
                    table.remove(projectiles, i)
                end

                if projectile.bhitBox:enter('Enemy') or projectile.bhitBox:enter('Wall') then

                    projectile.alive = false
                    projectile.bhitBox:destroy()
                    table.remove(projectiles, i)
                end
            end

            if projectile.bx <= 48 or projectile.bx >= 742 then -- coordonates from leftWall and rightWall in level.lua

                projectile.blurr = true
            else

                projectile.blurr = false
            end

            projectile.currentAnim:update(dt)
        end
    end
end


function projectileData.draw()

    if isPaused == true or gameState == "gameOver" then

        return nil

    else

        for _, projectile in ipairs(projectiles) do

            if projectile.alive then

                local scaleX = 4
                local offsetX = -65

                if projectile.direction < 0 then

                    scaleX = -4  -- invert sprite if left
                    offsetX = 65  
                end

                if projectile.blurr == false then
                    
                    projectile.currentAnim:draw(projectileData.pspriteSheet, projectile.bx + offsetX,  projectile.by - 55, nil, scaleX, 4, 0, 0)
                end
            end
        end
    end
end


return projectileData