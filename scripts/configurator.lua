

-- ***********************************************************************
-- **																	**
-- **	  	 Local: Declares all variables								**
-- **	     Notes: none												**
-- **																	**
-- ***********************************************************************

local outputResult = nil;
local strUseFontTheme = nil;
local strUseIconTheme = nil;
local strTempIcon = nil;
local strTempFont = nil;

local boolDebug = "off";


-- ***********************************************************************
-- **																	**
-- **	  Function: onInit()											**
-- **	Parameters:	None												**
-- **	   Returns: Nothing												**
-- **	     Notes: Fires off all functions on initialization			**
-- **																	**
-- ***********************************************************************

function onInit()

	-- Set the options
	registerChatOptions();
	-- Initialize the theme based on previously selected options
	-- may not need this is we get toggling going
    changeChatTheme();
	-- Change all of the icons and fonts based on the hit ans settings
	outputResult = ActionsManager.outputResult;
	ActionsManager.outputResult = swapThemeCollateral;

end


-- ***********************************************************************
-- **																	**
-- **	  Function: swapThemeCollateral()								**
-- **	Parameters:	bTower 												**
-- **				rSource												**
-- **				rTarget 											**
-- **				rMessageGM											**
-- **				rMessagePlayer										**
-- **	   Returns: Nothing												**
-- **	     Notes: Registers all options used by this extension		**
-- **																	**
-- ***********************************************************************

