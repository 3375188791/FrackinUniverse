function init()
  local bounds = mcontroller.boundBox()
end

function update(dt)
  mcontroller.controlModifiers({
      speedModifier = 1.15,
      airJumpModifier = 1.20,
      airForce = 30
    })
end

function uninit()
  
end