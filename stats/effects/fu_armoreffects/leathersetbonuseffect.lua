setName="fu_leatherset"

weaponEffect={
    {stat = "critChance", amount = 12},
    {stat = "powerMultiplier", baseMultiplier = 1.05}
  }

armorBonus2={
      {stat = "maxEnergy", baseMultiplier = 1.05},
      {stat = "critChance", amount = 5},
      {stat = "grit", amount = 0.2}
}

armorBonus={
      {stat = "critChance", amount = 5},
      {stat = "grit", amount = 0.1}
}

require "/stats/effects/fu_armoreffects/setbonuses_common.lua"

function init()
	setSEBonusInit(setName)
	weaponHandle=effect.addStatModifierGroup({})
	checkWeapons()
	armorHandle=effect.addStatModifierGroup(armorBonus)
    if (world.type() == "garden") or (world.type() == "forest")  then
       effect.setStatModifierGroup(armorHandle,armorBonus2)	
    end
end

function update(dt)
	if not checkSetWorn(self.setBonusCheck) then
		effect.expire()
	else
		checkWeapons()
	end
	if (world.type() == "garden") or (world.type() == "forest")  then
		effect.setStatModifierGroup(armorHandle,armorBonus2)
	else
		effect.setStatModifierGroup(armorHandle,armorBonus)
    end
	mcontroller.controlModifiers({--Khe: Remember: control modifiers such as this one REPLACE the previous one. causes annoying race-conditions.
		speedModifier = 1.05
	})
end

function checkWeapons()
	if weaponCheck("either",{"bow"}) then
		effect.setStatModifierGroup(weaponHandle,weaponEffect)
	else
		effect.setStatModifierGroup(weaponHandle,{})
	end
end