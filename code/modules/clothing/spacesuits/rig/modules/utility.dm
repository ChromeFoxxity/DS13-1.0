/* Contains:
 * /obj/item/rig_module/device
 * /obj/item/rig_module/device/healthscanner
 * /obj/item/rig_module/device/drill
 * /obj/item/rig_module/device/orescanner
 * /obj/item/rig_module/device/rcd
 * /obj/item/rig_module/device/anomaly_scanner
 * /obj/item/rig_module/maneuvering_jets
 * /obj/item/rig_module/chem_dispenser
 * /obj/item/rig_module/chem_dispenser/combat
 * /obj/item/rig_module/chem_dispenser/inaprovaline
 * /obj/item/rig_module/chem_dispenser/injector
 * /obj/item/rig_module/voice
 * /obj/item/rig_module/device/paperdispenser
 * /obj/item/rig_module/device/pen
 * /obj/item/rig_module/device/stamp
 * /obj/item/rig_module/hotswap
 */

/obj/item/rig_module/device
	name = "mounted device"
	desc = "Some kind of RIG mount."
	usable = 0
	selectable = 1
	toggleable = 0
	disruptive = 0

	var/device_type
	var/obj/item/device

/obj/item/rig_module/device/Destroy()
	QDEL_NULL(device)
	.=..()

/obj/item/rig_module/device/healthscanner
	name = "health scanner module"
	desc = "A RIG-mounted health scanner."
	icon_state = "scanner"
	interface_name = "health scanner"
	interface_desc = "Shows an informative health readout when used on a subject."
	use_power_cost = 200
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 3, TECH_ENGINEERING = 5)
	device_type = /obj/item/healthanalyzer

/obj/item/rig_module/device/drill
	name = "RIG drill mount"
	desc = "A very heavy diamond-tipped drill."
	icon_state = "drill"
	interface_name = "mounted drill"
	interface_desc = "A diamond-tipped industrial drill."
	suit_overlay_active = "mounted-drill"
	suit_overlay_inactive = "mounted-drill"
	use_power_cost = 75
	origin_tech = list(TECH_MATERIAL = 6, TECH_POWER = 4, TECH_ENGINEERING = 6)
	device_type = /obj/item/tool/pickaxe/diamonddrill

/obj/item/rig_module/device/anomaly_scanner
	name = "RIG anomaly scanner"
	desc = "You think it's called an Elder Sarsparilla or something."
	icon_state = "eldersasparilla"
	interface_name = "Alden-Saraspova counter"
	interface_desc = "An exotic particle detector commonly used by xenoarchaeologists."
	engage_string = "Begin Scan"
	use_power_cost = 200
	usable = 1
	selectable = 0
	device_type = /obj/item/ano_scanner
	origin_tech = list(TECH_BLUESPACE = 4, TECH_MAGNET = 4, TECH_ENGINEERING = 6)

/obj/item/rig_module/device/orescanner
	name = "ore scanner module"
	desc = "A clunky old ore scanner."
	icon_state = "scanner"
	interface_name = "ore detector"
	interface_desc = "A sonar system for detecting large masses of ore."
	engage_string = "Begin Scan"
	usable = 1
	selectable = 0
	use_power_cost = 200
	device_type = /obj/item/mining_scanner
	origin_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 4, TECH_ENGINEERING = 6)

/obj/item/rig_module/device/rcd
	name = "RCD mount"
	desc = "A cell-powered rapid construction device for a RIG."
	icon_state = "rcd"
	interface_name = "mounted RCD"
	interface_desc = "A device for building or removing walls. Cell-powered."
	usable = 1
	engage_string = "Configure RCD"
	use_power_cost = 300
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 5, TECH_ENGINEERING = 7)
	device_type = /obj/item/rcd/mounted

/obj/item/rig_module/device/Initialize()
	. = ..()
	if(device_type) device = new device_type(src)

