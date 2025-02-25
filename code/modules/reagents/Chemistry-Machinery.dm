#define BOTTLE_SPRITES list("bottle-1", "bottle-2", "bottle-3", "bottle-4") //list of available bottle sprites

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	name = "\improper ChemMaster 3000"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	clicksound = "button"
	clickvol = 20
	circuit = /obj/item/circuitboard/chem_master
	var/obj/item/reagent_containers/beaker = null
	var/obj/item/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 0
	var/condi = FALSE
	var/useramount = 15 // Last used amount
	var/pillamount = 10
	var/list/bottle_styles
	var/bottlesprite = 1
	var/pillsprite = 1
	var/max_pill_count = 20
	var/printing = FALSE
	var/list/pill_bottle_wrappers = list(
		"CLEAR" = "Default",
		COLOR_RED = "Red",
		COLOR_GREEN = "Green",
		COLOR_PALE_BTL_GREEN = "Pale Green",
		COLOR_BLUE = "Blue",
		COLOR_CYAN_BLUE = "Light Blue",
		COLOR_TEAL = "Teal",
		COLOR_YELLOW = "Yellow",
		COLOR_ORANGE = "Orange",
		COLOR_PINK = "Pink",
		COLOR_MAROON = "Brown"
	)

/obj/machinery/chem_master/Initialize()
	.=..()
	create_reagents(1000)

/obj/machinery/chem_master/ex_act(severity)
	if(atom_flags & ATOM_FLAG_INDESTRUCTIBLE)
		return
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return

/obj/machinery/chem_master/update_icon()
	icon_state = "mixer[beaker ? "1" : "0"]"

/obj/machinery/chem_master/dismantle()
	if(beaker)
		beaker.forceMove(loc)
	..()

/obj/machinery/chem_master/attackby(var/obj/item/B as obj, var/mob/user as mob)
	if(default_deconstruction_screwdriver(user, B))
		SStgui.update_uis(src)
		return
	if(default_deconstruction_crowbar(user, B))
		return
	if(default_part_replacement(user, B))
		return

	if(istype(B, /obj/item/reagent_containers/glass))
		if(beaker)
			to_chat(user, "A beaker is already loaded into the machine.")
			return
		if(!user.unEquip(B, src))
			return
		beaker = B
		to_chat(user, "You add the beaker to the machine!")
		update_icon()

	else if(istype(B, /obj/item/storage/pill_bottle))
		if(loaded_pill_bottle)
			to_chat(user, "A pill bottle is already loaded into the machine.")
			return
		if(!user.unEquip(B, src))
			return
		loaded_pill_bottle = B
		to_chat(user, "You add the pill bottle into the dispenser slot!")

	SStgui.update_uis(src)

/obj/machinery/chem_master/attack_hand(mob/user as mob)
	if(inoperable())
		return
	tgui_interact(user)

/obj/machinery/chem_master/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/pill_bottles),
		get_asset_datum(/datum/asset/simple/chem_master),
	)

/obj/machinery/chem_master/tgui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMaster", name)
		ui.open()

/obj/machinery/chem_master/ui_data(mob/user)
	var/list/data = list()

	data["loaded_pill_bottle"] = !!loaded_pill_bottle
	if(loaded_pill_bottle)
		data["loaded_pill_bottle_name"] = loaded_pill_bottle.name
		data["loaded_pill_bottle_second_name"] = replace_characters(loaded_pill_bottle.name, list("pill bottle"="", " ("="", ")"=""))
		data["loaded_pill_bottle_color"] = sanitizeFileName(pill_bottle_wrappers[loaded_pill_bottle.wrapper_color]) || "Default"
		data["loaded_pill_bottle_contents_len"] = loaded_pill_bottle.contents.len
		data["loaded_pill_bottle_storage_slots"] = loaded_pill_bottle.max_storage_space

	data["beaker"] = !!beaker
	if(beaker)
		var/list/beaker_reagents_list = list()
		data["beaker_reagents"] = beaker_reagents_list
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beaker_reagents_list[++beaker_reagents_list.len] = list("name" = R.name, "volume" = R.volume, "id" = R.type, "description" = R.description)

		var/list/buffer_reagents_list = list()
		data["buffer_reagents"] = buffer_reagents_list
		for(var/datum/reagent/R in reagents.reagent_list)
			buffer_reagents_list[++buffer_reagents_list.len] = list("name" = R.name, "volume" = R.volume, "id" = R.type, "description" = R.description)

	data["pillsprite"] = pillsprite
	data["bottlesprite"] = bottlesprite
	data["mode"] = mode
	data["printing"] = printing

	return data

