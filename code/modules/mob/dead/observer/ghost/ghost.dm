var/global/list/image/ghost_darkness_images = list() //this is a list of images for things ghosts should still be able to see when they toggle darkness
var/global/list/image/ghost_sightless_images = list() //this is a list of images for things ghosts should still be able to see even without ghost sight

/mob/dead/observer/ghost
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	appearance_flags = KEEP_TOGETHER
	blinded = 0
	anchored = 1	//  don't get pushed around
	universal_speak = 1
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mob_flags = MOB_FLAG_HOLY_BAD
	movement_handlers = list(/datum/movement_handler/mob/incorporeal)

	var/is_manifest = FALSE
	var/next_visibility_toggle = 0
	var/can_reenter_corpse
	var/bootime = 0
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghost - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	var/has_enabled_antagHUD = 0
	var/medHUD = 0
	var/antagHUD = 0
	var/atom/movable/following = null
	var/admin_ghosted = 0
	var/anonsay = 0
	var/ghostvision = 1 //is the ghost able to see things humans can't?
	var/seedarkness = 1
	var/static/obj/item/weapon/card/id/all_access/ghost_all_access
	var/obj/item/weapon/tool/multitool/ghost/ghost_multitool
	var/list/hud_images // A list of hud images

/mob/dead/observer/ghost/New(mob/body)
	add_verb(src, /mob/proc/toggle_antag_pool)

	var/turf/T
	if(ismob(body))
		T = get_turf(body) //Where is the body located?
		if(!T)
			T = pick(GLOB.latejoin | GLOB.latejoin_cryo | GLOB.latejoin_gateway) //Safety in case we cannot find the body's position
		forceMove(T)
		attack_logs_ = body.attack_logs_ //preserve our attack logs by copying them to our ghost

		set_appearance(body)

		mind = body.mind //we don't transfer the mind but we keep a reference to it.

		if(mind.name)
			name = mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
				if(gender == MALE)
					name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
				else
					name = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))

		key = body.key

	else
		forceMove(pick(GLOB.latejoin | GLOB.latejoin_cryo | GLOB.latejoin_gateway))
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.current = src
		mind.ghost = src

	if(!name)							//To prevent nameless ghosts
		name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
	real_name = name


	ghost_multitool = new(src)

	GLOB.ghost_mob_list += src

	..()

/mob/dead/observer/ghost/Destroy()
	GLOB.ghost_mob_list -= src
	stop_following()
	qdel(ghost_multitool)
	ghost_multitool = null
	if (mind)
		if (mind.ghost == src)
			mind.ghost = null
		mind = null
	if(hud_images)
		for(var/image/I in hud_images)
			show_hud_icon(I.icon_state, FALSE)
		hud_images = null
	return ..()

/mob/dead/observer/ghost/Topic(href, href_list)
	if (href_list["track"])
		if(istype(href_list["track"],/mob))
			var/mob/target = locate(href_list["track"]) in SSmobs.mob_list
			if(target)
				ManualFollow(target)
		else
			var/atom/target = locate(href_list["track"])
			if(istype(target))
				ManualFollow(target)
	else
		.=..()

/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/

/mob/dead/observer/ghost/Life()
	..()
	if(!loc) return
	if(!client) return 0

	handle_hud_glasses()

	if(antagHUD)
		var/list/target_list = list()
		for(var/mob/living/target in oview(src, 14))
			if(target.mind && target.mind.special_role)
				target_list += target
		if(target_list.len)
			assess_targets(target_list, src)
	if(medHUD)
		process_medHUD(src)


/mob/dead/observer/ghost/proc/process_medHUD(var/mob/M)
	var/client/C = M.client
	for(var/mob/living/carbon/human/patient in oview(M, 14))
		add_hudlist(C.images, patient, HEALTH_HUD)
		add_hudlist(C.images, patient, STATUS_HUD_OOC)

