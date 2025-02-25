/*
	Bugs a target crewmember, allowing you to see things around them

	When initially cast, it reveals a wide area around the victim. The radius gradually shrinks as the duration depletes.
	The duration depletes faster for each other visible crewmember around the host, so it is less effective for spying on large groups, but good for tracking loners

	Future Plans:
	Once the system is available, make duration based on psych damage instead. Lasting longer on people who are less sane
*/
#define TRACER_MAX_RANGE	10

/datum/signal_ability/psychic_tracer
	name = "Psychic Tracer"
	id = "psychic_tracer"
	desc = "Plants a psychic tracer on a target mob, causing them to act as a visual relay for necrovision. This allows signals to see in a radius around them. <br>\
	This can last up to 10 minutes, but it will expire faster the more human crewmembers are near the target. Visual radius will gradually dwindle as the duration runs out.<br>\
	<br>\
	Casting it again on a target who already has a tracer will refresh the duration and range"
	target_string = "any living mob or crewmember"
	energy_cost = 10
	require_corruption = FALSE
	require_necrovision = TRUE
	autotarget_range = 1
	target_types = list(/mob/living)

	targeting_method	=	TARGET_CLICK
	marker_active_required = -1

/datum/signal_ability/psychic_tracer/marker
	energy_cost = 70
	id = "psychic_tracer_postmarker"

	marker_active_required = TRUE


/datum/signal_ability/psychic_tracer/on_cast(var/mob/user, var/atom/target, var/list/data)
	var/datum/extension/psychic_tracer/MW = get_extension(target, /datum/extension/psychic_tracer)
	if (istype(MW))
		MW.refresh_duration()
		link_necromorphs_to(SPAN_NOTICE("Refreshed duration on Psychic Tracer attached to [target] at LINK"), target)
	else
		MW = set_extension(target, /datum/extension/psychic_tracer)
		link_necromorphs_to(SPAN_NOTICE("[user] planted a psychic tracer on [target] at LINK"), target)




/*
	Atom
	This is just a placeholder because visualnet and moved observation code requires a movable atom as a point of reference
*/
/obj/effect/psychic_tracer
	var/datum/extension/psychic_tracer/EM
	visualnet_range = TRACER_MAX_RANGE
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/psychic_tracer/Initialize(mapload)
	.=..()
	RegisterSignal(loc, COMSIG_MOVABLE_MOVED, .proc/holder_moved)
	forceMove(loc.loc)

/obj/effect/psychic_tracer/proc/holder_moved(atom/movable/source)
	forceMove(source.loc)

/obj/effect/psychic_tracer/get_visualnet_tiles()
	//Unsure why this is happening, but it seems that we aren't getting properly removed from chunk lists. Return PROCESS_KILL to ensure that happens
	if (!EM)
		if (!QDELETED(src))
			qdel(src)
		return PROCESS_KILL

	return EM.get_visualnet_tiles()

/obj/effect/psychic_tracer/Destroy()
	EM = null //Clears out the ref that's about to become nulled to save GC time.
	return ..()

/*
	Extension: Added to the infected mob
*/
/datum/extension/psychic_tracer
	name = "Psychic Tracer"
	expected_type = /mob/living
	flags = EXTENSION_FLAG_IMMEDIATE
	base_type = /datum/extension/psychic_tracer

	var/atom/A
	var/tick_interval_seconds = 4	//This serves a dual purpose
	var/initial_duration = 10 MINUTES
	var/initial_radius = TRACER_MAX_RANGE
	var/radius

	var/duration
	var/obj/effect/psychic_tracer/object

	//Crew
	var/crew_multiplier = 0.5	//50% faster for each visible crewmember




/datum/extension/psychic_tracer/New(var/datum/holder)
	.=..()
	A = holder
	duration = initial_duration
	addtimer(CALLBACK(src, /datum/extension/psychic_tracer/proc/tick), tick_interval_seconds SECONDS)
	object = new /obj/effect/psychic_tracer(holder)
	object.EM = src

	GLOB.necrovision.addVisionSource(object, VISION_SOURCE_VIEW, TRUE)


/datum/extension/psychic_tracer/proc/tick()
	var/numcrew = get_visible_crew()

	change_duration((tick_interval_seconds SECONDS) * (1 + (numcrew * crew_multiplier))*-1)
	if (duration > 0)
		addtimer(CALLBACK(src, /datum/extension/psychic_tracer/proc/tick), tick_interval_seconds SECONDS)



/datum/extension/psychic_tracer/proc/refresh_duration()
	change_duration(initial_duration - duration)



/datum/extension/psychic_tracer/proc/change_duration(var/change)
	duration += change

	if (duration <= 0)
		stop()
		return

	//Lets calculate the radius after this change
	var/percent = duration / initial_duration
	var/newradius = Ceiling(initial_radius * percent)
	set_radius(newradius)

/datum/extension/psychic_tracer/proc/set_radius(var/newradius)
	//Only update things if the radius has changed
	if (radius == newradius)
		return

	radius = newradius

	//Remove and re-add ourselves to update the necrovision
	GLOB.necrovision.removeVisionSource(object)
	object.visualnet_range = radius
	GLOB.necrovision.addVisionSource(object, VISION_SOURCE_VIEW, TRUE)

/datum/extension/psychic_tracer/proc/get_visualnet_tiles()
	return A.turfs_in_view(radius)


/datum/extension/psychic_tracer/proc/stop()
	remove_extension(holder, base_type)

/datum/extension/psychic_tracer/Destroy()
	GLOB.necrovision.removeVisionSource(object)
	QDEL_NULL(object)
	.=..()

//Find out how many crew can see our source
/datum/extension/psychic_tracer/proc/get_visible_crew()
	var/num = 0
	for (var/mob/living/carbon/human/H in view(10, A))
		if (H.stat == DEAD)
			continue

		if (H.is_necromorph())
			continue

		if (H == A)
			continue

		num++

	return num

#undef TRACER_MAX_RANGE