/obj/machinery/chem_master/ui_static_data(mob/user)
	. = list()
	.["condi"] = condi
	var/colors = list()
	for(var/A in pill_bottle_wrappers)
		colors += pill_bottle_wrappers[A]
	// Transfer modal information if there is one
	.["pill_bottle_colors"] = colors

/obj/machinery/chem_master/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	add_fingerprint(usr)
	switch(action)
		if("toggle")
			mode = !mode
			return TRUE
		if("ejectp")
			if(loaded_pill_bottle)
				loaded_pill_bottle.forceMove(get_turf(src))
				if(Adjacent(usr) && !issilicon(usr))
					usr.put_in_hands(loaded_pill_bottle)
				loaded_pill_bottle = null
			return TRUE
		if("print")
			if(printing || condi)
				return

			var/idx = text2num(params["idx"]) || 0
			var/from_beaker = text2num(params["beaker"]) || FALSE
			var/reagent_list = from_beaker ? beaker.reagents.reagent_list : reagents.reagent_list
			if(idx < 1 || idx > length(reagent_list))
				return

			var/datum/reagent/R = reagent_list[idx]

			printing = TRUE
			visible_message("<span class='notice'>[src] rattles and prints out a sheet of paper.</span>")
			// playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)

			var/obj/item/paper/P = new /obj/item/paper(loc)
			P.info = "<center><b>Chemical Analysis</b></center><br>"
			P.info += "<b>Time of analysis:</b> [station_time()]<br><br>"
			P.info += "<b>Chemical name:</b> [R.name]<br>"
			if(istype(R, /datum/reagent/blood))
				var/datum/reagent/blood/B = R
				P.info += "<b>Description:</b> N/A<br><b>Blood Type:</b> [B.data["blood_type"]]<br><b>DNA:</b> [B.data["blood_DNA"]]"
			else
				P.info += "<b>Description:</b> [R.description]"
			P.info += "<br><br><b>Notes:</b><br>"
			P.name = "Chemical Analysis - [R.name]"
			spawn(50)
				printing = FALSE
			return TRUE
		if("change_pill_bottle_style")
			if(!loaded_pill_bottle || !pill_bottle_wrappers)
				return
			var/color = "CLEAR"
			for(var/col in pill_bottle_wrappers)
				var/col_name = pill_bottle_wrappers[col]
				if(col_name == params["color"])
					color = col
					break
			if(color && color != "CLEAR")
				loaded_pill_bottle.wrapper_color = color
			else
				loaded_pill_bottle.wrapper_color = null
			loaded_pill_bottle.update_icon()
			return TRUE
		if("change_pill_bottle_name")
			if(!loaded_pill_bottle || !pill_bottle_wrappers)
				return
			var/answer = replace_characters(params["name"], list("(" = "", ")" =""))
			if(!answer || !replace_characters(answer, list(" " = "")))
				loaded_pill_bottle.name = "pill bottle"
			else
				loaded_pill_bottle.name = "pill bottle ([answer])"
			return TRUE
		if("add")
			var/id = text2path(params["id"])
			var/amount = text2num(params["amount"])
			if(!id || !amount)
				return
			beaker.reagents.trans_type_to(src, id, amount)
			return TRUE
		if("remove")
			var/id = text2path(params["id"])
			var/amount = text2num(params["amount"])
			if(!id || !amount)
				return
			if(mode)
				reagents.trans_type_to(beaker, id, amount)
			else
				reagents.remove_reagent(id, amount)
			return TRUE
		if("eject")
			if(!beaker)
				return
			if(mode)
				reagents.trans_to(beaker, reagents.total_volume)
			beaker.forceMove(get_turf(src))
			if(Adjacent(usr) && !issilicon(usr))
				usr.put_in_hands(beaker)
			beaker = null
			reagents.clear_reagents()
			update_icon()
			return TRUE
		if("create_condi_bottle")
			if(!condi || !reagents.total_volume)
				return
			var/obj/item/reagent_containers/food/condiment/P = new(loc)
			reagents.trans_to_obj(P, 50)
			return TRUE
		if("analyze")
			var/idx = text2num(params["idx"]) || 0
			var/from_beaker = text2num(params["beaker"]) || FALSE
			var/reagent_list = from_beaker ? beaker.reagents.reagent_list : reagents.reagent_list
			if(idx < 1 || idx > length(reagent_list))
				return

			var/datum/reagent/R = reagent_list[idx]
			var/output ="Reagent Name: [R.name]\n\
						Reagent Desc: [R.description]"
			if(!condi && istype(R, /datum/reagent/blood))
				var/datum/reagent/blood/B = R
				output += "\nBlood Type: [B.data["blood_type"]]\
							\nBlood DNA: [B.data["blood_DNA"]]"
			tgui_alert(usr, output, src, list("Ok"))
		if("addcustom")
			if(!beaker || !beaker.reagents.total_volume)
				return
			var/idx = text2num(params["idx"]) || 0
			var/reagent_list = params["beaker"] ? beaker.reagents.reagent_list : reagents.reagent_list
			if(idx < 1 || idx > length(reagent_list))
				return
			var/datum/reagent/R = reagent_list[idx]
			if(!R)
				return
			var/amount = tgui_input_number(usr, "Please enter the amount to transfer to buffer:", src, 0, R.volume, 0)
			if(!amount)
				return
			beaker.reagents.trans_type_to(src, R.type, amount)
			return TRUE
		if("removecustom")
			if(!reagents.total_volume)
				return
			var/idx = text2num(params["idx"]) || 0
			var/reagent_list = params["beaker"] ? beaker.reagents.reagent_list : reagents.reagent_list
			if(idx < 1 || idx > length(reagent_list))
				return
			var/datum/reagent/R = reagent_list[idx]
			if(!R)
				return
			var/amount = tgui_input_number(usr, "Please enter the amount to transfer to [mode ? "beaker" : "disposal"]:", src, 0, R.volume, 0)
			if(!amount)
				return
			if(mode)
				reagents.trans_type_to(beaker, R.type, amount)
			else
				reagents.remove_reagent(R.type, amount)
			return TRUE
		if("create_condi_pack")
			if(!condi || !reagents.total_volume)
				return
			var/condi_name = tgui_input_text(usr, "Please name your new condiment pack:", src, reagents.get_master_reagent_name(), MAX_CUSTOM_NAME_LEN)
			if(isnull(condi_name))
				return
			if(!condi_name)
				condi_name = reagents.get_master_reagent_name()
			var/obj/item/reagent_containers/pill/P = new(loc)
			P.name = "[condi_name] pack"
			P.desc = "A small condiment pack. The label says it contains [condi_name]."
			P.icon_state = "bouilloncube"//Reskinned monkey cube
			reagents.trans_to_obj(P, 10)
			return TRUE
		if("create_pill")
			if(condi || !reagents.total_volume)
				return
			var/amount_per_pill = CLAMP(reagents.total_volume, 0, MAX_UNITS_PER_PILL)
			var/default_name = "[reagents.get_master_reagent_name()] ([amount_per_pill]u)"
			var/pills_name = tgui_input_text(usr, "Please name your pill:", src, default_name, MAX_CUSTOM_NAME_LEN)
			if(isnull(pills_name))
				return
			if(!pills_name)
				pills_name = default_name

			if(reagents.total_volume <= 0)
				to_chat(usr, "<span class='notice'>Not enough reagents to create these pills!</span>")
				return

			var/obj/item/reagent_containers/pill/P = new(loc)
			P.name = "[pills_name] pill"
			P.pixel_x = rand(-7, 7) // Random position
			P.pixel_y = rand(-7, 7)
			P.icon_state = "pill[pillsprite]"
			if(P.icon_state in list("pill1", "pill2", "pill3", "pill4")) // if using greyscale, take colour from reagent
				P.color = reagents.get_color()
			reagents.trans_to_obj(P, amount_per_pill)
			// Load the pills in the bottle if there's one loaded
			if(istype(loaded_pill_bottle) && length(loaded_pill_bottle.contents) < loaded_pill_bottle.max_storage_space)
				P.forceMove(loaded_pill_bottle)
			return TRUE
		if("create_pill_multiple")
			if(condi || !reagents.total_volume)
				return
			var/pills_amount = tgui_input_number(usr, "Please enter the amount of pills to make (max [MAX_MULTI_AMOUNT] at a time):", src, 5, MAX_MULTI_AMOUNT, 0)
			if(!pills_amount)
				return
			var/amount_per_pill = CLAMP(reagents.total_volume/pills_amount, 0, MAX_UNITS_PER_PILL)
			var/default_name = "[reagents.get_master_reagent_name()] ([amount_per_pill]u)"
			var/pills_name = tgui_input_text(usr, "Please name your pills:", src, default_name, MAX_CUSTOM_NAME_LEN)
			if(isnull(pills_name))
				return
			if(!pills_name)
				pills_name = default_name

			if(reagents.total_volume <= 0)
				to_chat(usr, "<span class='notice'>Not enough reagents to create these pills!</span>")
				return

			for(var/i=1 to pills_amount)
				var/obj/item/reagent_containers/pill/P = new(loc)
				P.name = "[pills_name] pill"
				P.pixel_x = rand(-7, 7) // Random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "pill[pillsprite]"
				if(P.icon_state in list("pill1", "pill2", "pill3", "pill4")) // if using greyscale, take colour from reagent
					P.color = reagents.get_color()
				reagents.trans_to_obj(P, amount_per_pill)
				// Load the pills in the bottle if there's one loaded
				if(istype(loaded_pill_bottle) && length(loaded_pill_bottle.contents) < loaded_pill_bottle.max_storage_space)
					P.forceMove(loaded_pill_bottle)
			return TRUE
		if("create_bottle")
			if(condi || !reagents.total_volume)
				return
			var/amount_per_bottle = CLAMP(reagents.total_volume, 0, MAX_UNITS_PER_PILL)
			var/default_name = "[reagents.get_master_reagent_name()] ([amount_per_bottle]u)"
			var/bottle_name = tgui_input_text(usr, "Please name your bottle ([amount_per_bottle]u in the bottle):", src, default_name, MAX_CUSTOM_NAME_LEN)
			if(isnull(bottle_name))
				return
			if(!bottle_name)
				bottle_name = default_name
			if(reagents.total_volume <= 0)
				to_chat(usr, "<span class='notice'>Not enough reagents to create these bottles!</span>")
				return
			var/obj/item/reagent_containers/glass/bottle/P = new(loc)
			P.name = "[bottle_name] bottle"
			P.pixel_x = rand(-7, 7) // random position
			P.pixel_y = rand(-7, 7)
			P.icon_state = "bottle-[bottlesprite]" || "bottle-1"
			reagents.trans_to_obj(P, amount_per_bottle)
			P.update_icon()
			return TRUE
		if("create_bottle_multiple")
			if(condi || !reagents.total_volume)
				return
			var/bottles_amount = tgui_input_number(usr, "Please enter the amount of bottles to make (max [MAX_MULTI_AMOUNT] at a time):", src, 5, MAX_MULTI_AMOUNT, 0)
			if(!bottles_amount)
				return
			var/amount_per_bottle = CLAMP(reagents.total_volume/bottles_amount, 0, MAX_UNITS_PER_PILL)
			var/default_name = "[reagents.get_master_reagent_name()] ([amount_per_bottle]u)"
			var/bottle_name = tgui_input_text(usr, "Please name your bottles ([amount_per_bottle]u in the bottle):", src, default_name, MAX_CUSTOM_NAME_LEN)
			if(isnull(bottle_name))
				return
			if(!bottle_name)
				bottle_name = default_name
			if(reagents.total_volume <= 0)
				to_chat(usr, "<span class='notice'>Not enough reagents to create these bottles!</span>")
				return

			for(var/i=1 to bottles_amount)
				var/obj/item/reagent_containers/glass/bottle/P = new(loc)
				P.name = "[bottle_name] bottle"
				P.pixel_x = rand(-7, 7) // random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "bottle-[bottlesprite]" || "bottle-1"
				reagents.trans_to_obj(P, amount_per_bottle)
				P.update_icon()
			return TRUE
		if("change_pill_style")
			var/pill_style = round(text2num(params["new_pill_style"]))
			if(pill_style < 1 || pill_style > MAX_PILL_SPRITE)
				return
			pillsprite = pill_style
			return TRUE
		if("change_bottle_style")
			var/bottle_style = round(text2num(params["new_bottle_style"]))
			if(bottle_style < 1 || bottle_style > MAX_BOTTLE_SPRITE)
				return
			bottlesprite = bottle_style
			return TRUE

