--
-- luacheck: globals onInit onTabletopInit onClose registerChatOptions customAddChatMessage customDeliverChatMessage customOnReceiveMessage
-- luacheck: globals customOnDeliverMessage customCreateEntry replaceInspirationWidget changeInspirationWidget changeChat changeIconTheme
-- luacheck: globals Comm changeFontTheme changeGMIcon addFontTheme addIconTheme addGMPortrait printErrors
local sIcon = ''
local sFont = nil
local sGMIcon = nil
local bBIDI = false
local bInspiration = false

local createEntry = nil
local onDeliverMessage = nil
local onReceiveMessage = nil
local addChatMessage = nil
local deliverChatMessage = nil

local aGMCustom = {}
local aGMIcon = {'skull', 'dm', 'gm'}
local aFontTheme = {'light', 'light_20pt', 'light_22pt', 'dark', 'dark_20pt', 'dark_22pt'}
local aIconTheme = {'hex', 'simple', 'round', 'square', 'dots', 'texthex'}
local aOverrides = {
    'roll_attack',
    'roll_attack_hit',
    'roll_attack_miss',
    'roll_attack_crit',
    'roll_damage',
    'roll_cast',
    'roll_heal',
    'roll_effect'
}
local aFontsTypes = {
    'chatfont',
    'emotefont',
    'narratorfont',
    'systemfont',
    'msgfont',
    'oocfont',
    'chatnpcfont',
    'chatgmfont',
    'whisperfont'
}

local aCustomThemeErrors = {}

function onInit()
    -- Inspiration
    if User.getRulesetName() == '5E' or User.getRulesetName() == '2E' then
        bInspiration = true
        createEntry = CharacterListManager.createEntry
        CharacterListManager.createEntry = customCreateEntry
    end

    registerChatOptions()

    OptionsManager.registerCallback('CHATICONTHEME', changeIconTheme)
    OptionsManager.registerCallback('CHATFONTCOLORS', changeFontTheme)
    OptionsManager.registerCallback('CHATGMICON', changeGMIcon)
    OptionsManager.registerCallback('CHATGMICONCOLOR', changeGMIcon)
    if bInspiration then
        OptionsManager.registerCallback('CHATICONTHEME', changeInspirationWidget)
        OptionsManager.registerCallback('CHATINSPIRATION', changeInspirationWidget)
    end

    for _, sName in pairs(Extension.getExtensions()) do
        if Extension.getExtensionInfo(sName).name:match('Bardic Inspiration Die') then
            bBIDI = true
            break
        end
    end
end

function onTabletopInit()

    onDeliverMessage = ChatManager.onDeliverMessage
    onReceiveMessage = ChatManager.onReceiveMessage
    addChatMessage = Comm.addChatMessage
    deliverChatMessage = Comm.deliverChatMessage

    ChatManager.onDeliverMessage = customOnDeliverMessage
    ChatManager.onReceiveMessage = customOnReceiveMessage
    Comm.addChatMessage = customAddChatMessage
    Comm.deliverChatMessage = customDeliverChatMessage

    changeIconTheme()
    changeFontTheme()
    changeGMIcon()
    if User.getRulesetName() == '5E' or User.getRulesetName() == '2E' then
        changeInspirationWidget()
    end
    -- printErrors()
end

function onClose()
    OptionsManager.unregisterCallback('CHATICONTHEME', changeIconTheme)
    OptionsManager.unregisterCallback('CHATFONTCOLORS', changeFontTheme)
    OptionsManager.unregisterCallback('CHATGMICON', changeGMIcon)
    OptionsManager.unregisterCallback('CHATGMICONCOLOR', changeGMIcon)
    Comm.addChatMessage = addChatMessage
    Comm.deliverChatMessage = deliverChatMessage
    ChatManager.onDeliverMessage = onDeliverMessage
    ChatManager.onReceiveMessage = onReceiveMessage

    if bInspiration then
        OptionsManager.unregisterCallback('CHATICONTHEME', changeInspirationWidget)
        OptionsManager.unregisterCallback('CHATINSPIRATION', changeInspirationWidget)

        CharacterListManager.createEntry = createEntry
    end
end

