var/global/list/robot_modules = list(
	"Standard"		= /obj/item/robot_module/standard,
	"Service" 		= /obj/item/robot_module/clerical/butler,
	"Clerical" 		= /obj/item/robot_module/clerical/general,
	"Research" 		= /obj/item/robot_module/research,
	"Miner" 		= /obj/item/robot_module/miner,
	"Crisis" 		= /obj/item/robot_module/medical/crisis,
	"Surgeon" 		= /obj/item/robot_module/medical/surgeon,
	"Security" 		= /obj/item/robot_module/security/general,
	"Combat" 		= /obj/item/robot_module/security/combat,
	"Engineering"	= /obj/item/robot_module/engineering/general,
	"Janitor" 		= /obj/item/robot_module/janitor,
	"Party"         = /obj/item/robot_module/uncertified/party
	)

/obj/item/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = ITEM_SIZE_NO_CONTAINER
	item_state = "electronic"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	var/hide_on_manifest = 0
	var/channels = list()
	var/networks = list()
	var/languages = list(
		LANGUAGE_SOL_COMMON = 1,
		LANGUAGE_LUNAR = 1,
		LANGUAGE_UNATHI = 0,
		LANGUAGE_SIIK_MAAS = 0,
		LANGUAGE_SKRELLIAN = 0,
		LANGUAGE_GUTTER = 1,
		LANGUAGE_SIGN = 0,
		LANGUAGE_INDEPENDENT = 1,
		LANGUAGE_SPACER = 1)
	var/sprites = list()
	var/can_be_pushed = 1
	var/no_slip = 0
	var/list/modules = list()
	var/list/datum/matter_synth/synths = list()
	var/obj/item/emag = null
	var/obj/item/borg/upgrade/jetpack = null
	var/list/subsystems = list()
	var/list/obj/item/borg/upgrade/supported_upgrades = list()

	// Bookkeeping
	var/list/original_languages = list()
	var/list/added_networks = list()

/obj/item/robot_module/New(var/mob/living/silicon/robot/R)
	..()
	if (!istype(R))
		return

	R.module = src

	add_camera_networks(R)
	add_languages(R)
	add_subsystems(R)
	apply_status_flags(R)

	if(R.silicon_radio)
		R.silicon_radio.recalculateChannels()

	R.set_module_sprites(sprites)
	R.choose_icon(R.module_sprites.len + 1, R.module_sprites)

	for(var/obj/item/I in modules)
		I.canremove = 0

/obj/item/robot_module/proc/Reset(var/mob/living/silicon/robot/R)
	remove_camera_networks(R)
	remove_languages(R)
	remove_subsystems(R)
	remove_status_flags(R)

	if(R.silicon_radio)
		R.silicon_radio.recalculateChannels()
	R.choose_icon(0, R.set_module_sprites(list("Default" = "robot")))

/obj/item/robot_module/Destroy()
	for(var/module in modules)
		qdel(module)
	for(var/synth in synths)
		qdel(synth)
	modules.Cut()
	synths.Cut()
	qdel(emag)
	qdel(jetpack)
	emag = null
	jetpack = null
	return ..()

/obj/item/robot_module/emp_act(severity)
	if(modules)
		for(var/obj/O in modules)
			O.emp_act(severity)
	if(emag)
		emag.emp_act(severity)
	if(synths)
		for(var/datum/matter_synth/S in synths)
			S.emp_act(severity)
	..()
	return

/obj/item/robot_module/proc/respawn_consumable(var/mob/living/silicon/robot/R, var/rate)
	var/obj/item/flash/F = locate() in src.modules
	if(F)
		if(F.broken)
			F.broken = 0
			F.times_used = 0
			F.icon_state = "flash"
		else if(F.times_used)
			F.times_used--

	if(!synths || !synths.len)
		return

	for(var/datum/matter_synth/T in synths)
		T.add_charge(T.recharge_rate * rate)

/obj/item/robot_module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()
	for(var/obj/O in temp_list)
		if(O)
			modules += O

