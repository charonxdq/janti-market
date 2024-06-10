screenSize = Vector2(guiGetScreenSize())
importer:import('*'):from('in_ui')
importer:import('inArea,animate'):from('in_widget')
loadGameCode(_injectHooks())()

local triggerServerEvent_ = triggerServerEvent

function triggerServerEvent(eventName, ...)
    if exports.in_network:getNetworkStatus() then
        outputChatBox(">> Sunucuya istek gönderilemedi, internet bağlantınızı kontrol edip tekrar deneyin!", 225, 0, 0)
        return
    end
    return triggerServerEvent_(eventName, ...)
end

local linesGap = 48
local linesHeight = 1

function drawLinesBackground(position, size, color)
    color = color or 'GRAY'
    local linesCount = math.floor(size.y / (linesHeight + linesGap))
    local linesCountX = math.floor(size.x / (linesHeight + linesGap))

    for i = 1, linesCount do
        local y = position.y + (i - 1) * (linesHeight + linesGap)
        dxDrawRectangle(position.x, y, size.x, linesHeight, rgba(theme[color][700], 1))
    end

    for i = 1, linesCountX do
        local x = position.x + (i - 1) * (linesHeight + linesGap)
        dxDrawRectangle(x, position.y, linesHeight, size.y, rgba(theme[color][700], 1))
    end
end

function renderMarket(position, size)
    fonts = useFonts()
    theme = useTheme()

    if not shortName then
        shortName = exports.in_core:get('alias'):lower()
    end

    local tabPanel = drawTabPanel({
        position = position,
        size = size,
        padding = 0,

        name = 'dashboard_market_tabs',

        placement = 'horizontal',
        tabs = map(generalTabs, function(_, tab)
            return {
                name = tab.text,
                icon = ''
            }
        end),

        variant = 'soft',
        color = 'gray',

        activeTab = 1,
        disabled = false,
    })

    for i = 1, #generalTabs do
        local tab = generalTabs[i]
        if i == tabPanel.selected then
            if tab.render then
                tab.render(tabPanel.position, tabPanel.size)
            else

                tab.tabs = eachi(tab.tabs, function(_, tab)
                    local isDisabled = tab[4] and tab[4](shortName)
                    if not isDisabled then
                        return tab
                    end
                    return nil
                end)

                local subTabPanel = drawTabPanel({
                    position = tabPanel.position,
                    size = tabPanel.size,

                    name = 'dashboard_market_tabs_' .. i,

                    placement = 'vertical',
                    tabs = map(tab.tabs, function(_, tab)
                        return {
                            name = tab[1],
                            icon = ''
                        }
                    end),

                    variant = 'plain',
                    color = 'gray',

                    activeTab = 1,
                    disabled = false,
                })

                if subTabPanel.pressed then
                    exports.in_3dview:removeProcesses()
                end

                local activeSubTab = tab.tabs[subTabPanel.selected]
                if activeSubTab and activeSubTab[2] then
                    subTabPanel.size.y = subTabPanel.size.y + 10
                    activeSubTab[2](subTabPanel.position, subTabPanel.size, activeSubTab[3])
                end
            end
        end
    end
end

createNativeEvent(ClientEventNames.onClientResourceStop, resourceRoot, function()
    exports.in_3dview:removeProcesses()
end)

-- Kaplama Degistirmek Icin
addCommandHandler("arackaplama",
        function(cmd)
            if getElementData(localPlayer, "loggedin") == 1 and localPlayer.vehicle then
                if tonumber(localPlayer.vehicle:getData("owner")) == tonumber(localPlayer:getData("dbid")) then
                    if #localPlayer.vehicle:getData("textures") > 0 then
                        openTextureChanger(VEH_TEXTURE_CHANGE_PRICE, localPlayer.vehicle:getData("dbid"))
                    end
                end
            end
        end
)

addEventHandler("onClientVehicleStartEnter", root,
        function(player, seat)
            if player ~= localPlayer then
                return
            end

            if not exports.in_market:isPrivateCar(source) then
                return
            end
            if seat == 0 then
                local ownerFound = false
                local occupants = getVehicleOccupants(source) or {}
                local vehicleOwner = getElementData(source, "owner")
                local vehicleFaction = tonumber(getElementData(source, "faction"))

                if not shortName then
                    shortName = exports.in_core:get('alias'):lower()
                end

                if shortName == 'srp' then

                    return
                end

                for seat, occupant in pairs(occupants) do
                    if (occupant and getElementType(occupant) == "player") then
                        local dbid = getElementData(occupant, "dbid")
                        if dbid == vehicleOwner then
                            ownerFound = true
                            break
                        end
                    end
                end

                local playerDBID = getElementData(player, "dbid")
                if not ownerFound and not (playerDBID == vehicleOwner) then
                    if vehicleFaction == 8 then
                        return false
                    end
                    outputChatBox("[!] #ffffffÖzel aracın sahibi araçta olmadığı sürece araca binemezsin.", 255, 0, 0, true)
                    cancelEvent()
                end
            end
        end
)

