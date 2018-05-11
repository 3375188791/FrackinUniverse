require '/scripts/power.lua' --needed for contains()
require '/scripts/util.lua'
local crafting = false
local output = nil

function init()
	power.init()
	self = config.getParameter("duplicator")
	self.craftTime = config.getParameter("craftTime")
	self.timer = self.craftTime
end

function update(dt)
	--if wireCheck() == true then
		if crafting == false then
			if power.getTotalEnergy() >= config.getParameter('isn_requiredPower') then
				local fuelSlot = world.containerItemAt(entity.id(),0)
				fuelSlot = fuelSlot and fuelSlot.name or ""

				local inputOutputSlot = world.containerItemAt(entity.id(),1)
				inputOutputSlot = inputOutputSlot and inputOutputSlot.name or ""
				
				local fuelValue=self.fuel[fuelSlot] or 0
			
				if contains(self.inputOutput,inputOutputSlot) then
					world.containerConsumeAt(entity.id(),0,1)
					self.timer = self.craftTime
					output = inputOutputSlot
					outputCount = fuelValue  --  math.round(math.max( fuelValue * (item.price / 1000),10))  (needs root.itemConfig?)
					crafting = true
				end
			end
		end
	--end
	self.timer = self.timer - dt
	if self.timer <= 0 then
		if crafting == true then
		  animator.setAnimationState("base", "on")
			if power.consume(config.getParameter('isn_requiredPower')) then
				local slots = getOutSlotsFor(output)
				for _,i in pairs(slots) do
					output = world.containerPutItemsAt(entity.id(), {name=output,count=outputCount}, i)  
					if output == nil then
						break
					end
				end

				if output ~= nil then
				  world.spawnItem(output, entity.position(), outputCount)
				end
				crafting = false
			end
		else
		  animator.setAnimationState("base", "off")
		end
	end
	if not crafting and self.timer <= 0 then
		self.timer = self.craftTime
	end
	power.update(dt)
end

function wireCheck()
	return (object.inputNodeCount() == 0) or not object.isInputNodeConnected(0) or object.getInputNodeLevel(0)
end

function getOutSlotsFor(something)
    local empty = {} -- empty slots in the outputs
    local slots = {} -- slots with a stack of "something"

    for i = 2, 2 do -- iterate all output slots
        local stack = world.containerItemAt(entity.id(), i) -- get the stack on i
        if stack ~= nil then -- not empty
            if stack.name == something then -- its "something"
                table.insert(slots,i) -- possible drop slot
            end
        else -- empty
            table.insert(empty, i)
        end
    end

    for _,e in pairs(empty) do -- add empty slots to the end
        table.insert(slots,e)
    end
    return slots
end