/obj/item/robot_module/proc/add_languages(var/mob/living/silicon/robot/R)
	// Stores the languages as they were before receiving the module, and whether they could be synthezized.
	for(var/datum/language/language_datum in R.languages)
		original_languages[language_datum] = (language_datum in R.speech_synthesizer_langs)

	for(var/language in languages)
		R.add_language(language, languages[language])

/obj/item/robot_module/proc/remove_languages(var/mob/living/silicon/robot/R)
	// Clear all added languages, whether or not we originally had them.
	for(var/language in languages)
		R.remove_language(language)

	// Then add back all the original languages, and the relevant synthezising ability
	for(var/original_language in original_languages)
		R.add_language(original_language, original_languages[original_language])
	original_languages.Cut()

/obj/item/robot_module/proc/add_camera_networks(var/mob/living/silicon/robot/R)
	if(R.camera && (NETWORK_ROBOTS in R.camera.network))
		for(var/network in networks)
			if(!(network in R.camera.network))
				R.camera.add_network(network)
				added_networks |= network

/obj/item/robot_module/proc/remove_camera_networks(var/mob/living/silicon/robot/R)
	if(R.camera)
		R.camera.remove_networks(added_networks)
	added_networks.Cut()

/obj/item/robot_module/proc/add_subsystems(var/mob/living/silicon/robot/R)
	for(var/subsystem_type in subsystems)
		R.init_subsystem(subsystem_type)

/obj/item/robot_module/proc/remove_subsystems(var/mob/living/silicon/robot/R)
	for(var/subsystem_type in subsystems)
		R.remove_subsystem(subsystem_type)

/obj/item/robot_module/proc/apply_status_flags(var/mob/living/silicon/robot/R)
	if(!can_be_pushed)
		R.status_flags &= ~CANPUSH

/obj/item/robot_module/proc/remove_status_flags(var/mob/living/silicon/robot/R)
	if(!can_be_pushed)
		R.status_flags |= CANPUSH

/obj/item/robot_module/standard
	name = "standard robot module"
	sprites = list(	"Basic" = "robot_old",
					"Android" = "droid",
					"Default" = "robot",
					"Drone" = "drone-standard",
					"Doot" = "eyebot-standard"
				  )

/obj/item/robot_module/standard/New()
	src.modules += new /obj/item/flash(src)
	src.modules += new /obj/item/baton/loaded(src)
	src.modules += new /obj/item/extinguisher(src)
	src.modules += new /obj/item/tool/wrench(src)
	src.modules += new /obj/item/tool/crowbar(src)
	src.modules += new /obj/item/healthanalyzer(src)
	src.emag = new /obj/item/energy/sword(src)
	..()

/obj/item/robot_module/medical
	name = "medical robot module"
	channels = list("Medical" = 1)
	networks = list(NETWORK_MEDICAL)
	subsystems = list(/datum/tgui_module/crew_monitor)
	can_be_pushed = 0

/obj/item/robot_module/medical/surgeon
	name = "surgeon robot module"
	sprites = list(
					"Basic" = "Medbot",
					"Standard" = "surgeon",
					"Advanced Droid" = "droid-medical",
					"Needles" = "medicalrobot",
					"Drone" = "drone-surgery",
					"Doot" = "eyebot-medical"
					)

