//This file is used to contain unique properties of every map, and how we wish to alter them on a per-map basis.
//Use JSON files that match the datum layout and you should be set from there.

/datum/map_config
	// Metadata
	var/config_filename = "maps/colony.json"
	var/defaulted = TRUE  // set to FALSE by LoadConfig() succeeding
	// Config from maps.txt
	var/config_max_users = 0
	var/config_min_users = 0
	var/voteweight = 1
	var/votable = FALSE

	// Config actually from the JSON - should default to Meta
	var/map_name = "The Colony"
	var/map_path = "TheColony"
	var/map_file = list(
		"M.01_Mining_Colony_Underground.dmm",
		"M.02_Mining_Colony.dmm",
		"M.03_Mining_Colony_UpperLevels.dmm",
	)

	var/list/traits = list(
		list(
			"Up" = 1,
			"Baseturf" = /turf/simulated/floor/asteroid/outside_ds,
			"Linkage" = "Cross"
		),
		list(
			"Up" = 1,
			"Down" = -1,
			"Baseturf" = /turf/simulated/open,
			"Linkage" = "Cross"
		),
		list(
			"Down" = -1,
			"Baseturf" = /turf/simulated/open,
			"Linkage" = "Cross"
		)
	)

	var/map_datum = /datum/map/colony
	//Size of the map *2
	var/map_size = 400

/**
 * Proc that simply loads the default map config, which should always be functional.
 */
/proc/load_default_map_config()
	return new /datum/map_config


/**
 * Proc handling the loading of map configs. Will return the default map config using [/proc/load_default_map_config] if the loading of said file fails for any reason whatsoever, so we always have a working map for the server to run.
 * Arguments:
 * * filename - Name of the config file for the map we want to load. The .json file extension is added during the proc, so do not specify filenames with the extension.
 * * directory - Name of the directory containing our .json - Must be in MAP_DIRECTORY_WHITELIST. We default this to MAP_DIRECTORY_MAPS as it will likely be the most common usecase. If no filename is set, we ignore this.
 * * error_if_missing - Bool that says whether failing to load the config for the map will be logged in log_world or not as it's passed to LoadConfig().
 *
 * Returns the config for the map to load.
 */
/proc/load_map_config(filename = null, directory = null, error_if_missing = TRUE)
	var/datum/map_config/config = load_default_map_config()

	if(filename) // If none is specified, then go to look for next_map.json, for map rotation purposes.

		//Default to MAP_DIRECTORY_MAPS if no directory is passed
		if(directory)
			if(!(directory in MAP_DIRECTORY_WHITELIST))
				log_world("map directory not in whitelist: [directory] for map [filename]")
				return config
		else
			directory = MAP_DIRECTORY_MAPS

		filename = "[directory]/[filename].json"
	else
		filename = PATH_TO_NEXT_MAP_JSON


	if (!config.LoadConfig(filename, error_if_missing))
		qdel(config)
		return load_default_map_config()
	return config


#define CHECK_EXISTS(X) if(!istext(json[X])) { log_world("[##X] missing from json!"); return; }

/datum/map_config/proc/LoadConfig(filename, error_if_missing)
	if(!fexists(filename))
		if(error_if_missing)
			log_world("map_config not found: [filename]")
		return

	var/json = file(filename)
	if(!json)
		log_world("Could not open map_config: [filename]")
		return

	json = file2text(json)
	if(!json)
		log_world("map_config is not text: [filename]")
		return

	json = json_decode(json)
	if(!json)
		log_world("map_config is not json: [filename]")
		return

	config_filename = filename

	if(!json["version"])
		log_world("map_config missing version!")
		return

	if(json["version"] != MAP_CURRENT_VERSION)
		log_world("map_config has invalid version [json["version"]]!")
		return

	CHECK_EXISTS("map_datum")
	map_datum = text2path(json["map_datum"])
	//CHECK_EXISTS("map_size")
	map_size = json["map_size"]
	CHECK_EXISTS("map_name")
	map_name = json["map_name"]
	CHECK_EXISTS("map_path")
	map_path = json["map_path"]

	map_file = json["map_file"]
	// "map_file": "MetaStation.dmm"
	if (istext(map_file))
		if (!fexists("maps/[map_path]/[map_file]"))
			log_world("Map file ([map_path]/[map_file]) does not exist!")
			return
	// "map_file": ["Lower.dmm", "Upper.dmm"]
	else if (islist(map_file))
		for (var/file in map_file)
			if (!fexists("maps/[map_path]/[file]"))
				log_world("Map file ([map_path]/[file]) does not exist!")
				return
	else
		log_world("map_file missing from json!")
		return

	traits = json["traits"]
	// "traits": [{"Linkage": "Cross"}, {"Space Ruins": true}]
	if (islist(traits))
		// "Station" is set by default, but it's assumed if you're setting
		// traits you want to customize which level is cross-linked
		for (var/level in traits)
			if (!(ZTRAIT_STATION in level))
				level[ZTRAIT_STATION] = TRUE
	// "traits": null or absent -> default
	else if (!isnull(traits))
		log_world("map_config traits is not a list!")
		return

	if ("job_changes" in json)
		if(!islist(json["job_changes"]))
			log_world("map_config \"job_changes\" field is missing or invalid!")
			return

	defaulted = FALSE
	return TRUE
#undef CHECK_EXISTS

/datum/map_config/proc/GetFullMapPaths()
	if (istext(map_file))
		return list("maps/[map_path]/[map_file]")
	. = list()
	for (var/file in map_file)
		. += "maps/[map_path]/[file]"

/datum/map_config/proc/MakeNextMap()
	return config_filename == PATH_TO_NEXT_MAP_JSON || fcopy(config_filename, PATH_TO_NEXT_MAP_JSON)
