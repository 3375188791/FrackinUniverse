require("/scripts/vec2.lua")

function init()
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
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "ffbiomepoison", 1.0) -- send player a warning
  activateVisualEffects() 
  script.setUpdateDelta(5)
end

-- alert the player that they are affected
function activateVisualEffects()
  effect.setParentDirectives("fade=558833=0.7")
  animator.setParticleEmitterOffsetRegion("poisonbreath", mcontroller.boundBox())
  animator.setParticleEmitterActive("poisonbreath", true) 
end


-- ***************global reset
function resetValues()
  self.biomeTemp = config.getParameter("biomeTemp",0)              -- sets the base variable for the biome/effect
  self.windLevel =  world.windLevel(mcontroller.position())        -- is there wind? we note that too
  self.baseDmg = config.getParameter("baseDmgPerTick",0)           -- damage per tick
  self.baseDebuff = config.getParameter("baseDebuffPerTick",0)     --debuff per tick
  self.biomeThreshold = config.getParameter("biomeThreshold",0)    -- base Modifier (tier)
  self.biomeNight = config.getParameter("biomeNight",0)            -- is this effect worse at night? how much?
  self.situationPenalty = config.getParameter("situationPenalty",0)-- situational modifiers are seldom applied...but provided if needed
  self.liquidPenalty = config.getParameter("liquidPenalty",0)      -- does liquid make things worse? how much?  
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

function setNightPenalty()
  self.modDmg = self.baseDmg + self.biomeNight
  self.modDebuff = self.baseDebuff + self.biomeNight 
  self.baseDmg = self.damageApply + self.modDmg
  self.baseDebuff = self.debuffApply + self.modDebuff
end

function setSituationPenalty()
  self.modDmg = self.baseDmg + self.situationPenalty
  self.modDebuff = self.baseDebuff + self.situationPenalty
  self.baseDmg = self.damageApply + self.modDmg
  self.baseDebuff = self.debuffApply + self.modDebuff 
end

function setLiquidPenalty()
  self.modDmg = self.baseDmg + self.liquidPenalty
  self.modDebuff = self.baseDebuff + self.liquidPenalty
  self.baseDmg = self.damageApply + self.modDmg
  self.baseDebuff = self.debuffApply + self.modDebuff
end

function setWindPenalty()
  self.windLevel =  world.windLevel(mcontroller.position())
  self.modThreshold = (self.windlevel / 100) + self.biomeThreshold
  self.biomeThreshold = self.biomeThreshold + self.modThreshold  
end



function update(dt)
self.biomeTimer = self.biomeTimer - dt 
self.biomeTimer2 = self.biomeTimer2 - dt 
self.timerRadioMessage = self.timerRadioMessage - dt
self.damageApply = setEffectDamage()
self.debuffApply = setEffectDebuff()
self.baseRate = setEffectTime()
self.biomeThreshold = config.getParameter("biomeThreshold",0)

      if status.stat("poisonResistance",0) < 1.0 then  
        self.windLevel =  world.windLevel(mcontroller.position())
        if self.windLevel >= 40 then
                if self.timerRadioMessage == 0 then
                  world.sendEntityMessage(entity.id(), "queueRadioMessage", "ffbiomepoisonwind", 1.0) -- send player a warning
                  self.timerRadioMessage = 60
                    self.biomeThreshold = self.biomeThreshold * 1.6
  		    self.damageApply = setEffectDamage()
  		    self.debuffApply = setEffectDebuff()                 
		end
        end

      if (self.biomeTimer2 <= 0) and (status.stat("poisonResistance",0) < 1.0) and (status.stat("powerMultiplier") >=0.05) then
            effect.addStatModifierGroup({
              {stat = "powerMultiplier", amount = -((self.baseDebuff*2)/100)  }
            })
        makeAlert()
        self.biomeTimer2 = setEffectTime()
      end 
        
        self.damageApply = (self.damageApply /50)  
        status.modifyResource("health", -self.damageApply * dt)

        -- less agile the more damaged you are
        mcontroller.controlModifiers({  
	 airJumpModifier = 1 * (status.resource("health")/100), 
	 speedModifier = 1 * (status.resource("health")/100)
        }) 
      end     
end       

function makeAlert()
  local statusTextRegion = { 0, 1, 0, 1 }
  animator.setParticleEmitterOffsetRegion("statustext", statusTextRegion)
  animator.burstParticleEmitter("statustext")   
   animator.playSound("bolt")
end

function uninit()

end