/mob/dead/observer/ghost/proc/assess_targets(list/target_list, mob/dead/observer/ghost/U)
	var/client/C = U.client
	for(var/mob/living/carbon/human/target in target_list)
		add_hudlist(C.images, target,SPECIALROLE_HUD)
	for(var/mob/living/silicon/target in target_list)
		add_hudlist(C.images, target,SPECIALROLE_HUD)
	return 1

/mob/proc/ghostize(can_reenter_corpse = CORPSE_CAN_REENTER)
	if (is_necromorph() && !istype(src, /mob/dead/observer/eye/signal))	//Signals can use ghostize to leave the necromorph team
		return necro_ghost()

	// Are we the body of an aghosted admin? If so, don't make a ghost.
	if (teleop && istype(teleop, /mob/dead/observer/ghost))
		var/mob/dead/observer/ghost/G = teleop
		if(G.admin_ghosted)
			return
	hide_fullscreens()
	var/mob/dead/observer/ghost/ghost = new(src)	//Transfer safety to observer spawning proc.
	SSnano.user_transferred(src, ghost)
	SStgui.on_transfer(src, ghost)
	ghost.can_reenter_corpse = can_reenter_corpse
	ghost.timeofdeath = src.stat == DEAD ? src.timeofdeath : world.time
	if (ghost.client)		// For new ghosts we remove the verb from even showing up if it's not allowed.
		if (!ghost.client.holder && !CONFIG_GET(flag/antag_hud_allowed))
			remove_verb(ghost, /mob/dead/observer/ghost/verb/toggle_antagHUD)// Poor guys, don't know what they are missing!
		ghost.client.init_verbs()
	return ghost

/mob/dead/observer/ghost/is_advanced_tool_user()
	return TRUE

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	if (is_necromorph())
		necro_ghost() 	//Ghosting as a necromorph follows a different path
		return

	if(stat == DEAD)
		announce_ghost_joinleave(ghostize(CORPSE_CAN_REENTER))
	else
		var/response
		if(src.client && src.client.holder)
			response = tgui_alert(src, "You have the ability to Admin-Ghost. The regular Ghost verb will announce your presence to dead chat. Both variants will allow you to return to your body using 'aghost'.\n\nWhat do you wish to do?", "Are you sure you want to ghost?", list("Admin Ghost", "Stay in body"))
			if(response == "Admin Ghost")
				if(!src.client)
					return
				src.client.admin_ghost()
		else if(CONFIG_GET(number/respawn_delay))
			response = tgui_alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you won't be able to play this round for another [CONFIG_GET(number/respawn_delay)] minute\s! You can't change your mind so choose wisely!)", "Are you sure you want to ghost?", list("Ghost", "Stay in body"))
		else
			response = tgui_alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you won't be able to return to this body! You can't change your mind so choose wisely!)", "Are you sure you want to ghost?", list("Ghost", "Stay in body"))
		if(response != "Ghost")
			return
		resting = 1
		var/turf/location = get_turf(src)
		message_admins("[key_name_admin(usr)] has ghosted. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>JMP</a>)")
		log_game("[key_name_admin(usr)] has ghosted.")
		var/mob/dead/observer/ghost/ghost = ghostize(CORPSE_CANT_REENTER)	//0 parameter is so we can never re-enter our body, "Charlie, you can never come baaaack~" :3
		ghost.timeofdeath = world.time // Because the living mob won't have a time of death and we want the respawn timer to work properly.
		announce_ghost_joinleave(ghost)

/mob/dead/observer/ghost/can_use_hands()	return 0
/mob/dead/observer/ghost/is_active()		return 0


