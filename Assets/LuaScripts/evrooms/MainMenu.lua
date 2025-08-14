math.randomseed(os.time())

function LoadGame()

local scenes = {"MainGame1", "MainGame2", "MainGame3"}

local randomIndex = math.random(1, #scenes)

local targetScene = scenes[randomIndex]

    EVR:LoadScene(targetScene)
    
    print("zagruzaev scenu: " .. targetScene)

end