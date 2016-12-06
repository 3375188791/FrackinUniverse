require "/stats/effects/fu_armoreffects/setbonuses_common.lua"

function init()
    if (world.type() == "garden") or (world.type() == "forest") or (world.type() == "desert")  then
	    setBonusInit("fu_boneset", {
	      {stat = "maxHealth", baseMultiplier = 1.05},
	      {stat = "powerMultiplier", baseMultiplier = 1.05}
	    })  
    end  	
end