audioData = {}

function audioData.load()

    soundtrack = love.audio.newSource("audioWAV/CFKI - PauseTrack.wav", "stream")
    gameSoundtrack = love.audio.newSource("audioWAV/CFKI - GameplayTrack.wav", "stream")
    pauseSoundtrack = love.audio.newSource("audioWAV/CFKI - PauseTrack.wav", "stream")
    gOverSoundtrack = love.audio.newSource("audioWAV/CFKI - GameOverTrack.wav", "stream")
    playerGuns = love.audio.newSource("audioWAV/pguns.mp3", "static")
    playerHeals = love.audio.newSource("audioWAV/pheals.mp3", "static")
    playerShields = love.audio.newSource("audioWAV/pshield.mp3", "static")
    playerLoots = love.audio.newSource("audioWAV/pLoots.mp3", "static")
    giftSpawns = love.audio.newSource("audioWAV/gSpawns.mp3", "static")
    enemyDeaths = love.audio.newSource("audioWAV/eDeaths.mp3", "static")
    playerDmgs = love.audio.newSource("audioWAV/pDamaged.mp3", "static")

    love.audio.setVolume(1) -- master
    soundtrack:setVolume(0.6)
    gameSoundtrack:setVolume(0.8)
    pauseSoundtrack:setVolume(0.6)
    gOverSoundtrack:setVolume(1.2)
    playerDmgs:setVolume(3)
    enemyDeaths:setVolume(0.1)
    giftSpawns:setVolume(1.5)
    playerHeals:setVolume(0.5)
    playerShields:setVolume(0.8)
    playerGuns:setVolume(1)
end


function audioData.update(dt)

    -- blabla
end


function audioData.draw()
    
    -- blabla
end


return audioData