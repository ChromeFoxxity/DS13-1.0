/obj/random/tool
	name = "random tool"
	icon_state = "tool-grey"
	spawn_nothing_percentage = 15
	has_postspawn = TRUE

/obj/random/tool/item_to_spawn()
	return pickweight(list(
				//Screwdrivers
				/obj/item/tool/screwdriver/improvised = 12,
				/obj/item/tool/screwdriver = 8,
				/obj/item/tool/screwdriver/electric = 2,
				/obj/item/tool/screwdriver/combi_driver = 1,
				/obj/item/stack/net/small = 3,
				/obj/item/stack/net/medium = 1,


				//Wirecutters
				/obj/item/tool/wirecutters/improvised = 12,
				/obj/item/tool/wirecutters = 8,
				/obj/item/tool/wirecutters/armature = 2,

				//Welding Tools
				/obj/item/tool/weldingtool/improvised = 12,
				/obj/item/tool/weldingtool = 8,
				/obj/item/tool/weldingtool/advanced = 2,

				/obj/item/tool/omnitool = 0.5,

				/obj/item/tool/crowbar = 12,
				/obj/item/tool/crowbar/improvised = 5,
				/obj/item/tool/crowbar/prybar  = 3,//Pretty uncommon
				/obj/item/tool/crowbar/red = 1,
				/obj/item/tool/crowbar/pneumatic = 2,

				/obj/item/tool/wrench = 8,
				/obj/item/tool/wrench/big_wrench = 2,
				/obj/item/tool/wrench/improvised = 12,

				/obj/item/tool/shovel = 5,
				/obj/item/tool/shovel/spade = 2.5,
				/obj/item/tool/shovel/improvised = 8,

				/obj/item/tool/saw/improvised = 6,
				/obj/item/tool/saw/plasma = 1,

				/obj/item/tool/tape_roll = 12,
				/obj/item/tool/tape_roll/fiber = 2,
				/obj/item/tool/repairkit = 3,
				/obj/item/storage/belt/utility = 5,
				/obj/item/storage/belt/utility/full = 1,
				/obj/item/clothing/gloves/insulated/cheap = 5,
				/obj/item/clothing/head/welding = 5,
				/obj/item/extinguisher = 5,
				/obj/item/t_scanner = 2,
				/obj/item/antibody_scanner = 1,
				/obj/item/destTagger = 1,
				/obj/item/autopsy_scanner = 1,
				/obj/item/gps = 3,
				/obj/item/stack/cable_coil = 5,
				/obj/item/flash = 2,
				/obj/item/mop = 5,
				/obj/item/inflatable_dispenser = 3,
				/obj/item/grenade/chem_grenade/cleaner = 2,
				/obj/item/flashlight = 10,
				/obj/item/tank/jetpack/carbondioxide = 1.5,
				/obj/item/tank/jetpack/oxygen = 1,
				/obj/random/lathe_disk = 10,
				))


//Randomly spawned tools will often be in imperfect condition if they've been left lying out
/obj/random/tool/post_spawn(var/list/spawns)
	if (isturf(loc))
		for (var/obj/O in spawns)
			if (!istype(O, /obj/random) && prob(20))
				O.make_old()


/obj/random/tool/low_chance
	name = "low chance random tool"
	icon_state = "tool-grey-low"
	spawn_nothing_percentage = 60


/obj/random/tool/advanced
	name = "random advanced tool"

/obj/random/tool/advanced/item_to_spawn()
	return pickweight(list(
				/obj/item/tool/screwdriver/combi_driver = 3,
				/obj/item/tool/wirecutters/armature = 3,
				/obj/item/tool/omnitool = 2,
				/obj/item/tool/crowbar/pneumatic = 3,
				/obj/item/tool/wrench/big_wrench = 3,
				/obj/item/tool/weldingtool/advanced = 3,
				/obj/item/tool/saw/advanced_circular = 2,
				/obj/item/tool/saw/chain = 1,
				/obj/item/tool/saw/plasma = 1,
				/obj/item/tool/pickaxe/laser = 2,
				/obj/item/tool/tape_roll/fiber = 2,
				/obj/item/tool/repairkit = 2,
				/obj/item/stack/power_node = 2,
				/obj/item/stack/net/large = 1))

/obj/random/toolbox
	name = "random toolbox"
	desc = "This is a random toolbox."
	icon = 'icons/obj/storage.dmi'
	icon_state = "red"

/obj/random/toolbox/item_to_spawn()
	return pickweight(list(/obj/item/storage/toolbox/mechanical = 30,
				/obj/item/storage/toolbox/electrical = 20,
				/obj/item/storage/toolbox/emergency = 20))

/obj/random/toolbox/low_chance
	name = "low chance random toolbox"
	icon_state = "yellow"
	spawn_nothing_percentage = 60



//Random tool upgrades
/obj/random/tool_upgrade
	name = "random tool modification"

