-- SimScore's logic without the game's API (simscore spec §7), so it runs in tests too: the score's colour and line,
-- and which installed data addons are this server's.
SimScore = SimScore or {}
local S = SimScore

-- Warcraft Logs' colours by whole percentile
local COLOURS = {
  { 100, "e5cc80" }, { 99, "e268a8" }, { 95, "ff8000" }, { 75, "a335ee" }, { 50, "0070ff" }, { 25, "1eff00" }, { 0, "666666" },
}
function S.Colour(tenths)
  local whole = math.floor(tenths / 10)
  for _, c in ipairs(COLOURS) do
    if whole >= c[1] then return c[2] end
  end
  return COLOURS[#COLOURS][2]
end

-- 992 -> "99.2", 1000 -> "100"
function S.Format(tenths)
  if tenths >= 1000 then return "100" end
  return string.format("%d.%d", math.floor(tenths / 10), tenths % 10)
end

-- the icons by bracket: the class's, then the talent tree's
S.ICONS = {
  ["Warrior/Fury"] = { "Interface\\Icons\\ClassIcon_Warrior", "Interface\\Icons\\Ability_Warrior_InnerRage" },
  ["Warrior/Arms"] = { "Interface\\Icons\\ClassIcon_Warrior", "Interface\\Icons\\Ability_Warrior_SavageBlow" },
  ["Priest/Shadow"] = { "Interface\\Icons\\ClassIcon_Priest", "Interface\\Icons\\Spell_Shadow_ShadowWordPain" },
}

-- 14×14, the middle 86 % of the texture: Blizzard's border cut off, as the site's icons (scale(1.16))
local ICON_CROP = ":14:14:0:0:100:100:7:93:7:93"

-- "SimScore 99.2 [class][spec]", then each further spec's score and icons: `scores` is { { tenths, spec }, ... }, best
-- first; each number in its colour
function S.Line(scores)
  local parts = {}
  for _, s in ipairs(scores) do
    local icons = ""
    for _, path in ipairs(S.ICONS[s[2]] or {}) do icons = icons .. "|T" .. path .. ICON_CROP .. "|t" end
    parts[#parts + 1] = "|cff" .. S.Colour(s[1]) .. S.Format(s[1]) .. "|r" .. (icons ~= "" and " " .. icons or "")
  end
  return "SimScore " .. table.concat(parts, " ")
end

-- The scores of "First Surname" in the region's data, { { tenths, spec }, ... } best first (the data file's order:
-- (score, spec index) pairs), or nil
function S.Lookup(db, region, name)
  local d = db and db[region]
  local e = d and d[name]
  if type(e) ~= "table" or not d.specs then return nil end
  local out = {}
  for i = 1, #e - 1, 2 do out[#out + 1] = { e[i], d.specs[e[i + 1]] } end
  if #out == 0 then return nil end
  return out
end

local function norm(s) return (s or ""):lower():gsub("%s+", "") end

-- The data addons to load among the installed ones ({ name, region, ruleset } each): the player's region's, and of those
-- the ones of the player's ruleset. `pvp`: whether the server is a PvP ruleset (nil: unknown); `ruleset`: its name if
-- the client gives one (nil: unknown). When nothing narrower matches, every data addon of the region: their files merge.
function S.Choose(installed, region, pvp, ruleset)
  local own = {}
  for _, a in ipairs(installed) do
    if a.region and norm(a.region) == norm(region) then own[#own + 1] = a end
  end
  if ruleset then
    local exact = {}
    for _, a in ipairs(own) do if norm(a.ruleset) == norm(ruleset) then exact[#exact + 1] = a end end
    if #exact > 0 then return exact end
  end
  if pvp ~= nil then
    local same = {}
    for _, a in ipairs(own) do
      if (norm(a.ruleset):find("pvp", 1, true) ~= nil) == pvp then same[#same + 1] = a end
    end
    if #same > 0 then return same end
  end
  return own
end

S.REGIONS = { [1] = "us", [2] = "kr", [3] = "eu", [4] = "tw", [5] = "cn" }