function registerChatOptions()
    OptionsManager.registerOption2('CHATICONTHEME', false, 'option_header_chat_aesthetics_configurator',
                                   'option_label_CHATICONTHEME', 'option_entry_cycler', {
        labels = 'option_val_theme_simple|option_val_theme_hex|option_val_theme_round|' ..
            'option_val_theme_square|option_val_theme_dots|option_val_theme_texthex',
        values = 'simple|hex|round|square|dots|texthex',
        baselabel = 'option_val_theme_off',
        baseval = 'off',
        default = 'simple'
    })

    OptionsManager.registerOption2('CHATFONTCOLORS', false, 'option_header_chat_aesthetics_configurator',
                                   'option_label_CHATUSEFONTCOLORS', 'option_entry_cycler', {
        -- labels = "option_val_font_dark|option_val_font_light|option_val_font_hearth",
        -- values = "dark|light|hearth",
        labels = 'option_val_font_dark|option_val_font_dark_20pt|option_val_font_dark_22pt|' ..
            'option_val_font_light|option_val_font_light_20pt|option_val_font_light_22pt',
        values = 'dark|dark_20pt|dark_22pt|light|light_20pt|light_22pt',
        baselabel = 'option_val_font_off',
        baseval = 'off',
        default = 'dark'
    })

    OptionsManager.registerOption2('CHATGMICON', false, 'option_header_chat_aesthetics_configurator', 'option_label_CHATGMICON',
                                   'option_entry_cycler', {
        labels = 'option_val_gmicon_dm|option_val_gmicon_gm|option_val_gmicon_skull',
        values = 'dm|gm|skull',
        baselabel = 'option_val_gmicon_default',
        baseval = 'default',
        default = 'default'
    })
    OptionsManager.registerOption2('CHATGMICONCOLOR', false, 'option_header_chat_aesthetics_configurator',
                                   'option_label_CHATGMICONCOLOR', 'option_entry_cycler', {
        labels = 'option_val_gmicon_blood|option_val_gmicon_blue|option_val_gmicon_green|option_val_gmicon_purple|option_val_gmicon_red',
        values = 'blood|blue|green|purple|red',
        baselabel = 'option_val_gmicon_black',
        baseval = 'black',
        default = 'black'
    })
    if bInspiration then
        OptionsManager.registerOption2('CHATINSPIRATION', false, 'option_header_chat_aesthetics_configurator',
                                       'option_label_CHATINSPIRATION', 'option_entry_cycler', {
            labels = 'option_val_inspiration_no',
            values = 'no',
            baselabel = 'option_val_inspiration_yes',
            baseval = 'yes',
            default = 'yes'
        })
    end
end

function customAddChatMessage(messagedata)
    changeChat(messagedata)
    addChatMessage(messagedata)
end

function customDeliverChatMessage(messagedata, aUsers)
    changeChat(messagedata)
    deliverChatMessage(messagedata, aUsers)
end

-- We can't do it with a callback
-- because of the callback ordering and other callbacks from the ruleset
-- overwrite out font changes
function customOnDeliverMessage(messagedata, ...)
    local ret = onDeliverMessage(messagedata, ...)
    if messagedata and messagedata.font then
        changeChat(messagedata)
    end
    return ret
end

-- We can't do it with a callback
-- because of the callback ordering and other callbacks from the ruleset
-- overwrite out font changes
function customOnReceiveMessage(messagedata, ...)
    local ret = onReceiveMessage(messagedata, ...)
    if messagedata and messagedata.font then
        changeChat(messagedata)
    end
    return ret
end

function customCreateEntry(w, tData)
    createEntry(w, tData)
    changeInspirationWidget()
end

function changeInspirationWidget()
    local tIdentities = CharacterListManager.getActivatedIdentities();
    for _, sIdentity in pairs(tIdentities) do
        replaceInspirationWidget(sIdentity)
    end
    local tPartyIdentities = CharacterListManager.getPartyIdentities()
    for _, sIdentity in pairs(tPartyIdentities) do
        replaceInspirationWidget(sIdentity)
    end
end

function replaceInspirationWidget(sIdentity)
    local ctrlChar = CharacterListManager.getDisplayControlByPath(sIdentity.sPath)
    local widget = ctrlChar.findWidget('inspiration')
    if widget then
        if OptionsManager.getOption('CHATINSPIRATION') == 'yes' then
            widget.setBitmap('charlist_inspiration' .. sIcon)
        else
            widget.setBitmap('charlist_inspiration')
        end
        CharacterListManager_Inspiration.updateWidgets(ctrlChar)
    end

end

