math.randomseed(os.time())

-- Таблица точек возрождения
local spawnPoints = {
    CS.UnityEngine.Vector3(0, 1, 0),     
    CS.UnityEngine.Vector3(-8.55, 1, -6.64),
    CS.UnityEngine.Vector3(8.12, 1, -6.77), 
    CS.UnityEngine.Vector3(-2.23, 1, -30.63),
    CS.UnityEngine.Vector3(-10.8, 1, -23.76),
    CS.UnityEngine.Vector3(11.68, 1, -23.39),
}

local player = nil
local playerTrans = nil
local nextTeleportTime = 0 -- Время следующей телепортации в секундах
local interval = 60 -- Интервал в секундах (1 минута)

-- Функция для телепортации игрока
local function TeleportPlayer()
    if playerTrans == nil then
        player = EVR.Player
        playerTrans = player:GetComponent(typeof(CS.UnityEngine.Transform))
    end

    local SpawnNum = math.random(1, #spawnPoints)
    local targetPosition = spawnPoints[SpawnNum]
    playerTrans.position = targetPosition
    print("Player teleported #" .. SpawnNum .. ". Coordinates: " .. tostring(targetPosition))
end

-- Функция Start как точка входа
function Start()
    -- Инициализация: телепортируем сразу и устанавливаем время следующей телепортации
    TeleportPlayer()
    -- Получаем текущее время и добавляем интервал
    -- os.time() возвращает секунды, поэтому просто добавляем 60
    nextTeleportTime = os.time() + interval
    print("Initial teleport done. Next teleport in " .. interval .. " seconds.")
end

-- Функция Update вызывается каждый кадр (предполагается, что EnJoyTheVR так делает)
function Update()
    -- Проверяем, не настало ли время для телепортации
    if os.time() >= nextTeleportTime then
        TeleportPlayer()
        -- Устанавливаем время следующей телепортации
        nextTeleportTime = os.time() + interval
        print("Next teleport scheduled for " .. os.date("%X", nextTeleportTime))
    end
end