math.randomseed(os.time())

function LoadGame()


local scenes = {"MainGame1", "MainGame2", "MainGame3"}

local randomIndex = math.random(1, #scenes)

local targetScene = scenes[randomIndex]

    EVR:LoadScene(targetScene)
    
    print("zagruzaem scenu: " .. targetScene)

end

function Start() 
    EVR:Save("level", 0)
	local level = EVR:Load("level", "int")
    print(level)
end