/obj/machinery/chem_master/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/chem_master/proc/isgoodnumber(num)
	if(isnum(num))
		if(num > 200)
			num = 200
		else if(num < 0)
			num = 1
		return num
	else
		return FALSE

/obj/machinery/chem_master/condimaster
	name = "\improper CondiMaster 3000"
	condi = TRUE

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/obj/machinery/reagentgrinder

	name = "\improper All-In-One Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = BELOW_OBJ_LAYER
	density = 0
	anchored = 0
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	var/inuse = 0
	var/obj/item/reagent_containers/beaker = null
	var/limit = 10
	var/list/holdingitems = list()

/obj/machinery/reagentgrinder/New(var/atom/location, var/direction, var/nocircuit = FALSE)
	..()
	beaker = new /obj/item/reagent_containers/glass/beaker/large(src)

/obj/machinery/reagentgrinder/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))

/obj/machinery/reagentgrinder/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if (istype(O,/obj/item/reagent_containers/glass) || \
		istype(O,/obj/item/reagent_containers/food/drinks/glass2) || \
		istype(O,/obj/item/reagent_containers/food/drinks/shaker))

		if (beaker)
			return 1
		else
			if(!user.unEquip(O, src))
				return
			src.beaker =  O
			update_icon()
			SStgui.update_uis(src)
			return 0

	if(holdingitems && holdingitems.len >= limit)
		to_chat(usr, "The machine cannot hold anymore items.")
		return 1

	if(!istype(O))
		return

	if(istype(O,/obj/item/storage/plants))
		var/obj/item/storage/plants/bag = O
		var/failed = 1
		for(var/obj/item/G in O.contents)
			if(!G.reagents || !G.reagents.total_volume)
				continue
			failed = 0
			bag.remove_from_storage(G, src)
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit)
				break

		if(failed)
			to_chat(user, "Nothing in the plant bag is usable.")
			return 1

		if(!O.contents.len)
			to_chat(user, "You empty \the [O] into \the [src].")
		else
			to_chat(user, "You fill \the [src] from \the [O].")

		SStgui.update_uis(src)
		return 0

	if(istype(O,/obj/item/stack/material))
		var/obj/item/stack/material/stack = O
		var/material/material = stack.material
		if(!material.chem_products.len)
			to_chat(user, "\The [material.name] is unable to produce any usable reagents.")
			return 1

	else if(!O.reagents || !O.reagents.total_volume)
		to_chat(user, "\The [O] is not suitable for blending.")
		return 1

	if(!user.unEquip(O, src))
		return
	holdingitems += O
	SStgui.update_uis(src)
	return 0

