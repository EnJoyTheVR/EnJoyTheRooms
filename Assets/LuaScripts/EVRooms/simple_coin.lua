-- simple_coin.lua
-- Минимальный скрипт для тестирования

function OnSmallCoinCollected(triggerGO)
    CS.UnityEngine.Debug.Log("!!! OnSmallCoinCollected WORKS !!! Triggered by: " .. tostring(triggerGO.name))
    
    -- Просто меняем цвет объекта на красный при срабатывании для визуального подтверждения
    local renderer = triggerGO:GetComponent(typeof(CS.UnityEngine.Renderer))
    if renderer then
        local redMaterial = CS.UnityEngine.Material(CS.UnityEngine.Shader.Find("Standard"))
        redMaterial.color = CS.UnityEngine.Color.red
        renderer.material = redMaterial
    end
end

function Start()
    CS.UnityEngine.Debug.Log("Simple Coin Script Loaded and Started")
end

function Update()
    -- Пустой Update
end