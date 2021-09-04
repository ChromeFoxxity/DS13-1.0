//Sound environment defines. Reverb preset for sounds played in an area, see sound datum reference for more.
#define GENERIC 0
#define PADDED_CELL 1
#define ROOM 2
#define BATHROOM 3
#define LIVINGROOM 4
#define STONEROOM 5
#define AUDITORIUM 6
#define CONCERT_HALL 7
#define CAVE 8
#define ARENA 9
#define HANGAR 10
#define CARPETED_HALLWAY 11
#define HALLWAY 12
#define STONE_CORRIDOR 13
#define ALLEY 14
#define FOREST 15
#define CITY 16
#define MOUNTAINS 17
#define QUARRY 18
#define PLAIN 19
#define PARKING_LOT 20
#define SEWER_PIPE 21
#define UNDERWATER 22
#define DRUGGED 23
#define DIZZY 24
#define PSYCHOTIC 25

#define STANDARD_STATION STONEROOM
#define LARGE_ENCLOSED HANGAR
#define SMALL_ENCLOSED BATHROOM
#define TUNNEL_ENCLOSED CAVE
#define LARGE_SOFTFLOOR CARPETED_HALLWAY
#define MEDIUM_SOFTFLOOR LIVINGROOM
#define SMALL_SOFTFLOOR ROOM
#define ASTEROID CAVE
#define SPACE UNDERWATER

