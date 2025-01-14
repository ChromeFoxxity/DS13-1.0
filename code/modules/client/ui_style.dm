
// The default UI style is the first one in the list
GLOBAL_LIST_INIT(available_ui_styles, list(
	"Midnight"     = 'icons/hud/midnight.dmi',
	"Orange"       = 'icons/hud/orange.dmi',
	"old"          = 'icons/hud/old.dmi',
	"White"        = 'icons/hud/white.dmi',
	"old-noborder" = 'icons/hud/old-noborder.dmi',
	"minimalist"   = 'icons/hud/minimalist.dmi'
))

/proc/ui_style2icon(ui_style)
	return GLOB.available_ui_styles[ui_style] || GLOB.available_ui_styles[GLOB.available_ui_styles[1]]


/client/verb/change_ui()
	set name = "Change UI"
	set category = "OOC"
	set desc = "Configure your user interface"

	if(!ishuman(usr))
		to_chat(usr, "<span class='warning'>You must be human to use this verb.</span>")
		return

	var/UI_style_new = input(usr, "Select a style. White is recommended for customization") as null|anything in GLOB.available_ui_styles
	if(!UI_style_new) return

	var/UI_style_alpha_new = input(usr, "Select a new alpha (transparency) parameter for your UI, between 50 and 255") as null|num
	if(!UI_style_alpha_new || !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return

	var/UI_style_color_new = input(usr, "Choose your UI color. Dark colors are not recommended!") as color|null
	if(!UI_style_color_new) return

	//update UI
	var/list/icons = usr.hud_used.static_inventory + usr.hud_used.toggleable_inventory + usr.hud_used.hotkeybuttons
	icons.Add(usr.hud_used.zone_sel)
	icons.Add(usr.hud_used.gun_setting_icon)

	var/icon/ic = GLOB.available_ui_styles[UI_style_new]

	for(var/atom/movable/screen/I in icons)
		if(I.name in list(I_HELP, I_HURT, I_DISARM, I_GRAB)) continue
		I.icon = ic
		I.color = UI_style_color_new
		I.alpha = UI_style_alpha_new


	if(tgui_alert(src, "Like it? Save changes?", "Confirmation", list("Yes", "No")) == "Yes")
		prefs.UI_style = UI_style_new
		prefs.UI_style_alpha = UI_style_alpha_new
		prefs.UI_style_color = UI_style_color_new
		SScharacter_setup.queue_preferences_save(prefs)
		to_chat(usr, "UI was saved")
