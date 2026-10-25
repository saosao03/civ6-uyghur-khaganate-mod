local CIV_TYPE   = "CIVILIZATION_UYGUR_KAGANLIGI";
local PROP_KEY   = "UYGUR_HOSGORU_KATMAN";
local MAX_TIER   = 3;

local TIER_MODIFIERS = {
    [2] = { "UYGUR_HOSGORU_2_KULTUR" },
    [3] = { "UYGUR_HOSGORU_3_BILIM", "UYGUR_HOSGORU_3_INANC" },
};

function UygurHosgoruCountFaiths(pCity)
    local pCityReligion = pCity:GetReligion()
    if pCityReligion == nil then return 0 end
    
    local count = 0
    for row in GameInfo.Religions() do
        local relType = row.ReligionType
        local relIndex = row.Index
        
        if relType ~= "RELIGION_PANTHEON" then
            local followers = pCityReligion:GetNumFollowers(relIndex)
            if followers ~= nil and followers > 0 then
                count = count + 1
            end
        end
    end
    return count
end

function UygurHosgoruUpdateCity(pCity)
    local faiths  = math.min(UygurHosgoruCountFaiths(pCity), MAX_TIER);
    local current = pCity:GetProperty(PROP_KEY);
    if current == nil then
        current = 0;
    end

    if faiths <= current then
        return;
    end

    for tier = current + 1, faiths do
        local list = TIER_MODIFIERS[tier];
        if list ~= nil then
            for _, modifierId in ipairs(list) do
                pCity:AttachModifierByID(modifierId);
            end
        end
    end

    pCity:SetProperty(PROP_KEY, faiths);
end

function UygurHosgoruOnGameTurnStarted(turn)
    for _, iPlayerID in ipairs(PlayerManager.GetAliveMajorIDs()) do
        local pConfig = PlayerConfigurations[iPlayerID];
        if pConfig ~= nil and pConfig:GetCivilizationTypeName() == CIV_TYPE then
            local pPlayer = Players[iPlayerID];
            if pPlayer ~= nil then
                for _, pCity in pPlayer:GetCities():Members() do
                    local ok, err = pcall(UygurHosgoruUpdateCity, pCity);
                    if not ok then
                        print("Uygur hosgoru HATA: " .. tostring(err));
                    end
                end
            end
        end
    end
end

GameEvents.OnGameTurnStarted.Add(UygurHosgoruOnGameTurnStarted);
print("Uygur hosgoru: betik yuklendi");