function swapThemeCollateral(bTower, rSource, rTarget, rMessageGM, rMessagePlayer)

	-- *** DEBUG Let's see WTF is happening *** --
	if (boolDebug == "on") then
		Debug.console("---------------------------------------------------");
		Debug.console("------------------- BEGIN DEBUG -------------------");
		Debug.console("---------------------------------------------------");
		Debug.console("rMessageGM = ", rMessageGM);
		Debug.console("---------------------------------------------------");
		Debug.console("rMessagePlayer = ", rMessagePlayer);
		Debug.console("---------------------------------------------------");
		Debug.console("rTarget = ", rTarget);
		Debug.console("---------------------------------------------------");
		Debug.console("rSource = ", rSource);
		Debug.console("---------------------------------------------------");
		Debug.console("bTower = ", bTower);
		Debug.console("---------------------------------------------------");
		Debug.console("rMessageGM.text = ", rMessageGM.text);
		Debug.console("---------------------------------------------------");
		Debug.console("rMessagePlayer.text = ", rMessagePlayer.text);
		Debug.console("---------------------------------------------------");
		Debug.console("rMessageGM.icon = ", rMessageGM.icon);
		Debug.console("---------------------------------------------------");
		Debug.console("rMessagePlayer.icon = ", rMessagePlayer.icon);
		Debug.console("---------------------------------------------------");
		Debug.console("------------------- END DEBUG -------------------");
		Debug.console("---------------------------------------------------");
	end


	-- check the chat message for hits and misses
	if (rMessageGM and rMessagePlayer) then
		
		-- *************************************** --
		-- **	GET OPTION						** --
		-- *************************************** --

		strUseFontTheme = OptionsManager.getOption("CHATFONTCOLORS");
		strUseIconTheme = OptionsManager.getOption("CHATICONTHEME");

		-- *************************************** --
		-- **	CHANGE THE FONTS 				** --
		-- *************************************** --

		--set the string
		if (strUseFontTheme == "hearth") then
			strTempFont = "_hearth";
		elseif (strUseFontTheme == "light") then
			strTempFont = "_light";
		elseif (strUseFontTheme == "dark") then
			strTempFont = "_dark";
		else
			strTempFont = "";
		end
		-- Set the theme
		if (strUseFontTheme == "off") then
			-- set nothing'
		else
			-- now set the new fonts
			if (rMessageGM.icon == "roll_attack_hit") then
				-- it is a normal hit... 
				-- ONCE THIS WORKS, JUST APPEND A STRING TO THE END
				-- set the icon to hex hit
				rMessageGM.font = "attack_roll_hit_msgfont" .. strTempFont;
				rMessagePlayer.font = "attack_roll_hit_msgfont" .. strTempFont;
			elseif (rMessageGM.icon == "roll_attack_miss") then
				-- it is not a hit
				-- set things to a miss
				rMessageGM.font = "attack_roll_miss_msgfont" .. strTempFont;
				rMessagePlayer.font = "attack_roll_miss_msgfont" .. strTempFont;
				-- now that it is a miss, see if it is a fumble
				if string.match(rMessageGM.text, "%[AUTOMATIC MISS%]") then
					-- it is a fumble... reset things to a fumble
					rMessageGM.font = "attack_roll_fumble_msgfont" .. strTempFont;
					rMessagePlayer.font = "attack_roll_fumble_msgfont" .. strTempFont;
				end	
			elseif (rMessageGM.icon == "roll_attack_crit") then
				-- it is a critical hit... set the stuff for crit
				rMessageGM.font = "attack_roll_crit_msgfont" .. strTempFont;
				rMessagePlayer.font = "attack_roll_crit_msgfont" .. strTempFont;
			elseif (rMessageGM.icon == "roll_damage") then
				-- it is a dammage roll
				rMessageGM.font = "dammage_roll_msgfont" .. strTempFont;
				rMessagePlayer.font = "dammage_roll_msgfont" .. strTempFont;
			elseif (rMessageGM.icon == "roll_cast") then
				-- it is a cast roll
				rMessageGM.font = "cast_roll_msgfont" .. strTempFont;
				rMessagePlayer.font = "cast_roll_msgfont" .. strTempFont;
			elseif (rMessageGM.icon == "roll_heal") then
				-- it is a cast roll
				rMessageGM.font = "heal_roll_msgfont" .. strTempFont;
				rMessagePlayer.font = "heal_roll_msgfont" .. strTempFont;
			elseif (rMessageGM.icon == "roll_effect") then
				-- it is an effect roll
				rMessageGM.font = "effect_msgfont" .. strTempFont;
				rMessagePlayer.font = "effect_msgfont" .. strTempFont;
			end
		end
		-- ********* END CHANGE THE FONTS ******** --


		-- *************************************** --
		-- **	CHANGE THE ICONS 				** --
		-- *************************************** --
		
		--set the string
		if (strUseIconTheme == "hex") then
			strTempIcon = "_hex";
		elseif (strUseIconTheme == "simple") then
			strTempIcon = "_simple";
		elseif (strUseIconTheme == "round") then
			strTempIcon = "_round";
		elseif (strUseIconTheme == "square") then
			strTempIcon = "_square";
		elseif (strUseIconTheme == "dots") then
			strTempIcon = "_dots";
		else
			strTempIcon = "";
		end

		-- now set the new icons
		if (rMessageGM.icon == "roll_attack_hit") then
			-- it is a normal hit... 
			-- ONCE THIS WORKS, JUST APPEND A STRING TO THE END
			-- set the icon to hex hit
			rMessageGM.icon = "roll_attack_hit" .. strTempIcon;
			rMessagePlayer.icon = "roll_attack_hit" .. strTempIcon;
		elseif (rMessageGM.icon == "roll_attack_miss") then
			-- it is not a hit
			-- set things to a miss
			rMessageGM.icon = "roll_attack_miss" .. strTempIcon;
			rMessagePlayer.icon = "roll_attack_miss" .. strTempIcon;

			-- now that it is a miss, see if it is a fumble
			if string.match(rMessageGM.text, "%[AUTOMATIC MISS%]") then
				-- it is a fumble... reset things to a fumble
				rMessageGM.icon = "roll_attack_fumble" .. strTempIcon;
				rMessagePlayer.icon = "roll_attack_fumble" .. strTempIcon;
			end
					
		elseif (rMessageGM.icon == "roll_attack_crit") then
			-- it is a critical hit... set the stuff for crit
			rMessageGM.icon = "roll_attack_crit" .. strTempIcon;
			rMessagePlayer.icon = "roll_attack" .. strTempIcon;

		elseif (rMessageGM.icon == "roll_damage") then
			-- it is a dammage roll
			rMessageGM.icon = "roll_damage" .. strTempIcon;
			rMessagePlayer.icon = "roll_damage" .. strTempIcon;

		elseif (rMessageGM.icon == "roll_cast") then
			-- it is a cast roll
			rMessageGM.icon = "roll_cast" .. strTempIcon;
			rMessagePlayer.icon = "roll_cast" .. strTempIcon;

		elseif (rMessageGM.icon == "roll_heal") then
			-- it is a heal roll
			rMessageGM.icon = "roll_heal" .. strTempIcon;
			rMessagePlayer.icon = "roll_heal" .. strTempIcon;

		elseif (rMessageGM.icon == "roll_effect") then
			-- it is an effect roll
			rMessageGM.icon = "roll_effect" .. strTempIcon;
			rMessagePlayer.icon = "roll_effect" .. strTempIcon;

		end
		-- ********* END CHANGE THE ICONS ******** --

		-- *************************************** --
		-- **		PORTRAIT OVERRIDE 			** --
		-- *************************************** --
		-- if the user doesn't wants to use character portriats instead of
		-- custom icons, override the icons we just set.
		--if (strUseIconTheme == "portraits") then
		--	Debug.console("strUseIconTheme = ", strUseIconTheme);
		--	Debug.console("sType = ", rSource["sType"]);
		--	-- make sure it is a player character
		--	if (rSource["sType"] == "pc") then
		--		local charsheet = DB.findNode(rSource["sCreatureNode"]);
		--		Debug.console("charsheet = ", charsheet);
		--		Debug.console("charsheet.getName = ", charsheet.getName());
	 	--		rMessageGM.icon = "portrait_" .. charsheet.getName() .. "_chat";
		--		rMessagePlayer.icon = "portrait_" .. charsheet.getName() .. "_chat";
		--	end
		--end



		-- WHEN WORKING ON THIS, MOVE IT BEFORE WE REST ICONS INTO EFFECT "ELSE"
		-- *************************************** --
		-- **	CHANGE THE EFFECTS ICONS 		** --
		-- *************************************** --

		-- BEGIN: CHECK FOR EFFECTS ... THIS WILL NEVER GET TRIGGERED NEED A NEW SOLUTION
		-- This EFFECTS isn't working
		-- Debug.console("rMessageGM = ", rMessageGM.text);
		-- Debug.console("rMessagePlayer = ", rMessagePlayer.text);

		--if string.match(rMessageGM.text, "Effect%[") then

			-- Debug.console("it matched the string. rMessageGM, rMessagePlayer = ", rMessageGM, rMessagePlayer);

			-- the effect is EXPIRED?? This can't be right.
		--	rMessageGM.icon = "effect";
		--	rMessagePlayer.icon = "effect";
		--	rMessageGM.font = "effect_msgfont";
		--	rMessagePlayer.font = "effect_msgfont";
			-- Once this is working us the actual effect types
		-- end

		-- ********* END CHANGE EFFECTS ICONS ******** --
		
	end




	-- send it to the chat window... woot
	outputResult(bTower, rSource, rTarget, rMessageGM, rMessagePlayer);