/mob/dead/observer/ghost/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
	if(!client)	return
	if(!(mind && mind.current && can_reenter_corpse))
		to_chat(src, "<span class='warning'>You have no body.</span>")
		return
	if(mind.current.key && copytext(mind.current.key,1,2)!="@")	//makes sure we don't accidentally kick any clients
		to_chat(src, "<span class='warning'>Another consciousness is in your body... it is resisting you.</span>")
		return
	stop_following()
	SSnano.user_transferred(src, mind.current)
	SStgui.on_transfer(src, mind.current)
	mind.current.key = key
	mind.current.teleop = null
	mind.current.reload_fullscreens()
	if(!admin_ghosted)
		announce_ghost_joinleave(mind, 0, "They now occupy their body again.")
	return 1

/mob/dead/observer/ghost/verb/toggle_medHUD()
	set category = "Ghost"
	set name = "Toggle MedicHUD"
	set desc = "Toggles Medical HUD allowing you to see how everyone is doing"
	if(!client)
		return
	if(medHUD)
		medHUD = 0
		to_chat(src, "<span class='notice'>Medical HUD Disabled</span>")
	else
		medHUD = 1
		to_chat(src, "<span class='notice'>Medical HUD Enabled</span>")
/mob/dead/observer/ghost/verb/toggle_antagHUD()
	set category = "Ghost"
	set name = "Toggle AntagHUD"
	set desc = "Toggles AntagHUD allowing you to see who is the antagonist"

	if(!client)
		return
	var/mentor = is_mentor(usr.client)
	if(!CONFIG_GET(flag/antag_hud_allowed) && (!client.holder || mentor))
		to_chat(src, "<span class='warning'>Admins have disabled this for this round.</span>")
		return
	var/mob/dead/observer/ghost/M = src
	if(jobban_isbanned(M, "AntagHUD"))
		to_chat(src, "<span class='danger'>You have been banned from using this feature</span>")
		return
	if(CONFIG_GET(flag/antag_hud_restricted) && !M.has_enabled_antagHUD && (!client.holder || mentor))
		var/response = tgui_alert(src, "If you turn this on, you will not be able to take any part in the round.","Are you sure you want to turn this feature on?", list("Yes","No"))
		if(response != "Yes") return
		M.can_reenter_corpse = 0
	if(!M.has_enabled_antagHUD && (!client.holder || mentor))
		M.has_enabled_antagHUD = 1
	if(M.antagHUD)
		M.antagHUD = 0
		to_chat(src, "<span class='notice'>AntagHUD Disabled</span>")
	else
		M.antagHUD = 1
		to_chat(src, "<span class='notice'>AntagHUD Enabled</span>")
/mob/dead/observer/ghost/verb/dead_tele(A in area_repository.get_areas_by_z_level())
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"

	var/area/thearea = area_repository.get_areas_by_z_level()[A]
	if(!thearea)
		to_chat(src, "No area available.")
		return

	var/list/area_turfs = get_area_turfs(thearea, shall_check_if_holy() ? list(/proc/is_holy_turf) : list())
	if(!area_turfs.len)
		to_chat(src, "<span class='warning'>This area has been entirely made into sacred grounds, you cannot enter it while you are in this plane of existence!</span>")
		return

	ghost_to_turf(pick(area_turfs))

/mob/dead/observer/ghost/verb/dead_tele_coord(tx as num, ty as num, tz as num)
	set category = "Ghost"
	set name = "Teleport to Coordinate"
	set desc= "Teleport to a coordinate"

	var/turf/T = locate(tx, ty, tz)
	if(T)
		ghost_to_turf(T)
	else
		to_chat(src, "<span class='warning'>Invalid coordinates.</span>")
/mob/dead/observer/ghost/verb/follow(var/datum/follow_holder/fh in get_follow_targets())
	set category = "Ghost"
	set name = "Follow"
	set desc = "Follow and haunt a mob."

	if(!fh.show_entry()) return
	ManualFollow(fh.followed_instance)

/mob/dead/observer/ghost/proc/ghost_to_turf(var/turf/target_turf)
	if(check_is_holy_turf(target_turf))
		to_chat(src, "<span class='warning'>The target location is holy grounds!</span>")
		return
	stop_following()
	forceMove(target_turf)

