require "/scripts/kheAA/transferUtil.lua"

excavatorCommon={}
states={}
reDrillLevelFore=0
redrillPosFore=nil
reDrillLevelback=0
redrillPosBack=nil
deltatime = 0;
local delta2=0
step=0;
time = 0;
--[[
node list:
	powerNode
	hiPumpNode
	outDataNode
	outLiquidNode
	hiMineNode

]]

function excavatorCommon.init(drill,pump)
	local did=false
	delta2=100
	transferUtil.init()
	storage.facing=util.clamp(object.direction(),0,1)
	storage.isDrill=drill
	storage.isPump=pump
	if drill == true or pump == true then
		storage.width=0
		did=true
	end
	if pump then
		require "/scripts/kheAA/liquidLib.lua"
		storage.depth=-1
		storage.liquids={}
		did=true
	end
	if did then
		storage.state="start"
		anims()
	else
		storage.state="off"
	end
end

function excavatorCommon.cycle(dt)
	if delta2 > 1 then
		transferUtil.loadSelfContainer()
		delta2=0
	else
		delta2=delta2+dt
	end
	if storage.state=="off" then
		return
	end
	if transferUtil.powerLevel(powerNode) then
		setRunning(true)
		if storage.state=="stop" then
			storage.state="start"
			return;
		end
	else
		deltatime=0
	end
	deltatime = deltatime + dt;
	time = time + dt;
	if time > 10 then
		local pos = storage.position;
		local x1 = world.xwrap(pos[1] - 1);
		local x2 = world.xwrap(pos[1] + 1);
		local rect = {x1, pos[2] - 1, x2, pos[2] + 1}
		world.loadRegion(rect);
		if storage.isDrill then
			x1 = world.xwrap(pos[1] + storage.drillPos[1] - storage.maxWidth)
			x2 = world.xwrap(pos[1] + storage.drillPos[1] + storage.maxWidth)
			rect = {x1, pos[2] + storage.drillPos[2] - 5, x2, pos[2] + storage.drillPos[2] + 5};
			world.loadRegion(rect);
		end
		time=0
	end
	states[storage.state](dt);
end

function states.start(dt)
	if storage.isDrill then
		storage.state="moveDrillBar"
	else
		storage.state="movePump"
	end
end

function states.moveDrillBar(dt)
	if deltatime >= 0.2 then
		step = step + 0.2;
		deltatime=0
	end
	animator.resetTransformationGroup("horizontal")
	animator.scaleTransformationGroup("horizontal", {storage.width+step,1});
	animator.translateTransformationGroup("horizontal", {2,1});
	if step >= 1 then
		step = 0;
		storage.width = storage.width + 1;
		local pos = storage.position;
		local searchPos = {world.xwrap(pos[1] + storage.width + 2), pos[2] + 1};
		if storage.width >= storage.maxWidth or world.material(searchPos, "foreground") then
			animator.setAnimationState("drillState", "on");
			renderDrill(storage.drillPos)
			storage.state = "moveDrill";
			storage.drillTarget = excavatorCommon.getNextDrillTarget();
			setRunning(false);
		end
	end
	
end

function states.moveDrill(dt)
	local drillPos = storage.drillPos;
	local drillTarget = storage.drillTarget;
	local drillDir = excavatorCommon.getDir();
	if step >= 1 then
		step = 0;
		drillPos[1] = drillPos[1] + drillDir[1];
		drillPos[2] = drillPos[2] + drillDir[2];
		renderDrill({drillPos[1], drillPos[2]})
	end
	if deltatime >= 0.05 then
		step = step + 0.1;
		deltatime = 0;
		renderDrill({drillPos[1] + drillDir[1] * step, drillPos[2] + drillDir[2] * step})
	end
	if drillPos[1] == drillTarget[1] and drillPos[2] == drillTarget[2] then
		if storage.isPump then
			storage.state = "pump";
		else
			storage.state = "mine";
		end
	end
end



function states.movePump(dt)
	if deltatime >= 0.2 then
		step = step + 0.2;
	end
	if step >= 1 then
		step = 0;
		storage.depth = storage.depth - 1;
		storage.state = "pump";
		renderPump(step)
	end
	if deltatime >= 0.1 then
		step = step + 0.1;
		deltatime = 0;
		renderPump(step)
	end