/obj/item/robot_module/medical/surgeon/New()
	src.modules += new /obj/item/flash(src)
	src.modules += new /obj/item/healthanalyzer(src)
	src.modules += new /obj/item/reagent_containers/borghypo/surgeon(src)
	src.modules += new /obj/item/tool/scalpel/manager(src)
	src.modules += new /obj/item/tool/hemostat(src)
	src.modules += new /obj/item/tool/retractor(src)
	src.modules += new /obj/item/tool/cautery(src)
	src.modules += new /obj/item/bonegel(src)
	src.modules += new /obj/item/FixOVein(src)
	src.modules += new /obj/item/tool/bonesetter(src)
	src.modules += new /obj/item/tool/saw/circular(src)
	src.modules += new /obj/item/tool/surgicaldrill(src)
	src.modules += new /obj/item/gripper/organ(src)
	src.modules += new /obj/item/robot_rack/roller(src, 1)
	src.modules += new /obj/item/shockpaddles/robot(src)
	src.emag = new /obj/item/reagent_containers/spray(src)
	src.emag.reagents.add_reagent(/datum/reagent/acid/triflicacid, 250)
	src.emag.SetName("Triflic Acid spray")

	var/datum/matter_synth/medicine = new /datum/matter_synth/medicine(10000)
	synths += medicine

	var/obj/item/stack/nanopaste/N = new /obj/item/stack/nanopaste(src)
	var/obj/item/stack/medical/advanced/bruise_pack/B = new /obj/item/stack/medical/advanced/bruise_pack(src)
	N.uses_charge = 1
	N.charge_costs = list(1000)
	N.synths = list(medicine)
	B.uses_charge = 1
	B.charge_costs = list(1000)
	B.synths = list(medicine)
	src.modules += N
	src.modules += B

	..()

/obj/item/robot_module/medical/surgeon/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	if(src.emag)
		var/obj/item/reagent_containers/spray/PS = src.emag
		PS.reagents.add_reagent(/datum/reagent/acid/triflicacid, 2 * amount)
	..()

/obj/item/robot_module/medical/crisis
	name = "crisis robot module"
	sprites = list(
					"Basic" = "Medbot",
					"Standard" = "surgeon",
					"Advanced Droid" = "droid-medical",
					"Needles" = "medicalrobot",
					"Drone - Medical" = "drone-medical",
					"Drone - Chemistry" = "drone-chemistry",
					"Doot" = "eyebot-medical"
					)

/obj/item/robot_module/medical/crisis/New()
	src.modules += new /obj/item/tool/crowbar(src)
	src.modules += new /obj/item/flash(src)
	src.modules += new /obj/item/borg/sight/hud/med(src)
	src.modules += new /obj/item/healthanalyzer(src)
	src.modules += new /obj/item/reagent_scanner/adv(src)
	src.modules += new /obj/item/robot_rack/roller(src, 1)
	src.modules += new /obj/item/robot_rack/body_bag(src)
	src.modules += new /obj/item/reagent_containers/borghypo/crisis(src)
	src.modules += new /obj/item/shockpaddles/robot(src)
	src.modules += new /obj/item/reagent_containers/dropper/industrial(src)
	src.modules += new /obj/item/reagent_containers/syringe(src)
	src.modules += new /obj/item/gripper/chemistry(src)
	src.modules += new /obj/item/extinguisher/mini(src)
	src.modules += new /obj/item/taperoll/medical(src)
	src.modules += new /obj/item/inflatable_dispenser/robot(src) // Allows usage of inflatables. Since they are basically robotic alternative to EMTs, they should probably have them.
	src.emag = new /obj/item/reagent_containers/spray(src)
	src.emag.reagents.add_reagent(/datum/reagent/acid/triflicacid, 250)
	src.emag.SetName("Triflic Acid spray")

	var/datum/matter_synth/medicine = new /datum/matter_synth/medicine(15000)
	synths += medicine

	var/obj/item/stack/medical/ointment/O = new /obj/item/stack/medical/ointment(src)
	var/obj/item/stack/medical/bruise_pack/B = new /obj/item/stack/medical/bruise_pack(src)
	var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(src)
	O.uses_charge = 1
	O.charge_costs = list(1000)
	O.synths = list(medicine)
	B.uses_charge = 1
	B.charge_costs = list(1000)
	B.synths = list(medicine)
	S.uses_charge = 1
	S.charge_costs = list(1000)
	S.synths = list(medicine)
	src.modules += O
	src.modules += B
	src.modules += S

	..()