GLOBAL_LIST_INIT(shatter_sound,list('sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg'))
GLOBAL_LIST_INIT(explosion_sound,list('sound/effects/Explosion1.ogg','sound/effects/Explosion2.ogg'))
GLOBAL_LIST_INIT(spark_sound,list('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg'))
GLOBAL_LIST_INIT(rustle_sound,list('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg'))
GLOBAL_LIST_INIT(punch_sound,list('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg'))
GLOBAL_LIST_INIT(clown_sound,list('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg'))
GLOBAL_LIST_INIT(swing_hit_sound,list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg'))
GLOBAL_LIST_INIT(hiss_sound,list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg'))
GLOBAL_LIST_INIT(page_sound,list('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg'))
//GLOBAL_LIST_INIT(fracture_sound,list('sound/effects/bonebreak1.ogg','sound/effects/bonebreak2.ogg','sound/effects/bonebreak3.ogg','sound/effects/bonebreak4.ogg'))
GLOBAL_LIST_INIT(fracture_sound,list('sound/effects/impacts/limb_break_1.ogg','sound/effects/impacts/limb_break_2.ogg','sound/effects/impacts/limb_break_3.ogg','sound/effects/impacts/limb_break_4.ogg'))
GLOBAL_LIST_INIT(lighter_sound,list('sound/items/lighter1.ogg','sound/items/lighter2.ogg','sound/items/lighter3.ogg'))
GLOBAL_LIST_INIT(keyboard_sound,list('sound/machines/keyboard/keypress1.ogg','sound/machines/keyboard/keypress2.ogg','sound/machines/keyboard/keypress3.ogg','sound/machines/keyboard/keypress4.ogg'))
GLOBAL_LIST_INIT(keystroke_sound,list('sound/machines/keyboard/keystroke1.ogg','sound/machines/keyboard/keystroke2.ogg','sound/machines/keyboard/keystroke3.ogg','sound/machines/keyboard/keystroke4.ogg'))
GLOBAL_LIST_INIT(switch_sound,list('sound/machines/switch1.ogg','sound/machines/switch2.ogg','sound/machines/switch3.ogg','sound/machines/switch4.ogg'))
GLOBAL_LIST_INIT(button_sound,list('sound/machines/button1.ogg'))
GLOBAL_LIST_INIT(button2_sound,list('sound/machines/button2.ogg'))
GLOBAL_LIST_INIT(chop_sound,list('sound/weapons/chop1.ogg','sound/weapons/chop2.ogg','sound/weapons/chop3.ogg'))
GLOBAL_LIST_INIT(thud_sound,list('sound/effects/impacts/thud1.ogg','sound/effects/impacts/thud2.ogg','sound/effects/impacts/thud3.ogg'))
GLOBAL_LIST_INIT(dooropen_sound,list('sound/machines/airlock_open.ogg','sound/machines/airlock_open2.ogg'))
GLOBAL_LIST_INIT(doorclose_sound,list('sound/machines/airlock_close.ogg','sound/machines/airlock_close2.ogg'))
GLOBAL_LIST_INIT(doorheavyopen_sound,list('sound/machines/airlock_heavy_open.ogg','sound/machines/airlock_heavy_open2.ogg'))
GLOBAL_LIST_INIT(doorheavyclose_sound,list('sound/machines/airlock_heavy_close.ogg','sound/machines/airlock_heavy_close2.ogg'))
GLOBAL_LIST_INIT(interact_sound,list('sound/machines/vending_click.ogg'))
GLOBAL_LIST_INIT(bubble_sound,list('sound/machines/tankbubble1.ogg','sound/machines/tankbubble2.ogg','sound/machines/tankbubble3.ogg'))
GLOBAL_LIST_INIT(bubble_small_sound,list('sound/machines/tanksmallbubble1.ogg','sound/machines/tanksmallbubble2.ogg','sound/machines/tanksmallbubble3.ogg','sound/machines/tanksmallbubble4.ogg'))
GLOBAL_LIST_INIT(fleshtear_sound, list('sound/effects/organic/flesh_tear_1.ogg','sound/effects/organic/flesh_tear_2.ogg','sound/effects/organic/flesh_tear_3.ogg',))


/proc/playsound(var/atom/source, soundin, vol as num, vary, extrarange as num, falloff, var/is_global, var/frequency, var/is_ambiance = 0)




	if(istext(soundin))
		soundin = get_sfx(soundin) // same sound for everyone

	if(isarea(source))
		log_debug("[source] is an area and is trying to make the sound: [soundin]")
		return
	frequency = vary && isnull(frequency) ? get_rand_frequency() : frequency // Same frequency for everybody
	var/turf/turf_source = get_turf(source)

 	// Looping through the player list has the added bonus of working for mobs inside containers
	for (var/P in GLOB.player_list)
		var/mob/M = P
		if(!M || !M.client)
			continue
		if(get_dist(M, turf_source) <= (world.view + extrarange) * 2)
			var/turf/T = get_turf(M)
			if(T && T.z == turf_source.z && (!is_ambiance || M.get_preference_value(/datum/client_preference/play_ambiance) == GLOB.PREF_YES))
				M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, is_global, extrarange)

var/const/FALLOFF_SOUNDS = 0.5

/mob/proc/playsound_local(var/turf/turf_source, soundin, vol as num, vary, frequency, falloff, is_global, extrarange)



	if(!src.client || ear_deaf > 0)	return
	var/sound/S = soundin
	if(!istype(S))
		soundin = get_sfx(soundin)
		S = sound(soundin)
		S.wait = 0 //No queue
		S.channel = 0 //Any channel
		S.volume = vol
		S.environment = -1
		if(frequency)
			S.frequency = frequency
		else if (vary)
			S.frequency = get_rand_frequency()

	//sound volume falloff with pressure
	var/pressure_factor = 1.0

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)



		S.volume -= max(distance - (world.view + extrarange), 0) * 2 //multiplicative falloff to add on top of natural audio falloff.


		var/datum/gas_mixture/hearer_env = T.return_air()
		var/datum/gas_mixture/source_env = turf_source.return_air()

		if (hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())

			if (pressure < ONE_ATMOSPHERE)
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else //in space
			pressure_factor = 0

		if (distance <= 1)
			pressure_factor = max(pressure_factor, 0.15)	//hearing through contact

		S.volume *= pressure_factor


		if (S.volume <= 0)
			return	//no volume means no sound

		var/dx = turf_source.x - T.x // Hearing from the right/left
		S.x = dx
		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = dz
		// The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	if(!is_global)

		if(istype(src,/mob/living/))
			var/mob/living/carbon/M = src
			if (istype(M) && M.hallucination_power > 50 && M.chem_effects[CE_MIND] < 1)
				S.environment = PSYCHOTIC
			else if (M.druggy)
				S.environment = DRUGGED
			else if (M.drowsyness)
				S.environment = DIZZY
			else if (M.confused)
				S.environment = DIZZY
			else if (M.stat == UNCONSCIOUS)
				S.environment = UNDERWATER
			else if (pressure_factor < 0.5)
				S.environment = SPACE
			else
				var/area/A = get_area(src)
				S.environment = A.sound_env

		else if (pressure_factor < 0.5)
			S.environment = SPACE
		else
			var/area/A = get_area(src)
			S.environment = A.sound_env



	src << S



