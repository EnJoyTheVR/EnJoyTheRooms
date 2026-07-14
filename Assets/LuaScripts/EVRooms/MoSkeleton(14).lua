-- Полный скрипт для поведения скелета (AI) с NavMesh и Raycast
-- Сохраните как skeleton_ai_final.lua

-- === Настройки ИИ ===
local walkSpeed = 1.5       
local runSpeed = 4.0        
local detectionRange = 200.0  
local loseTime = 5.0        
local updateInterval = 0.2  
local danceDuration = 3.0   
-- ====================

-- === Точки патрулирования ===
local patrolPoints = {
    CS.UnityEngine.Vector3(16.39, 0, 9.79),
    CS.UnityEngine.Vector3(18.91, 0, -8.12),
    CS.UnityEngine.Vector3(19.19, 0, -31.28),
    CS.UnityEngine.Vector3(5.38, 0, 9.93),
    CS.UnityEngine.Vector3(7.9, 0, -6.45),
    CS.UnityEngine.Vector3(4.47, 0, -31.59),
    CS.UnityEngine.Vector3(-9.03, 0, 9.74),
    CS.UnityEngine.Vector3(-9.54, 0, -10.7),
    CS.UnityEngine.Vector3(-7.15, 0, -32.106),
    CS.UnityEngine.Vector3(-22.16, 0, -13.704),
    CS.UnityEngine.Vector3(-20.41, 0, 9.76),
    CS.UnityEngine.Vector3(-20.27, 0, -31.73),
    CS.UnityEngine.Vector3(-35.52, 0, 7.47),
    CS.UnityEngine.Vector3(-35.028, 0, -5.13),
    CS.UnityEngine.Vector3(-30.92, 0, -31.49),
    CS.UnityEngine.Vector3(-46.83, 0, 6.75),
    CS.UnityEngine.Vector3(-44.75, 0, -11.03),
    CS.UnityEngine.Vector3(-50.14, 0, -32.01),
}
-- ====================

-- === Анимации танцев ===
-- ЗАМЕНИТЕ на реальные названия анимаций вашего скелета
local danceAnimations = {
    "Dance1",
    "Dance2",
    "Dance3"
}
-- ====================

-- === Глобальные переменные скелета ===
local SKELETON_OBJECT_NAME = "MoSkeleton14" -- <<< Имя вашего объекта скелета

local skeletonTransform = nil
local skeletonNavMeshAgent = nil -- Компонент NavMesh Agent
local skeletonAnimator = nil 
local player = nil
local playerTransform = nil
local currentState = "patrol" 
local currentPatrolIndex = 1
local targetPatrolPoint = nil
local lastUpdateTime = 0
local lastSeenPlayerTime = 0 
local danceStartTime = 0     
local isMoving = true        

-- === НОВАЯ ЛОГИКА NAVMESH AGENT (Исправленная) ===
-- Глобальная переменная для задержки после достижения точки
local atPatrolPoint = false
local patrolPointDelay = 0
local patrolPointDelayDuration = 1.0 -- 1 секунда задержки
-- =============================

-- Вспомогательные функции для работы с векторами
local function GetVectorMagnitude(vector)
    if vector == nil then return 0 end
    return vector.magnitude 
end

local function NormalizeVector(vector)
    if vector == nil then return CS.UnityEngine.Vector3.zero end
    return vector.normalized
end

-- Функция для получения игрока
local function GetPlayer()
    if player == nil or playerTransform == nil then
        player = EVR.Player
        if player ~= nil then
            playerTransform = player:GetComponent(typeof(CS.UnityEngine.Transform))
        end
    end
    return player, playerTransform
end