/obj/machinery/reagentgrinder/attack_ai(mob/user as mob)
	attack_hand(user)

/obj/machinery/reagentgrinder/attack_hand(mob/user as mob)
	if(inoperable())
		return
	tgui_interact(user)

/obj/machinery/reagentgrinder/tgui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Grinder", name)
		ui.open()

/obj/machinery/reagentgrinder/ui_data(mob/user)
	var/list/data = list()
	var/list/processing = list()
	for(var/obj/item/O in holdingitems)
		processing += capitalize(O.name)
	if(processing.len)
		data["processing"] = processing
	else
		data["processing"] = FALSE
	data["inuse"] = inuse
	data["isBeakerLoaded"] = beaker ? 1 : 0

	if(!beaker)
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null
	else
		data["beakerCurrentVolume"] = beaker.reagents.total_volume
		data["beakerMaxVolume"] = beaker.reagents.maximum_volume

	var/list/beakerContents = list()
	if(length(beaker?.reagents?.reagent_list))
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume, "id" = R.type)))
	data["beakerContents"] = beakerContents

	return data

/obj/machinery/reagentgrinder/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if ("grind")
			grind(usr)
		if("eject")
			eject()
		if ("detach")
			detach()
	SStgui.update_uis(src)

/obj/machinery/reagentgrinder/proc/detach()
	if (!beaker)
		return
	beaker.dropInto(loc)
	if(Adjacent(usr) && !issilicon(usr))
		usr.put_in_hands(beaker)
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/proc/eject()
	if (!holdingitems || holdingitems.len == 0)
		return

	for(var/obj/item/O in holdingitems)
		O.forceMove(src.loc)
		holdingitems -= O
		if(Adjacent(usr) && !issilicon(usr))
			usr.put_in_hands(O)
	holdingitems.Cut()


