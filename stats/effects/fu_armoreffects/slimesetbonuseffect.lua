setName="fu_slimeset"

weaponEffect={
    {stat = "critChance", amount = 6},
    {stat = "powerMultiplier", amount = 0.10}
}

armorBonus={
	    {stat = "wetImmunity", amount = 1},
	    {stat = "poisonResistance", amount = 0.35},
	    {stat = "poisonStatusImmunity", amount = 1},
	    {stat = "slimestickImmunity", amount = 1},
	    {stat = "slimefrictionImmunity", amount = 1},
	    {stat = "slimeImmunity", amount = 1},
	    {stat = "snowslowImmunity", amount = 1},
	    {stat = "iceslipImmunity", amount = 1},
	    {stat = "mudslowImmunity", amount = 1}
}

require "/stats/effects/fu_armoreffects/setbonuses_common.lua"

function init()
	setSEBonusInit(setName)
	weaponHandle=effect.addStatModifierGroup({})
	checkWeapons()
	armorHandle=effect.addStatModifierGroup(armorBonus)	
end

function update(dt)
	if not checkSetWorn(self.setBonusCheck) then
		effect.expire()
	else
		checkWeapons()
	end
end

function checkWeapons()
	local weapons=weaponCheck({"slime"})
	if weapons["both"] then
		effect.setStatModifierGroup(weaponHandle,setBonusMultiply(weaponEffect,2))
	elseif weapons["either"] then
		effect.setStatModifierGroup(weaponHandle,weaponEffect)
	else
		effect.setStatModifierGroup(weaponHandle,{})
	end
end