function init()
	warningResource="biomeairlesswarning"
	message(true)
end

function update(dt)
	message()
end

function message(force)
	if not world.breathable(entity.position()) then
		if status.isResource(warningResource) then
			if not status.resourcePositive(warningResource) then
				world.sendEntityMessage(entity.id(), "queueRadioMessage", "biomeairless", 1.0)
			end
			status.setResourcePercentage(warningResource,1.0)
		elseif force then
			world.sendEntityMessage(entity.id(), "queueRadioMessage", "biomeairless", 30.0)
		end
	end
end