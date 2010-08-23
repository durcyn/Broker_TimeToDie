local UnitHealth = _G.UnitHealth
local UnitExists = _G.UnitExists
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsFriend = _G.UnitIsFriend
local GetTime = _G.GetTime
local abs = _G.abs
local strformat = _G.string.format

local ttd = LibStub("LibDataBroker-1.1"):NewDataObject("Time To Die", {
	icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
	type = "data source",
	label = "TTD",
	text = "",
})

local display

local eventFrame = CreateFrame("Frame")
eventFrame:Hide()
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event, unit, ...) 
	if event == "PLAYER_LOGIN" then
		eventFrame:UnregisterEvent("PLAYER_LOGIN")
		if nil == _G.TIMETODIE_UNIT then _G.TIMETODIE_UNIT = "target" end
	elseif event == "UNIT_HEALTH" then
		if unit == display then ttd:update(unit) end
	elseif event == "PLAYER_TARGET_CHANGED" then
		if _G.TIMETODIE_UNIT and _G.TIMETODIE_UNIT == "target" then ttd:change(_G.TIMETODIE_UNIT) end
	elseif event == "PLAYER_FOCUS_CHANGED" then
		if _G.TIMETODIE_UNIT and _G.TIMETODIE_UNIT == "focus"  then ttd:change(_G.TIMETODIE_UNIT) end
	end
end)

local health0, time0 -- baseline values 
local mhealth, mtime -- midpoint values

function ttd:update(unit)
	local health, time = UnitHealth(unit), GetTime()
	
	if not health0 then
		health0, time0 = health, time
		return
	end

	if not mhealth then
		mhealth, mtime = health, time
	else
		mhealth, mtime = (mhealth + health) / 2, (mtime + time) / 2
	end
	
	local dhealth = mhealth - health0

	if dhealth ~= 0 then
		time = health * (time0 - mtime) / dhealth
		if abs(time) > 60 then
			ttd.text = ("%dm %ds"):format(time/60, time%60)
		else
			ttd.text = ("%ds"):format(time%60)
		end
	else
		ttd.text = "0s"
	end
end

function ttd:change(unit)
	health0, time0, mhealth, mtime = nil
	ttd.text = ""
	local token = strformat("%starget", unit)
	if not UnitExists(unit) then return
	elseif UnitIsEnemy("player", unit) then display = unit return
	elseif UnitIsFriend("player", unit) and UnitExists(token) and UnitIsEnemy("player", token) then display = token
	end
end