end


-- ***********************************************************************
-- **																	**
-- **	  Function: registerChatOptions()								**
-- **	Parameters:	None												**
-- **	   Returns: Nothing												**
-- **	     Notes: Registers all options used by this extension		**
-- **																	**
-- ***********************************************************************

function registerChatOptions()


	-- ** Set the Theme **
	OptionsManager.registerOption2(
	"CHATICONTHEME",
	 	false,
	 	"option_header_chat_aesthetics_configurator",
	 	"option_label_CHATICONTHEME",
	 	"option_entry_cycler",
	 	{
	 		--labels = "option_val_theme_simple|option_val_theme_hex|option_val_theme_round|option_val_theme_square|option_val_theme_portraits|option_val_theme_off",
	 		--values = "simple|hex|round|square|portraits|off",
			labels = "option_val_theme_simple|option_val_theme_hex|option_val_theme_round|option_val_theme_square|option_val_theme_dots",
	 		values = "simple|hex|round|square|dots",
			baselabel = "option_val_theme_off",
	 		baseval = "off",
	 		default = "simple"
	 	}
	);

	-- ** Set the Font **
	OptionsManager.registerOption2(
		"CHATFONTCOLORS",
		false,
		"option_header_chat_aesthetics_configurator",
		"option_label_CHATUSEFONTCOLORS",
		"option_entry_cycler",
		{
			labels = "option_val_font_dark|option_val_font_light|option_val_font_hearth",
			values = "dark|light|hearth",
			baselabel = "option_val_font_off",
			baseval = "off",
			default = "dark"
		}
	);

	-- ** Set the GM Icon **
    -- OptionsManager.registerOption2(
    --     "CHATGMICON",
    --     false,
    --     "option_header_chat_aesthetics_configurator",
    --     "option_label_CHATGMICON",
    --     "option_entry_cycler",
    --     {
    --         labels = "option_val_gmicon_default|option_val_gmicon_round|option_val_gmicon_hex",
    --         values = "default|round|hex",
    --         baselabel = "option_val_gmicon_default",
    --         baseval = "default",
    --         default = "default"
    --     }
    -- );

