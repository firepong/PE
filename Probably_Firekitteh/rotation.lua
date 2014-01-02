-- ProbablyEngine Rotation Packager
-- Custom Feral Combat Druid Rotation
-- Created on Nov 3rd 2013 7:51 am
ProbablyEngine.condition.register("hasSpell", function(target, spell)
	if IsSpellKnown(spell) then
		return true
	end
	return false
end)

ProbablyEngine.condition.register("HasSpell", function(target, spell)
  return ProbablyEngine.condition["hasSpell"](target, spell)
end)

ProbablyEngine.condition.register("debuff.damage", function(target, spell)
	local debuff,_,_,_,_,_,expires,caster,_,_,_,_,_,_,damage = UnitDebuff(target, spell)
	
	if debuff ~= nil and (caster == 'player' or caster == 'pet') then
		return damage
	end
	return 0
end)

ProbablyEngine.condition.register("modifier.Rip", function(target, spell)
  return ((113 + 320 * 5 * 1 + 0.0484 * 5 * UnitAttackPower('Player') * 1))*1.15
end)

ProbablyEngine.condition.register("modifier.Rake", function(target, spell)
  return (495 + (.285 * UnitAttackPower("player"))) * (1 + GetMasteryEffect() / 100)*1.15
end)
ProbablyEngine.condition.register("behind", function(target, var1)
	if not delay then
		delay = 0
	end
	if not fooframe then 
		fooframe = CreateFrame("Frame")
	end

	fooframe:RegisterEvent("UI_ERROR_MESSAGE")
	fooframe:SetScript("OnEvent", function(self, event, ...)
		local msg = ...;
		if (msg == var1) then
			error = true
			delay = GetTime()
		end
	end);
	
	if GetTime() - delay > 2 then
		delay = 0
		error = false
	end
	return error
end)

function UnitBuffID(var1,var2,var3)
	return UnitBuff(var1,GetSpellInfo(var2),var3)
end

function UnitDebuffID(var1,var2,var3)
	local hasdebuff = UnitDebuff(var1,GetSpellInfo(var2))
	if hasdebuff ~= nil and var3 == ("Player" or "Pet") then
		if select(8,UnitDebuff(var1,GetSpellInfo(var2))) == ("player" or "pet" or "Player" or "Pet") then
			return UnitDebuff(var1,GetSpellInfo(var2))
		else
			return false
		end
	elseif var3 == nil or "nil" then
		return UnitDebuff(var1,GetSpellInfo(var2))
	end
end

local sr = {
	127538,
	52610
}

--var1 = Player
function HasSR(var1)
	for i=1,#sr do
		local hasSR = select(7,UnitBuffID(var1,sr[i]))
		
		if hasSR then
			return true,hasSR
		end
	end
	return false
end

function HasGlyph(glyphid)
	for index = 1, 6 do
		local _,_,_,glyph = GetGlyphSocketInfo(index)
		
		if glyph == glyphid then
			return true
		end
	end
	return false
end

function canRip(var1,var2)
	--Variables
	local CurrentRipDamage = select(15,UnitDebuffID(var2,1079, "Player")) or 0
	local CalculatedRipDamage = (floor(113 + 320 * 5 * (1+(GetMasteryEffect()/100)) + 0.04851 * 5 * UnitAttackPower("player") * (1+(GetMasteryEffect()/100)))*select(7, UnitDamage('player')))
	local RipMultiplier = CalculatedRipDamage * 1.10
	--buffs/Debuffs/CD's
	local rip, _, _, _, _, _, riptimer = UnitDebuffID(var2, 1079, "Player")
	local ripCP = GetComboPoints(var1, var2)
	local riphealth = 100 * UnitHealth(var2) / UnitHealthMax(var2)
	local psBuff = UnitBuffID(var1,69369)
	local waBuff = UnitDebuff(var2,"Weakened Armor")

	if not psBuff and waBuff then
		local bossID = tonumber(UnitGUID(var2):sub(-13, -9), 16)
		
		if bossID ~= 63053 and rip then
			if riphealth > 25 then
				if ripCP == 5 then
					if riptimer - GetTime() < 4 then
						return true
					elseif RipMultiplier > CurrentRipDamage*2.8 and ripCP == 5 then
						return true
					else return false
					end
				end
			end
		elseif (bossID ~= 63053 ) and not rip and ripCP == 5 then
			return true
		else return false
		end
	end
	return false
end

function canFB(var1,var2)
	--Buffs/Debuffs/CD's
	local fbrip, _, _, _, _, _, fbtimer = UnitDebuffID(var2, 1079)
	local fbCP = GetComboPoints(var1, var2)
	local fbhealth = 100 * UnitHealth(var2) / UnitHealthMax(var2)
	local bsHealth = UnitHealthMax(var2) * 10
	local fbenergy = UnitPower(var1) / UnitPowerMax(var1) * 100
	local psBuff = UnitBuffID(var1,69369)
	local waBuff =  UnitDebuff(var2,"Weakened Armor")

	if not psBuff and waBuff then
		local bossID = tonumber(UnitGUID(var2):sub(-13, -9), 16)
		
		if (bossID == 63053 ) and fbCP == 5  then
			return true
		elseif fbhealth <= 25 then
			if fbrip then
				if fbCP == 5 then
					return true
				elseif fbtimer - GetTime() < 5 and fbCP < 3 then
					return true
				end
			end
		elseif fbrip then
			if fbtimer - GetTime() > 8 and fbenergy >= 50 and fbCP == 5 then
				return true	
			end		
		end
	end
	return false
