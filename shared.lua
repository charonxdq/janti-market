VEH_TEXTURE_CHANGE_PRICE = 40
TINT_PRICE, PLATE_PRICE = 30, 20 -- araç satın alınırken seçilen eksta özellikler

CKnameChangePrice = 30
CKprice = 0

MarketEnums = {
    Username_Change = 1,
    Name_Change = 2,
    VIP = 3,
    Character_Slot = 4,
    Vehicle_Slot = 5,
    House_Slot = 6,
    History_Remover = 7,
    Inventory_Slot = 8,
    Inactive_Characters = 9,
    OOC_Unjail = 10,
    Custom_Phone_Number = 11,
    Faction_Name_Change = 12,
    UnGunjail = 13,

    Vehicle_Armor = 14,
    Vehicle_Plate_Design = 15,
    Vehicle_Plate_Change = 16,
    Vehicle_Tint = 17,
    Vehicle_Neon = 18,
    Vehicle_Texture = 19,
    Vehicle_Butterfly_Door = 20,
}

Features = {}

Features.personal = {
    { key = MarketEnums.Username_Change, name = 'İsim Değişikliği', price = 70, callback = openNameChanger, color = 'BLUE', icon = '' },
    { key = MarketEnums.Name_Change, name = 'Kullanıcı Adı Değişikliği', price = 70, callback = openUserChanger, color = 'ORANGE', icon = '' },

    { key = MarketEnums.VIP, name = 'VIP', price = 3, callback = openVIP, color = 'YELLOW', icon = '' },

    { key = MarketEnums.Character_Slot, name = 'Ek Karakter Slotu (+1)', price = 25, callback = addCharSlot, color = 'GREEN', icon = '' },
    { key = MarketEnums.Vehicle_Slot, name = 'Ek Araç Slotu (+1)', price = 25, callback = addVehicleSlot, color = 'GREEN', icon = '' },
    { key = MarketEnums.House_Slot, name = 'Ek Ev Slotu (+1)', price = 25, callback = addHouseSlot, color = 'GREEN', icon = '' },
    { key = MarketEnums.History_Remover, name = 'History Sildirme (1 adet)', price = 5, callback = openHistoryRemover, color = 'RED', icon = '', condition = function(shortName)
        return shortName == 'srp'
    end },
    { key = MarketEnums.Inventory_Slot, name = 'Kalıcı Envanter Arttırıcı', price = 60, callback = upgradeInvSlot, color = 'YELLOW', icon = '' },
    { key = MarketEnums.Inactive_Characters, name = 'Karakter Yasağı Kaldırma', price = 100, callback = openInactiveCharacters, color = 'RED', icon = '' },
    { key = MarketEnums.OOC_Unjail, name = 'OOC Hapis Açtırma', price = function()
        local adminJailData = localPlayer:getData("adminjail")
        if not adminJailData then
            return 0
        end

        return calculateOOCJailPrice(adminJailData)
    end, callback = openOocUnjail, color = 'RED', icon = '', condition = function(shortName)
        return shortName == 'srp'
    end },
    { key = MarketEnums.Custom_Phone_Number, name = 'Özel Telefon Numarası', price = 30, callback = openCustomPhoneNumber, color = 'PURPLE', icon = '' },

    { key = MarketEnums.Faction_Name_Change, name = 'Birlik İsim Değişikliği', price = 40, callback = openFactionNameChanger, color = 'BLUE', icon = '' },

    { key = MarketEnums.UnGunjail, name = 'Silah Kısıtlaması Kaldırma', price = 0, callback = openUnGunjail, color = 'RED', icon = '' },
}

Features.carFeatures = {
    { key = MarketEnums.Vehicle_Armor, name = 'Araç Zırhı (500 hp - Kalıcı)', price = 70, callback = openVehicleArmor, color = 'GRAY', icon = '' },
    { key = MarketEnums.Vehicle_Plate_Design, name = 'Plaka Tasarımı', price = 30, callback = openPlateDesigner, color = 'GRAY', icon = '' },
    { key = MarketEnums.Vehicle_Plate_Change, name = 'Plaka Değişikliği', price = 30, callback = openPlateChanger, color = 'GRAY', icon = '' },
    { key = MarketEnums.Vehicle_Tint, name = 'Cam Filmi', price = 40, callback = openVehicleTint, color = 'GRAY', icon = '' },
    { key = MarketEnums.Vehicle_Neon, name = 'Neon Sistemi', price = 60, callback = openVehicleNeon, color = 'GRAY', icon = '' },
    { key = MarketEnums.Vehicle_Texture, name = 'Kaplama Sistemi', price = 90, callback = openTextureChanger, color = 'GRAY', icon = '' },
    { key = MarketEnums.Vehicle_Butterfly_Door, name = 'Kelebek Kapı', price = 35, callback = openButterflyDoor, color = 'GRAY', icon = '' },
}

