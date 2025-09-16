-- billboard.lua
-- Скрипт для поворота объекта к игроку (билборд)

-- === Настройки ===
-- Имя объекта, который должен быть билбордом
local BILLBOARD_OBJECT_NAME = "SmallCoin (8)"  -- <<< ЗАМЕНИТЕ на имя вашего объекта

-- =================

-- Глобальная переменная для хранения ссылки на Transform объекта
local billboardTransform = nil

-- Функция Start
function Start()

    -- Находим объект по имени при старте
    local billboardGO = CS.UnityEngine.GameObject.Find(BILLBOARD_OBJECT_NAME)
    if billboardGO then
        -- Получаем его компонент Transform
        billboardTransform = billboardGO:GetComponent(typeof(CS.UnityEngine.Transform))
    else
        CS.UnityEngine.Debug.LogWarning("Object named '" .. BILLBOARD_OBJECT_NAME .. "' not found in the scene.")
    end


    -- Проверяем, есть ли у нас ссылка на Transform объекта
    if billboardTransform then
        -- Получаем игрока (EVR.Player должен существовать)
        local player = EVR.Player
        if player then
            -- Получаем Transform игрока (обычно это камера)
            local playerTransform = player:GetComponent(typeof(CS.UnityEngine.Transform))
            if playerTransform then
                -- Заставляем объект смотреть на позицию игрока
                function FixedUpdate() -- Это и есть поведение "билборд" - поворот по всем трем осям
                 billboardTransform:LookAt(playerTransform)
                end   -- Альтернатива: billboardTransform:LookAt(playerTransform.position)
            else
                -- print("Could not get Player's Transform") -- Для отладки
            end
        else
            -- print("EVR.Player is nil") -- Для отладки
        end
    else
        -- Если объект не был найден при Start, можно попробовать искать его периодически
        -- или просто ничего не делать, если он должен быть в сцене заранее.
        -- print("Billboard Transform is not set.") -- Для отладки
    end
end

local objectToDestroy = CS.UnityEngine.GameObject.Find("SmallCoin (8)")

function OnSmallCoin8()
    -- Удаляем объект
    CS.UnityEngine.Object.Destroy(objectToDestroy)
    print("SmallCoin1 Has been getted.")
end