end

function canSR(var1,var2)
	--Variables
	local HasGlyph = HasGlyph(127540)
	local HasSR = select(2,HasSR(var1))
	--Misc
	local CP = GetComboPoints(var1, var2)
	local cat = UnitBuffID(var1,768)
	local psBuff = UnitBuffID(var1,69369)

	if not psBuff then
		if cat then
			if not HasGlyph then
			
				if not HasSR and CP > 0 then
					return true
				elseif HasSR and HasSR - GetTime() < 4 and CP > 3 then
					return true
				elseif HasSR and HasSR - GetTime() < 2 and CP < 3 then
					return true
				end
			elseif HasGlyph then
			
				if not HasSR then
					return true
				elseif HasSR and HasSR - GetTime() < 3 then
					return true
				end
			end
		end
	end
end

if UnitExists("Target") and UnitCanAttack("Player","Target") then
	canRip("Player","Target")
	canFB("Player","Target")
end

function HasThrash(var1,var2)
	local CCasting = UnitBuffID(var2,135700)
	local tBuff = UnitDebuffID(var1, 106830, "Player")
	local tTimer = select(7,UnitDebuffID(var1, 106830, "Player"))
	local rake, _, _, _, _, _, raketimer = UnitDebuffID(var1, 1822, "Player")
	local rip, _, _, _, _, _, riptimer = UnitDebuffID(var1, 1079, "Player")
	local tfBuff = UnitBuffID(var2,5217)
	
	if CCasting and not tBuff then
		return true
	elseif CCasting and tBuff then
		local Timer = (tTimer - GetTime())
		
		if Timer < 3 then
			return true,Timer
		end
--	elseif CCasting and not tBuff or (tBuff and (tTimer - GetTime()) <= 3) and tfBuff and (rake and (raketimer - GetTime()) > 3) and (rip and (riptimer - GetTime()) > 3) then
--		return true
	end
	return false
end

function canThrash(var1,var2)
	--Variables
	local HasGlyph = HasGlyph(127540)
	local HasThrash = HasThrash(var1,var2)
		
	if HasGlyph then
		if HasThrash and HasSR then
			return true
		end
	elseif not HasGlyph then
		if HasThrash and HasSR then
			return true
		end
	end
end

function canShred(var1,var2)
	local combo = GetComboPoints(var1,var2)
	
	if HasGlyph(114234) and combo < 5 and UnitBuff(var1,"Tiger's Fury") or UnitBuff(var1,"Berserk") then
		return true
	end
end

ProbablyEngine.rotation.register_custom(103, "FireKitteh", {

  -- Cat
  { "Cat Form", "!player.buff(Cat Form)" },

  -- Self Heals
  { "Healing Touch", "player.buff(Predatory Swiftness)" },

  -- AoE
  { "Swipe", "modifier.multitarget" },

  -- Debuffs
  { "Faerie Fire", "!target.debuff(Weakened Armor)" },

  -- Buffs
  { "Savage Roar", (function() return canSR("Player","Target") end)},
  { "Berserk", {
    "player.buff(Tiger's Fury)",
	"target.level > 96"
  }},
  { "Berserking", {
    "player.HasSpell(26297)",
    "player.buff(Berserk)"
  }},
  { "Lifeblood", {
    "player.HasSpell(121279)",
	"player.buff(Berserk)"
  }},
  

  -- Free Thrash
  { "Thrash", "player.buff(Clearcasting)" },

  -- Spend Combo
  -- Tiger's Fury
  { "Tiger's Fury", "player.energy <= 40"},

  -- Rake
  { "Rake", {
    "player.buff(Dream of Cenarius).count > 1",
    "!player.buff(Clearcasting)"
  }},
-- {	"Rake", {
--   "target.debuff(Rake).damage > modifier.Rake",
--	"!player.buff(Clearcasting)"
-- }},
  { "Rake", "target.debuff(Rake).duration <= 4" },

  -- Rip
  { "Rip", (function () return canRip("player","target") end)},

  -- Ferocious Bite
  -- Target Health is less then 25%
  { "Ferocious Bite", (function() return canFB("Player","Target") end)},

  -- Build Combo
  -- Mangle/Shred
  { "Shred", (function() return canShred("Player","Target") end)},
--  { "Shred", {
--    "!behind(SPELL_FAILED_NOT_BEHIND)",
--	"player.combopoints < 5"
--  }},
  { "Mangle", {
    "!player.buff(Berserk)",
	"!player.buff(Tiger's Fury)",
	"!player.buff(Clearcasting)",
    "player.buff(Clearcasting)",
	"player.combopoints < 5"
  }},
  { "Mangle", {
    "!player.buff(Berserk)",
	"!player.buff(Tiger's Fury)",
	"!player.buff(Clearcasting)",
	"player.buff(Clearcasting)",
	"player.combopoints < 5"
  }},
  { "Mangle", {
    "!player.buff(Berserk)",
	"!player.buff(Tiger's Fury)",
	"!player.buff(Clearcasting)",
	"player.combopoints < 5" 
  }},

})