/obj/item/robot_module/medical/crisis/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/reagent_containers/syringe/S = locate() in src.modules
	if(S.mode == 2)
		S.reagents.clear_reagents()
		S.mode = initial(S.mode)
		S.desc = initial(S.desc)
		S.update_icon()

	if(src.emag)
		var/obj/item/reagent_containers/spray/PS = src.emag
		PS.reagents.add_reagent(/datum/reagent/acid/triflicacid, 2 * amount)

	..()


/obj/item/robot_module/engineering
	name = "engineering robot module"
	channels = list("Engineering" = 1)
	networks = list(NETWORK_ENGINEERING)
	subsystems = list(/datum/nano_module/power_monitor, /datum/nano_module/supermatter_monitor)
	supported_upgrades = list(/obj/item/borg/upgrade/rcd)
	sprites = list(
					"Basic" = "Engineering",
					"Antique" = "engineerrobot",
					"Landmate" = "landmate",
					"Landmate - Treaded" = "engiborg+tread",
					"Drone" = "drone-engineer",
					"Doot" = "eyebot-engineering"
					)
	no_slip = 1

/obj/item/robot_module/engineering/general/New()
	src.modules += new /obj/item/flash(src)
	src.modules += new /obj/item/borg/sight/meson(src)
	src.modules += new /obj/item/extinguisher(src)
	src.modules += new /obj/item/tool/weldingtool/advanced(src)
	src.modules += new /obj/item/tool/screwdriver(src)
	src.modules += new /obj/item/tool/wrench(src)
	src.modules += new /obj/item/tool/crowbar(src)
	src.modules += new /obj/item/tool/wirecutters(src)
	src.modules += new /obj/item/tool/multitool(src)
	src.modules += new /obj/item/t_scanner(src)
	src.modules += new /obj/item/analyzer(src)
	src.modules += new /obj/item/geiger(src)
	src.modules += new /obj/item/taperoll/engineering(src)
	src.modules += new /obj/item/taperoll/atmos(src)
	src.modules += new /obj/item/gripper(src)
	src.modules += new /obj/item/lightreplacer(src)
	src.modules += new /obj/item/pipe_painter(src)
	src.modules += new /obj/item/floor_painter(src)
	src.modules += new /obj/item/inflatable_dispenser/robot(src)
	src.emag = new /obj/item/baton/robot/electrified_arm(src)

	var/datum/matter_synth/metal = new /datum/matter_synth/metal(60000)
	var/datum/matter_synth/glass = new /datum/matter_synth/glass(40000)
	var/datum/matter_synth/plasteel = new /datum/matter_synth/plasteel(20000)
	var/datum/matter_synth/wire = new /datum/matter_synth/wire()
	synths += metal
	synths += glass
	synths += plasteel
	synths += wire

	var/obj/item/matter_decompiler/MD = new /obj/item/matter_decompiler(src)
	MD.metal = metal
	MD.glass = glass
	src.modules += MD

	var/obj/item/stack/material/cyborg/steel/M = new (src)
	M.synths = list(metal)
	src.modules += M

	var/obj/item/stack/material/cyborg/glass/G = new (src)
	G.synths = list(glass)
	src.modules += G

	var/obj/item/stack/rods/cyborg/R = new /obj/item/stack/rods/cyborg(src)
	R.synths = list(metal)
	src.modules += R

	var/obj/item/stack/cable_coil/cyborg/C = new /obj/item/stack/cable_coil/cyborg(src)
	C.synths = list(wire)
	src.modules += C

	var/obj/item/stack/tile/floor/cyborg/S = new /obj/item/stack/tile/floor/cyborg(src)
	S.synths = list(metal)
	src.modules += S

	var/obj/item/stack/material/cyborg/glass/reinforced/RG = new (src)
	RG.synths = list(metal, glass)
	src.modules += RG

	var/obj/item/stack/material/cyborg/plasteel/PL = new (src)
	PL.synths = list(plasteel)
	src.modules += PL

	..()

/obj/item/robot_module/engineering/general/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/lightreplacer/LR = locate() in src.modules
	LR.Charge(R, amount)
	..()

