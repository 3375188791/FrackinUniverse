require '/scripts/power.lua'

function update(dt)
	storage.checkticks = (storage.checkticks or 0) + dt
	      
	local location = isn_getTruePosition() 
	local light = world.lightLevel(location)
	local powerLevel = config.getParameter("powerLevel",1) 
	if storage.checkticks >= 10 then
	  storage.checkticks = storage.checkticks - 10
	  if isn_powerGenerationBlocked() then
		animator.setAnimationState("meter", "0")
		power.setPower(0)
	  else
                genmult = 1
                if (light) <= 0.4 then genmult = 1
		elseif (light) >= 0.8 then genmult = 4 * (1 + light)	                  
		elseif (light) >= 0.75 then genmult = 4	  
		elseif (light) >= 0.70 then genmult = 3 
		elseif (light) >= 0.60 then genmult = 2 		  
		elseif (light) <= 0 then genmult = 0 
		end	  
		
		if world.type() == 'playerstation' then  genmult = 4 end -- player space station always counts as high power, but never MAX power.
		if world.liquidAt(location) then genmult = genmult * 0.5 end -- water halves the output
		
		local generated = math.min(powerLevel * genmult,36) -- max at 36 just in case.	
		
		if genmult >= 4 then animator.setAnimationState("meter", "4")
		elseif genmult > 3 then animator.setAnimationState("meter", "3")
		elseif genmult > 2 then animator.setAnimationState("meter", "2")
		elseif genmult < 2 then animator.setAnimationState("meter", genmult)
		else animator.setAnimationState("meter", "0")
		end
	        power.setPower(generated)
	  end
	end
	power.update(dt)
end


function isn_powerGenerationBlocked()
	-- Power generation does not occur if...
	local location = isn_getTruePosition()
	if world.type == 'unknown' then return true -- it's on a ship
	elseif world.underground(location) then return true -- it's underground
	elseif world.lightLevel(location) < 0.2 then return true -- its light enough
	elseif world.timeOfDay() > 0.50 then return true end -- its not daytime. might replace this last one if we can selectively ignore lights
end

function isn_getTruePosition()
  storage.truepos = storage.truepos or {entity.position()[1] + math.random(2,3), entity.position()[2] + 1}
  return storage.truepos
end