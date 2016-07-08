attackState = {}

function attackState.enter()
  if not self.target or not targetValid(self.target) then
    return nil
  end

  return { timer = config.getParameter("attackApproachTime"), stage = "approach" }
end

function attackState.enteringState(stateData)
  -- world.logInfo("Entering attack state")
end

function attackState.update(dt, stateData)
  if not self.target then return true end

  stateData.timer = stateData.timer - dt
  
  local toTarget = entity.distanceToEntity(self.target)

  if stateData.stage == "approach" then
    move(toTarget, true)
    if vec2.mag(toTarget) <= config.getParameter("attackStartDistance") then
      -- world.logInfo("winding up...")
      stateData.stage = "windup"
      stateData.timer = config.getParameter("attackWindupTime")
    end
  elseif stateData.stage == "windup" then
    animator.setAnimationState("movement", "swimSlow")
    setBodyDirection(toTarget)
    if stateData.timer <= 0 then
      -- world.logInfo("charging...")
      stateData.stage = "charge"
      animator.setAnimationState("attack", "melee")
      stateData.chargeDirection = toTarget
      stateData.timer = config.getParameter("attackChargeTime")
    end
  elseif stateData.stage == "charge" then
    if collides("blockedSensors") then return true end

    if entity.animationState("attack") == "melee" then
      entity.setDamageOnTouch(true)
      mcontroller.controlParameters({flySpeed = config.getParameter("attackChargeSpeed")})
      move(stateData.chargeDirection, true, true)
    else
      entity.setDamageOnTouch(false)
      move(stateData.chargeDirection, false)
    end
  end
  
  return stateData.timer <= 0
end

function attackState.leavingState(stateData)
  entity.setDamageOnTouch(false)
end