/obj/item/robot_module/security
	name = "security robot module"
	channels = list("Security" = 1)
	networks = list(NETWORK_SECURITY)
	subsystems = list(/datum/tgui_module/crew_monitor, /datum/nano_module/digitalwarrant)
	can_be_pushed = 0
	supported_upgrades = list(/obj/item/borg/upgrade/weaponcooler)

/obj/item/robot_module/security/general
	sprites = list(
					"Basic" = "secborg",
					"Red Knight" = "Security",
					"Black Knight" = "securityrobot",
					"Bloodhound" = "bloodhound",
					"Bloodhound - Treaded" = "secborg+tread",
					"Drone" = "drone-sec",
					"Doot" = "eyebot-security",
					"Tridroid" = "orb-security"
				)

/obj/item/robot_module/security/general/New()
	src.modules += new /obj/item/flash(src)
	src.modules += new /obj/item/borg/sight/hud/sec(src)
	src.modules += new /obj/item/handcuffs/cyborg(src)
	src.modules += new /obj/item/baton/robot(src)
	src.modules += new /obj/item/gun/energy/gun/secure/mounted(src)
	src.modules += new /obj/item/taperoll/police(src)
	src.modules += new /obj/item/megaphone(src)
	src.modules += new /obj/item/holowarrant(src)
	src.emag = new /obj/item/gun/energy/laser/mounted(src)
	..()

/obj/item/robot_module/security/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	..()
	var/obj/item/gun/energy/gun/secure/mounted/T = locate() in src.modules
	if(T && T.power_supply)
		if(T.power_supply.charge < T.power_supply.maxcharge)
			T.power_supply.give(T.charge_cost * amount)
			T.update_icon()
		else
			T.charge_tick = 0

	var/obj/item/baton/robot/B = locate() in src.modules
	if(B && B.bcell)
		B.bcell.give(amount)

/obj/item/robot_module/janitor
	name = "janitorial robot module"
	channels = list("Service" = 1)
	sprites = list(
					"Basic" = "JanBot2",
					"Mopbot"  = "janitorrobot",
					"Mop Gear Rex" = "mopgearrex",
					"Drone" = "drone-janitor",
					"Doot" = "eyebot-janitor"
					)

/obj/item/robot_module/janitor/New()
	src.modules += new /obj/item/flash(src)
	src.modules += new /obj/item/soap/nanotrasen(src)
	src.modules += new /obj/item/storage/bag/trash(src)
	src.modules += new /obj/item/mop(src)
	src.modules += new /obj/item/lightreplacer(src)
	src.emag = new /obj/item/reagent_containers/spray(src)
	src.emag.reagents.add_reagent(/datum/reagent/lube, 250)
	src.emag.SetName("Lube spray")
	..()

/obj/item/robot_module/janitor/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	..()
	var/obj/item/lightreplacer/LR = locate() in src.modules
	LR.Charge(R, amount)
	if(src.emag)
		var/obj/item/reagent_containers/spray/S = src.emag
		S.reagents.add_reagent(/datum/reagent/lube, 20 * amount)

/obj/item/robot_module/clerical
	name = "service robot module"
	channels = list("Service" = 1)
	languages = list(
					LANGUAGE_SOL_COMMON	= 1,
					LANGUAGE_UNATHI		= 1,
					LANGUAGE_SIIK_MAAS	= 1,
					LANGUAGE_SIIK_TAJR	= 0,
					LANGUAGE_SKRELLIAN	= 1,
					LANGUAGE_LUNAR	= 1,
					LANGUAGE_GUTTER		= 1,
					LANGUAGE_INDEPENDENT= 1,
					LANGUAGE_SPACER = 1
					)

/obj/item/robot_module/clerical/butler
	sprites = list(	"Waitress" = "Service",
					"Kent" = "toiletbot",
					"Bro" = "Brobot",
					"Rich" = "maximillion",
					"Default" = "Service2",
					"Drone - Service" = "drone-service",
					"Drone - Hydro" = "drone-hydro",
					"Doot" = "eyebot-standard"
					)

