require "/scripts/kheAA/transferUtil.lua"
local deltatime = 0;
local linkRange=1;

function init()
	transferUtil.init()
	storage.receiveItems=true
	inDataNode=0
	outDataNode=0
	storage.inContainers={}
	storage.outContainers={}
	storage.containerId=nil
	storage.containerPos={0,0}
	linkRange=20
end

function update(dt)
	deltatime = deltatime + dt;
	if deltatime < 1 then
		return;
	end
	deltatime=0
	findContainer()
	object.setOutputNodeLevel(outDataNode,not storage.containerId==nil)
end

function findContainer()
	if storage.containerId == nil then
		local tempRect=transferUtil.pos2Rect(storage.position,linkRange)
		if not world.regionActive(temprect) then
			world.loadRegion(tempRect)
		end
	elseif not world.regionActive(transferUtil.pos2Rect(storage.containerPos,1)) then
		world.loadRegion(transferUtil.pos2Rect(storage.containerPos,1))
		if not world.entityExists(storage.containerId) then
			storage.containerId=nil
		end
	end

	local objectIds = world.objectQuery(entity.position(), linkRange, { order = "nearest" })
	for _, objectId in pairs(objectIds) do
		if world.containerSize(objectId) then
			storage.containerId=objectId
			storage.containerPos=world.callScriptedEntity(storage.containerId,"entity.position")
			storage.inContainers[storage.containerId]=storage.containerPos
			storage.outContainers[storage.containerId]=storage.containerPos
			break
		end
	end 
end