/obj/random/tool_upgrade/item_to_spawn()
	return pickweight(list(
	/obj/item/tool_modification/reinforcement/stick = 1,
	/obj/item/tool_modification/reinforcement/heatsink = 1,
	/obj/item/tool_modification/reinforcement/plating = 1.5,
	/obj/item/tool_modification/reinforcement/guard = 0.75,
	/obj/item/tool_modification/productivity/ergonomic_grip = 1,
	/obj/item/tool_modification/productivity/ratchet = 1,
	/obj/item/tool_modification/productivity/red_paint = 0.75,
	/obj/item/tool_modification/productivity/whetstone = 0.5,
	/obj/item/tool_modification/productivity/diamond_blade = 0.25,
	/obj/item/tool_modification/productivity/oxyjet = 0.75,
	/obj/item/tool_modification/productivity/motor = 0.75,
	/obj/item/tool_modification/refinement/laserguide = 1,
	/obj/item/tool_modification/refinement/stabilized_grip = 1,
	/obj/item/tool_modification/refinement/magbit = 0.75,
	/obj/item/tool_modification/refinement/ported_barrel = 0.5,
	///obj/item/tool_modification/augment/cell_mount = 0.75,//Removed because this codebase only has one cell size
	/obj/item/tool_modification/augment/fuel_tank = 1,
	/obj/item/tool_modification/augment/expansion = 0.25,
	/obj/item/tool_modification/augment/spikes = 1,
	/obj/item/tool_modification/augment/dampener = 0.5,
	/obj/item/stack/power_node = 1))


//A fancier subset of the most desireable upgrades
/obj/random/tool_upgrade/rare/item_to_spawn()
	return pickweight(list(
	/obj/item/tool_modification/reinforcement/guard = 1,
	/obj/item/tool_modification/productivity/ergonomic_grip = 1,
	/obj/item/tool_modification/productivity/red_paint = 1,
	/obj/item/tool_modification/productivity/diamond_blade = 1,
	/obj/item/tool_modification/productivity/motor = 1,
	/obj/item/tool_modification/refinement/laserguide = 1,
	/obj/item/tool_modification/refinement/stabilized_grip = 1,
	/obj/item/tool_modification/augment/expansion = 1,
	/obj/item/tool_modification/augment/dampener = 0.5,
	/obj/item/stack/power_node = 1))


//A tool with several mods pre_installed
/obj/random/tool/modded
	var/list/possible_tools = list(
				//Screwdrivers
				/obj/item/tool/screwdriver/improvised = 12,
				/obj/item/tool/screwdriver = 8,
				/obj/item/tool/screwdriver/electric = 2,
				/obj/item/tool/screwdriver/combi_driver = 1,

				//Wirecutters
				/obj/item/tool/wirecutters/improvised = 12,
				/obj/item/tool/wirecutters = 8,
				/obj/item/tool/wirecutters/armature = 2,

				//Welding Tools
				/obj/item/tool/weldingtool/improvised = 12,
				/obj/item/tool/weldingtool = 8,
				/obj/item/tool/weldingtool/advanced = 2,

				/obj/item/tool/omnitool = 0.5,

				/obj/item/tool/crowbar = 12,
				/obj/item/tool/crowbar/improvised = 5,
				/obj/item/tool/crowbar/prybar  = 3,//Pretty uncommon
				/obj/item/tool/crowbar/red = 1,
				/obj/item/tool/crowbar/pneumatic = 2,

				/obj/item/tool/wrench = 8,
				/obj/item/tool/wrench/big_wrench = 2,
				/obj/item/tool/wrench/improvised = 12,

				/obj/item/tool/shovel = 5,
				/obj/item/tool/shovel/spade = 2.5,
				/obj/item/tool/shovel/improvised = 8,

				/obj/item/tool/saw/improvised = 6,
				/obj/item/tool/saw/plasma = 1
				)


	var/list/possible_mods = list(
	/obj/item/tool_modification/reinforcement/stick = 1,
	/obj/item/tool_modification/reinforcement/heatsink = 1,
	/obj/item/tool_modification/reinforcement/plating = 1.5,
	/obj/item/tool_modification/reinforcement/guard = 0.75,
	/obj/item/tool_modification/productivity/ergonomic_grip = 1,
	/obj/item/tool_modification/productivity/ratchet = 1,
	/obj/item/tool_modification/productivity/red_paint = 0.75,
	/obj/item/tool_modification/productivity/whetstone = 0.5,
	/obj/item/tool_modification/productivity/diamond_blade = 0.25,
	/obj/item/tool_modification/productivity/oxyjet = 0.75,
	/obj/item/tool_modification/productivity/motor = 0.75,
	/obj/item/tool_modification/refinement/laserguide = 1,
	/obj/item/tool_modification/refinement/stabilized_grip = 1,
	/obj/item/tool_modification/refinement/magbit = 0.75,
	/obj/item/tool_modification/refinement/ported_barrel = 0.5,
	/obj/item/tool_modification/augment/fuel_tank = 1,
	/obj/item/tool_modification/augment/expansion = 0.25,
	/obj/item/tool_modification/augment/spikes = 1,
	/obj/item/tool_modification/augment/dampener = 0.5)

/obj/random/tool/modded/spawn_item()
	var/tooltype = pickweight(possible_tools)
	var/obj/item/tool/T = new tooltype(loc)

	//Alright now lets apply mods until we run out or the tool is full
	while (possible_mods.len && LAZYLEN(T.modifications) < T.max_modifications)
		var/modtype = pickweight(possible_mods)
		var/obj/item/tool_modification/TU = new modtype(loc)
		//If the tool doesn't successfully apply, we delete it. Brute force method!
		if (!TU.try_apply(T))
			qdel(TU)

		//Success or fail, remove this mod from the list. we can't have two of the same mod anyway
		possible_mods -= modtype

	return list(T)