// This is the ghost's follow verb with an argument
/mob/dead/observer/ghost/proc/ManualFollow(var/atom/movable/target)
	if(!target || target == following || target == src)
		return

	stop_following()
	following = target
	RegisterSignal(following, COMSIG_MOVABLE_MOVED, /atom/movable/proc/move_to_turf)
	RegisterSignal(following, COMSIG_ATOM_DIR_CHANGE, .proc/recursive_dir_set)
	RegisterSignal(following, COMSIG_PARENT_QDELETING, .proc/stop_following)

	to_chat(src, "<span class='notice'>Now following \the [following].</span>")
	move_to_turf(following, loc, following.loc)

/mob/dead/observer/ghost/proc/recursive_dir_set(atom/a, old_dir, new_dir)
	SIGNAL_HANDLER
	if (new_dir != old_dir)
		set_dir(new_dir)

/mob/dead/observer/ghost/proc/stop_following()
	SIGNAL_HANDLER
	if(following)
		to_chat(src, "<span class='notice'>No longer following \the [following]</span>")
		UnregisterSignal(following, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE, COMSIG_PARENT_QDELETING))
		following = null

/mob/dead/observer/ghost/move_to_turf(var/atom/movable/am, var/old_loc, var/new_loc)
	var/turf/T = get_turf(new_loc)
	if(check_is_holy_turf(T))
		to_chat(src, "<span class='warning'>You cannot follow something standing on holy grounds!</span>")
		return
	..()

/mob/dead/observer/ghost/memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")
/mob/dead/observer/ghost/add_memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")
/mob/dead/observer/ghost/PostIncorporealMovement()
	stop_following()

/mob/dead/observer/ghost/verb/analyze_air()
	set name = "Analyze Air"
	set category = "Ghost"

	var/turf/t = get_turf(src)
	if(t)
		print_atmos_analysis(src, atmosanalyzer_scan(t))

/mob/dead/observer/ghost/verb/check_radiation()
	set name = "Check Radiation"
	set category = "Ghost"

	var/turf/t = get_turf(src)
	if(t)
		var/rads = SSradiation.get_rads_at_turf(t)
		to_chat(src, "<span class='notice'>Radiation level: [rads ? rads : "0"] Bq.</span>")

/mob/dead/observer/ghost/verb/become_mouse()
	set name = "Become mouse"
	set category = "Ghost"

	if(CONFIG_GET(flag/disable_player_mice))
		to_chat(src, "<span class='warning'>Spawning as a mouse is currently disabled.</span>")
		return

	if(!MayRespawn(1, ANIMAL_SPAWN_DELAY))
		return

	var/turf/T = get_turf(src)
	if(!T || (T.z in GLOB.using_map.admin_levels))
		to_chat(src, "<span class='warning'>You may not spawn as a mouse on this Z-level.</span>")
		return

	var/response = tgui_alert(src, "Are you -sure- you want to become a mouse?","Are you sure you want to squeek?", list("Squeek!","Nope!"))
	if(response != "Squeek!") return  //Hit the wrong key...again.


	//find a viable mouse candidate
	var/mob/living/simple_animal/mouse/host
	var/obj/machinery/atmospherics/unary/vent_pump/vent_found
	var/list/found_vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in SSmachines.machinery)
		if(!v.welded && v.z == T.z)
			found_vents.Add(v)
	if(found_vents.len)
		vent_found = pick(found_vents)
		host = new /mob/living/simple_animal/mouse(vent_found.loc)
	else
		to_chat(src, "<span class='warning'>Unable to find any unwelded vents to spawn mice at.</span>")
	if(host)
		if(CONFIG_GET(flag/uneducated_mice))
			host.universal_understand = 0
		announce_ghost_joinleave(src, 0, "They are now a mouse.")
		host.ckey = src.ckey
		host.status_flags |= NO_ANTAG
		to_chat(host, "<span class='info'>You are now a mouse. Try to avoid interaction with players, and do not give hints away that you are more than a simple rodent.</span>")
