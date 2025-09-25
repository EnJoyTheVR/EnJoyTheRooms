local LightComponent = self:GetComponent("Light")

function OnTriggerEnter()
    LightComponent.enabled = true
end

function OnTriggerExit()
    LightComponent.enabled = false
end