/obj/item/rig_module/device/engage(atom/target)
	if(!..() || !device)
		return 0

	if(!target)
		device.attack_self(holder.wearer)
		return 1

	var/turf/T = get_turf(target)
	if(istype(T) && !T.Adjacent(get_turf(src)))
		return 0

	var/resolved = target.attackby(device,holder.wearer)
	if(!resolved && device && target)
		device.afterattack(target,holder.wearer,1)
	return 1


/obj/item/rig_module/chem_dispenser
	name = "mounted chemical dispenser"
	desc = "A complex web of tubing and needles suitable for RIG use."
	icon_state = "injector"
	usable = 1
	selectable = 0
	toggleable = 0
	disruptive = 0
	use_power_cost = 5000

	engage_string = "Inject"

	interface_name = "integrated chemical dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the wearer's bloodstream."

	charges = list(
		list("inaprovaline",  "inaprovaline",  /datum/reagent/inaprovaline,      80),
		list("dylovene",      "dylovene",      /datum/reagent/dylovene,          40),
		list("bicaridine",    "bicaridine",    /datum/reagent/bicaridine,        80),
		list("kelotane",      "kelotane",      /datum/reagent/kelotane,          40),
		list("tramadol",      "tramadol",      /datum/reagent/tramadol,          40),
		list("dexalin plus",  "dexalin plus",  /datum/reagent/dexalinp,          40),
		list("antibiotics",   "antibiotics",   /datum/reagent/spaceacillin,      40),
		list("iron",          "iron",          /datum/reagent/iron,              40)
		)

	var/max_reagent_volume = 80 //Used when refilling.

/obj/item/rig_module/chem_dispenser/ninja
	interface_desc = "Dispenses loaded chemicals directly into the wearer's bloodstream. This variant is made to be extremely light and flexible."

	//just over a syringe worth of each. Want more? Go refill. Gives the ninja another reason to have to show their face.
	charges = list(
		list("inaprovaline",  "inaprovaline",  /datum/reagent/inaprovaline,      20),
		list("dylovene",      "dylovene",      /datum/reagent/dylovene,          20),
		list("bicaridine",    "bicaridine",    /datum/reagent/bicaridine,        20),
		list("kelotane",      "kelotane",      /datum/reagent/kelotane,          20),
		list("tramadol",      "tramadol",      /datum/reagent/tramadol,          20),
		list("dexalin plus",  "dexalin plus",  /datum/reagent/dexalinp,          20),
		list("antibiotics",   "antibiotics",   /datum/reagent/spaceacillin,      20),
		list("iron",          "iron",          /datum/reagent/iron,              20)
		)

/obj/item/rig_module/chem_dispenser/accepts_item(var/obj/item/input_item, var/mob/living/user)

	if(!input_item.is_open_container())
		return 0

	if(!input_item.reagents || !input_item.reagents.total_volume)
		to_chat(user, "\The [input_item] is empty.")
		return 0

	// Magical chemical filtration system, do not question it.
	var/total_transferred = 0
	for(var/datum/reagent/R in input_item.reagents.reagent_list)
		for(var/chargetype in charges)
			var/datum/rig_charge/charge = charges[chargetype]
			if(charge.product_type == R.type)

				var/chems_to_transfer = R.volume

				if((charge.charges + chems_to_transfer) > max_reagent_volume)
					chems_to_transfer = max_reagent_volume - charge.charges

				charge.charges += chems_to_transfer
				input_item.reagents.remove_reagent(R.type, chems_to_transfer)
				total_transferred += chems_to_transfer

				break

	if(total_transferred)
		to_chat(user, "<font color='blue'>You transfer [total_transferred] units into the suit reservoir.</font>")
	else
		to_chat(user, "<span class='danger'>None of the reagents seem suitable.</span>")
	return 1

