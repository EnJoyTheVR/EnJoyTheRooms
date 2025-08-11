math.randomseed(os.time())

function Start()
 local player = EVR.Player
 local playerTrans = player:GetComponent("Transform")

 local spawnPoints = {
  CS.UnityEngine.Vector3(0, 1, 0),     
  CS.UnityEngine.Vector3(-8.55, 1, -6.64),
  CS.UnityEngine.Vector3(8.12, 1, -6.77), 
  CS.UnityEngine.Vector3(-2.23, 1, -30.63),
  CS.UnityEngine.Vector3(-10.8, 1, -23.76),
 }

 local SpawnNum = math.random(1, #spawnPoints)

 local targetPosition = spawnPoints[SpawnNum]

 playerTrans.position = targetPosition

 print("player teleported #" .. SpawnNum .. ". Coordinati: " .. tostring(targetPosition))
end