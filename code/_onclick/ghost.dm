/client/var/inquisitive_ghost = 1
/mob/dead/observer/ghost/verb/toggle_inquisition() // warning: unexpected inquisition
	set name = "Toggle Inquisitiveness"
	set desc = "Sets whether your ghost examines everything on click by default"
	set category = "Ghost"
	if(!client) return
	client.inquisitive_ghost = !client.inquisitive_ghost
	if(client.inquisitive_ghost)
		to_chat(src, "<span class='notice'>You will now examine everything you click on.</span>")
	else
		to_chat(src, "<span class='notice'>You will no longer examine things you click on.</span>")

/mob/dead/observer/ghost/DblClickOn(var/atom/A, var/params)
	if(can_reenter_corpse && mind && mind.current)
		if(A == mind.current || (mind.current in A)) // double click your corpse or whatever holds it
			reenter_corpse()						// (cloning scanner, body bag, closet, mech, etc)
			return

	// Things you might plausibly want to follow
	if(istype(A,/atom/movable))
		ManualFollow(A)
	// Otherwise jump
	else
		stop_following()
		forceMove(get_turf(A))

/mob/dead/observer/ghost/ClickOn(var/atom/A, var/params)
	if(!canClick()) return
	set_click_cooldown(DEFAULT_QUICK_COOLDOWN)

	// You are responsible for checking config.ghost_interaction when you override this function
	// Not all of them require checking, see below
	var/list/modifiers = params2list(params)
	if(modifiers["alt"])
		var/target_turf = get_turf(A)
		if(target_turf)
			AltClickOn(target_turf)
	else
		A.attack_ghost(src)

// Oh by the way this didn't work with old click code which is why clicking shit didn't spam you
/atom/proc/attack_ghost(mob/dead/observer/ghost/user as mob)
	if(!istype(user))
		return
	if(user.client && user.client.inquisitive_ghost)
		user.examinate(src)
	return

// ---------------------------------------
// And here are some good things for free:
// Now you can click through portals, wormholes, gateways, and teleporters while observing. -Sayu

/obj/machinery/teleport/hub/attack_ghost(mob/user as mob)
	var/atom/l = loc
	var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(l.x - 2, l.y, l.z))
	if(com.locked)
		user.forceMove(get_turf(com.locked))

/obj/effect/portal/attack_ghost(mob/user as mob)
	if(target)
		user.forceMove(get_turf(target))