end



function excavatorCommon.grab(grabPos)
	local drops = world.itemDropQuery(grabPos,5);
	for i = 1, #drops do
		local item = world.takeItemDrop(drops[i]);
		if item~=nil then
			transferUtil.throwItemsAt(storage.containerId,storage.inContainers[storage.containerId],item,true)
		end
	end
end



function states.mine(dt)
	if deltatime < 0.1 then
		return;
	end
	deltatime = 0;
	if redrillPosFore ~= nil then
		if reDrillLevelFore == 1 then
			if world.material(redrillPosFore,"foreground") then
				world.damageTileArea(redrillPosFore,1.25, "foreground", redrillPosFore, "plantish", storage.drillPower/3)
				reDrillLevelFore=2
				excavatorCommon.grab(redrillPosFore)
				return
			else
				reDrillLevelFore=0
				redrillPosFore=nil
			end
		elseif reDrillLevelFore == 2 then
			if world.material(redrillPosFore,"foreground") then
				world.damageTileArea(redrillPosFore,1.25, "foreground", redrillPosFore, "plantish", storage.drillPower/3)
				reDrillLevelFore=0
				excavatorCommon.grab(redrillPosFore)
				return
			else
				reDrillLevelFore=0
				redrillPosFore=nil
			end
		end
	end
	if redrillPosBack ~= nil then
		if reDrillLevelBack == 1 then
			if world.material(redrillPosBack,"background") then
				world.damageTileArea(redrillPosBack,1.25, "background", redrillPosBack, "plantish", storage.drillPower/3)
				reDrillLevelBack=2
				excavatorCommon.grab(redrillPosBack)
				return
			else
				reDrillLevelBack=0
				redrillPosBack=nil
			end
		elseif reDrillLevelBack == 2 then
			if world.material(redrillPosBack,"background") then
				world.damageTileArea(redrillPosBack,1.25, "background", redrillPosBack, "plantish", storage.drillPower/3)
				reDrillLevelBack=0
				excavatorCommon.grab(redrillPosBack)
				return
			else
				reDrillLevelBack=0
				redrillPosBack=nil
			end
		end
	end

	local absdrillPos = transferUtil.getAbsPos(storage.drillPos,storage.position);
	if (storage.position[2]-absdrillPos[2]) > storage.drillRange then
		drillAnimReset()
		drillReset()
		setRunning(false)
		storage.state="stop"
		return
	end
	if world.material(absdrillPos,"foreground") then
		world.damageTiles({absdrillPos}, "foreground", absdrillPos, "plantish", storage.drillPower)
		if world.material(absdrillPos,"foreground") then
			local weeds=world.entityQuery({absdrillPos[1]-20,absdrillPos[2]-20},{absdrillPos[1]+20,absdrillPos[2]+20})
			if weeds~=nil then
				for k,v in pairs(weeds) do
					if world.entityExists(v) then
					end
				end
				redrillPosFore=absdrillPos;
				reDrillLevelFore=1
				return
			end
		end
	end
	if transferUtil.powerLevel(hiMineNode,true) then
		world.damageTiles({absdrillPos}, "background", absdrillPos, "plantish", storage.drillPower)
		if world.material(absdrillPos,"background") then
			world.damageTiles({absdrillPos}, "background", absdrillPos, "plantish", storage.drillPower)
			if world.material(absdrillPos,"background") then
				redrillPosBack=absdrillPos;
				reDrillLevelBack=1
				return
			end
		end
	end
	storage.drillTarget = excavatorCommon.getNextDrillTarget();
	deltatime=0.1
	storage.state = "moveDrill";
	excavatorCommon.grab(absdrillPos)
	
end

