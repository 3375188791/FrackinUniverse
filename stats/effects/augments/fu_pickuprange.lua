function init()
  self.value = config.getParameter("refresh")
  script.setUpdateDelta(self.value)
end

function update(dt)
	world.placeObject("fu_pickuprangetemp", world.entityPosition(entity.id()), 1, {range = config.getParameter("range")})
end

function uninit()
  
end
