/obj/item/disk/botany
	name = "flora data disk"
	desc = "A small disk used for carrying data on plant genetics."
	icon = 'icons/obj/hydroponics_machines.dmi'
	icon_state = "disk"
	w_class = ITEM_SIZE_TINY

	var/list/genes = list()
	var/genesource = "unknown"

/obj/item/disk/botany/attack_self(var/mob/user as mob)
	if(genes.len)
		var/choice = tgui_alert(user, "Are you sure you want to wipe the disk?", "Xenobotany Data", list("No", "Yes"))
		if(src && user && genes && choice && choice == "Yes" && user.Adjacent(get_turf(src)))
			to_chat(user, "You wipe the disk data.")
			SetName(initial(name))
			desc = initial(name)
			genes = list()
			genesource = "unknown"

/obj/item/storage/box/botanydisk
	name = "flora disk box"
	desc = "A box of flora data disks, apparently."
	startswith = list(/obj/item/disk/botany = 14)

/obj/machinery/botany
	icon = 'icons/obj/hydroponics_machines.dmi'
	icon_state = "hydrotray3"
	density = 1
	anchored = 1
	use_power = 1

	var/obj/item/seeds/seed // Currently loaded seed packet.
	var/obj/item/disk/botany/loaded_disk //Currently loaded data disk.

	var/open = 0
	var/active = 0
	var/action_time = 5
	var/last_action = 0
	var/eject_disk = 0
	var/failed_task = 0
	var/disk_needs_genes = 0



/obj/machinery/botany/can_harvest_biomass()
	return MASS_READY

/obj/machinery/botany/harvest_biomass()
	return BIOMASS_HARVEST_MEDIUM


/obj/machinery/botany/Process()

	..()
	if(!active) return

	if(world.time > last_action + action_time)
		finished_task()

/obj/machinery/botany/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/botany/attack_hand(mob/user as mob)
	ui_interact(user)

/obj/machinery/botany/proc/finished_task()
	active = 0
	if(failed_task)
		failed_task = 0
		visible_message("\icon[src] [src] pings unhappily, flashing a red warning light.")
	else
		visible_message("\icon[src] [src] pings happily.")

	if(eject_disk)
		eject_disk = 0
		if(loaded_disk)
			loaded_disk.forceMove(get_turf(src))
			visible_message("\icon[src] [src] beeps and spits out [loaded_disk].")
			loaded_disk = null

/obj/machinery/botany/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/seeds))
		if(seed)
			to_chat(user, "There is already a seed loaded.")
			return
		var/obj/item/seeds/S =W
		if(S.seed && S.seed.get_trait(TRAIT_IMMUTABLE) > 0)
			to_chat(user, "That seed is not compatible with our genetics technology.")
		else if(user.unEquip(W, src))
			seed = W
			to_chat(user, "You load [W] into [src].")
		return

	if(default_deconstruction_screwdriver(user, W))
		return

	if(default_deconstruction_crowbar(user, W))
		return

	if(default_part_replacement(user, W))
		return

	if(istype(W,/obj/item/disk/botany))
		if(loaded_disk)
			to_chat(user, "There is already a data disk loaded.")
			return
		else
			var/obj/item/disk/botany/B = W

			if(B.genes && B.genes.len)
				if(!disk_needs_genes)
					to_chat(user, "That disk already has gene data loaded.")
					return
			else
				if(disk_needs_genes)
					to_chat(user, "That disk does not have any gene data loaded.")
					return
			if(!user.unEquip(W, src))
				return
			loaded_disk = W
			to_chat(user, "You load [W] into [src].")

		return
	..()

// Allows for a trait to be extracted from a seed packet, destroying that seed.
/obj/machinery/botany/extractor
	name = "lysis-isolation centrifuge"
	icon_state = "traitcopier"
	clicksound = "button2"
	circuit = /obj/item/circuitboard/extractor

	var/datum/seed/genetics // Currently scanned seed genetic structure.
	var/degradation = 0     // Increments with each scan, stops allowing gene mods after a certain point.

/obj/machinery/botany/extractor/dismantle()
	for(var/atom/movable/A in contents)
		A.forceMove(loc)
	..()