function states.pump(dt)
	if deltatime < 0.2 then
		return;
	end
	deltatime = 0;

	--###world.forceDestroyLiquid()
	local liquid = world.destroyLiquid(transferUtil.getAbsPos({storage.facing, storage.depth},storage.position));
	if liquid ~= nil then
		if storage.liquids[liquid[1]] == nil then
			storage.liquids[liquid[1]] = 0;
		end
		storage.liquids[liquid[1]] = storage.liquids[liquid[1]] + liquid[2];
	end
	
	if not transferUtil.powerLevel(hiPumpNode,true) then
		for k,v in pairs(storage.liquids) do
			if v >= 1 then
				if liquidLib.liquidIds[k] ~= nil then
					local try,count=transferUtil.throwItemsAt(storage.containerId,storage.inContainers[storage.containerId],{name = liquidLib.liquidIds[k], count = 1})
					if try then
						storage.liquids[k] = storage.liquids[k] - count;
						break
					end
				else
				--BLOATY!
					local tempList=object.getOutputNodeIds(outLiquidNode)
					if #tempList > 0 then
						local outputPipes={}
						for _,v in pairs(tempList) do
							local result=world.callScriptedEntity(v[1],"liquidLib.canReceiveLiquid")
							if result then
								table.insert(outputPipes,v[1])
							end
						end
						if #outputPipes>0 then
							local outputPipe=transferUtil.nearest(entity.id(),outputPipes)
							world.callScriptedEntity(outputPipe,"liquidLib.receiveLiquid",{k,1})
							storage.liquids[k]=v-1
						end
						break
					end
				end
			end
		end
	else
		local myItems=world.containerItems(entity.id());
		local itmConf=nil;
		local temp;
		for k,v in pairs(liquidLib.liquidIds) do
			if world.containerConsume(entity.id(),{name=v,1}) then
				storage.liquids[k]=storage.liquids[k]+1
			end
		end
		--NEED TO REFINE THIS! seriously bloaty.
		for k,v in pairs(storage.liquids) do
			local tempList=object.getOutputNodeIds(outLiquidNode)
			if #tempList > 0 then
				local outputPipes={}
				for _,v in pairs(tempList) do
					local result=world.callScriptedEntity(v[1],"liquidLib.canReceiveLiquid")
					if result then
						table.insert(outputPipes,v[1])
					end
				end
				if #outputPipes>0 then
					local outputPipe=transferUtil.nearest(storage.containerId,storage.inContainers[storage.containerId],outputPipes)
					world.callScriptedEntity(outputPipe,"liquidLib.receiveLiquid",{k,1})
					storage.liquids[k]=v-1
				end
				break
			end
		end
	end
	if world.material(transferUtil.getAbsPos({storage.facing, storage.depth - 1},storage.position), "foreground") then
		return;
	end
	if liquid == nil then
		if storage.isDrill then
			storage.state = "moveDrill";
		else
			storage.state = "movePump";
		end
	end
end


function states.stop()
	-- body
end


function excavatorCommon.getNextDrillTarget()
	local pos = storage.position;
	local target = {storage.drillPos[1], storage.drillPos[2]}
	if storage.facing == 1 and target[1] >= storage.width + 1 then
		storage.facing = -1
		target[2] = target[2] - 1;	 
	elseif storage.facing == -1 and target[1] <= 2 then
		storage.facing = 1
		target[2] = target[2] - 1;
	else
		target[1] = target[1] + storage.facing;
	end
	if pos[2] + target[2] <= 1 then
		storage.state = "stop";
	end
	
	storage.drillDir = excavatorCommon.getDir();
	--world.loadRegion({ target[1]-4, target[2]-4, target[1]+4, target[2]+4 })
	return target;
end

function excavatorCommon.getDir()
	local dir = {0,0};
	local drillPos = storage.drillPos;
	local drillTarget = storage.drillTarget;
		if drillTarget[1] > drillPos[1] then
			dir[1] = 1
		elseif drillTarget[1] < drillPos[1] then
			dir[1] = -1
		end
		if drillTarget[2] > drillPos[2] then
			dir[2] = 1
		elseif drillTarget[2] < drillPos[2] then
			dir[2] = -1
		end
		storage.drillDir = dir;
		return dir;
end

function anims()
	if(animWarn~=true) then
		sb.logInfo("Excavator lib loaded. Your anims, however, are not.")
		animWarn=true
	end
end