/obj/machinery/reagentgrinder/meddle()
	grind()

/obj/machinery/reagentgrinder/proc/grind(mob/user)

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return

	// Sanity check.
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return

	hurt_hand(user)
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	inuse = 1

	// Reset the machine.
	spawn(60)
		inuse = 0
		interact(user)

	var/skill_factor = CLAMP01(1 + 0.3*((user ? user.get_skill_value(SKILL_MEDICAL) - SKILL_EXPERT : 1))/(SKILL_EXPERT - SKILL_MIN))
	// Process.
	for (var/obj/item/O in holdingitems)

		var/remaining_volume = beaker.reagents.maximum_volume - beaker.reagents.total_volume
		if(remaining_volume <= 0)
			break

		var/obj/item/stack/material/stack = O
		if(istype(stack))
			var/material/material = stack.material
			if(!material.chem_products.len)
				break

			var/list/chem_products = material.chem_products
			var/sheet_volume = 0
			for(var/chem in chem_products)
				sheet_volume += chem_products[chem]

			var/amount_to_take = max(0,min(stack.amount,round(remaining_volume/sheet_volume)))
			if(amount_to_take)
				stack.use(amount_to_take)
				if(QDELETED(stack))
					holdingitems -= stack
				for(var/chem in chem_products)
					beaker.reagents.add_reagent(chem, (amount_to_take*chem_products[chem]*skill_factor))
				continue

		if(O.reagents)
			O.reagents.trans_to(beaker, O.reagents.total_volume, skill_factor)
			if(O.reagents.total_volume == 0)
				holdingitems -= O
				qdel(O)
			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

