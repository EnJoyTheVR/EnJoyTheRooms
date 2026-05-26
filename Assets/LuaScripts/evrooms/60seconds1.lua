-- Скрипт для включения компонента NavMeshAgent у монстров

-- Имена объектов монстров
local monsterNames = {
    "MoSkeleton1",
    "MoSkeleton2",
    "MoSkeleton3",
    "MoSkeleton4",
    "MoSkeleton5",
    "MoSkeleton6",
    "MoSkeleton7",
    "MoSkeleton8",
    "MoSkeleton9",
    "MoSkeleton10",
    "MoSkeleton11",
    "MoSkeleton12",
    "MoSkeleton13",
    "MoSkeleton14",
    "MoSkeleton15",
}

-- Функция для включения NavMeshAgent
function EnableNavMeshAgents()
    for i, monsterName in ipairs(monsterNames) do
        local monsterGO = CS.UnityEngine.GameObject.Find(monsterName)
        if monsterGO then
            -- Исправленный путь к NavMeshAgent
            local navAgent = monsterGO:GetComponent(typeof(CS.UnityEngine.AI.NavMeshAgent))
            if navAgent then
                navAgent.enabled = true
            end
        end
    end
end

-- Вызов функции
-- EnableNavMeshAgents()


-- Скрипт для загрузки случайной сцены через 60 секунд (с os.time)

-- Список названий сцен, которые можно загрузить
local sceneList = {
    "MainGame2",       -- Замените на реальные названия ваших сцен
    "MainGame3",
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
    local level = EVR:Load("level", "int")
    EVR:Save("level", level + 1)
    local level = EVR:Load("level", "int")
    print(level)
    math.randomseed(os.time())
    print("Random scene loader started. Will load in " .. interval .. " seconds.")
    isGameEnded = false
    hasSceneLoaded = false
    startTime = os.time() -- Запоминаем время старта
    -- Скрипт для телепортации монстров в зависимости от уровня
    -- Список возможных точек телепортации (замените на реальные координаты в вашей сцене)
    local teleportPoints = {
        CS.UnityEngine.Vector3(15.76, 0, 4.294),
        CS.UnityEngine.Vector3(16.23, 0, -10.61057),
        CS.UnityEngine.Vector3(16.28, 0, -32.13057),
        CS.UnityEngine.Vector3(9.02, 0, -11.27057),
        CS.UnityEngine.Vector3(-9.15, 0, 9.939432),
        CS.UnityEngine.Vector3(-12.36, 0, -11.60057),
        CS.UnityEngine.Vector3(-12.74, 0, -26.93057),
        CS.UnityEngine.Vector3(-22.85, 0, -13.89057),
        CS.UnityEngine.Vector3(-28.51, 0, 9.729433),
        CS.UnityEngine.Vector3(-31.45, 0, -6.940567),
        CS.UnityEngine.Vector3(-30.72, 0, -32.46057),
        CS.UnityEngine.Vector3(-37.56, 0, -11.04057),
        CS.UnityEngine.Vector3(-42.71, 0, 4.419433),
        CS.UnityEngine.Vector3(-50.37, 0, -8.290567),
        CS.UnityEngine.Vector3(-41.55, 0, -34.69057),
        -- Добавьте больше точек по необходимости
        -- CS.UnityEngine.Vector3(x, y, z),
    }

    -- Имена объектов монстров (должны соответствовать именам в сцене Unity)
    local monsterNames = {
        "MoSkeleton1",
        "MoSkeleton2",
        "MoSkeleton3",
        "MoSkeleton4",
        "MoSkeleton5",
        "MoSkeleton6",
        "MoSkeleton7",
        "MoSkeleton8",
        "MoSkeleton9",
        "MoSkeleton10",
        "MoSkeleton11",
        "MoSkeleton12",
        "MoSkeleton13",
        "MoSkeleton14",
        "MoSkeleton15",
    }
    -- =================

    -- Функция для получения случайного элемента из таблицы
    local function GetRandomElement(tbl)
        if #tbl == 0 then return nil end
        math.randomseed(os.time())
        local randomIndex = math.random(1, #tbl)
        return tbl[randomIndex]
    end

    -- Функция для получения случайного элемента из таблицы БЕЗ повторений
    -- Удаляет выбранный элемент из исходной таблицы
    local function GetRandomElementAndRemove(tbl)
        if #tbl == 0 then return nil end
        math.randomseed(os.time())
        local randomIndex = math.random(1, #tbl)
        local element = tbl[randomIndex]
        -- Удаляем выбранный элемент, чтобы его не выбрали снова
        table.remove(tbl, randomIndex)
        return element
    end

    -- Функция для телепортации
    function TeleportMonsters()
        print("Starting teleportation for level: " .. level)

        -- Проверяем, не превышает ли уровень количество монстров или точек
        local numMonstersToTeleport = math.min(level, #monsterNames)
        local numPointsAvailable = #teleportPoints

        if numMonstersToTeleport > numPointsAvailable then
            print("Warning: Level (" .. level .. ") requires more teleport points than available (" .. numPointsAvailable .. ").")
            print("Only " .. numPointsAvailable .. " monsters will be teleported.")
            numMonstersToTeleport = numPointsAvailable
        end

        -- Создаем копию списка точек, чтобы не изменять оригинальный список
        local availablePoints = {}
        for i, v in ipairs(teleportPoints) do
            availablePoints[i] = v
        end

        -- Цикл по количеству монстров, которые нужно телепортировать
        for i = 1, numMonstersToTeleport do
            local monsterName = monsterNames[i]
            if not monsterName then
                print("Warning: Monster name for index " .. i .. " is nil. Stopping teleportation.")
                break
            end

            -- Находим GameObject монстра по имени
            local monsterGO = CS.UnityEngine.GameObject.Find(monsterName)
            if monsterGO then
                local monsterTransform = monsterGO:GetComponent(typeof(CS.UnityEngine.Transform))
                if monsterTransform then
                    -- Получаем случайную точку из доступных и удаляем её из списка
                    local randomPoint = GetRandomElementAndRemove(availablePoints)
                    if randomPoint then
                        -- Устанавливаем новую позицию
                        monsterTransform.position = randomPoint
                        print("Teleported " .. monsterName .. " to " .. tostring(randomPoint))
                    else
                        -- Это не должно произойти, если проверки выше корректны
                        print("Error: No more available teleport points for " .. monsterName)
                    end
                else
                    print("Error: Could not get Transform component for " .. monsterName)
                end
            else
                print("Error: Monster GameObject named '" .. monsterName .. "' not found in scene.")
            end
        end

        print("Teleportation complete for level: " .. level)
    end

    -- Вызов функции (можно вызвать из другого места, когда нужно)
    TeleportMonsters()
    EnableNavMeshAgents()
    
    local textGO = CS.UnityEngine.GameObject.Find("DeathMenu/Canvas/Text Level")
    if textGO then
       local textComp = textGO:GetComponent(typeof(CS.TMPro.TMP_Text))
       if textComp then
          textComp.text = tostring(level)
       end
    end
end

-- Функция Update (должна вызываться EnJoyTheVR)
function FixedUpdate()
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