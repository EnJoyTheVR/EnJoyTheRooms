-- billboard.lua
-- ������ ��� �������� ������� � ������ (�������)

-- === ��������� ===
-- ��� �������, ������� ������ ���� ���������
local BILLBOARD_OBJECT_NAME = "SmallCoin"  -- <<< �������� �� ��� ������ �������

-- =================

-- ���������� ���������� ��� �������� ������ �� Transform �������
local billboardTransform = nil

-- ������� Start
function Start()

    -- ������� ������ �� ����� ��� ������
    local billboardGO = CS.UnityEngine.GameObject.Find(BILLBOARD_OBJECT_NAME)
    if billboardGO then
        -- �������� ��� ��������� Transform
        billboardTransform = billboardGO:GetComponent(typeof(CS.UnityEngine.Transform))
    else
        CS.UnityEngine.Debug.LogWarning("Object named '" .. BILLBOARD_OBJECT_NAME .. "' not found in the scene.")
    end



    -- ���������, ���� �� � ��� ������ �� Transform �������
    if billboardTransform then
        -- �������� ������ (EVR.Player ������ ������������)
        local player = EVR.Player
        if player then
            -- �������� Transform ������ (������ ��� ������)
            local playerTransform = player:GetComponent(typeof(CS.UnityEngine.Transform))
            if playerTransform then
                -- ���������� ������ �������� �� ������� ������
                function FixedUpdate()-- ��� � ���� ��������� "�������" - ������� �� ���� ���� ����
                 billboardTransform:LookAt(playerTransform)
                end     -- ������������: billboardTransform:LookAt(playerTransform.position)
            else
                -- print("Could not get Player's Transform") -- ��� �������
            end
        else
            -- print("EVR.Player is nil") -- ��� �������
        end
    else
        -- ���� ������ �� ��� ������ ��� Start, ����� ����������� ������ ��� ������������
        -- ��� ������ ������ �� ������, ���� �� ������ ���� � ����� �������.
        -- print("Billboard Transform is not set.") -- ��� �������
    end
end

local objectToDestroy = CS.UnityEngine.GameObject.Find("SmallCoin")

function OnSmallCoin()
    
    CS.UnityEngine.Object.Destroy(self)
    print("1 coin Has been getted.")
end