/obj/item/rig_module/chem_dispenser/engage(atom/target)

	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	if(!charge_selected)
		to_chat(H, "<span class='danger'>You have not selected a chemical type.</span>")
		return 0

	var/datum/rig_charge/charge = charges[charge_selected]

	if(!charge)
		return 0

	var/chems_to_use = 10
	if(charge.charges <= 0)
		to_chat(H, "<span class='danger'>Insufficient chems!</span>")
		return 0
	else if(charge.charges < chems_to_use)
		chems_to_use = charge.charges

	var/mob/living/carbon/target_mob
	if(target)
		if(istype(target,/mob/living/carbon))
			target_mob = target
		else
			return 0
	else
		target_mob = H

	if(target_mob != H)
		to_chat(H, "<span class='danger'>You inject [target_mob] with [chems_to_use] unit\s of [charge.display_name].</span>")
	to_chat(target_mob, "<span class='danger'>You feel a rushing in your veins as [chems_to_use] unit\s of [charge.display_name] [chems_to_use == 1 ? "is" : "are"] injected.</span>")
	target_mob.reagents.add_reagent(charge.product_type, chems_to_use)

	charge.charges -= chems_to_use
	if(charge.charges < 0) charge.charges = 0

	return 1

/obj/item/rig_module/chem_dispenser/combat

	name = "combat chemical injector"
	desc = "A complex web of tubing and needles suitable for RIG use."

	charges = list(
		list("bicaridine",   "bicaridine",   /datum/reagent/bicaridine,            80),
		list("dermaline",    "dermaline",    /datum/reagent/dermaline,             80),
		list("dexalinp",     "dexalinp",     /datum/reagent/dexalinp,              40),
		list("oxycodone",    "oxycodone",    /datum/reagent/tramadol/oxycodone,    80),
		list("nanoblood",    "nanoblood",    /datum/reagent/nanoblood,             40),
		list("synaptizine",  "synaptizine",  /datum/reagent/synaptizine,           20),
		list("medgel",       "medgel",       /datum/reagent/ds_medicalgelreagent,  10),
		)

	interface_name = "combat chem dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the bloodstream."


/obj/item/rig_module/chem_dispenser/inaprovaline

	name = "inaprovaline chemical dispensor"
	desc = "A complex web of tubing and needles suitable for RIG use."

	charges = list(
		list("inaprovaline",   "inaprovaline",   /datum/reagent/inaprovaline,    1000),
		)

	interface_name = "inaprovaline chem dispenser"
	interface_desc = "Dispenses inaprovaline directly into the bloodstream."


/obj/item/rig_module/chem_dispenser/injector

	name = "mounted chemical injector"
	desc = "A complex web of tubing and a large needle suitable for RIG use."
	usable = 0
	selectable = 1
	disruptive = 1
	use_power_cost = 10000//looks like a lot but only reduces the RIG power by 7 or so on each use

	charges = list(
		list("inaprovaline",  "inaprovaline",  /datum/reagent/inaprovaline,      160),
		list("dylovene",      "dylovene",      /datum/reagent/dylovene,          40),
		list("bicaridine",    "bicaridine",    /datum/reagent/bicaridine,        40),
		list("kelotane",      "kelotane",      /datum/reagent/kelotane,          20),
		list("tramadol",      "tramadol",      /datum/reagent/tramadol,          20),
		list("dexalin plus",  "dexalin plus",  /datum/reagent/dexalinp,          20),
		list("antibiotics",   "antibiotics",   /datum/reagent/spaceacillin,      20),
		list("iron",          "iron",          /datum/reagent/iron,              20)
		)

	interface_name = "mounted chem injector"
	interface_desc = "Dispenses loaded chemicals via an arm-mounted injector."

/obj/item/rig_module/chem_dispenser/injector/inap
	name = "mounted inaprovaline injector"
	use_power_cost = 1000
	charges = list(
		list("inaprovaline",  "inaprovaline",  /datum/reagent/inaprovaline,   2000),
		)
	interface_name = "mounted inap injector"