/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_sfx(soundin)
	switch(soundin)
		if ("shatter") soundin = pick(GLOB.shatter_sound)
		if ("explosion") soundin = pick(GLOB.explosion_sound)
		if ("sparks") soundin = pick(GLOB.spark_sound)
		if ("rustle") soundin = pick(GLOB.rustle_sound)
		if ("punch") soundin = pick(GLOB.punch_sound)
		if ("clownstep") soundin = pick(GLOB.clown_sound)
		if ("swing_hit") soundin = pick(GLOB.swing_hit_sound)
		if ("hiss") soundin = pick(GLOB.hiss_sound)
		if ("pageturn") soundin = pick(GLOB.page_sound)
		if ("fracture") soundin = pick(GLOB.fracture_sound)
		if ("light_bic") soundin = pick(GLOB.lighter_sound)
		if ("keyboard") soundin = pick(GLOB.keyboard_sound)
		if ("keystroke") soundin = pick(GLOB.keystroke_sound)
		if ("switch") soundin = pick(GLOB.switch_sound)
		if ("button") soundin = pick(GLOB.button_sound)
		if ("button2") soundin = pick(GLOB.button2_sound)
		if ("chop") soundin = pick(GLOB.chop_sound)
		if ("thud") soundin = pick(GLOB.thud_sound)
		if ("dooropen") soundin = pick(GLOB.dooropen_sound)
		if ("doorclose") soundin = pick(GLOB.doorclose_sound)
		if ("doorheavyopen") soundin = pick(GLOB.doorheavyopen_sound)
		if ("doorheavyclose") soundin = pick(GLOB.doorheavyclose_sound)
		if ("interact") soundin = pick(GLOB.interact_sound)
		if ("bubble") soundin = pick(GLOB.bubble_sound)
		if ("bubble_small") soundin = pick(GLOB.bubble_small_sound)
		if ("fleshtear")	soundin = pick(GLOB.fleshtear_sound)
	return soundin


//Repeating sound support
//This datum is intended to play a sound repeatedly at a given interval over a given duration
//It is not intended for looping audio seamlessly, the sounds can have random gaps between repeats

/*
	Usage:
	To start and immediately play
	var/datum/repeating_sound/mysound = new(30,100,0.15, src, soundfile, 80, 1)

	to stop
	mysound.stop()
	mysound = null (It will qdel itself)

	Pass in a list of soundfiles and one of them will be randomly picked in each iteration.
	They should probably all be around the same length, or at least all <= the smallest interval
*/
/datum/repeating_sound
	//The atom we play the sound from, but we'll use a weak reference instead of holding it in memory
	//To prevent GC issues
	var/source

	//Past this time we will no longer loop and delete ourselves
	var/end_time

	//How often to play
	var/interval

	//Should be in the range 0..1. 0 disables the feature, 1 allows interval to be anywhere from 0-2x the norm
	var/variance

	var/soundin
	var/list/soundlist
	var/vol
	var/vary
	var/extrarange
	var/falloff
	var/is_global
	var/use_pressure
	//Used to stop it early
	var/timer_handle

	var/self_id

/datum/repeating_sound/New(var/_interval, var/duration, var/interval_variance = 0, var/atom/_source, var/_soundin, var/_vol, var/_vary, var/_extrarange, var/_falloff, var/_is_global, var/_use_pressure = TRUE)
	end_time = world.time + duration
	source = "\ref[_source]"
	interval = _interval
	variance = interval_variance
	soundin = _soundin
	if (islist(_soundin))
		soundlist = _soundin
	vol = _vol
	vary = _vary
	extrarange = _extrarange
	falloff = _falloff
	is_global = _is_global
	use_pressure = _use_pressure
	self_id = "\ref[src]"

	//When created we do our first sound immediately
	//If you want the first sound delayed, wrap it in a spawn call or something
	do_sound()


/datum/repeating_sound/proc/do_sound()
	timer_handle = null //This has been successfully called, that handle is no use now

	var/atom/playfrom = locate(source)
	if (QDELETED(playfrom))
		//Our source atom is gone, no more sounds
		stop()
		return

	//We're past the end time, no more sounds
	if (world.time > end_time)
		stop()
		return

	//Actually play the sound
	var/spath = soundin
	world << "Picking spath [spath] 1"
	if (soundlist)

		spath = pick(soundlist)
		world << "Picking spath [spath] 2"
	playsound(playfrom, spath, vol, vary, extrarange, falloff, is_global)

	//Setup the next sound
	var/nextinterval = interval
	if (variance)
		nextinterval *= rand_between(1-variance, 1+variance)

	//Set the next timer handle
	timer_handle = addtimer(CALLBACK(src, .proc/do_sound, TRUE), nextinterval, TIMER_STOPPABLE)



/datum/repeating_sound/proc/stop()
	if (timer_handle)
		deltimer(timer_handle)
	qdel(src)