function changeChat(messagedata)
    local bHideBIDIOutput = (bBIDI and messagedata.text:match('Bardic Inspiration'))
    local bOverride = StringManager.contains(aOverrides, messagedata.icon)
    if messagedata.icon == 'portrait_gm_token' then
        messagedata.icon = sGMIcon
    end
    if (OptionsManager.getOption('CHATFONTCOLORS') ~= 'off') then
        if (messagedata.icon == 'roll_attack_hit') then
            if bHideBIDIOutput then
                messagedata.font = 'attack_roll_msgfont' .. sFont
            else
                messagedata.font = 'attack_roll_hit_msgfont' .. sFont
            end
        elseif (messagedata.icon == 'roll_attack_miss') then
            if bHideBIDIOutput then
                messagedata.font = 'attack_roll_msgfont' .. sFont
            elseif string.match(messagedata.text, '%[AUTOMATIC MISS%]') then
                messagedata.font = 'attack_roll_fumble_msgfont' .. sFont
            else
                messagedata.font = 'attack_roll_miss_msgfont' .. sFont
            end
        elseif (messagedata.icon == 'roll_attack_crit') then
            messagedata.font = 'attack_roll_crit_msgfont' .. sFont
        elseif (messagedata.icon == 'roll_damage') then
            messagedata.font = 'dammage_roll_msgfont' .. sFont
        elseif (messagedata.icon == 'roll_cast') then
            messagedata.font = 'cast_roll_msgfont' .. sFont
        elseif (messagedata.icon == 'roll_heal') then
            messagedata.font = 'heal_roll_msgfont' .. sFont
        elseif (messagedata.icon == 'roll_effect') then
            messagedata.font = 'effect_msgfont' .. sFont
        end
        if StringManager.contains(aFontsTypes, messagedata.font) then
            messagedata.font = messagedata.font .. sFont
        end
    end
    if (OptionsManager.getOption('CHATICONTHEME') ~= 'off') and messagedata.icon then
        if bOverride then
            if (messagedata.icon == 'roll_attack_miss') and
                (string.match(messagedata.text, '%[AUTOMATIC MISS%]') or string.match(messagedata.text, '%[CRITICAL MISS%]')) then
                messagedata.icon = 'roll_attack_fumble' .. sIcon
            elseif (messagedata.icon == 'roll_effect') and string.match(messagedata.text, '%[EXPIRED%]') then
                messagedata.icon = 'roll_effect_expired' .. sIcon
            else
                messagedata.icon = messagedata.icon .. sIcon
            end

        end
        if bHideBIDIOutput and messagedata.icon:match('roll_attack') then
            messagedata.icon = 'roll_attack' .. sIcon
        end
    end
end

function changeIconTheme()
    local sUseIconTheme = OptionsManager.getOption('CHATICONTHEME')
    if StringManager.contains(aIconTheme, sUseIconTheme) then
        sIcon = '_' .. sUseIconTheme
    else
        sIcon = ''
    end
end

function changeFontTheme()
    local sUseFontTheme = OptionsManager.getOption('CHATFONTCOLORS')
    if StringManager.contains(aFontTheme, sUseFontTheme) then
        sFont = '_' .. sUseFontTheme
    else
        sFont = ''
    end
end

function changeGMIcon()
    local sUseGMIcon = OptionsManager.getOption('CHATGMICON')
    local sUseGMIconColor = OptionsManager.getOption('CHATGMICONCOLOR')

    sGMIcon = 'GMIcon'
    if (sUseGMIcon == 'default') then
        sGMIcon = 'GMIcon_default'
    elseif StringManager.contains(aGMIcon, sUseGMIcon) then
        sGMIcon = sGMIcon .. '_' .. sUseGMIcon .. '_' .. sUseGMIconColor
    elseif StringManager.contains(aGMCustom, sUseGMIcon) then
        sGMIcon = sGMIcon .. '_' .. sUseGMIcon
    else
        sGMIcon = 'portrait_gm_token'
    end
end

function addFontTheme(sFontThemeLabel, sFontThemeValue)
    OptionsManager.addOptionValue('CHATFONTCOLORS', sFontThemeLabel, sFontThemeValue)
    table.insert(aFontTheme, sFontThemeValue)
end

function addIconTheme(sIconThemeLabel, sIconThemeValue)
    OptionsManager.addOptionValue('CHATICONTHEME', sIconThemeLabel, sIconThemeValue)
    table.insert(aIconTheme, sIconThemeValue)
end

function addGMPortrait(sPortraitLabel, sPortraitValue)
    -- local sPortrait = "GMIcon_" .. sPortraitValue
    -- if not Interface.isIcon(sPortrait) then
    -- 	table.insert(aCustomThemeErrors, "GM Portrait: " .. sPortrait .. " does not exist")
    -- else
    OptionsManager.addOptionValue('CHATGMICON', sPortraitLabel, sPortraitValue)
    table.insert(aGMCustom, sPortraitValue)
    -- end
end

-- Probably want to think about this more. Do we want to force errors and not load
-- What if in the future we add more icon/font hooks? I don't think we want to not
-- load what a user might have as custom assets
function printErrors()
    local rMessage = {font = 'systemfont', icon = 'drowbe_brand'}
    for _, sError in pairs(aCustomThemeErrors) do
        rMessage.text = sError
        Comm.addChatMessage(rMessage)
    end
end