/obj/item/rig_module/voice

	name = "RIG voice synthesiser"
	desc = "A speaker box and sound processor."
	icon_state = "megaphone"
	usable = 1
	selectable = 0
	toggleable = 0
	disruptive = 0
	active_power_cost = 100

	engage_string = "Configure Synthesiser"

	interface_name = "voice synthesiser"
	interface_desc = "A flexible and powerful voice modulator system."

	var/obj/item/voice_changer/voice_holder

/obj/item/rig_module/voice/Initialize()
	. = ..()
	voice_holder = new(src)
	voice_holder.active = 0

/obj/item/rig_module/voice/Destroy()
	QDEL_NULL(voice_holder)
	.=..()

/obj/item/rig_module/voice/installed()
	..()
	holder.speech = src

/obj/item/rig_module/voice/uninstalled(obj/item/rig/former)
	..()
	former.speech = null

/obj/item/rig_module/voice/engage()

	if(!..())
		return

	var/choice= input("Would you like to toggle the synthesiser or set the name?") as null|anything in list("Enable","Disable","Set Name")

	if(!choice)
		return 0

	switch(choice)
		if("Enable")
			active = 1
			voice_holder.active = 1
			to_chat(usr, "<font color='blue'>You enable the speech synthesiser.</font>")
		if("Disable")
			active = 0
			voice_holder.active = 0
			to_chat(usr, "<font color='blue'>You disable the speech synthesiser.</font>")
		if("Set Name")
			var/raw_choice = sanitize(input(usr, "Please enter a new name.")  as text|null, MAX_NAME_LEN)
			if(!raw_choice)
				return 0
			voice_holder.voice = raw_choice
			to_chat(usr, "<font color='blue'>You are now mimicking <B>[voice_holder.voice]</B>.</font>")
	return 1

/obj/item/rig_module/maneuvering_jets

	name = "RIG maneuvering jets"
	desc = "A compact gas thruster system for a RIG. Allows Zero G manoeuvring."
	icon_state = "thrusters"
	usable = 1
	toggleable = 1
	selectable = 0
	disruptive = 0
	active_power_cost = 50

	suit_overlay_active = "maneuvering_active"
	suit_overlay_inactive = null //"maneuvering_inactive"

	engage_string = "Toggle Stabilizers"
	activate_string = "Activate Thrusters"
	deactivate_string = "Deactivate Thrusters"

	interface_name = "maneuvering jets"
	interface_desc = "An inbuilt EVA maneuvering system that runs off the rig air supply."
	origin_tech = list(TECH_MATERIAL = 6,  TECH_ENGINEERING = 7)
	var/obj/item/tank/jetpack/rig/jets

/obj/item/rig_module/maneuvering_jets/Destroy()
	QDEL_NULL(jets)
	.=..()

/obj/item/rig_module/maneuvering_jets/engage()
	if(!..())
		return
	jets.toggle_rockets()
	return 1

/obj/item/rig_module/maneuvering_jets/activate()
	if(!..())
		return

	if(active)
		return 0

	active = 1

	spawn(1)
		if(suit_overlay_active)
			suit_overlay = suit_overlay_active
		else
			suit_overlay = null
		holder.update_icon()

	if(!jets.on)
		jets.toggle()
	return 1

/obj/item/rig_module/maneuvering_jets/deactivate()
	if(!..())
		return 0
	if(jets.on)
		jets.toggle()
	return 1

/obj/item/rig_module/maneuvering_jets/Initialize()
	. = ..()
	jets = new(src)

/obj/item/rig_module/maneuvering_jets/installed()
	..()
	jets.holder = holder
	jets.ion_trail.set_up(holder)

/obj/item/rig_module/maneuvering_jets/uninstalled(var/obj/item/rig/former, var/mob/living/user)
	..()
	jets.holder = null
	jets.ion_trail.set_up(jets)

