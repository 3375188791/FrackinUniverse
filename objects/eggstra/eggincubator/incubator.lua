-- Egg Incubation
-- player places egg in incubator
-- egg hatch time is eggs base hatch time +- any modifiers
-- factors that influence egg hatch time are "hardiness", the type of egg, warmth. colder worlds hatch slower (unless a cold-type egg)
-- plus every egg also gets a random variable attached to it that can change the hatch time, so each egg is a bit unique

function init()
  -- egg type?
  incubation = {
    default = 400,
    egg = 400,
    henegg = 400,
    primedegg = 200,
    raptoregg = 1200,
    firefluffaloegg = 800,
    poisonfluffaloegg =  800,
    icefluffaloegg = 800,
    electricfluffalofegg = 800,
    fluffaloegg = 400,
    robothenegg = 400,
    mooshiegg = 300
  }
  -- egg modifiers
  eggmodifiers = {
    default = 1
  }

  -- change this to check the egg instead. each egg has a spawnMod that influences its hatch time
  spawnMod = math.random(10) -- + config.getParameter("spawnModValue")

  -- is world temperature suitable? warmer weather reduces spawn time unless it likes cold
  storage.warmth = 0
  storage.cold = 0

  -- how tough is the egg? the tougher it is, the longer it takes to hatch
  storage.hardiness = 0
end



function update()
  checkHatching()
end

function checkHatching()
  if entity.id() then
    local container = entity.id()
    local item = world.containerItemAt(container, 0)
    if item ~= nil and incubation[item.name] ~= nil then

      -- set incubation time
      if storage.incubationTime == nil then
        storage.incubationTime = os.time()
      end
      --sb.logInfo("Incubation time: %s", storage.incubationTime)

      -- set the eggs current age
      local age = (os.time() - storage.incubationTime) - spawnMod
      --sb.logInfo("age: %s", age)
      --sb.logInfo("hatch modifier: %s", spawnMod)

      -- base hatch time
      local hatchTime = incubation[item.name]
      if hatchTime == nil then   -- Cannot ever be true, since this if-block never gets run if hatchTime would be nil
        hatchTime = incubation.default
        --sb.logInfo("Hatch time: %s", hatchTime)
      end

      -- forced hatch time
      local forceHatchTime = item.forceHatchTime
      if forceHatchTime == nil then
        forceHatchTime = (hatchTime / 2)
      end

      -- set visual growth bar on the incubator
      self.indicator = math.ceil( (age / hatchTime) * 9)

      -- hatching check
      if age >= hatchTime then
        hatchEgg()
        age = 0
        self.indicator = 0
        storage.incubationTime = nil
        self.timer = 0
      end

        if self.indicator == nil then self.indicator = 0 end
        if self.timer == nil or self.timer > self.indicator then self.timer = self.indicator - 1 end
        if self.timer > -1 then animator.setGlobalTag("bin_indicator", self.timer) end
        self.timer = self.timer + 1

    end
  end



end

-- function canHatch(item)  -- is it a supported egg type?
--   if item == nil then return false end
--   if item.name == "egg" or item.name =="henegg" then return true end
--   if item.name == "primedegg" then return true end
--   if item.name == "goldenegg" then return true end
--   if item.name == "raptoregg" then return true end
--   if item.name == "mooshiegg" then return true end
--   if item.name == "fluffaloegg" then return true end
--   if item.name == "firefluffaloegg" then return true end
--   if item.name == "icefluffaloegg" then return true end
--   if item.name == "poisonfluffaloegg" then return true end
--   if item.name == "electricfluffaloegg" then return true end
--   if item.name == "robothenegg" then return true end
--   return false
-- end

function hatchEgg()  --make the baby
  local container = entity.id()
  local item = world.containerTakeNumItemsAt(container, 0, 1)
  if item then
    local spawnposition = entity.position()
    spawnposition[2] = spawnposition[2] + 2
    local parameters = {}
    parameters.persistent = true
    parameters.damageTeam = 0
    parameters.startTime = os.time()
    parameters.damageTeamType = "passive"
    if item.name == "egg" or item.name == "primedegg" or item.name == "henegg" then
      world.spawnMonster("fuhenbaby", spawnposition, parameters)
    elseif item.name == "goldenegg" then
      world.spawnItem("money", spawnposition, 5000)
    elseif item.name == "mooshiegg" then
      world.spawnMonster("fumooshibaby", spawnposition, parameters)
    elseif item.name == "fluffaloegg" then
      world.spawnMonster("fufluffalo", spawnposition, parameters)
    elseif item.name == "firefluffaloegg" then
      world.spawnMonster("fufirefluffalo", spawnposition, parameters)
    elseif item.name == "icefluffaloegg" then
      world.spawnMonster("fuicefluffalo", spawnposition, parameters)
    elseif item.name == "poisonfluffaloegg" then
      world.spawnMonster("fupoisonfluffalo", spawnposition, parameters)
    elseif item.name == "electricfluffaloegg" then
      world.spawnMonster("fuelectricfluffalo", spawnposition, parameters)
    elseif item.name == "robothenegg" then
      world.spawnMonster("furobothenbaby", spawnposition, parameters)
    elseif item.name == "raptoregg" then
      --sb.logInfo("Trying to spawn raptor. Parameters is %s", parameters)
      world.spawnMonster("furaptor4", spawnposition, parameters)
    end
  end
  storage.incubationTime = nil
end