generalTabs = {
    { text = "Mağaza", tabs = {
        { "Kişisel Özellikler", drawPersonalFeatures, Features.personal },
        { "Araç Özellikleri", drawPersonalFeatures, Features.carFeatures },
        { "Özel Araçlar", drawPrivateCars, {},
          function(shortName)
              return shortName == 'srp'
          end
        },
        { "Evcil Hayvanlar", drawPets, {} },
        { "Silahlar", drawSpecialWeapons, {},
          function(shortName)
              return shortName == 'srp'
          end },
        { "Para Çevirme", drawConvertMoney, {},
          function(shortName)
              return shortName == 'srp'
          end },
        { "Animasyonlar", drawAnimations, {} },

        { "Etiketler", drawTags, {},
          function(shortName)
              return shortName == 'srp'
          end },
        { "Polis Yetki Alımı", drawPoliceRanks, {} },
        { "Yetki Alımı", drawStaffManagement, {},
          function(shortName)
              return shortName == 'srp'
          end }
    } },
    { text = "Alım Geçmişi", render = drawBuyHistory },
    { text = "Yükleme Geçmişi", render = drawLoadHistory },
}

VIPPrices = {}
specialCars = nil

local function loadVariables()
    local available_tags = exports.in_tag:getAvailableTags()
    local private_weapons = exports.in_core:get("privateWeapons")

    generalTabs[1]["tabs"][4][3] = {
        {
            { "Silah Adı", 0.4 },
            { "Fiyat", 0.3 }
        }, -- Grid rows
    }
    for index, data in pairs(private_weapons) do
        table.insert(generalTabs[1]["tabs"][4][3], data)
    end

    generalTabs[1]["tabs"][7][3] = {
        {
            { "Etiket Adı", 0.4 },
            { "Fiyat", 0.3 }
        }, -- Grid rows
    }
    for index, data in pairs(available_tags) do
        table.insert(generalTabs[1]["tabs"][7][3], data)
    end

    VIPPrices = exports.in_core:get("vipPrices")
    local list = {}
    for id, data in pairs(VIPPrices) do
        list[tonumber(id)] = data
    end
    VIPPrices = list
end

if localPlayer then
    addEventHandler("onClientCoreLoaded", localPlayer, loadVariables)
    addEventHandler("onClientResourceStart", resourceRoot, loadVariables)
else
    addEventHandler("onResourceStart", resourceRoot, loadVariables)
    addEventHandler("onCoreLoaded", root, loadVariables)
end

restrictedWeapons = {}
for i = 0, 15 do
    restrictedWeapons[i] = true
end

function getPrivateVehicles()
    local private_cars = exports.in_core:get("privateVehicles")
    local specialCars = {}
    for i, data in pairs(private_cars) do
        specialCars[tonumber(data.model)] = true
    end
    return specialCars
end

function isPrivateCar(vehicle)
    local cars = getPrivateVehicles()
    return cars[isElement(vehicle) and tonumber(getElementModel(vehicle)) or tonumber(vehicle)]
end

function getCharacterNameChangePrice(changeCharacterName)
    return changeCharacterName and 100 or 70
end

function hasBalance(player, balance)
    if tonumber(player) then
        local row = exports.in_storage:getCache('accounts', tonumber(player), 'id')

        if not row then
            return false
        end

        return tonumber(balance) >= 0 and tonumber(row.gamecoin or 0) >= tonumber(balance)
    end

    local playerBalance = tonumber(getElementData(player, "player.balance"))
    if playerBalance and tonumber(balance) and playerBalance >= tonumber(balance) and tonumber(balance) >= 0 then
        return true
    end
    return false
end

function findVehicleFromID(vehicleID)
    for index, vehicle in ipairs(getElementsByType("vehicle")) do
        if (tonumber(vehicle:getData("dbid")) == tonumber(vehicleID)) then
            return vehicle
        end
    end
    return false
end