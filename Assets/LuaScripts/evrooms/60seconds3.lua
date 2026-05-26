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
        CS.UnityEngine.Vector3(15.96, 0, 9.51),
        CS.UnityEngine.Vector3(15.69, 0, -11.76),
        CS.UnityEngine.Vector3(15.99, 0, -31.8),
        CS.UnityEngine.Vector3(-21.75, 0, -11.85),
        CS.UnityEngine.Vector3(3.6, 0, -5.3),
        CS.UnityEngine.Vector3(-12.53, 0, -10.59),
        CS.UnityEngine.Vector3(-7.15, 0, 4.12),
        CS.UnityEngine.Vector3(-6.89, 0, -27.17),
        CS.UnityEngine.Vector3(-48.82, 0, -9.78),
        CS.UnityEngine.Vector3(-52.47, 0, 9.39),
        CS.UnityEngine.Vector3(-51.28, 0, -28.2),
        CS.UnityEngine.Vector3(-37.67, 0, -10.76),
        CS.UnityEngine.Vector3(-27.22, 0, -8.3),
        CS.UnityEngine.Vector3(-30.2, 0, 9.75),
        CS.UnityEngine.Vector3(-28.98, 0, -22.88),
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

