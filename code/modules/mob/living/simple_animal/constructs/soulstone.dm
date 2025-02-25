#define SOULSTONE_CRACKED -1
#define SOULSTONE_EMPTY 0
#define SOULSTONE_ESSENCE 1

/obj/item/soulstone
	name = "soul stone shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'."
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_BELT
	origin_tech = list(TECH_BLUESPACE = 4, TECH_MATERIAL = 4)

	var/full = SOULSTONE_EMPTY
	var/is_evil = 1
	var/mob/living/simple_animal/shade = null
	var/smashing = 0
	var/soulstatus = null

/obj/item/soulstone/full
	full = SOULSTONE_ESSENCE
	icon_state = "soulstone2"

/obj/item/soulstone/New()
	..()
	shade = new /mob/living/simple_animal/shade(src)

/obj/item/soulstone/Destroy()
	QDEL_NULL(shade)
	return ..()

/obj/item/soulstone/examine(mob/user)
	. = ..()
	if(full == SOULSTONE_EMPTY)
		to_chat(user, "The shard still flickers with a fraction of the full artifact's power, but it needs to be filled with the essence of someone's life before it can be used.")
	if(full == SOULSTONE_ESSENCE)
		to_chat(user,"The shard has gone transparent, a seeming window into a dimension of unspeakable horror.")
	if(full == SOULSTONE_CRACKED)
		to_chat(user, "This one is cracked and useless.")

/obj/item/soulstone/update_icon()
	if(full == SOULSTONE_EMPTY)
		icon_state = "soulstone"
	if(full == SOULSTONE_ESSENCE)
		icon_state = "soulstone2" //TODO: A spookier sprite. Also unique sprites.
	if(full == SOULSTONE_CRACKED)
		icon_state = "soulstone"//TODO: cracked sprite
		SetName("cracked soulstone")

/obj/item/soulstone/attackby(var/obj/item/I, var/mob/user)
	..()
	if(is_evil && istype(I, /obj/item/nullrod))
		to_chat(user, "<span class='notice'>You cleanse \the [src] of taint, purging its shackles to its creator..</span>")
		is_evil = 0
		return
	if(I.force > 10)
		if(!smashing)
			to_chat(user, "<span class='notice'>\The [src] looks fragile. Are you sure you want to smash it? If so, hit it again.</span>")
			smashing = 1
			spawn(20)
				smashing = 0
			return
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [I], and it breaks.[shade.client ? " You hear a terrible scream!" : ""]</span>", "<span class='warning'>You hit \the [src] with \the [I], and it breaks.[shade.client ? " You hear a terrible scream!" : ""]</span>", shade.client ? "You hear a scream." : null)
		set_full(SOULSTONE_CRACKED)

/obj/item/soulstone/attack(var/mob/living/simple_animal/M, var/mob/user)
	if(M == shade)
		to_chat(user, "<span class='notice'>You recapture \the [M].</span>")
		M.forceMove(src)
		return
	if(full == SOULSTONE_ESSENCE)
		to_chat(user, "<span class='notice'>\The [src] is already full.</span>")
		return
	if(M.stat != DEAD && !M.is_asystole())
		to_chat(user, "<span class='notice'>Kill or maim the victim first.</span>")
		return
	for(var/obj/item/W in M)
		M.drop_from_inventory(W)
	M.dust()
	set_full(SOULSTONE_ESSENCE)

/obj/item/soulstone/attack_self(var/mob/user)
	if(full != SOULSTONE_ESSENCE) // No essence - no shade
		to_chat(user, "<span class='notice'>This [src] has no life essence.</span>")
		return

	if(!shade.key) // No key = hasn't been used
		to_chat(user, "<span class='notice'>You cut your finger and let the blood drip on \the [src].</span>")
		user.pay_for_rune(1)
		var/datum/ghosttrap/cult/shade/S = get_ghost_trap("soul stone")
		S.request_player(shade, "The soul stone shade summon ritual has been performed. ")
	else if(!shade.client) // Has a key but no client - shade logged out
		to_chat(user, "<span class='notice'>\The [shade] in \the [src] is dormant.</span>")
		return
	else if(shade.loc == src)
		var/choice = tgui_alert(user, "Would you like to invoke the spirit within?", "Confirmation", list("Yes", "No"))
		if(choice == "Yes")
			shade.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You summon \the [shade].</span>")
		else
			return

/obj/item/soulstone/proc/set_full(var/f)
	full = f
	update_icon()

/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive."

/obj/structure/constructshell/cult
	icon_state = "construct-cult"
	desc = "This eerie contraption looks like it would come alive if supplied with a missing ingredient."

/obj/structure/constructshell/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/soulstone))
		var/obj/item/soulstone/S = I
		if(!S.shade.client)
			to_chat(user, "<span class='notice'>\The [I] has essence, but no soul. Activate it in your hand to find a soul for it first.</span>")
			return
		if(S.shade.loc != S)
			to_chat(user, "<span class='notice'>Recapture the shade back into \the [I] first.</span>")
			return
		var/construct = tgui_alert(user, "Please choose which type of construct you wish to create.", "Choose type", list("Artificer", "Wraith", "Juggernaut"))
		var/ctype
		if(!construct)
			return
		switch(construct)
			if("Artificer")
				ctype = /mob/living/simple_animal/construct/builder
			if("Wraith")
				ctype = /mob/living/simple_animal/construct/wraith
			if("Juggernaut")
				ctype = /mob/living/simple_animal/construct/armoured
		var/mob/living/simple_animal/construct/C = new ctype(get_turf(src))
		C.key = S.shade.key
		//C.cancel_camera()
		if(S.is_evil)
			GLOB.cult.add_antagonist(C.mind)
		qdel(S)
		qdel(src)

#undef SOULSTONE_CRACKED
#undef SOULSTONE_EMPTY
#undef SOULSTONE_ESSENCE