/obj/item/robot_module/clerical/butler/New()
	src.modules += new /obj/item/flash(src)
	src.modules += new /obj/item/gripper/service(src)
	src.modules += new /obj/item/reagent_containers/glass/bucket(src)
	src.modules += new /obj/item/material/minihoe(src)
	src.modules += new /obj/item/material/hatchet(src)
	src.modules += new /obj/item/analyzer/plant_analyzer(src)
	src.modules += new /obj/item/storage/plants(src)
	src.modules += new /obj/item/robot_harvester(src)
	src.modules += new /obj/item/material/kitchen/rollingpin(src)
	src.modules += new /obj/item/material/knife(src)

	var/obj/item/rsf/M = new /obj/item/rsf(src)
	M.stored_matter = 30
	src.modules += M

	src.modules += new /obj/item/reagent_containers/dropper/industrial(src)

	var/obj/item/flame/lighter/zippo/L = new /obj/item/flame/lighter/zippo(src)
	L.lit = 1
	src.modules += L

	src.modules += new /obj/item/tray/robotray(src)
	src.modules += new /obj/item/reagent_containers/borghypo/service(src)
	src.emag = new /obj/item/reagent_containers/food/drinks/bottle/small/beer(src)

	var/datum/reagents/R = src.emag.create_reagents(50)
	R.add_reagent(/datum/reagent/chloralhydrate/beer2, 50)
	src.emag.SetName("Mickey Finn's Special Brew")
	..()

/obj/item/robot_module/clerical/general
	name = "clerical robot module"
	channels = list("Service" = 1, "Supply" = 1)
	sprites = list(
					"Waitress" = "Service",
					"Kent" = "toiletbot",
					"Bro" = "Brobot",
					"Rich" = "maximillion",
					"Default" = "Service2",
					"Drone" = "drone-service",
					"Doot" = "eyebot-standard"
					)

/obj/item/robot_module/clerical/general/New()
	src.modules += new /obj/item/flash(src)
	src.modules += new /obj/item/pen/robopen(src)
	src.modules += new /obj/item/form_printer(src)
	src.modules += new /obj/item/gripper/clerical(src)
	src.modules += new /obj/item/hand_labeler(src)
	src.modules += new /obj/item/stamp(src)
	src.modules += new /obj/item/stamp/denied(src)
	src.modules += new /obj/item/destTagger(src)
	src.emag = new /obj/item/stamp/chameleon(src)

	var/datum/matter_synth/package_wrap = new /datum/matter_synth/package_wrap()
	synths += package_wrap

	var/obj/item/stack/package_wrap/cyborg/PW = new /obj/item/stack/package_wrap/cyborg(src)
	PW.synths = list(package_wrap)
	src.modules += PW

	..()

/obj/item/robot_module/general/butler/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	..()
	var/obj/item/reagent_containers/food/condiment/enzyme/E = locate() in src.modules
	E.reagents.add_reagent(/datum/reagent/enzyme, 2 * amount)
	if(src.emag)
		var/obj/item/reagent_containers/food/drinks/bottle/small/beer/B = src.emag
		B.reagents.add_reagent(/datum/reagent/chloralhydrate/beer2, 2 * amount)

/obj/item/robot_module/miner
	name = "miner robot module"
	subsystems = list(/datum/nano_module/supply)
	channels = list("Supply" = 1, "Science" = 1)
	networks = list(NETWORK_MINE)
	sprites = list(
					"Basic" = "Miner_old",
					"Advanced Droid" = "droid-miner",
					"Treadhead" = "Miner",
					"Drone" = "drone-miner",
					"Doot" = "eyebot-miner"
				)
	supported_upgrades = list(/obj/item/borg/upgrade/jetpack)

/obj/item/robot_module/miner/New()
	src.modules += new /obj/item/flash(src)
	src.modules += new /obj/item/borg/sight/meson(src)
	src.modules += new /obj/item/tool/wrench(src)
	src.modules += new /obj/item/tool/screwdriver(src)
	src.modules += new /obj/item/storage/ore(src)
	src.modules += new /obj/item/storage/sheetsnatcher/borg(src)
	src.modules += new /obj/item/gripper/miner(src)
	src.modules += new /obj/item/mining_scanner(src)
	src.modules += new /obj/item/tool/crowbar(src)
	..()