-- === НОВАЯ ЛОГИКА NAVMESH AGENT (Исправленная) ===
-- Функция для установки состояния
local function SetState(newState)
    if currentState ~= newState then
        print("Skeleton AI: State changed to '" .. newState .. "'")
        currentState = newState
        -- Сброс задержки при смене состояния
        atPatrolPoint = false 
        patrolPointDelay = 0
        
        if newState == "patrol" then
            isMoving = true
            lastSeenPlayerTime = 0
            print("Skeleton starts patrolling.")
            -- Установка начальной цели для NavMesh Agent
            if skeletonNavMeshAgent ~= nil and #patrolPoints > 0 then
                 --currentPatrolIndex = 1
                 targetPatrolPoint = patrolPoints[currentPatrolIndex]
                 skeletonNavMeshAgent:SetDestination(targetPatrolPoint)
                 print("NavMesh Agent initial destination set to: " .. tostring(targetPatrolPoint))
            else
                print("Warning: Could not set initial NavMesh Agent destination.")
            end
            
        elseif newState == "chase" then
            isMoving = true
            lastSeenPlayerTime = os.time() 
            
        elseif newState == "dancing" then
            isMoving = false
            if skeletonNavMeshAgent ~= nil then
                skeletonNavMeshAgent:ResetPath()
                print("NavMesh Agent path reset for dancing.")
            end
            danceStartTime = os.time()
            if skeletonAnimator ~= nil and #danceAnimations > 0 then
                math.randomseed(os.time())
                local randomDance = danceAnimations[math.random(1, #danceAnimations)]
                skeletonAnimator:Play(randomDance)
                print("Skeleton is dancing: " .. randomDance)
            else
                print("Skeleton is 'dancing' (no animator or animations defined)")
            end
        end
    end
end
-- =============================

-- Функция для вычисления расстояния до игрока
local function GetDistanceToPlayer()
    local _, pTransform = GetPlayer()
    if pTransform ~= nil and skeletonTransform ~= nil then
        local delta = pTransform.position - skeletonTransform.position
        return GetVectorMagnitude(delta)
    end
    return math.huge
end

-- === Проверка видимости игрока через Raycast ===
local function IsPlayerVisible()
    local _, pTransform = GetPlayer()
    if pTransform ~= nil and skeletonTransform ~= nil then
        local skeletonPos = skeletonTransform.position
        local playerPos = pTransform.position
        
        -- Позиция "глаз" скелета немного выше его центра
        local skeletonEyePos = skeletonPos + CS.UnityEngine.Vector3(0, 1.5, 0) 
        -- Позиция "глаз" игрока
        local playerEyePos = playerPos + CS.UnityEngine.Vector3(0, 1.5, 0) 
        
        local distance = GetVectorMagnitude(playerEyePos - skeletonEyePos)
        
        if distance <= detectionRange then
            local direction = playerEyePos - skeletonEyePos
            
            local hits = CS.UnityEngine.Physics.RaycastAll(skeletonEyePos, direction, distance)
            
            local sortedHits = {}
            for i = 0, hits.Length - 1 do
                table.insert(sortedHits, hits[i])
            end
            table.sort(sortedHits, function(a, b) return a.distance < b.distance end)
            
            if #sortedHits > 0 then
                local firstHit = sortedHits[1]
                if firstHit.collider.gameObject == pTransform.gameObject or 
                   firstHit.collider.transform:IsChildOf(pTransform) or
                   pTransform:IsChildOf(firstHit.collider.transform) then
                    return true
                end
                return false
            else
                return true
            end
        end
    end
    return false
end
-- =========================================================

-- === НОВАЯ ЛОГИКА NAVMESH AGENT (Исправленная) ===
-- Функция для поворота скелета к цели (может быть не нужна, если NavMesh Agent сам поворачивает)
local function RotateTowards(targetPosition)
    if skeletonTransform == nil or skeletonNavMeshAgent ~= nil then return end
    local direction = targetPosition - skeletonTransform.position
    direction.y = 0 
    if GetVectorMagnitude(direction) > 0.1 then
        local lookRotation = CS.UnityEngine.Quaternion.LookRotation(direction)
        skeletonTransform.rotation = CS.UnityEngine.Quaternion.Slerp(
            skeletonTransform.rotation, 
            lookRotation, 
            5.0 * updateInterval 
        )
    end
end

-- Функция для движения скелета (ЗАМЕНЕНА логикой NavMesh Agent)
local function MoveSkeleton(targetPosition, speed)
    if skeletonNavMeshAgent ~= nil then
        if isMoving then
            skeletonNavMeshAgent.speed = speed
            local success = skeletonNavMeshAgent:SetDestination(targetPosition)
            if not success then
                 print("NavMesh Agent could not find path to " .. tostring(targetPosition))
                 return false
            end
            
            local distance = skeletonNavMeshAgent.remainingDistance
            local reached = (not skeletonNavMeshAgent.pathPending) and 
                            (skeletonNavMeshAgent.remainingDistance <= skeletonNavMeshAgent.stoppingDistance) and
                            (skeletonNavMeshAgent.pathStatus == CS.UnityEngine.AI.NavMeshPathStatus.PathComplete)
            return reached
        else
            skeletonNavMeshAgent:ResetPath()
            return false
        end
    else
        print("ERROR: NavMesh Agent is nil in MoveSkeleton!")
        return true
    end
end

-- Логика патрулирования (ИСПРАВЛЕННАЯ)
local function UpdatePatrol()
    if skeletonTransform == nil or skeletonNavMeshAgent == nil then return end

    -- Проверка видимости игрока
    if IsPlayerVisible() then
        lastSeenPlayerTime = os.time() 
        SetState("chase")
        return
    end

    -- Логика перехода к следующей точке с задержкой
    if atPatrolPoint then
        patrolPointDelay = patrolPointDelay + updateInterval
        if patrolPointDelay >= patrolPointDelayDuration then
            atPatrolPoint = false
            patrolPointDelay = 0
            -- Выбираем следующую точку
            currentPatrolIndex = (currentPatrolIndex % #patrolPoints) + 1
            targetPatrolPoint = patrolPoints[currentPatrolIndex]
            print("Moving to next patrol point: " .. tostring(targetPatrolPoint))
            if skeletonNavMeshAgent ~= nil and targetPatrolPoint ~= nil then
                skeletonNavMeshAgent:SetDestination(targetPatrolPoint)
            end
        end
        return -- Ждем завершения задержки
    end

    -- Проверяем, достиг ли агент своей цели
    if skeletonNavMeshAgent.isOnNavMesh and not skeletonNavMeshAgent.pathPending then
        local distanceToTarget = skeletonNavMeshAgent.remainingDistance
        if distanceToTarget <= 1.0 then -- Порог "достижения" точки
            print("Skeleton reached patrol point (distance: " .. distanceToTarget .. "). Waiting...")
            atPatrolPoint = true
            patrolPointDelay = 0
            -- Останавливаем агент, чтобы он не "дергался" возле точки
            if skeletonNavMeshAgent ~= nil then
                skeletonNavMeshAgent:ResetPath() 
            end
            return
        end
    end

    -- Если агент "потерял" путь, заставляем его снова идти к текущей цели
    if skeletonNavMeshAgent.isOnNavMesh and not skeletonNavMeshAgent.pathPending and 
       skeletonNavMeshAgent.remainingDistance == math.huge and targetPatrolPoint ~= nil then
        skeletonNavMeshAgent:SetDestination(targetPatrolPoint)
    end
end
-- =============================

-- Логика преследования
local function UpdateChase()
    local p, pTransform = GetPlayer()
    if pTransform == nil or skeletonTransform == nil then 
        SetState("patrol")
        return 
    end

    local playerPosition = pTransform.position
    
    if IsPlayerVisible() then
        lastSeenPlayerTime = os.time() 
        MoveSkeleton(playerPosition, runSpeed)
        -- Проверка "догнал ли"
        local distanceToPlayer = GetDistanceToPlayer()
        if distanceToPlayer < 1 then
             local deathMenu = CS.UnityEngine.GameObject.Find("DeathMenu")
             deathMenu:GetComponent(typeof(CS.UnityEngine.Transform)).position = EVR.Player:GetComponent(typeof(CS.UnityEngine.Transform)).position
             EVR:BlockStick()
             print("Skeleton caught the player!")
             SetState("dancing")
        end
    else
        local timeSinceLastSeen = os.time() - lastSeenPlayerTime
        if timeSinceLastSeen >= loseTime then
            print("Skeleton lost player after " .. timeSinceLastSeen .. " seconds.")
            SetState("patrol")
        end
        MoveSkeleton(playerPosition, runSpeed)
    end
end

-- Логика танца
local function UpdateDancing()
    if skeletonTransform == nil then return end
    
    local timeDancing = os.time() - danceStartTime
    if timeDancing >= danceDuration then
        print("Skeleton finished dancing.")
        SetState("patrol")
    end
end

-- Функция Start
function Start()
    print("Skeleton AI (with NavMesh Agent) script started.")
    
    local skeletonGO = CS.UnityEngine.GameObject.Find(SKELETON_OBJECT_NAME)
    if skeletonGO ~= nil then
        skeletonTransform = skeletonGO:GetComponent(typeof(CS.UnityEngine.Transform))
        -- === НОВАЯ ЛОГИКА NAVMESH AGENT ===
        skeletonNavMeshAgent = skeletonGO:GetComponent(typeof(CS.UnityEngine.AI.NavMeshAgent))
        if skeletonNavMeshAgent ~= nil then
            print("NavMesh Agent found on Skeleton.")
            skeletonNavMeshAgent.speed = walkSpeed
            skeletonNavMeshAgent.angularSpeed = 120.0
            skeletonNavMeshAgent.stoppingDistance = 0.5
        else
            print("CRITICAL ERROR: NavMesh Agent NOT found on Skeleton! AI will not work correctly.")
            print("Please add 'NavMesh Agent' component to the 'MoSkeleton' GameObject in Unity Editor.")
        end
        -- =============================
        skeletonAnimator = skeletonGO:GetComponent(typeof(CS.UnityEngine.Animator))
        if skeletonAnimator == nil then
            print("Warning: Animator not found on Skeleton. Dancing will be without animation.")
        end
    else
        print("CRITICAL ERROR: Skeleton object '" .. SKELETON_OBJECT_NAME .. "' not found in scene.")
    end

    if #patrolPoints > 0 then
       currentPatrolIndex = math.random(1, #patrolPoints)
    end
    
    SetState("patrol") -- Инициализируем состояние
    lastUpdateTime = 0
    lastSeenPlayerTime = 0
    isMoving = true
    atPatrolPoint = false
    patrolPointDelay = 0
    
    print("Skeleton AI initialized.")
end

-- Функция Update 
function FixedUpdate()
    lastUpdateTime = lastUpdateTime + 1
    if lastUpdateTime < 12 then 
        return
    end
    lastUpdateTime = 0

    if currentState == "patrol" then
        UpdatePatrol()
    elseif currentState == "chase" then
        UpdateChase()
    elseif currentState == "dancing" then
        UpdateDancing()
    end
end