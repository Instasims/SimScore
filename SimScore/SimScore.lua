-- SimScore (simscore spec §7): a player's SimScore in their tooltip, from the data addon of this server
-- (SimScore_DB_<REGION>_<Ruleset>, loaded on demand). Core.lua has the logic.
local S = SimScore
local AddOns = C_AddOns or {}
local GetNumAddOns = AddOns.GetNumAddOns or GetNumAddOns
local GetAddOnInfo = AddOns.GetAddOnInfo or GetAddOnInfo
local GetAddOnMetadata = AddOns.GetAddOnMetadata or GetAddOnMetadata
local LoadAddOn = AddOns.LoadAddOn or LoadAddOn

local region

local function isPvP()
  if C_GameRules and C_GameRules.IsGameRuleActive and Enum and Enum.GameRule and Enum.GameRule.PvPRuleset then
    return C_GameRules.IsGameRuleActive(Enum.GameRule.PvPRuleset) and true or false
  end
  return nil
end

local function loadData()
  region = (GetCurrentRegionName and GetCurrentRegionName() or ""):lower()
  if region == "" then region = S.REGIONS[GetCurrentRegion and GetCurrentRegion() or 0] or "" end
  local installed = {}
  for i = 1, GetNumAddOns() do
    local name = GetAddOnInfo(i)
    local r = GetAddOnMetadata(i, "X-SimScore-Region")
    if r then installed[#installed + 1] = { name = name, region = r, ruleset = GetAddOnMetadata(i, "X-SimScore-Ruleset") } end
  end
  for _, a in ipairs(S.Choose(installed, region, isPvP(), nil)) do LoadAddOn(a.name) end
end

local function nameOf(unit)
  local first, second = UnitFullName(unit)
  if not first then return nil end
  -- Forever: the second value is the surname
  return (second and second ~= "") and (first .. " " .. second) or first
end

local function addLine(tooltip, unit)
  if not unit or not UnitIsPlayer(unit) then return end
  local name = nameOf(unit)
  local scores = S.Lookup(SimScore_DB, region, name)
  if scores then tooltip:AddLine(S.Line(scores)) end
end

if TooltipDataProcessor and Enum and Enum.TooltipDataType then
  TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip ~= GameTooltip then return end
    local _, unit = tooltip:GetUnit()
    addLine(tooltip, unit)
  end)
else
  GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
    local _, unit = tooltip:GetUnit()
    addLine(tooltip, unit)
  end)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", loadData)
