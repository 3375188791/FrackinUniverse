require("/scripts/vec2.lua")

function init()
if (status.stat("poisonResistance",0)  >= 1.0) or status.statPositive("poisonStatusImmunity") or status.statPositive("gasImmunity") or world.type()=="unknown" then
  effect.expire()
end

-- checks strength of effect vs resistance
if (config.getParameter("baseDmgPerTick",0) >= 1) and (status.stat("poisonResistance",0)  >= 0.3) then
  effect.expire()
elseif (config.getParameter("baseDmgPerTick",0) >= 2) and (status.stat("poisonResistance",0)  >= 0.6) then
  effect.expire()
elseif (config.getParameter("baseDmgPerTick",0) >= 3) and (status.stat("poisonResistance",0)  >= 1.0) then
  effect.expire()
elseif (config.getParameter("biomeThreshold",0) == 1.2) and (status.stat("poisonResistance",0)  >= 0.5) then
  effect.expire()   
end

  self.timerRadioMessage = 0  -- initial delay for secondary radiomessages
  
  -- Environment Configuration --
  --base values
  self.baseRate = config.getParameter("baseRate",0)                
  self.baseDmg = config.getParameter("baseDmgPerTick",0)        
  self.baseDebuff = config.getParameter("baseDebuffPerTick",0)     
  self.biomeTemp = config.getParameter("biomeTemp",0)              
  
  --timers
  self.biomeTimer = self.baseRate
  self.biomeTimer2 = (self.baseRate * (1 + status.stat("poisonResistance",0)) *10)
  
  --conditionals

  self.windLevel =  world.windLevel(mcontroller.position())        -- is there wind? we note that too
  self.biomeThreshold = config.getParameter("biomeThreshold",0)    -- base Modifier (tier)
  self.biomeNight = config.getParameter("biomeNight",0)            -- is this effect worse at night? how much?
  self.situationPenalty = config.getParameter("situationPenalty",0)-- situational modifiers are seldom applied...but provided if needed
  self.liquidPenalty = config.getParameter("liquidPenalty",0)      -- does liquid make things worse? how much?  
  
  -- activate visuals and check stats
  if not self.usedIntro then
    world.sendEntityMessage(entity.id(), "queueRadioMessage", "ffbiomegenericpoison", 1.0) -- send player a warning
    self.usedIntro = 1
  end
  
  activateVisualEffects() 
  script.setUpdateDelta(5)
end

-- *******************Damage effects
function setEffectDamage()
  return ( ( self.baseDmg ) *  (1 -status.stat("poisonResistance",0) ) * self.biomeThreshold  )
end

function setEffectDebuff()
  return ( ( ( self.baseDebuff) * self.biomeTemp ) * (1 -status.stat("poisonResistance",0) * self.biomeThreshold) )
end

function setEffectTime()
  return (self.baseRate * (1 - status.stat("poisonResistance",0)))
end

-- ******** Applied bonuses and penalties
function setNightPenalty()
  if (self.biomeNight > 1) then
    self.baseDmg = self.baseDmg + self.biomeNight
    self.baseDebuff = self.baseDebuff + self.biomeNight
  end
end

function setSituationPenalty()
  if (self.situationPenalty > 1) then
    self.baseDmg = self.baseDmg + self.situationPenalty
    self.baseDebuff = self.baseDebuff + self.situationPenalty 
  end
end

function setLiquidPenalty()
  if (self.liquidPenalty > 1) then
    self.baseDmg = self.baseDmg * 2
    self.baseDebuff = self.baseDebuff + self.liquidPenalty 
  end
end

function setWindPenalty()
  self.windLevel =  world.windLevel(mcontroller.position())
  if (self.windLevel > 1) then
    self.biomeThreshold = self.biomeThreshold + (self.windlevel / 100)
  end  
end

-- ********************************

--**** Other functions
function getLight()
  local position = mcontroller.position()
  position[1] = math.floor(position[1])
  position[2] = math.floor(position[2])
  local lightLevel = world.lightLevel(position)
  lightLevel = math.floor(lightLevel * 100)
  return lightLevel
end

function daytimeCheck()
	return world.timeOfDay() < 0.5 -- true if daytime
end

function undergroundCheck()
	return world.underground(mcontroller.position()) 
end


function isDry()
local mouthPosition = vec2.add(mcontroller.position(), status.statusProperty("mouthPosition"))
	if not world.liquidAt(mouthPosition) then
	    inWater = 0
	end
end

function toHex(num)
  local hex = string.format("%X", math.floor(num + 0.5))
  if num < 16 then hex = "0"..hex end
  return hex
end

function hungerLevel()
  if status.isResource("food") then
   return status.resource("food")
  else
   return 50
  end
end

--*********alert the player that they are affected
function activateVisualEffects()
  effect.setParentDirectives("fade=558833=0.7")
  animator.setParticleEmitterOffsetRegion("poisonbreath", mcontroller.boundBox())
  animator.setParticleEmitterActive("poisonbreath", true) 
end

function makeAlert()
   local statusTextRegion = { 0, 1, 0, 1 }
   animator.setParticleEmitterOffsetRegion("statustext", statusTextRegion)
   animator.burstParticleEmitter("statustext")   
   animator.playSound("bolt")
end


function update(dt)
self.biomeTimer = self.biomeTimer - dt 
self.biomeTimer2 = self.biomeTimer2 - dt 
self.timerRadioMessage = self.timerRadioMessage - dt

--set the base stats
  self.baseRate = config.getParameter("baseRate",0)                
  self.baseDmg = config.getParameter("baseDmgPerTick",0)        
  self.baseDebuff = config.getParameter("baseDebuffPerTick",0)     
  self.biomeTemp = config.getParameter("biomeTemp",0)  
  self.biomeThreshold = config.getParameter("biomeThreshold",0)    
  self.biomeNight = config.getParameter("biomeNight",0)            
  self.situationPenalty = config.getParameter("situationPenalty",0)
  self.liquidPenalty = config.getParameter("liquidPenalty",0)   
  
  self.baseRate = setEffectTime()
  self.damageApply = setEffectDamage()   
  self.debuffApply = setEffectDebuff() 
   
  -- environment checks
  daytime = daytimeCheck()
  underground = undergroundCheck()
  local lightLevel = getLight() 

      if status.stat("poisonResistance",0) < 1.0 then  
        self.windLevel =  world.windLevel(mcontroller.position())
        if self.windLevel >= 40 then
                setWindPenalty() 
                if self.timerRadioMessage == 0 then
                  if not self.usedWind then
                    world.sendEntityMessage(entity.id(), "queueRadioMessage", "ffbiomepoisonwind", 1.0) -- send player a warning
                    self.timerRadioMessage = 220 
                    self.usedWind = 1
                  end
		end
        end

	self.damageApply = setEffectDamage()   
	self.debuffApply = setEffectDebuff()  
	
      if (self.biomeTimer2 <= 0) and (status.stat("poisonResistance",0) < 1.0) and (status.stat("powerMultiplier") >=0.05) then
            effect.addStatModifierGroup({
              {stat = "powerMultiplier", amount = -(self.debuffApply/100)  }
            })
        makeAlert()
        self.biomeTimer2 = setEffectTime()
      end 
        
        status.modifyResource("health", -self.damageApply * dt)

             self.statedit = 1 * (status.resource("health")/100)
             if self.statedit <=0 then
               self.statedit = 0
             end
             mcontroller.controlModifiers({
	         airJumpModifier = self.statedit, 
	         speedModifier = self.statedit 
             })  
      end     
end       

function uninit()

end