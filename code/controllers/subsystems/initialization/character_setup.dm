SUBSYSTEM_DEF(character_setup)
	name = "Character Setup"
	init_order = SS_INIT_CHAR_SETUP
	priority = SS_PRIORITY_CHAR_SETUP
	flags = SS_BACKGROUND
	wait = 1 SECOND
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/list/prefs_awaiting_setup = list()
	var/list/preferences_datums = list()
	var/list/newplayers_requiring_init = list()

	var/list/save_queue = list()

/datum/controller/subsystem/character_setup/Initialize()
	for(var/datum/preferences/prefs as anything in prefs_awaiting_setup)
		prefs_awaiting_setup -= prefs
		prefs.setup()
		CHECK_TICK
	for(var/mob/dead/new_player/new_player as anything in newplayers_requiring_init)
		newplayers_requiring_init -= new_player
		new_player.deferred_login()
		CHECK_TICK
	. = ..()

/datum/controller/subsystem/character_setup/fire(resumed = FALSE)
	while(save_queue.len)
		var/datum/preferences/prefs = save_queue[save_queue.len]
		save_queue.len--

		if(!QDELETED(prefs))
			prefs.save_preferences()

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/character_setup/proc/queue_preferences_save(var/datum/preferences/prefs)
	save_queue |= prefs
