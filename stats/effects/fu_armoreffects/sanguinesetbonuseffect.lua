setName="fu_sanguineset"

weaponEffect={
    {stat = "critChance", amount = 15}
  }
  
armorBonus={
    {stat = "poisonResistance", amount = 0.15}
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
		status.removeEphemeralEffect( "regenerationsanguine" )
	else
		checkWeapons()
		status.addEphemeralEffect( "regenerationsanguine" )
	  mcontroller.controlModifiers({
	      speedModifier = 1.10
	    })
	end	
end

function checkWeapons()
	if weaponCheck("either",{"dagger","whip"}) then
		effect.setStatModifierGroup(weaponHandle,weaponEffect)
	else
		effect.setStatModifierGroup(weaponHandle,{})
	end
end