/obj/machinery/botany/extractor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	if(!user)
		return

	var/list/data = list()

	var/list/geneMasks = plant_controller.gene_masked_list
	data["geneMasks"] = geneMasks

	data["activity"] = active
	data["degradation"] = degradation

	if(loaded_disk)
		data["disk"] = 1
	else
		data["disk"] = 0

	if(seed)
		data["loaded"] = "[seed.name]"
	else
		data["loaded"] = 0

	if(genetics)
		data["hasGenetics"] = 1
		data["sourceName"] = genetics.display_name
		if(!genetics.roundstart)
			data["sourceName"] += " (variety #[genetics.uid])"
	else
		data["hasGenetics"] = 0
		data["sourceName"] = 0

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "botany_isolator.tmpl", "Lysis-isolation Centrifuge UI", 470, 450)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/botany/Topic(href, href_list)

	if(..())
		return 1

	if(href_list["eject_packet"])
		if(!seed) return
		seed.forceMove(get_turf(src))

		if(seed.seed.name == "new line" || isnull(plant_controller.seeds[seed.seed.name]))
			seed.seed.uid = plant_controller.seeds.len + 1
			seed.seed.name = "[seed.seed.uid]"
			plant_controller.seeds[seed.seed.name] = seed.seed

		seed.update_seed()
		visible_message("\icon[src] [src] beeps and spits out [seed].")

		seed = null

	if(href_list["eject_disk"])
		if(!loaded_disk) return
		loaded_disk.forceMove(get_turf(src))
		visible_message("\icon[src] [src] beeps and spits out [loaded_disk].")
		loaded_disk = null

	usr.set_machine(src)
	src.add_fingerprint(usr)

/obj/machinery/botany/extractor/Topic(href, href_list)

	if(..())
		return 1

	var/mob/user = usr
	user.set_machine(src)
	src.add_fingerprint(user)

	if(href_list["scan_genome"])

		if(!seed) return

		last_action = world.time
		active = 1

		if(seed && seed.seed)
			if(prob(user.skill_fail_chance(SKILL_BOTANY, 100, SKILL_ADEPT)))
				failed_task = 1
			else
				genetics = seed.seed
				degradation = 0

		qdel(seed)
		seed = null

	if(href_list["get_gene"])

		if(!genetics || !loaded_disk) return

		last_action = world.time
		active = 1

		var/datum/plantgene/P = genetics.get_gene(href_list["get_gene"])
		if(!P) return
		loaded_disk.genes += P

		loaded_disk.genesource = "[genetics.display_name]"
		if(!genetics.roundstart)
			loaded_disk.genesource += " (variety #[genetics.uid])"

		loaded_disk.name += " ([plant_controller.gene_tag_masks[href_list["get_gene"]]], #[genetics.uid])"
		loaded_disk.desc += " The label reads \'gene [plant_controller.gene_tag_masks[href_list["get_gene"]]], sampled from [genetics.display_name]\'."
		eject_disk = 1

		degradation += rand(20,60) + user.skill_fail_chance(SKILL_BOTANY, 100, SKILL_ADEPT)
		var/expertise = max(0, user.get_skill_value(SKILL_BOTANY) - SKILL_ADEPT)
		degradation = max(0, degradation - 10*expertise)

		if(degradation >= 100)
			failed_task = 1
			genetics = null
			degradation = 0

	if(href_list["clear_buffer"])
		if(!genetics) return
		genetics = null
		degradation = 0

	src.updateUsrDialog()
	return

// Fires an extracted trait into another packet of seeds with a chance
// of destroying it based on the size/complexity of the plasmid.
/obj/machinery/botany/editor
	name = "bioballistic delivery system"
	icon_state = "traitgun"
	disk_needs_genes = 1
	clicksound = "button2"
	circuit = /obj/item/circuitboard/editor

/obj/machinery/botany/editor/dismantle()
	for(var/atom/movable/A in contents)
		A.forceMove(loc)
	..()

/obj/machinery/botany/editor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	if(!user)
		return

	var/list/data = list()

	data["activity"] = active

	if(seed)
		data["degradation"] = seed.modified
	else
		data["degradation"] = 0

	if(loaded_disk && loaded_disk.genes.len)
		data["disk"] = 1
		data["sourceName"] = loaded_disk.genesource
		data["locus"] = ""

		for(var/datum/plantgene/P in loaded_disk.genes)
			if(data["locus"] != "") data["locus"] += ", "
			data["locus"] += "[plant_controller.gene_tag_masks[P.genetype]]"

	else
		data["disk"] = 0
		data["sourceName"] = 0
		data["locus"] = 0

	if(seed)
		data["loaded"] = "[seed.name]"
	else
		data["loaded"] = 0

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "botany_editor.tmpl", "Bioballistic Delivery UI", 470, 450)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/botany/editor/Topic(href, href_list)

	if(..())
		return 1

	if(href_list["apply_gene"])
		if(!loaded_disk || !seed) return

		var/mob/user = usr
		last_action = world.time
		active = 1

		if(!isnull(plant_controller.seeds[seed.seed.name]))
			seed.seed = seed.seed.diverge(1)
			seed.seed_type = seed.seed.name
			seed.update_seed()

		if(prob(seed.modified))
			failed_task = 1
			seed.modified = 101

		for(var/datum/plantgene/gene in loaded_disk.genes)
			seed.seed.apply_gene(gene)
			var/expertise = max(user.get_skill_value(SKILL_ANATOMY) - SKILL_ADEPT)
			seed.modified += rand(5,10) + min(-5, 30 * expertise)

	usr.set_machine(src)
	src.add_fingerprint(usr)