/obj/item/robot_module/research
	name = "research module"
	channels = list("Science" = 1)
	networks = list(NETWORK_RESEARCH)
	sprites = list(
					"Droid" = "droid-science",
					"Drone" = "drone-science",
					"Doot" = "eyebot-science"
					)

/obj/item/robot_module/research/New()
	src.modules += new /obj/item/flash(src)
//	src.modules += new /obj/item/portable_destructive_analyzer(src)
	src.modules += new /obj/item/gripper/research(src)
	src.modules += new /obj/item/gripper/no_use/loader(src)
	src.modules += new /obj/item/robotanalyzer(src)
	src.modules += new /obj/item/card/robot(src)
	src.modules += new /obj/item/tool/wrench(src)
	src.modules += new /obj/item/tool/screwdriver(src)
	src.modules += new /obj/item/tool/weldingtool(src)
	src.modules += new /obj/item/tool/wirecutters(src)
	src.modules += new /obj/item/tool/crowbar(src)
	src.modules += new /obj/item/tool/scalpel/laser(src)
	src.modules += new /obj/item/tool/saw/circular(src)
	src.modules += new /obj/item/extinguisher/mini(src)
	src.modules += new /obj/item/reagent_containers/syringe(src)
	src.modules += new /obj/item/gripper/chemistry(src)

	var/datum/matter_synth/nanite = new /datum/matter_synth/nanite(10000)
	synths += nanite

	var/obj/item/stack/nanopaste/N = new /obj/item/stack/nanopaste(src)
	N.uses_charge = 1
	N.charge_costs = list(1000)
	N.synths = list(nanite)
	src.modules += N

	..()

/obj/item/robot_module/syndicate
	name = "illegal robot module"
	hide_on_manifest = 1
	sprites = list(
					"Dread" = "securityrobot",
				)
	var/id

/obj/item/robot_module/syndicate/New(var/mob/living/silicon/robot/R)
	forceMove(R)
	src.modules += new /obj/item/flash(src)
	src.modules += new /obj/item/energy/sword(src)
	//src.modules += new /obj/item/gun/energy/pulse_rifle/destroyer(src)
	src.modules += new /obj/item/card/emag(src)
	var/jetpack = new/obj/item/tank/jetpack/carbondioxide(src)
	src.modules += jetpack
	R.hud_used.internals = jetpack

	id = R.idcard
	src.modules += id
	..()

/obj/item/robot_module/syndicate/Destroy()
	src.modules -= id
	id = null
	return ..()

/obj/item/robot_module/security/combat
	name = "combat robot module"
	hide_on_manifest = 1
	sprites = list("Combat Android" = "droid-combat")

/obj/item/robot_module/security/combat/New()
	src.modules += new /obj/item/flash(src)
	src.modules += new /obj/item/borg/sight/thermal(src)
	src.modules += new /obj/item/gun/energy/laser/mounted(src)
	src.modules += new /obj/item/borg/combat/shield(src)
	src.modules += new /obj/item/borg/combat/mobility(src)
	src.emag = new /obj/item/gun/energy/lasercannon/mounted(src)
	..()

/obj/item/robot_module/drone
	name = "drone module"
	hide_on_manifest = 1
	no_slip = 1
	networks = list(NETWORK_ENGINEERING)