/obj/machinery/reagentgrinder/proc/hurt_hand(mob/living/carbon/human/user)
	if (!user)
		return
	var/skill_to_check = SKILL_MEDICAL
	if(user.get_skill_value(SKILL_COOKING) > user.get_skill_value(SKILL_MEDICAL))
		skill_to_check = SKILL_COOKING
	if(!istype(user) || !prob(user.skill_fail_chance(skill_to_check, 50, SKILL_BASIC)))
		return
	var/hand = pick(BP_L_HAND, BP_R_HAND)
	var/obj/item/organ/external/hand_organ = user.get_organ(hand)
	if(!hand_organ)
		return

	var/dam = rand(10, 15)
	user.visible_message("<span class='danger'>\The [user]'s hand gets caught in \the [src]!</span>", "<span class='danger'>Your hand gets caught in \the [src]!</span>")
	user.apply_damage(dam, BRUTE, hand, damage_flags = DAM_SHARP, used_weapon = "grinder")
	if(BP_IS_ROBOTIC(hand_organ))
		beaker.reagents.add_reagent(/datum/reagent/iron, dam)
	else
		user.take_blood(beaker, dam)
	user.Stun(2)
	INVOKE_ASYNC(src, .proc/shake, user, 40)

/obj/machinery/reagentgrinder/proc/shake(mob/user, duration)
	for(var/i = 1, i<=duration, i++)
		sleep(1)
		if(!user || !Adjacent(user))
			break
		if(user.is_jittery)
			continue
		user.do_jitter(4)

	if(user && !user.is_jittery)
		user.do_jitter(0) //resets the icon.