/mob/dead/observer/ghost/verb/view_manfiest()
	set name = "Show Crew Manifest"
	set category = "Ghost"

	var/dat
	dat += "<h4>Crew Manifest</h4>"
	dat += html_crew_manifest()

	src << browse(dat, "window=manifest;size=370x420;can_close=1")

//This is called when a ghost is drag clicked to something.
/mob/dead/observer/ghost/MouseDrop(atom/over)
	if(!usr || !over) return
	if(isghost(usr) && usr.client && isliving(over))
		var/mob/living/M = over
		// If they an admin, see if control can be resolved.
		if(usr.client.holder && usr.client.holder.cmd_ghost_drag(src,M))
			return
		// Otherwise, see if we can possess the target.
		if(usr == src && try_possession(M))
			return
	if(istype(over, /obj/machinery/drone_fabricator))
		if(try_drone_spawn(src, over))
			return

	return ..()

/mob/dead/observer/ghost/proc/try_possession(var/mob/living/M)
	if(!CONFIG_GET(flag/ghosts_can_possess_animals))
		to_chat(src, "<span class='warning'>Ghosts are not permitted to possess animals.</span>")
		return 0
	if(!M.can_be_possessed_by(src))
		return 0
	return M.do_possession(src)

/mob/dead/observer/ghost/pointed(atom/A as mob|obj|turf in view())
	if(!..())
		return 0
	usr.visible_message("<span class='deadsay'><b>[src]</b> points to [A]</span>")
	return 1

/mob/dead/observer/ghost/proc/show_hud_icon(var/icon_state, var/make_visible)
	if(!hud_images)
		hud_images = list()
	var/image/hud_image = hud_images[icon_state]
	if(!hud_image)
		hud_image = image('icons/mob/mob.dmi', loc = src, icon_state = icon_state)
		hud_images[icon_state] = hud_image

	if(make_visible)
		add_client_image(hud_image)
	else
		remove_client_image(hud_image)

/mob/dead/observer/ghost/verb/toggle_anonsay()
	set category = "Ghost"
	set name = "Toggle Anonymous Chat"
	set desc = "Toggles showing your key in dead chat."

	src.anonsay = !src.anonsay
	if(anonsay)
		to_chat(src, "<span class='info'>Your key won't be shown when you speak in dead chat.</span>")
	else
		to_chat(src, "<span class='info'>Your key will be publicly visible again.</span>")

/mob/dead/observer/ghost/canface()
	return 1

/mob/proc/can_admin_interact()
	return 0

/mob/dead/observer/ghost/can_admin_interact()
	return check_rights(R_ADMIN, 0, src)

/mob/dead/observer/ghost/verb/toggle_ghostsee()
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts"
	set category = "Ghost"
	ghostvision = !(ghostvision)
	updateghostsight()
	to_chat(src, "You [(ghostvision?"now":"no longer")] have ghost vision.")

/mob/dead/observer/ghost/verb/toggle_darkvision()
	set name = "Toggle Darkness"
	set category = "Ghost"

	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

	sync_lighting_plane_alpha()

/mob/dead/observer/ghost/proc/updateghostsight()
	if (!seedarkness)
		set_see_invisible(SEE_INVISIBLE_NOLIGHTING)
	else
		set_see_invisible(ghostvision ? SEE_INVISIBLE_OBSERVER : SEE_INVISIBLE_LIVING)
	updateghostimages()

/mob/dead/observer/ghost/proc/updateghostimages()
	if (!client)
		return
	client.images -= ghost_sightless_images
	client.images -= ghost_darkness_images
	if(!seedarkness)
		client.images |= ghost_sightless_images
		if(ghostvision)
			client.images |= ghost_darkness_images
	else if(seedarkness && !ghostvision)
		client.images |= ghost_sightless_images
	client.images -= ghost_image //remove ourself

