setName="fu_xithriciteset"

armorBonus={
	{stat = "breathProtection", amount = 1},
{stat = "waterbreathProtection", amount = 1},
{stat = "pressureImmunity", amount = 1},

{stat = "shadowImmunity", amount = 1},
{stat = "shadowResistance", amount = 1.0},
{stat = "insanityImmunity", amount = 1},

{stat = "ffextremeradiationImmunity", amount = 1},
{stat = "radiationburnImmunity", amount = 1},
{stat = "biomeradiationImmunity", amount = 1},
{stat = "radiationResistance", amount = 1.0},


{stat = "shockResistance", amount = 0.60},
{stat = "cosmicResistance", amount = 0.60}

}

require "/stats/effects/fu_armoreffects/setbonuses_common.lua"

function init()
	setSEBonusInit(setName)

	armorBonusHandle=effect.addStatModifierGroup(armorBonus)
end

function update(dt)
if not checkSetWorn(self.setBonusCheck) then
	effect.expire()
end
end