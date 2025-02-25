#define DEFAULT_SKYBOX_SIZE	736
#define BASE_BUFFER_TILES	15
#define SKYBOX_PADDING	4	// How much larger we want the skybox image to be than client's screen (in turfs)
#define SKYBOX_TURFS	(DEFAULT_SKYBOX_SIZE/WORLD_ICON_SIZE)
/atom/movable/screen/skybox
	name = "skybox"
	mouse_opacity = 0
	icon = null
	appearance_flags = TILE_BOUND|PIXEL_SCALE
	anchored = TRUE
	simulated = FALSE
	screen_loc = "CENTER:-224,CENTER:-224"
	layer = OBJ_LAYER
	plane = SKYBOX_PLANE
	blend_mode = BLEND_MULTIPLY

	var/side_motion
	var/slide_range = -224
	var/scalar = 1

	//Even at the map edge, a mob must always remain this-many tiles from the map edge.
	var/buffer_tiles = 15

	//By default the skybox positions its own lowerleft corner where we point to. So we must additionally offset it by this in both directions to centre it
	var/base_offset = -368

/atom/movable/screen/skybox/proc/scale_to_view(var/view)
	var/matrix/M = matrix()
	// Translate to center the icon over us!
	M.Translate(-(DEFAULT_SKYBOX_SIZE - WORLD_ICON_SIZE) / 2)
	// Scale appropriately based on view size.  (7 results in scale of 1)
	view = text2num(view) || 7 // Sanitize
	M.Scale(((min(MAX_CLIENT_VIEW, view) + SKYBOX_PADDING) * 2 + 1) / SKYBOX_TURFS)
	src.transform = M

/client
	var/atom/movable/screen/skybox/skybox

/client/proc/update_skybox(var/rebuild = FALSE)
	if(!skybox)
		skybox = new()
		screen += skybox
		rebuild = 1

	var/turf/T = get_turf(eye)
	if(T)
		if(rebuild)
			skybox.overlays.Cut()
			skybox.overlays += SSskybox.get_skybox(T.z, max(world.view, view_radius))
			screen |= skybox
			skybox.scalar = view_scalar(view_radius)

			skybox.buffer_tiles = BASE_BUFFER_TILES + view_radius

			//Alright, time for some math. First of all, how big is the skybox image now, in pixels
			var/skybox_side_size = DEFAULT_SKYBOX_SIZE * skybox.scalar

			//Here's the minimum distance in pixels we need to be from the edge, to not-see whitespace
			var/buffer_pixels = (view_radius + 1) * WORLD_ICON_SIZE

			//And here's the farthest we're allowed to slide on both axes before we see whitespace. Inverting it makes math easier
			skybox.slide_range = ((skybox_side_size *0.5) - buffer_pixels)	*-1

			skybox.base_offset = skybox_side_size * -0.5


		//This gets a percentage of how far we are along the side of the map, in a range between 0 to 1
		//Buffer is added to our own position, because we're position+buffer away from the lower sides
		//Buffer is added TWICE to the world maxx/y values, because the percentage is measured as a whole along that line
		//Because of the buffer, neither of the values will ever be 0 or 1
		var/vector2/locpercent = get_new_vector(
		(skybox.buffer_tiles + T.x) / (world.maxx + skybox.buffer_tiles*2),
		(skybox.buffer_tiles + T.y) / (world.maxy + skybox.buffer_tiles*2)
		)

		//Now we double the values and then subtract 1. This rescales it to a value between -1 to 1
		locpercent.SelfMultiply(2)
		locpercent.x -= 1
		locpercent.y -= 1
		skybox.screen_loc = "CENTER:[round(skybox.base_offset + (skybox.slide_range * locpercent.x))],CENTER:[round(skybox.base_offset + (skybox.slide_range* locpercent.y))]"
		release_vector(locpercent)

/mob/Login()
	..()
	client.update_skybox(TRUE)

/mob/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	var/old_z = get_z(src)
	. = ..()
	if(. && client)
		client.update_skybox(old_z != get_z(src))

/mob/forceMove(atom/destination, hardforce, glide_size_override=0)
	var/old_z = get_z(src)

	. = ..()
	if(. && client)
		client.update_skybox(old_z != get_z(src))