/mob/dead/observer/ghost/MayRespawn(var/feedback = 0, var/respawn_time = 0)
	if(!client)
		return 0
	if(mind && mind.current && mind.current.stat != DEAD && can_reenter_corpse == CORPSE_CAN_REENTER && !check_rights(R_ADMIN|R_DEBUG))
		if(feedback)
			to_chat(src, "<span class='warning'>Your non-dead body prevents you from respawning.</span>")
		return 0
	if(CONFIG_GET(flag/antag_hud_restricted) && has_enabled_antagHUD == 1)
		if(feedback)
			to_chat(src, "<span class='warning'>antagHUD restrictions prevent you from respawning.</span>")
		return 0

	var/timedifference = world.time - timeofdeath
	if(!client.holder && respawn_time && timeofdeath && timedifference < respawn_time MINUTES)
		var/timedifference_text = time2text(respawn_time MINUTES - timedifference,"mm:ss")
		to_chat(src, "<span class='warning'>You must have been dead for [respawn_time] minute\s to respawn. You have [timedifference_text] left.</span>")
		return 0

	return 1

/proc/isghostmind(var/datum/mind/player)
	if( player?.ghost)
		return TRUE
	else if (isghost(player.current))
		return TRUE
	return FALSE
	//.= player && !isnewplayer(player.current) && (!player.current || isghost(player.current) || (isliving(player.current) && player.current.stat == DEAD) || !player.current.client)


/mob/proc/check_is_holy_turf(var/turf/T)
	return 0

/mob/dead/observer/ghost/check_is_holy_turf(var/turf/T)
	if(shall_check_if_holy() && is_holy_turf(T))
		return TRUE

/mob/dead/observer/ghost/proc/shall_check_if_holy()
	if(invisibility >= INVISIBILITY_OBSERVER)
		return FALSE
	if(check_rights(R_ADMIN|R_FUN, 0, src))
		return FALSE
	return TRUE

/mob/dead/observer/ghost/proc/set_appearance(var/mob/target)
	var/pre_alpha = alpha
	var/pre_plane = plane
	var/pre_layer = layer
	var/pre_invis = invisibility

	appearance = target
	appearance_flags |= initial(appearance_flags)
	alpha = pre_alpha
	plane = pre_plane
	layer = pre_layer
	set_invisibility(pre_invis)
	transform = null	//make goast stand up

/mob/dead/observer/ghost/verb/respawn()
	set name = "Respawn"
	set category = "OOC"

	if (!check_rights(R_ADMIN|R_DEBUG, 0, src) && !CONFIG_GET(flag/abandon_allowed))
		to_chat(usr, "<span class='notice'>Respawn is disabled.</span>")
		return
	if (!(SSticker && SSticker.mode))
		to_chat(usr, "<span class='notice'><B>You may not attempt to respawn yet.</B></span>")
		return
	if (SSticker.mode && SSticker.mode.deny_respawn)
		to_chat(usr, "<span class='notice'>Respawn is disabled for this roundtype.</span>")
		return
	else if(!MayRespawn(1, CONFIG_GET(number/respawn_delay)))
		return

	to_chat(usr, "You can respawn now, enjoy your new life!")
	to_chat(usr, "<span class='notice'><B>Make sure to play a different character, and please roleplay correctly!</B></span>")
	announce_ghost_joinleave(client, 0)

	var/mob/dead/new_player/M = new /mob/dead/new_player()
	M.key = key
	log_and_message_admins("has respawned.", M)


//special multitool used so admin ghosts can fiddle with doors
/obj/item/weapon/tool/multitool/ghost
	var/mob/dead/observer/ghost/ghost

/obj/item/weapon/tool/multitool/ghost/New(var/mob/dead/observer/ghost/ghost)
	src.ghost = ghost
	.=..()

/obj/item/weapon/tool/multitool/ghost/Destroy()
	if (ghost && ghost.ghost_multitool == src)
		ghost.ghost_multitool = null

	.=..()