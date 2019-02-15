function init()
  self.inputLocation = object.position()
  self.relocateLiquid = self.relocateLiquid or 0
  storage.liquidStandard = storage.liquidStandard or false
  storage.liquidPressurized = storage.liquidPressurized or false
  storage.outputProtected = storage.outputProtected or false
  storage.currentState = storage.currentState or false
  output(storage.currentState)
  self.timer = 0
end

function output(stateCurrent)
  if stateCurrent ~= storage.currentState then
    storage.currentState = stateCurrent
    animator.setAnimationState("inputState",toggleState(stateCurrent,"on","off"))
  end
end

function moveLiquid(inputLocation,outputLocation)
    -- what liquid are we in? We check here.
    local inValidLiquid= world.liquidAt(inputLocation)
    
    -- is there sufficient liquid at the location to relocate? If so, set the output liquid.
    if inValidLiquid and inValidLiquid[2] > 0.1 then  
        local outputLiquid = world.liquidAt(outputLocation)
        
        --is there liquid here?
        if (storage.liquidPressurized or (not outputLiquid or (outputLiquid[1] == inValidLiquid[1] and outputLiquid[2] < 1))) then 
        
            -- check protections at location
            if storage.outputProtected then 
              world.setTileProtection(world.dungeonId(storage.outputLocation), false) 
            end
            
            -- remove liquid from current location
            world.destroyLiquid(inputLocation)
            
            --spawn liquid at new location
            world.spawnLiquid(outputLocation,inValidLiquid[1],inValidLiquid[2]*1.01)
            
            -- is the zone protected? check
            if storage.outputProtected then 
              world.setTileProtection(world.dungeonId(storage.outputLocation), true) 
            end
            
            return true
        end
    end
    return false
end

-- node checks for wiring
function onInputNodeChange(args)
  setCurrentOutput()
end

function onNodeConnectionChange() 
  setCurrentOutput() 
end

-- look for pumps. This should probably be streamlined to not be necessary at all and can simply scan for an itemTag, or something of the sort
function locatePump(area)
    for outputObject,v in pairs(area) do
        local var = world.entityName(outputObject)
        if var == "pumpoutputStandard" or  
           var == "pumpoutputPressurized" then--or
           --var == "pumpoutputStandardElder" or
           --var == "pumpoutputPressurizedElder" then
        	return outputObject
        end
    end
    return false
 end

function setCurrentOutput()
    if object.isOutputNodeConnected(0) then
        local outputId =  locatePump(object.getOutputNodeIds(0))
        local var -- set to null
        if not outputId then
            var = "null"
        else
            storage.outputLocation = world.entityPosition(outputId)
            var = world.entityName(outputId)
            
            --tile protection will break the pumps if we dont store it and toggle it before and after each pump sequence.
            -- sadly, this spams the hell out of the log. I don't think theres another viable way to run this though.
            storage.outputProtected = world.isTileProtected(storage.outputLocation)
        end
        storage.liquidStandard = var == "pumpoutputStandard"
        storage.liquidPressurized = var == "pumpoutputPressurized"
    end
end

--update every dt ms
function update(dt)

    if self.timer <= 0 then
        setCurrentOutput()
        self.initialValue = 1000
    end
    
    self.initialValue = self.initialValue - 1
    local hasMovedLiquid = false
    
    if object.isOutputNodeConnected(0) and object.getInputNodeLevel(0)  then
        output(true)
        if storage.liquidStandard or storage.liquidPressurized then
            hasMovedLiquid = moveLiquid(self.inputLocation,storage.outputLocation)
            hasMovedLiquid = moveLiquid(toright(self.inputLocation),toright(storage.outputLocation)) or hasMovedLiquid
        end
    else
        output(false)
        object.setAllOutputNodes(false)
    end
    
    self.relocateLiquid = toggleState(hasMovedLiquid,3,self.relocateLiquid -1)
    object.setAllOutputNodes(self.relocateLiquid > 0)
end

--random helper functions
--ternary operator
function toggleState(condition,iftrue,iffalse)
    if condition then return iftrue else return iffalse end
end

-- will have to examine if this is actually needed. seems i could set this elsewhere.
--return one pos to the right
function toright( pos )
    return {pos[1]+1,pos[2]}
end
