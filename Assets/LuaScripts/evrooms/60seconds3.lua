-- ������ ��� �������� ��������� ����� ����� 60 ������ (� os.time)

-- ������ �������� ����, ������� ����� ���������
local sceneList = {
    "MainGame1",       -- �������� �� �������� �������� ����� ����
    "MainGame2",
    -- �������� ������ ���� �� �������������
}

local isGameEnded = false   -- ���� ��� ��������� �������
local startTime = 0         -- ����� ������� �������
local interval = 60         -- �������� � �������� (1 ������)
local hasSceneLoaded = false -- ����, ����� ��������� ����� ������ ���� ���

-- ������� ��� ������ ��������� ����� �� ������
local function GetRandomScene()
    if #sceneList == 0 then
        print("Error: Scene list is empty!")
        return nil
    end
    math.randomseed(os.time())
    local randomIndex = math.random(1, #sceneList)
    return sceneList[randomIndex]
end

-- �������, ������� ������������� ������ (���������� ��� ���������� ����)
function gameEnd()
    isGameEnded = true
    print("Game ended. Scene loading timer stopped.")
end

-- ������� ��� �������� ��������� �����
local function LoadRandomScene()
    if isGameEnded then
        print("Scene loading skipped because game has ended.")
        return
    end
    
    if hasSceneLoaded then
        return -- ��� ���������, �� ��������� �����
    end
    
    local sceneName = GetRandomScene()
    if sceneName ~= nil then
        print("60 seconds passed. Loading random scene: " .. sceneName)
        -- ������ �������� false ��������, ��� ���������� ����� �� ����� ���������
        EVR:LoadScene(sceneName, false)
        hasSceneLoaded = true
    else
        print("Failed to load random scene: no scenes available.")
    end
end

-- ������� Start (���������� ��� �������������)
function Start()
    print("Random scene loader started. Will load in " .. interval .. " seconds.")
    isGameEnded = false
    hasSceneLoaded = false
    startTime = os.time() -- ���������� ����� ������
end

-- ������� Update (������ ���������� EnJoyTheVR)
function Update()
    -- ���������, �� ����������� �� ����
    if isGameEnded then
        return -- ������ �� ������, ���� ���� ���������
    end

    -- ���������, �� ���� �� ��������� �����
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    
    if elapsedTime >= interval then
        LoadRandomScene()
    end
end