end


-- ***********************************************************************
-- **																	**
-- **	  Function: changeChatTheme										**
-- **	Parameters:	None												**
-- **	   Returns: Nothing												**
-- **	     Notes: Right now this does nothing. It will be wired to	**
-- **				deal with the icon swapping at some point.			**
-- **																	**
-- ***********************************************************************

function changeChatTheme()

	-- Debug.console("gmicon = ", rMessageGM.icon);
	-- tBitmapNames["roll_damage"] = "roll_damage_simple";
	-- Debug.console("tBitmapNames = ", tBitmapNames["roll_damage"]);
	-- Get the theme from options
	-- strTheme = OptionsManager.getOption("CHATTHEME");
	-- Debug.console("strTheme = ", strTheme);
	-- tBitmapChatIcons["roll_attack_hit"] = "roll_attack_hit_"..OptionsManager.getOption("CHATTHEME");

		-- if option == "A" then
		--   window.button.setIcons("buttonIcon".."A")
		-- elseif option == "B" then
		--   window.button.setIcons("buttonIcon".."B")
		--end  
	-- Set the theme
	-- if (strTheme == "hex") then
		-- HEX Theme
		-- Debug.console("** HEX ** ");

		-- window.roll_attack_hit.setIcons("roll_attack_hit".."_hex")
		-- window.roll_attack_hit.setIcons("themes/hex/roll_attack.png");
		-- ChatManager.roll_attack_hit.setIcons("themes/hex/effect.png");
		--tBitmapChatIcons["roll_attack_hit"] = "roll_attack_hit_"..OptionsManager.getOption("DEATHINDICATOR");
		-- statusWidget = tokenCT.addBitmapWidget(tBitmapNames[sBitmapName]);
    	-- statusWidget.setBitmap(tBitmapNames[sBitmapName]);
		--tBitmapNames["roll_attack_hit"] = "roll_attack_hit_hex";
		--tBitmapChatIcons["roll_attack_hit"] = "roll_attack_hit_"..strTheme;
		--<icon name="roll_attack" file="themes/hex/roll_attack.png" />
	-- else
		-- None selected use default
		--Debug.console("** ELSE DEFAULT ** ");
	-- end

end