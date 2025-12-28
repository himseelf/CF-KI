levelData = {}

function levelData.load()
    
    -- loading physics environment
    windf = require("libraries/windfield")
    physEnv = windf.newWorld(0, 5000)
    UIfont = love.graphics.newFont("font/Pixeled.ttf")

    physEnv:addCollisionClass('Player')
    physEnv:addCollisionClass('Ghost')
    physEnv:addCollisionClass('Enemy', {ignores = {'Ghost', 'Enemy'}})
    physEnv:addCollisionClass('pProjectile', {ignores = {'Player', 'pProjectile'}})
    physEnv:addCollisionClass('Wall', {ignores = {'Enemy'}})
    physEnv:addCollisionClass('Ground', {ignores = {'Ghost'}})
    physEnv:addCollisionClass('Loot', {ignores = {'Wall', 'Enemy', 'Player'}})

    ground = physEnv:newRectangleCollider(-2500, 520, 10000, 50)
    wallLeft = physEnv:newRectangleCollider(0, 0, 46, 600) 
    wallRight = physEnv:newRectangleCollider(756, 0, 50, 600) 
    wallUp = physEnv:newRectangleCollider(0, 0, 800, 50)
    
    -- Types can be 'static', 'dynamic', 'kinematic' or 'none'. Defaults to 'dynamic'
    ground:setType('static')
    ground:setCollisionClass('Ground')
    wallLeft:setType('static')
    wallLeft:setCollisionClass('Wall')
    wallRight:setType('static')
    wallRight:setCollisionClass('Wall')
    wallUp:setType('static')
end


function levelData.update(dt)

    physEnv:update(dt)
end


function levelData.draw()
    
    physEnv:draw()
end


return levelData