/obj/item/rig_module/device/paperdispenser
	name = "RIG paper dispenser"
	desc = "Crisp sheets."
	icon_state = "paper"
	interface_name = "paper dispenser"
	interface_desc = "Dispenses warm, clean, and crisp sheets of paper."
	engage_string = "Dispense"
	use_power_cost = 200
	usable = 1
	selectable = 0
	device_type = /obj/item/paper_bin

/obj/item/rig_module/device/paperdispenser/engage(atom/target)

	if(!..() || !device)
		return 0

	if(!target)
		device.attack_hand(holder.wearer)
		return 1

/obj/item/rig_module/device/pen
	name = "mounted pen"
	desc = "For mecha John Hancocks."
	icon_state = "pen"
	interface_name = "mounted pen"
	interface_desc = "Signatures with style(tm)."
	engage_string = "Change color"
	usable = 1
	device_type = /obj/item/pen/multi
	process_with_rig = FALSE

/obj/item/rig_module/device/stamp
	name = "mounted internal affairs stamp"
	desc = "DENIED."
	icon_state = "stamp"
	interface_name = "mounted stamp"
	interface_desc = "Leave your mark."
	engage_string = "Toggle stamp type"
	usable = 1
	var/iastamp
	var/deniedstamp
	process_with_rig = FALSE

/obj/item/rig_module/device/stamp/Initialize()
	. = ..()
	iastamp = new /obj/item/stamp/internalaffairs(src)
	deniedstamp = new /obj/item/stamp/denied(src)
	device = iastamp

/obj/item/rig_module/device/stamp/engage(atom/target)
	if(!..() || !device)
		return 0

	if(!target)
		if(device == iastamp)
			device = deniedstamp
			to_chat(holder.wearer, "<span class='notice'>Switched to denied stamp.</span>")
		else if(device == deniedstamp)
			device = iastamp
			to_chat(holder.wearer, "<span class='notice'>Switched to internal affairs stamp.</span>")
		return 1

/obj/item/rig_module/device/decompiler
	name = "mounted matter decompiler"
	desc = "A drone matter decompiler reconfigured for RIG use."
	icon_state = "ewar"
	interface_name = "mounted matter decompiler"
	interface_desc = "Eats trash like no one's business."
	origin_tech = list(TECH_MATERIAL = 5, TECH_ENGINEERING = 5)
	device_type = /obj/item/matter_decompiler
	process_with_rig = FALSE

/obj/item/rig_module/cooling_unit
	name = "mounted cooling unit"
	toggleable = 1
	origin_tech = list(TECH_MAGNET = 2, TECH_MATERIAL = 2, TECH_ENGINEERING = 5)
	interface_name = "mounted cooling unit"
	interface_desc = "A heat sink with a liquid cooled radiator and an integrated kinetic battery. Uses kinetic motion to store energy to power the RIG for long term use. Activate to generate power and maintain a cool core temperature."
	module_cooldown = 0 SECONDS //no cd because its critical for a life-support module
	var/max_cooling = 12
	var/thermostat = T20C

/obj/item/rig_module/cooling_unit/Process()
	if(!active)
		return passive_power_cost

	var/mob/living/carbon/human/H = holder.wearer

	var/temp_adj = min(H.bodytemperature - thermostat, max_cooling) //Actually copies the original CU code

	if (temp_adj < 0.5)
		return passive_power_cost

	H.bodytemperature -= temp_adj
	active_power_cost = 100
	return active_power_cost


/obj/item/rig_module/hotswap
	name = "hotswap module"
	desc = "Allows the RIG frame to be modified while it is worn and active"
	loadout_tags = list(LOADOUT_TAG_RIG_HOTSWAP)

/obj/item/rig_module/hotswap/installed()
	.=..()
	holder.hotswap = TRUE

/obj/item/rig_module/hotswap/uninstalled(var/obj/item/rig/former, var/mob/living/user)
	former.hotswap = FALSE
	.=..()