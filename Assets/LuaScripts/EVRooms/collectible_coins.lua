-- collectible_coins.lua
-- Скрипт для управления плоскими собираемыми очками (билбордами)

-- === Настройки ===
local SCORE_SAVE_KEY = "TotalScore"
local SMALL_COIN_VALUE = 1
local BIG_COIN_VALUE = 25

-- Таблица для отслеживания собранных объектов
-- Ключ: GameObject очка, Значение: true (если собран)
local collectedObjects = {}

-- Таблицы для больших очков (для анимации)
local bigCoinsTable = {}
local originalYPositions = {}
-- =================

-- === Вспомогательные функции для работы с векторами ===
-- Правильный способ получить квадрат длины вектора
local function GetVectorSqrMagnitude(vector)
    if vector == nil then return 0 end
    return vector.sqrMagnitude -- СВОЙСТВО
end

-- Правильный способ получить длину вектора
local function GetVectorMagnitude(vector)
    if vector == nil then return 0 end
    return vector.magnitude -- СВОЙСТВО
end
-- ======================================================

-- === Логика игры ===
-- Функция для обновления отображения счета (замените на вашу логику UI)
local function UpdateScoreDisplay(newScore)
    print("Current Score: " .. newScore)
    -- Пример обновления текста на сцене:
    -- local scoreTextGO = CS.UnityEngine.GameObject.Find("ScoreText")
    -- if scoreTextGO then
    --     local tmpText = scoreTextGO:GetComponent(typeof(CS.TMPro.TMP_Text))
    --     if tmpText then
    --         tmpText.text = "Score: " .. newScore
    --     end
    -- end
end

-- Функция для сохранения счета
local function SaveScore(score)
    EVR:Save(SCORE_SAVE_KEY, score)
    print("Score saved: " .. score)
end

-- Функция для загрузки счета
local function LoadScore()
    local savedScore = EVR:Load(SCORE_SAVE_KEY, "int")
    if savedScore == nil then
        savedScore = 0 -- Возвращаем 0, если счет еще не сохранялся
    end
    return savedScore
end
-- ================

-- === Ф