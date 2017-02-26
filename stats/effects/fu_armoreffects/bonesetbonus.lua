require "/stats/effects/fu_armoreffects/setbonuses_common.lua"
--remove or convert. code bleh!
function init()
    if (world.type() == "garden") or (world.type() == "forest") then
	    setBonusInit("fu_boneset", {
	      {stat = "maxHealth", baseMultiplier = 1.10},
	      {stat = "powerMultiplier", baseMultiplier = 1.05},
	      {stat = "physicalResistance", amount = 0.05},
              {stat = "fallDamageMultiplier", baseMultiplier = 0.25}
	    }) 
       else
	    setBonusInit("fu_boneset", {
	      {stat = "maxHealth", baseMultiplier = 1.05},
              {stat = "fallDamageMultiplier", baseMultiplier = 0.25}
	    })        
    end  	
end