function showVIPInformationPanel()
	if isElement(vipWindow) then destroyElement(vipWindow) return end
	
	vipWindow = guiCreateWindow(0.26, 0.31, 0.80, 0.31, "VIP Ozellikleri", true)
	guiWindowSetSizable(vipWindow, false)
	exports.in_global:centerWindow(vipWindow)
    local moneyCurrency = exports.in_core:get("currency") or "$"
    local vipOne = exports.in_core:get("vipPrices")[1]
    local vipTwo = exports.in_core:get("vipPrices")[2]
    local vipThree = exports.in_core:get("vipPrices")[3]
    local vipFour = exports.in_core:get("vipPrices")[4]

    local hourlyPaydayOne = exports.in_core:get("hourlyPaydayVipIncome")[1]
    local hourlyPaydayTwo = exports.in_core:get("hourlyPaydayVipIncome")[2]
    local hourlyPaydayThree = exports.in_core:get("hourlyPaydayVipIncome")[3]
    local hourlyPaydayFour = exports.in_core:get("hourlyPaydayVipIncome")[4]

	label1 = guiCreateLabel(0.01, 0.07, 0.24, 0.05, "[VIP 1] 1 Aylık "..vipOne.." TL", true, vipWindow)
	guiSetFont(label1, "default-bold-small")
	guiLabelSetColor(label1, 180,127,51)
	guiLabelSetHorizontalAlign(label1, "center", false)
	label2 = guiCreateLabel(0.25, 0.07, 0.24, 0.05, "[VIP 2] 1 Aylık "..vipTwo.." TL", true, vipWindow)
	guiSetFont(label2, "default-bold-small")
	guiLabelSetColor(label2, 148,148,148)
	guiLabelSetHorizontalAlign(label2, "center", false)
	label3 = guiCreateLabel(0.50, 0.07, 0.24, 0.05, "[VIP 3] 1 Aylık "..vipThree.." TL", true, vipWindow)
	guiSetFont(label3, "default-bold-small")
	guiLabelSetColor(label3, 233,233,26)
	guiLabelSetHorizontalAlign(label3, "center", false)
	label4 = guiCreateLabel(0.74, 0.07, 0.24, 0.05, "[VIP 4] 1 Aylık "..vipFour.." TL", true, vipWindow)
	guiSetFont(label4, "default-bold-small")
	guiLabelSetColor(label4, 36,218,232)
	guiLabelSetHorizontalAlign(label4, "center", false)
	label5 = guiCreateLabel(0.01, 0.11, 0.24, 0.86, "* Her maaşta +"..hourlyPaydayOne..moneyCurrency.." alır.\n* PM Açma/Kapatma özelliği\n* VIP Logosu\n* Mesleklerde her turda +25$\n* Maske Takma Özelliği (Örnek: Gizli #34545)", true, vipWindow)
	label6 = guiCreateLabel(0.25, 0.11, 0.24, 0.86, "* Her maaşta +"..hourlyPaydayTwo..moneyCurrency.." alır.\n* PM Açma/Kapatma özelliği\n* Hızlı Reklam Vermek CNN'e gitmeden.\n* VIP Logosu\n* Mesleklerde her turda +50$\n* Maske Takma Özelliği (Örnek: Gizli #34545)\n* AK-47 marka silahı kullanabilme özelliği", true, vipWindow)
	label7 = guiCreateLabel(0.50, 0.11, 0.24, 0.86, "* Her maaşta +"..hourlyPaydayThree..moneyCurrency.." alır.\n* PM Açma/Kapatma özelliği\n* Hızlı Reklam Vermek CNN'e gitmeden.\n* VIP Logosu\n* Uygun fiyata mermi satın almak (Yarı Fiyatına %50)\n* Mesleklerde her turda +75$\n* Maske Takma Özelliği (Örnek: Gizli #34545)\n* Ücretsiz Tamir Özelliği\n* Ücretsiz /tedaviol Özelliği\n* AK-47 marka silahı kullanabilme özelliği", true, vipWindow)
	label8 = guiCreateLabel(0.74, 0.11, 0.24, 0.86, "* Her maaşta +"..hourlyPaydayFour..moneyCurrency.." alır.\n* PM Açma/Kapatma özelliği\n* Hızlı Reklam Vermek CNN'e gitmeden.\n* VIP Logosu\n* Uygun fiyata mermi satın almak (%60 Uyguna)\n* Mesleklerde her turda +100$\n* Maske Takma Özelliği (Örnek: Gizli #34545)\n* Sahip olduğunuz araçların vergisi %35 daha az gelmektedir.\n* Ücretsiz Tamir Özelliği\n* Ücretsiz /tedaviol Özelliği\n* /onayla yazmadan otomatik saatlik bonus almak.\n* AK-47 ve M4 marka silahı kullanabilme özelliği\n* Birlik Aracı Çekebilmek (/aracgetir ile)", true, vipWindow)
	close = guiCreateButton(0.01, 0.78, 0.98, 0.20, "Kapat", true, vipWindow)
	addEventHandler("onClientGUIClick", close, function(b) if (b == "left") then destroyElement(vipWindow) end end)
end
addCommandHandler("vip", showVIPInformationPanel)
addCommandHandler("vipbilgi", showVIPInformationPanel)