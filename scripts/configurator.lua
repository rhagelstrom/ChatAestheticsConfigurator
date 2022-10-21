local sIcon = nil
local sFont = nil
local sGMIcon = nil
local bBIDI = false
local bInspiration = false

local createEntry = nil
local deliverChatMessage = nil

local aGMIcon = {"skull","dm","gm"}
local aFontTheme = {"light","dark"}
local aIconTheme = {"hex","simple","round","square", "dots"}
local aOverrides  = {"roll_attack", "roll_attack_hit", "roll_attack_miss", "roll_attack_crit","roll_damage","roll_cast", "roll_heal", "roll_effect" }
local aFontsTypes = {"chatfont", "emotefont", "narratorfont", "systemfont", "msgfont", "oocfont", "chatnpcfont", "chatgmfont", "whisperfont"}

function onInit()
	registerChatOptions()

	OptionsManager.registerCallback("CHATICONTHEME", changeIconTheme)
	OptionsManager.registerCallback("CHATFONTCOLORS", changeFontTheme)
	OptionsManager.registerCallback("CHATGMICON", changeGMIcon)
	OptionsManager.registerCallback("CHATGMICONCOLOR", changeGMIcon)
	deliverChatMessage = Comm.deliverChatMessage
	Comm.deliverChatMessage = customDeliverChatMessage

	changeIconTheme()
	changeFontTheme()
	changeGMIcon()
	for _,sName in pairs(Extension.getExtensions()) do
		if Extension.getExtensionInfo(sName).name:match("Bardic Inspiration Die") then
			bBIDI = true
			OptionsManager.registerCallback("CHATICONTHEME", changeInspirationWidget)
			break
		end
	end

	--Inspiration
	if User.getRulesetName() == "5E" or User.getRulesetName() == "2E" then
		bInspiration = true
		createEntry = CharacterListManager.createEntry
		CharacterListManager.createEntry = customCreateEntry
	end
end

function onClose()
	OptionsManager.unregisterCallback("CHATICONTHEME", changeIconTheme)
	OptionsManager.unregisterCallback("CHATFONTCOLORS", changeFontTheme)
	OptionsManager.unregisterCallback("CHATGMICON", changeGMIcon)
	OptionsManager.unregisterCallback("CHATGMICONCOLOR", changeGMIcon)
	Comm.deliverChatMessage = deliverChatMessage
	if bInspiration then
		OptionsManager.unregisterCallback("CHATICONTHEME", changeInspirationWidget)
		CharacterListManager.createEntry = createEntry
	end
end

function registerChatOptions()
	OptionsManager.registerOption2(
	"CHATICONTHEME",
	 	false,
	 	"option_header_chat_aesthetics_configurator",
	 	"option_label_CHATICONTHEME",
	 	"option_entry_cycler",
	 	{
			labels = "option_val_theme_simple|option_val_theme_hex|option_val_theme_round|option_val_theme_square|option_val_theme_dots",
	 		values = "simple|hex|round|square|dots",
			baselabel = "option_val_theme_off",
	 		baseval = "off",
	 		default = "simple"
	 	}
	)

	OptionsManager.registerOption2(
		"CHATFONTCOLORS",
		false,
		"option_header_chat_aesthetics_configurator",
		"option_label_CHATUSEFONTCOLORS",
		"option_entry_cycler",
		{
			-- labels = "option_val_font_dark|option_val_font_light|option_val_font_hearth",
			-- values = "dark|light|hearth",
			labels = "option_val_font_dark|option_val_font_light",
			values = "dark|light",
			baselabel = "option_val_font_off",
			baseval = "off",
			default = "dark"
		}
	)

    OptionsManager.registerOption2(
        "CHATGMICON",
        false,
        "option_header_chat_aesthetics_configurator",
        "option_label_CHATGMICON",
        "option_entry_cycler",
        {
            labels = "option_val_gmicon_dm|option_val_gmicon_gm|option_val_gmicon_skull",
            values = "dm|gm|skull",
	        baselabel = "option_val_gmicon_default",
            baseval = "default",
            default = "default"
        }
    )
    OptionsManager.registerOption2(
        "CHATGMICONCOLOR",
        false,
        "option_header_chat_aesthetics_configurator",
        "option_label_CHATGMICONCOLOR",
        "option_entry_cycler",
        {
            labels = "option_val_gmicon_blood|option_val_gmicon_blue|option_val_gmicon_green|option_val_gmicon_purple|option_val_gmicon_red",
            values = "blood|blue|green|purple|red",
	        baselabel = "option_val_gmicon_black",
            baseval = "black",
            default = "black"
        }
    )