/obj/item/robot_module/drone/New(var/mob/living/silicon/robot/robot)
	src.modules += new /obj/item/tool/weldingtool(src)
	src.modules += new /obj/item/tool/screwdriver(src)
	src.modules += new /obj/item/tool/wrench(src)
	src.modules += new /obj/item/tool/crowbar(src)
	src.modules += new /obj/item/tool/wirecutters(src)
	src.modules += new /obj/item/tool/multitool(src)
	src.modules += new /obj/item/lightreplacer(src)
	src.modules += new /obj/item/gripper(src)
	src.modules += new /obj/item/soap(src)
	src.modules += new /obj/item/gripper/no_use/loader(src)
	src.modules += new /obj/item/extinguisher/mini(src)
	src.modules += new /obj/item/pipe_painter(src)
	src.modules += new /obj/item/floor_painter(src)
	src.modules += new /obj/item/reagent_containers/spray/cleaner/drone(src)

	robot.hud_used.internals = new/obj/item/tank/jetpack/carbondioxide(src)
	src.modules += robot.hud_used.internals


	var/datum/matter_synth/metal = new /datum/matter_synth/metal(25000)
	var/datum/matter_synth/glass = new /datum/matter_synth/glass(25000)
	var/datum/matter_synth/wood = new /datum/matter_synth/wood(2000)
	var/datum/matter_synth/plastic = new /datum/matter_synth/plastic(1000)
	var/datum/matter_synth/wire = new /datum/matter_synth/wire(30)
	synths += metal
	synths += glass
	synths += wood
	synths += plastic
	synths += wire

	var/obj/item/matter_decompiler/MD = new /obj/item/matter_decompiler(src)
	MD.metal = metal
	MD.glass = glass
	MD.wood = wood
	MD.plastic = plastic
	src.modules += MD

	var/obj/item/stack/material/cyborg/steel/M = new (src)
	M.synths = list(metal)
	src.modules += M

	var/obj/item/stack/material/cyborg/glass/G = new (src)
	G.synths = list(glass)
	src.modules += G

	var/obj/item/stack/rods/cyborg/R = new /obj/item/stack/rods/cyborg(src)
	R.synths = list(metal)
	src.modules += R

	var/obj/item/stack/cable_coil/cyborg/C = new /obj/item/stack/cable_coil/cyborg(src)
	C.synths = list(wire)
	src.modules += C

	var/obj/item/stack/tile/floor/cyborg/S = new /obj/item/stack/tile/floor/cyborg(src)
	S.synths = list(metal)
	src.modules += S

	var/obj/item/stack/material/cyborg/glass/reinforced/RG = new (src)
	RG.synths = list(metal, glass)
	src.modules += RG

	var/obj/item/stack/tile/wood/cyborg/WT = new /obj/item/stack/tile/wood/cyborg(src)
	WT.synths = list(wood)
	src.modules += WT

	var/obj/item/stack/material/cyborg/wood/W = new (src)
	W.synths = list(wood)
	src.modules += W

	var/obj/item/stack/material/cyborg/plastic/P = new (src)
	P.synths = list(plastic)
	src.modules += P
	..()

/obj/item/robot_module/drone/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	..()
	var/obj/item/reagent_containers/spray/cleaner/drone/SC = locate() in src.modules
	SC.reagents.add_reagent(/datum/reagent/space_cleaner, 8 * amount)

/obj/item/robot_module/drone/construction
	name = "construction drone module"
	hide_on_manifest = 1
	channels = list("Engineering" = 1)
	languages = list()

/obj/item/robot_module/drone/construction/New()
	src.modules += new /obj/item/rcd/borg(src)
	..()

/obj/item/robot_module/drone/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/lightreplacer/LR = locate() in src.modules
	LR.Charge(R, amount)
	..()
	return

/obj/item/robot_module/uncertified
	name = "uncertified robot module"
	sprites = list(	"Roller" = "omoikane"
			  )

/obj/item/robot_module/uncertified/party/Initialize()
	name = "Madhouse Productions Official Party Module"
	channels = list("Service" = 1, "Entertainment" = 1)
	networks = list(NETWORK_THUNDER)
	modules += new /obj/item/boombox(src)
	modules += new /obj/item/bikehorn/airhorn(src)
	modules += new /obj/item/party_light(src)

	var/obj/item/gun/launcher/money/MC = new (src)
	MC.receptacle_value = 5000
	MC.dispensing = 100
	modules += MC

	. = ..()