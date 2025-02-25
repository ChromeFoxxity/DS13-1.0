/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!check_rights(R_DEBUG))	return

	if(Debug2)
		Debug2 = 0
		message_admins("[key_name(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		Debug2 = 1
		message_admins("[key_name(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")

	feedback_add_details("admin_verb","DG2") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

// callproc moved to code/modules/admin/callproc


/client/proc/reload_configuration()
	set category = "Debug"
	set name = "Reload Configuration"
	set desc = "Force config reload to world default"
	if(!check_rights(R_DEBUG))
		return
	if(tgui_alert(usr, "Are you absolutely sure you want to reload the configuration from the default path on the disk, wiping any in-round modificatoins?", "Really reset?", list("No", "Yes")) == "Yes")
		config.admin_reload()

/client/proc/Cell()
	set category = "Debug"
	set name = "Cell"
	if(!mob)
		return
	var/turf/T = mob.loc

	if (!( istype(T, /turf) ))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = "<span class='notice'>Coordinates: [T.x],[T.y],[T.z]</span>\n"
	t += "<span class='warning'>Temperature: [env.temperature]</span>\n"
	t += "<span class='warning'>Pressure: [env.return_pressure()]kPa</span>\n"
	for(var/g in env.gas)
		t += "<span class='notice'>[g]: [env.gas[g]] / [env.gas[g] * R_IDEAL_GAS_EQUATION * env.temperature / env.volume]kPa</span>\n"

	usr.show_message(t, 1)
	feedback_add_details("admin_verb","ASL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(var/mob/M in SSmobs.mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(!SSticker)
		tgui_alert(src, "Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		tgui_alert(src, "Invalid mob")

/client/proc/cmd_admin_animalize(var/mob/M in SSmobs.mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(!SSticker)
		alert("Wait until the game starts")
		return

	if(!M)
		tgui_alert(src, "That mob doesn't seem to exist, close the panel and try again.")
		return

	if(istype(M, /mob/dead/new_player))
		tgui_alert(src, "The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(10)
		M.Animalize()


/client/proc/makepAI(var/turf/T in SSmobs.mob_list)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	var/list/available = list()
	for(var/mob/C in SSmobs.mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = input("Choose a player to play the pAI", "Spawn pAI") in available
	if(!choice)
		return 0
	if(!isghost(choice))
		var/confirm = input("[choice.key] isn't ghosting right now. Are you sure you want to yank them out of them out of their body and place them in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return 0
	var/obj/item/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)
	pai.SetName(sanitizeSafe(input(choice, "Enter your pAI name:", "pAI Name", "Personal AI") as text))
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/paiCandidate/candidate in paiController.pai_candidates)
		if(candidate.key == choice.key)
			paiController.pai_candidates.Remove(candidate)
	feedback_add_details("admin_verb","MPAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_slimeize(var/mob/M in SSmobs.mob_list)
	set category = "Fun"
	set name = "Make slime"

	if(!SSticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has slimeized [M.key].")
		spawn(10)
			M:slimeize()
			feedback_add_details("admin_verb","MKMET") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_and_message_admins("made [key_name(M)] into a slime.")
	else
		tgui_alert(src, "Invalid mob")

/*
/client/proc/cmd_admin_monkeyize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Monkey"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/target = M
		log_admin("[key_name(src)] is attempting to monkeyize [M.key].")
		spawn(10)
			target.monkeyize()
	else
		tgui_alert(src, "Invalid mob")

/client/proc/cmd_admin_changelinginize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Changeling"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] a changeling.")
		spawn(10)
			M.absorbed_dna[M.real_name] = M.dna.Clone()
			M.make_changeling()
			if(M.mind)
				M.mind.set_special_role("Changeling")
	else
		tgui_alert(src, "Invalid mob")
*/
/*
/client/proc/cmd_admin_abominize(var/mob/M in mob_list)
	set category = null
	set name = "Make Abomination"

	to_chat(usr, "Ruby Mode disabled. Command aborted.")
	return
	if(!ticker)
		alert("Wait until the game starts.")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] an abomination.")

	//	spawn(10)
	//		M.make_abomination()

*/
/*
/client/proc/make_cultist(var/mob/M in mob_list) // -- TLE, modified by Urist
	set category = "Fun"
	set name = "Make Cultist"
	set desc = "Makes target a cultist"
	if(!cultwords["travel"])
		runerandom()
	if(M)
		if(M.mind in SSticker.mode.cult)
			return
		else
			if(tgui_alert(src, "Spawn that person a tome?", "Confirmation","Yes","No")=="Yes")
				to_chat(M, "<span class='warning'>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie. A tome, a message from your new master, appears on the ground.</span>")
				new /obj/item/book/tome(M.loc)
			else
				to_chat(M, "<span class='warning'>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</span>")
			var/glimpse=pick("1","2","3","4","5","6","7","8")
			switch(glimpse)
				if("1")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["travel"]] is travel...</span>")
				if("2")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["blood"]] is blood...</span>")
				if("3")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["join"]] is join...</span>")
				if("4")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["hell"]] is Hell...</span>")
				if("5")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["destroy"]] is destroy...</span>")
				if("6")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["technology"]] is technology...</span>")
				if("7")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["self"]] is self...</span>")
				if("8")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["see"]] is see...</span>")

			if(M.mind)
				M.mind.set_special_role("Cultist")
				SSticker.mode.cult += M.mind
			to_chat(src, "Made [M] a cultist.")
*/

//TODO: merge the vievars version into this or something maybe mayhaps
/client/proc/cmd_debug_del_all()
	set category = "Debug"
	set name = "Del-All"

	var/searching_type = input(usr, "Enter type of an object to delete.", "Delete:") as null|text
	if(!searching_type)
		return
	var/list/matches = list()
	for(var/path in (subtypesof(/obj)|subtypesof(/mob)))
		if(findtext("[path]", searching_type))
			matches += path
	if(!length(matches))
		return
	var/type_to_del = input(usr, "Choose type to delete.", "Delete:") as null|anything in matches
	if(type_to_del)
		for(var/atom/O in world)
			if(istype(O, type_to_del))
				qdel(O)
		log_admin("[key_name(src)] has deleted all instances of [type_to_del].")
		message_admins("[key_name_admin(src)] has deleted all instances of [type_to_del].", 0)
	feedback_add_details("admin_verb","DELA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.", 0)
	feedback_add_details("admin_verb","MPWN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_tog_aliens()
	set category = "Server"
	set name = "Toggle Aliens"

	CONFIG_SET(flag/aliens_allowed, !CONFIG_GET(flag/aliens_allowed))
	log_admin("[key_name(src)] has turned aliens [CONFIG_GET(flag/aliens_allowed) ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned aliens [CONFIG_GET(flag/aliens_allowed) ? "on" : "off"].", 0)
	feedback_add_details("admin_verb","TAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(var/mob/M in SSmobs.mob_list)
	set category = "Admin"
	set name = "Grant Full Access"

	if (!SSticker)
		alert("Wait until the game starts")
		return
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/card/id/id = H.GetIdCard()
		if(id)
			id.icon_state = MATERIAL_GOLD
			id.access = get_all_accesses()
		else
			id = new/obj/item/card/id(M);
			id.icon_state = MATERIAL_GOLD
			id.access = get_all_accesses()
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.SetName("[id.registered_name]'s ID Card ([id.assignment])")
			H.equip_to_slot_or_del(id, slot_wear_id)
			H.update_inv_wear_id()
	else
		tgui_alert(src, "Invalid mob")
	feedback_add_details("admin_verb","GFA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_and_message_admins("has granted [M.key] full access.")

/client/proc/cmd_assume_direct_control(var/mob/M in SSmobs.mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(!check_rights(R_DEBUG|R_ADMIN))
		return
	var/mob/adminmob = src.mob
	if(M.key)
		if(tgui_alert(src, "This mob is being controlled by [M.key]. Are you sure you wish to assume control of it? [M.key] will be made a ghost.", "Confirmation", list("Yes","No")) != "Yes")
			return
		else
			new/mob/dead/observer/ghost(M)
	log_and_message_admins("assumed direct control of [M].")
	adminmob.mind.transfer_to(M)
	if(isghost(adminmob))
		qdel(adminmob)
	feedback_add_details("admin_verb","ADC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!






/client/proc/cmd_admin_areatest()
	set category = "Mapping"
	set name = "Test areas"

	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()

	for(var/area/A in world)
		if(!(A.type in areas_all))
			areas_all.Add(A.type)

	for(var/obj/machinery/power/apc/APC in world)
		var/area/A = get_area(APC)
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)

	for(var/obj/machinery/alarm/alarm in world)
		var/area/A = get_area(alarm)
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)

	for(var/obj/machinery/requests_console/RC in world)
		var/area/A = get_area(RC)
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)

	for(var/obj/machinery/light/L in world)
		var/area/A = get_area(L)
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)

	for(var/obj/machinery/light_switch/LS in world)
		var/area/A = get_area(LS)
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)

	for(var/obj/item/radio/intercom/I in world)
		var/area/A = get_area(I)
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)

	for(var/obj/machinery/camera/C in world)
		var/area/A = get_area(C)
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	log_debug("<b>AREAS WITHOUT AN APC:</b>")
	for(var/areatype in areas_without_APC)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT AN AIR ALARM:</b>")
	for(var/areatype in areas_without_air_alarm)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT A REQUEST CONSOLE:</b>")
	for(var/areatype in areas_without_RC)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT ANY LIGHTS:</b>")
	for(var/areatype in areas_without_light)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT A LIGHT SWITCH:</b>")
	for(var/areatype in areas_without_LS)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT ANY INTERCOMS:</b>")
	for(var/areatype in areas_without_intercom)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT ANY CAMERAS:</b>")
	for(var/areatype in areas_without_camera)
		log_debug("* [areatype]")

/datum/admins/proc/cmd_admin_dress()
	set category = "Fun"
	set name = "Select equipment"

	if(!check_rights(R_FUN))
		return

	var/mob/living/carbon/human/H = input("Select mob.", "Select equipment.") as null|anything in GLOB.human_mob_list
	if(!H)
		return

	var/decl/hierarchy/outfit/outfit = input("Select outfit.", "Select equipment.") as null|anything in outfits()
	if(!outfit)
		return

	var/reset_equipment = (outfit.flags&OUTFIT_RESET_EQUIPMENT)
	if(!reset_equipment)
		reset_equipment = tgui_alert(usr, "Do you wish to delete all current equipment first?", "Delete Equipment?", list("Yes", "No")) == "Yes" ? TRUE : FALSE

	feedback_add_details("admin_verb","SEQ")
	dressup_human(H, outfit, reset_equipment)

/proc/dressup_human(var/mob/living/carbon/human/H, var/decl/hierarchy/outfit/outfit, var/undress = TRUE)
	if(!H || !outfit)
		return
	if(undress)
		H.delete_inventory(TRUE)
	outfit.equip(H)
	log_and_message_admins("changed the equipment of [key_name(H)] to [outfit.name].")

/client/proc/startSinglo()
	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing"

	if(tgui_alert(src, "Are you sure? This will start up the engine. Should only be used during debug!", "Confirmation","Yes","No") != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in world)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field_generator/F in world)
		if(F.anchored)
			F.Varedit_start = 1
	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in world)
			if(G.anchored)
				var/obj/singularity/S = new /obj/singularity(get_turf(G), 50)
				spawn(0)
					qdel(G)
				S.energy = 1750
				S.current_size = 7
				S.icon = 'icons/effects/224x224.dmi'
				S.icon_state = "singularity_s7"
				S.pixel_x = -96
				S.pixel_y = -96
				S.grav_pull = 0
				//S.consume_range = 3
				S.dissipate = 0
				//S.dissipate_delay = 10
				//S.dissipate_track = 0
				//S.dissipate_strength = 10

	for(var/obj/machinery/power/rad_collector/Rad in world)
		if(Rad.anchored)
			if(!Rad.P)
				var/obj/item/tank/phoron/Phoron = new/obj/item/tank/phoron(Rad)
				Phoron.air_contents.gas[MATERIAL_PHORON] = 70
				Rad.drainratio = 0
				Rad.P = Phoron
				Phoron.forceMove(Rad)

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in world)
		if(SMES.anchored)
			SMES.input_attempt = 1

/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs", "Ghost Mobs", "Clients"))
		if("Players")
			to_chat(usr, jointext(GLOB.player_list,","))
		if("Admins")
			to_chat(usr, jointext(GLOB.admins,","))
		if("Mobs")
			to_chat(usr, jointext(SSmobs.mob_list,","))
		if("Living Mobs")
			to_chat(usr, jointext(GLOB.living_mob_list,","))
		if("Dead Mobs")
			to_chat(usr, jointext(GLOB.dead_mob_list,","))
		if("Ghost Mobs")
			to_chat(usr, jointext(GLOB.ghost_mob_list,","))
		if("Clients")
			to_chat(usr, jointext(GLOB.clients,","))

// DNA2 - Admin Hax
/client/proc/cmd_admin_toggle_block(var/mob/M,var/block)
	if(!SSticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon))
		M.dna.SetSEState(block,!M.dna.GetSEState(block))
		domutcheck(M,null,MUTCHK_FORCED)
		M.update_mutations()
		var/state="[M.dna.GetSEState(block)?"on":"off"]"
		var/blockname=assigned_blocks[block]
		message_admins("[key_name_admin(src)] has toggled [M.key]'s [blockname] block [state]!")
		log_admin("[key_name(src)] has toggled [M.key]'s [blockname] block [state]!")
	else
		tgui_alert(src, "Invalid mob")

/datum/admins/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the Runtime Viewer"

	if(!check_rights(R_RUNTIMES))
		return

	GLOB.error_cache.show_to(usr.client)


/client/proc/start_line_profiling()
	set category = "Profile"
	set name = "Start line profiling"
	set desc = "Starts tracking line by line profiling for code lines that support it"

	LINE_PROFILE_START

	message_admins("<span class='adminnotice'>[key_name_admin(src)] started line by line profiling.</span>")
	feedback_add_details("admin_verb","Start line profiling")
	log_admin("[key_name(src)] started line by line profiling.")

/client/proc/stop_line_profiling()
	set category = "Profile"
	set name = "Stop line profiling"
	set desc = "Stops tracking line by line profiling for code lines that support it"

	LINE_PROFILE_STOP

	message_admins("<span class='adminnotice'>[key_name_admin(src)] stopped line by line profiling.</span>")
	feedback_add_details("admin_verb","Stop line profiling")
	log_admin("[key_name(src)] stopped line by line profiling.")

/client/proc/show_line_profiling()
	set category = "Profile"
	set name = "Show line profiling"
	set desc = "Shows tracked profiling info from code lines that support it"

	var/sortlist = list(
		"Avg time"		=	/proc/cmp_profile_avg_time_dsc,
		"Total Time"	=	/proc/cmp_profile_time_dsc,
		"Call Count"	=	/proc/cmp_profile_count_dsc
	)
	var/sort = input(src, "Sort type?", "Sort Type", "Avg time") as null|anything in sortlist
	if (!sort)
		return
	sort = sortlist[sort]
	profile_show(src, sort)

/client/proc/cmd_analyse_health_panel()
	set category = "Debug"
	set name = "Analyse Health"
	set desc = "Get an advanced health reading on a human mob."

	var/mob/living/carbon/human/H = input("Select mob.", "Analyse Health") as null|anything in GLOB.human_mob_list
	if(!H)	return

	cmd_analyse_health(H)

/client/proc/cmd_analyse_health(var/mob/living/carbon/human/H)

	if(!check_rights(R_DEBUG))
		return

	if(!H)	return

	var/datum/advanced_scanner/AS = new /datum/advanced_scanner()
	AS.occupant = H
	AS.tgui_interact(mob)

/client/proc/cmd_analyse_health_context(mob/living/carbon/human/H as mob in GLOB.human_mob_list)
	set category = null
	set name = "Analyse Human Health"

	if(!check_rights(R_DEBUG))
		return
	if(!ishuman(H))	return
	cmd_analyse_health(H)
	feedback_add_details("admin_verb","ANLS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/*/client/proc/cmd_display_overlay_log()		// Uncomment here and in 'code/modules/admin/admin_verbs.dm'
	set category = "Debug"						// if you want to see how much it takes to render overlay
	set name = "Display overlay Log"
	set desc = "Display SSoverlays log of everything that's passed through it."
	render_stats(SSoverlays.stats, src)*/

/obj/effect/debugmarker
	icon = LIGHTING_ICON
	icon_state = "lighting_transparent"

	layer = HOLOMAP_LAYER
	alpha = 127

/client/var/list/image/powernet_markers = list()
/client/proc/visualpower()
	set category = "Debug"
	set name = "Visualize Powernets"

	if(!check_rights(R_DEBUG)) return
	visualpower_remove()
	powernet_markers = list()

	for(var/datum/powernet/PN in SSmachines.powernets)
		var/netcolor = rgb(rand(100,255),rand(100,255),rand(100,255))
		for(var/obj/structure/cable/C in PN.cables)
			var/image/I = image('icons/effects/lighting_object.dmi', get_turf(C), "lighting_transparent")
			I.plane = GAME_PLANE_UPPER
			I.layer = EXPOSED_WIRE_LAYER
			I.alpha = 127
			I.color = netcolor
			I.maptext = "\ref[PN]"
			powernet_markers += I
	images += powernet_markers

/client/proc/visualpower_remove()
	set category = "Debug"
	set name = "Remove Powernets Visuals"

	images -= powernet_markers
	QDEL_NULL_LIST(powernet_markers)


/client/proc/gc_stress()
	set category = "Debug"
	set name = "Stress Test Garbage Collection"
	set desc = "Mass deletes objects onscreen to stress-test garbage collection."

	for (var/obj/O in range(world.view, mob))
		qdel(O)


/client/proc/dummy_crowd()
	set category = "Debug"
	set name = "Spawn Dummy Crowd"
	set desc = "Makes a bunch of dummies for testing AOE attacks"

	if(tgui_alert(mob, "Spawn dummy crowd?", "Dummy Crowd", list("Yes", "No")) == "Yes")
		for(var/turf/T as anything in RANGE_TURFS(mob, 1))
			new /mob/living/carbon/human/dummy(T)

/// A debug verb to check the sources of currently running timers
/client/proc/check_timer_sources()
	set category = "Debug"
	set name = "Check Timer Sources"
	set desc = "Checks the sources of the running timers"
	if (!check_rights(R_DEBUG))
		return

	var/bucket_list_output = generate_timer_source_output(SStimer.bucket_list)
	var/second_queue = generate_timer_source_output(SStimer.second_queue)

	usr << browse({"
		<h3>bucket_list</h3>
		[bucket_list_output]
		<h3>second_queue</h3>
		[second_queue]
	"}, "window=check_timer_sources;size=700x700")

/proc/generate_timer_source_output(list/datum/timedevent/events)
	var/list/per_source = list()

	// Collate all events and figure out what sources are creating the most
	for (var/_event in events)
		if (!_event)
			continue
		var/datum/timedevent/event = _event

		do
			if (event.source)
				if (per_source[event.source] == null)
					per_source[event.source] = 1
				else
					per_source[event.source] += 1
			event = event.next
		while (event && event != _event)

	// Now, sort them in order
	var/list/sorted = list()
	for (var/source in per_source)
		sorted += list(list("source" = source, "count" = per_source[source]))
	sorted = sortTim(sorted, .proc/cmp_timer_data)

	// Now that everything is sorted, compile them into an HTML output
	var/output = "<table border='1'>"

	for (var/_timer_data in sorted)
		var/list/timer_data = _timer_data
		output += {"<tr>
			<td><b>[timer_data["source"]]</b></td>
			<td>[timer_data["count"]]</td>
		</tr>"}

	output += "</table>"

	return output

/proc/cmp_timer_data(list/a, list/b)
	return b["count"] - a["count"]
