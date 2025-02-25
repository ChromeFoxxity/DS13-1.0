//Visager's tracks 'Battle!' and 'Miniboss Fight' from the album 'Songs from an Unmade World 2' are available here
//http://freemusicarchive.org/music/Visager/Songs_From_An_Unmade_World_2/ and are made available under the CC BY 4.0 Attribution license,
//which is available for viewing here: https://creativecommons.org/licenses/by/4.0/legalcode


//the king and his court
/mob/living/simple_animal/hostile/retaliate/goat/king
	name = "king of goats"
	desc = "The oldest and wisest of goats; king of his race, peerless in dignity and power. His golden fleece radiates nobility."
	icon_state = "king_goat"
	icon_living = "king_goat"
	icon_dead = "goat_dead"
	speak_emote = list("brays in a booming voice")
	emote_hear = list("brays in a booming voice")
	emote_see = list("stamps a mighty foot, shaking the surroundings")
	meat_amount = 12
	response_help  = "placates"
	response_harm   = "assaults"
	attacktext = "brutalized"
	health = 500
	max_health = 500
	melee_damage_lower = 35
	melee_damage_upper = 55
	mob_size = MOB_LARGE
	can_escape = 1

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2
	name = "emperor of goats"
	desc = "The King of Kings, God amongst men, and your superior in every way."
	icon_state = "king_goat2"
	icon_living = "king_goat2"
	meat_amount = 36
	turns_per_move = 13
	health = 750
	max_health = 750
	melee_damage_lower = 40
	melee_damage_upper = 60
	default_pixel_y = 5
	var/spellscast = 0
	var/phase3 = FALSE
	var/datum/sound_token/boss_theme
	var/sound_id = "goat"
	var/special_attacks = 0

//alright let's get stupid
/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/Initialize()
	. = ..()
	boss_theme = GLOB.sound_player.PlayLoopingSound(src, sound_id, 'sound/music/Visager-Battle.ogg', volume = 10, range = 7, falloff = 4, prefer_mute = TRUE)
	var/matrix/M = new
	M.Scale(1.25)
	transform = M

/mob/living/simple_animal/hostile/retaliate/goat/guard
	name = "honour guard"
	desc = "A very handsome and noble beast."
	icon_state = "goat_guard"
	icon_living = "goat_guard"
	icon_dead = "goat_guard_dead"
	health = 125
	max_health = 125
	turns_per_move = 8
	melee_damage_lower = 10
	melee_damage_upper = 15

/mob/living/simple_animal/hostile/retaliate/goat/guard/master
	name = "master of the guard"
	desc = "A very handsome and noble beast - the most trusted of all the king's men."
	health = 200
	max_health = 200
	turns_per_move = 10
	melee_damage_lower = 15
	melee_damage_upper = 20

/mob/living/simple_animal/hostile/retaliate/goat/king/Retaliate()
	..()
	if(stat == CONSCIOUS && prob(5))
		visible_message("<span class='warning'>\The [src] bellows indignantly, with a judgemental gleam in his eye.</span>")

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/Retaliate()
	..()
	if(spellscast < 5)
		if(prob(5) && speed == 0) //speed buff
			spellscast++
			visible_message("<span class='cult'>\The [src] shimmers and seems to phase in and out of reality itself!</span>")
			speed = -1

		else if(prob(5) && melee_damage_lower != 50) //damage buff
			spellscast++
			visible_message("<span class='cult'>\The [src]' horns grow larger and more menacing!</span>")
			melee_damage_lower = 50

		else if(prob(5)) //stun move
			spellscast++
			visible_message("<span class='cult'>\The [src]' fleece flashes with blinding light!</span>")
			new /obj/item/grenade/flashbang/instant(src.loc) //lol

		else if(prob(5)) //spawn adds
			spellscast++
			visible_message("<span class='cult'>\The [src] calls his imperial guard to his aid!</span>")
			new /mob/living/simple_animal/hostile/retaliate/goat/guard/master(src.loc)
			new /mob/living/simple_animal/hostile/retaliate/goat/guard(src.loc)
			new /mob/living/simple_animal/hostile/retaliate/goat/guard(src.loc)

		else if(prob(5)) //EMP blast
			spellscast++
			visible_message("<span class='cult'>\The [src] disrupts nearby electrical equipment!</span>")
			empulse(get_turf(src), 5, 2, 0)

		else if(prob(5) && damtype == BRUTE && !special_attacks) //elemental attacks
			spellscast++
			if(prob(50))
				visible_message("<span class='cult'>\The [src]' horns flicker with holy white flame!</span>")
				damtype = BURN
			else
				visible_message("<span class='cult'>\The [src]' horns glimmer, electricity arcing between them!</span>")
				damtype = ELECTROCUTE

		else return

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/Life()
	..()
	if(special_attacks >= 3 && damtype != BRUTE)
		visible_message("<span class='cult'>The energy surrounding \the [src]'s horns dissipates.</span>")
		damtype = BRUTE

	if(health <= 150 && !phase3 && spellscast == 5) //begin phase 3, reset spell limit and heal
		phase3 = TRUE
		spellscast = 0
		health = 500
		icon_state = "king_goat3"
		icon_living = "king_goat3"
		visible_message("<span class='cult'>\The [src]' wounds close with a flash, and when he emerges, he's even larger than before!</span>")
		QDEL_NULL(boss_theme)
		boss_theme = GLOB.sound_player.PlayLoopingSound(src, sound_id, 'sound/music/Visager-Miniboss_Fight.ogg', volume = 10, range = 8, falloff = 4, prefer_mute = TRUE)
		var/matrix/M = new
		M.Scale(1.5)
		transform = M
		default_pixel_y = 10

/mob/living/simple_animal/hostile/retaliate/goat/king/proc/OnDeath()
	if(prob(85))
		visible_message("<span class='cult'>\The light radiating from \the [src]' fleece dims...</span>")
	else
		visible_message("<span class='cult'>\The [src] lets loose a terrific wail as its wounds close shut with a flash of light, and its eyes glow even brighter than before!</span>")
		new /mob/living/simple_animal/hostile/retaliate/goat/king/phase2(src.loc)
		Destroy()

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/OnDeath()
	QDEL_NULL(boss_theme)
	if(phase3)
		visible_message("<span class='cult'>\The [src] shrieks as the seal on his power breaks and his wool sheds off!</span>")
		new /obj/item/towel/fleece(src.loc)

/mob/living/simple_animal/hostile/retaliate/goat/king/death()
	..()
	OnDeath()

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/Destroy()
	QDEL_NULL(boss_theme)
	. = ..()

/mob/living/simple_animal/hostile/retaliate/goat/king/UnarmedAttack(mob/living/L)
	..()
	if(prob(5))
		L.Weaken(0.5)
		L.confused += 1
		visible_message("<span class='warning'>\The [L] is bowled over by the impact of [src]'s attack!</span>")

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/UnarmedAttack(mob/living/L)
	..()
	if(damtype != BRUTE)
		special_attacks++