end

function customDeliverChatMessage(messagedata, tRecipients)
	changeChat(messagedata)
	deliverChatMessage(messagedata, tRecipients)
end

function customCreateEntry(sIdentity)
	createEntry(sIdentity)
	replaceInspirationWidget(sIdentity)
end

function changeInspirationWidget()
	local tIdentities = User.getAllActiveIdentities()
	for _,sIdentity in pairs(tIdentities) do
		replaceInspirationWidget(sIdentity)
	end
end

function replaceInspirationWidget(sIdentity)
	local ctrlChar = CharacterListManager.findControlForIdentity(sIdentity)
	if ctrlChar then
		local widget = ctrlChar.findWidget("inspiration")
		if widget then
			widget.setBitmap("charlist_inspiration" .. sIcon)
			CharacterListManager_Inspiration.updateWidgets(sIdentity)
		end
	end
end

function changeChat(messagedata)
	local bHideBIDIOutput = (bBIDI and messagedata.text:match("Bardic Inspiration"))
	local bOverride = StringManager.contains(aOverrides, messagedata.icon)
	if messagedata.icon == "portrait_gm_token" then
		messagedata.icon = sGMIcon
	end
	if (OptionsManager.getOption("CHATFONTCOLORS") ~= "off") then
		if (messagedata.icon == "roll_attack_hit") then
			if bHideBIDIOutput  then
				messagedata.font = "attack_roll_msgfont" .. sFont
			else
				messagedata.font = "attack_roll_hit_msgfont" .. sFont
			end
		elseif (messagedata.icon == "roll_attack_miss") then
			if bHideBIDIOutput  then
				messagedata.font = "attack_roll_msgfont" .. sFont
			elseif string.match(messagedata.text, "%[AUTOMATIC MISS%]") then
				messagedata.font = "attack_roll_fumble_msgfont" .. sFont
			else
				messagedata.font = "attack_roll_miss_msgfont" .. sFont
			end
		elseif (messagedata.icon == "roll_attack_crit") then
			messagedata.font = "attack_roll_crit_msgfont" .. sFont
		elseif (messagedata.icon == "roll_damage") then
			messagedata.font = "dammage_roll_msgfont" .. sFont
		elseif (messagedata.icon == "roll_cast") then
			messagedata.font = "cast_roll_msgfont" .. sFont
		elseif (messagedata.icon == "roll_heal") then
			messagedata.font = "heal_roll_msgfont" .. sFont
		elseif (messagedata.icon == "roll_effect") then
			messagedata.font = "effect_msgfont" .. sFont
		end
		if StringManager.contains(aFontsTypes, messagedata.font) then
			messagedata.font =  messagedata.font .. sFont
		end
	end
	if (OptionsManager.getOption("CHATICONTHEME") ~= "off") then
		if bOverride then
			if (messagedata.icon == "roll_attack_miss") and (string.match(messagedata.text, "%[AUTOMATIC MISS%]") or string.match(messagedata.text, "%[CRITICAL MISS%]")) then
				messagedata.icon = "roll_attack_fumble" .. sIcon
			elseif (messagedata.icon == "roll_effect")  and string.match(messagedata.text, "%[EXPIRED%]") then
				messagedata.icon = "roll_effect_expired" .. sIcon
			else
				messagedata.icon = messagedata.icon .. sIcon
			end

		end
		if bHideBIDIOutput and messagedata.icon:match("roll_attack") then
			messagedata.icon = "roll_attack" .. sIcon
		end
	end
end

function changeIconTheme()
	local sUseIconTheme = OptionsManager.getOption("CHATICONTHEME")
	if StringManager.contains(aIconTheme, sUseIconTheme) then
		sIcon = "_" ..sUseIconTheme
	else
		sIcon = ""
	end
end

function changeFontTheme()
	local sUseFontTheme = OptionsManager.getOption("CHATFONTCOLORS")
	if StringManager.contains(aFontTheme, sUseFontTheme) then
		sFont = "_" ..sUseFontTheme
	else
		sFont = ""
	end
end

function changeGMIcon()
	local sUseGMIcon = OptionsManager.getOption("CHATGMICON")
	local sUseGMIconColor = OptionsManager.getOption("CHATGMICONCOLOR")

	sGMIcon = "GMIcon"
	if (sUseGMIcon == "default") then
		sGMIcon = "GMIcon_default"
	elseif StringManager.contains(aGMIcon, sUseGMIcon) then
		sGMIcon = sGMIcon .. "_" .. sUseGMIcon .. "_" .. sUseGMIconColor
	else
		sGMIcon "portrait_gm_token"
	end
end