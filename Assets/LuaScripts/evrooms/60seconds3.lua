-- Скрипт для загрузки случайной сцены через 60 секунд (с os.time)

-- Список названий сцен, которые можно загрузить
local sceneList = {
    "MainGame1",       -- Замените на реальные названия ваших сцен
    "MainGame2",
    -- Добавьте больше сцен по необходимости
}

local isGameEnded = false   -- Флаг для остановки таймера
local startTime = 0         -- Время запуска таймера
local interval = 60         -- Интервал в секундах (1 минута)
local hasSceneLoaded = false -- Флаг, чтобы загрузить сцену только один раз

-- Функция для выбора случайной сцены из списка
local function GetRandomScene()
    if #sceneList == 0 then
        print("Error: Scene list is empty!")
        return nil
    end
    math.randomseed(os.time())
    local randomIndex = math.random(1, #sceneList)
    return sceneList[randomIndex]
end

-- Функция, которая останавливает таймер (вызывается при завершении игры)
function gameEnd()
    isGameEnded = true
    print("Game ended. Scene loading timer stopped.")
end

-- Функция для загрузки случайной сцены
local function LoadRandomScene()
    if isGameEnded then
        print("Scene loading skipped because game has ended.")
        return
    end
    
    if hasSceneLoaded then
        return -- Уже загружали, не загружаем снова
    end
    
    local sceneName = GetRandomScene()
    if sceneName ~= nil then
        print("60 seconds passed. Loading random scene: " .. sceneName)
        -- Второй аргумент false означает, что предыдущая сцена НЕ будет оставлена
        EVR:LoadScene(sceneName, false)
        hasSceneLoaded = true
    else
        print("Failed to load random scene: no scenes available.")
    end
end

-- Функция Start (вызывается при инициализации)
function Start()
    print("Random scene loader started. Will load in " .. interval .. " seconds.")
    isGameEnded = false
    hasSceneLoaded = false
    startTime = os.time() -- Запоминаем время старта
end

-- Функция Update (должна вызываться EnJoyTheVR)
function Update()
    -- Проверяем, не остановлена ли игра
    if isGameEnded then
        return -- Ничего не делаем, если игра завершена
    end

    -- Проверяем, не пора ли загружать сцену
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    
    if elapsedTime >= interval then
        LoadRandomScene()
    end
end