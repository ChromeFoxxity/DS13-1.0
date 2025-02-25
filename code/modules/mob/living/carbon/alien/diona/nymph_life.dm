//Dionaea regenerate health and nutrition in light.
/mob/living/carbon/alien/diona/handle_environment(datum/gas_mixture/environment)

	if(health <= 0 || stat == DEAD)
		return

	var/turf/checking = get_turf(src)
	if(!checking)
		return

	var/light_amount = checking.get_lumcount() * 5

	if(radiation <= 20)
		if(last_glow)
			set_light_on(FALSE)
			last_glow = 0
	else
		var/mult = Clamp(radiation/200, 0.5, 1)
		if(last_glow != mult)
			set_light_range(5*mult)
			set_light_power(mult)
			set_light_color("#55ff55")
			set_light_on(TRUE)
			last_glow = mult

	nutrition = Clamp(nutrition + Floor(radiation/100) + light_amount, 0, 500)

	if(radiation >= 50 || light_amount > 2) //if there's enough light, heal
		adjustBruteLoss(-1)
		adjustFireLoss(-1)
		adjustToxLoss(-1)
		adjustOxyLoss(-1)

	if(!client)
		handle_npc(src)
