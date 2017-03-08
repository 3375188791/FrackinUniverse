require("/scripts/vec2.lua")

function init()
  -- Environment Configuration --

  --first, the modifier for temperature
  self.biomeTemp = config.getParameter("biomeTemp",0)
  
  --then, the modifier for night time effects
  self.biomeNight = config.getParameter("biomeNight",0)
  
  -- what is critical temperature threshold? This value is used to determine chance of catching hypothermia
  self.biomeThreshold = config.getParameter("biomeThreshold",0)
  
  -- now we set the base effect config
  self.windLevel =  world.windLevel(mcontroller.position())
  self.radioMessageTimer = 1
  self.baseDmg = config.getParameter("baseDmgPerTick",0)
  self.baseDebuff = config.getParameter("baseDebuffPerTick",0)
  self.baseRate = config.getParameter("baseRate",0)
  self.biomeTimer = config.getParameter("baseRate",0)
  self.biomeTimer2= config.getParameter("baseRate",0)
  
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "ffbiomepoison", 1.0) -- send player a warning
  -- set values, activate effects
  activateVisualEffects()
  setValues()
  self.timerRadioMessage = 0
  self.situationalPenalty = 0
  script.setUpdateDelta(5)
end

function setValues()
-- check resist level and apply modifier for effects
-- this effects how hard the environmental effects hit you in general. Note that the higher up you go in resists, the less severe effects become , until they are effectively ignorable.
  if status.stat("poisonResistance") <= 0.99 then
    self.poisonhitmod = 1.5 * 1+ (status.stat("poisonResistance",0) * 4)
  elseif status.stat("poisonResistance") <= 0.80 then
    self.poisonhitmod = 1.25 * 1+ (status.stat("poisonResistance",0) * 3.5)    
  elseif status.stat("poisonResistance") <= 0.75 then
    self.poisonhitmod = 1 * 1+ (status.stat("poisonResistance",0) * 3) 
  elseif status.stat("poisonResistance") <= 0.65 then
    self.poisonhitmod = 0.8 * 1+ (status.stat("poisonResistance",0) * 2.5)    
  elseif status.stat("poisonResistance") <= 0.50 then
    self.poisonhitmod = 0.6 * 1+ (status.stat("poisonResistance",0) * 2)
  elseif status.stat("poisonResistance") <= 0.40 then
    self.poisonhitmod = 0.4 * 1+ (status.stat("poisonResistance",0) * 1.5)    
  elseif status.stat("poisonResistance") <= 0.30 then
    self.poisonhitmod = 0.1
  elseif status.stat("poisonResistance") <= 0.10 then
    self.poisonhitmod = 0.05
  elseif status.stat("poisonResistance") <= 0.05 then
    self.poisonhitmod = 0.05       
  else
    self.poisonhitmod = 0.05
  end 
    self.poisonhitTimer = self.poisonhitmod
end

-- alert the player that they are affected
function activateVisualEffects()
  effect.setParentDirectives("fade=558833=0.7")
  animator.setParticleEmitterOffsetRegion("poisonbreath", mcontroller.boundBox())
  animator.setParticleEmitterActive("poisonbreath", true) 
end

function update(dt)
-- environment checks
 
self.biomeTimer = self.biomeTimer - dt 
self.biomeTimer2 = self.biomeTimer2 - dt 
self.debuffApply = (self.baseDebuff* self.biomeTemp) * (-self.poisonhitmod)

self.damageApply = ( self.baseDmg * 1- math.min(status.stat("poisonResistance"),0) ) * self.biomeTemp

      if status.stat("poisonResistance") < 1.0 then  
             mcontroller.controlModifiers({  -- BACKWARDS MOVEMENT --- port this over to INSANITY!
	         airJumpModifier = status.stat("poisonResistance")+0.2, 
	         speedModifier = status.stat("poisonResistance")+0.2
             })    
      end       
-- if timer is 0 and they have less than 100% resist, proceed
      if self.biomeTimer <= 0 and status.stat("poisonResistance") < 1.0 then   
        -- first we check how windy it is
        self.windLevel =  world.windLevel(mcontroller.position())

        -- is it nighttime or above ground? 
        if self.windLevel >= 20 then
                if self.timerRadioMessage == 0 then
                  world.sendEntityMessage(entity.id(), "queueRadioMessage", "ffbiomeradiationwind", 1.0) -- send player a warning
                  self.timerRadioMessage = 60
		end
        end
        
        -- radiation is uncaring about where it affects you. no situationalPenalty.
	self.situationalPenalty = 0

	   -- final Damage calculation
	   -- apply the damage constantly but silently         
	   self.damageApply = ((self.damageApply) * (1+self.biomeTemp)) * (1+ (self.windLevel/100)) 
	   if status.stat("maxHealth") >=2 then
	     status.modifyResource("health", math.min(-self.damageApply * (1-status.stat("poisonResistance"))*self.biomeTemp ) * dt)
	   else
	     status.modifyResource("health", 1)
	   end
	   
          -- activate visuals and check stats
	  activateVisualEffects()

	  -- set the timers
          self.biomeTimer = self.poisonhitTimer
          self.timerRadioMessage = self.timerRadioMessage - dt  

          -- this second timer is a slower effect, which gradually weakns them at a pace 4x as slow as the standard effect
          if self.biomeTimer2 <= 0 then
            effect.addStatModifierGroup({
              {stat = "protection", amount = -self.baseDebuff  },
              {stat = "powerMultiplier", amount = -(self.baseDebuff/100 )  }
            })
            self.biomeTimer2 = self.poisonhitTimer *1.2
            makeAlert()
          end
          self.biomeTimer2 = self.biomeTimer2 - dt
      end
end       

function makeAlert()
        world.spawnProjectile("poisonsmoke",mcontroller.position(),entity.id(),directionTo,false,{power = 0,damageTeam = sourceDamageTeam})
 	animator.playSound("bolt")
end

function uninit()

end