function init(virtual)
	if virtual == true then return end
	
	if storage.currentstoredpower == nil then storage.currentstoredpower = 0 end
	if storage.powercapacity == nil then storage.powercapacity = config.getParameter("isn_batteryCapacity") end
	if storage.voltage == nil then storage.voltage = config.getParameter("isn_batteryVoltage") end
	if storage.active == nil then storage.active = true end
end

function update(dt)
	if storage.currentstoredpower < storage.voltage then
		-- less than storage.voltage in store; considered discharged
		animator.setAnimationState("meter", "d")
	else	-- not discharged
		local powerlevel = isn_getXPercentageOfY(storage.currentstoredpower,storage.powercapacity)
		if powerlevel ~= 0 then powerlevel = powerlevel / 10 end	-- Q:Why a separate statement? A:if function returns nil, /10 will error. -r
		powerlevel = isn_numericRange(powerlevel,0,10)
		animator.setAnimationState("meter", tostring(math.floor(powerlevel)))
	end
	
	local powerinput = isn_getCurrentPowerInput(true)
	if powerinput >= 1 then
		storage.currentstoredpower = storage.currentstoredpower + powerinput
		-- sb.logInfo(string.format("Storing %.2fu, now at %.2fu", powerinput, storage.currentstoredpower))
	end

	-- drain power according to attached devices; max drain is storage.voltage
	-- without the max drain, a field generator will drain each of three 8u batteries at a rate of 24u per battery state update
	local poweroutput = math.min(storage.voltage, isn_sumPowerActiveDevicesConnectedOnOutboundNode(0))
	if poweroutput > 0 and storage.currentstoredpower > 0 then
		storage.currentstoredpower = storage.currentstoredpower - poweroutput
		-- sb.logInfo(string.format("Draining %.2fu, now at %.2fu", poweroutput, storage.currentstoredpower))
	end
	
	storage.currentstoredpower = math.min(storage.currentstoredpower, storage.powercapacity)
end

function isn_getCurrentPowerStorage()
	return isn_getXPercentageOfY(storage.currentstoredpower,storage.powercapacity)
end

function isn_getCurrentPowerOutput(divide)
	if not storage.active then return 0 end  -- This might be pointless. Need to think about it. -r
	if storage.currentstoredpower <= 0 then return 0 end
	local divisor = isn_countPowerDevicesConnectedOnOutboundNode(0)
	
	-- if divisor < 1 then return 0 end
	if divide and divisor > 0 then return storage.voltage / divisor
	else return storage.voltage end
end

function onNodeConnectionChange()
	if isn_checkValidOutput() then object.setOutputNodeLevel(0, true)
	else object.setOutputNodeLevel(0, false) end
end

function onInputNodeChange(args)
	storage.active = (object.isInputNodeConnected(0) and object.getInputNodeLevel(0)) or (object.isInputNodeConnected(1) and object.getInputNodeLevel(1))
end