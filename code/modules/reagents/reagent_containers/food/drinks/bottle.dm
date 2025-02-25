///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom

/obj/item/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	force = 5
	var/smash_duration = 5 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/isGlass = 1 //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

	var/obj/item/reagent_containers/glass/rag/rag = null
	var/rag_underlay = "rag"

/obj/item/reagent_containers/food/drinks/bottle/Initialize()
	.=..()
	if(isGlass)
		unacidable = 1

/obj/item/reagent_containers/food/drinks/bottle/Destroy()
	if(rag)
		rag.forceMove(src.loc)
	rag = null
	return ..()

//when thrown on impact, bottles smash and spill their contents
/obj/item/reagent_containers/food/drinks/bottle/throw_impact(atom/hit_atom, var/speed)
	..()

	var/mob/M = thrower
	if(isGlass && istype(M) && M.a_intent != I_HELP)
		var/throw_dist = get_dist(throw_source, loc)
		if(speed > throw_speed || smash_check(throw_dist)) //not as reliable as smashing directly
			if(reagents)
				hit_atom.visible_message("<span class='notice'>The contents of \the [src] splash all over [hit_atom]!</span>")
				reagents.splash(hit_atom, reagents.total_volume)
			src.smash(loc, hit_atom)

/obj/item/reagent_containers/food/drinks/bottle/proc/smash_check(var/distance)
	if(!isGlass || !smash_duration)
		return 0

	var/list/chance_table = list(95, 95, 90, 85, 75, 60, 40, 15) //starting from distance 0
	var/idx = max(distance + 1, 1) //since list indices start at 1
	if(idx > chance_table.len)
		return 0
	return prob(chance_table[idx])

/obj/item/reagent_containers/food/drinks/bottle/proc/smash(var/newloc, atom/against = null)
	//Creates a shattering noise and replaces the bottle with a broken_bottle
	var/obj/item/broken_bottle/B = new /obj/item/broken_bottle(newloc)
	if(prob(33))
		new/obj/item/material/shard(newloc) // Create a glass shard at the target's location!
	B.icon_state = src.icon_state

	var/icon/I = new('icons/obj/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	if(rag && rag.on_fire && isliving(against))
		rag.forceMove(loc)
		var/mob/living/L = against
		L.IgniteMob()

	playsound(src, "shatter", 70, 1)
	src.transfer_fingerprints_to(B)

	qdel(src)
	return B

/obj/item/reagent_containers/food/drinks/bottle/attackby(obj/item/W, mob/user)
	if(!rag && istype(W, /obj/item/reagent_containers/glass/rag))
		insert_rag(W, user)
		return
	if(rag && istype(W, /obj/item/flame))
		rag.attackby(W, user)
		return
	..()

/obj/item/reagent_containers/food/drinks/bottle/attack_self(mob/user)
	if(rag)
		remove_rag(user)
	else
		..()

/obj/item/reagent_containers/food/drinks/bottle/proc/insert_rag(obj/item/reagent_containers/glass/rag/R, mob/user)
	if(!isGlass || rag) return
	if(user.unEquip(R))
		to_chat(user, "<span class='notice'>You stuff [R] into [src].</span>")
		rag = R
		rag.forceMove(src)
		atom_flags &= ~ATOM_FLAG_OPEN_CONTAINER
		update_icon()

/obj/item/reagent_containers/food/drinks/bottle/proc/remove_rag(mob/user)
	if(!rag) return
	user.put_in_hands(rag)
	rag = null
	atom_flags |= ATOM_FLAG_OPEN_CONTAINER
	update_icon()

/obj/item/reagent_containers/food/drinks/bottle/open(mob/user)
	if(rag) return
	..()

/obj/item/reagent_containers/food/drinks/bottle/update_icon()
	underlays.Cut()
	if(rag)
		var/underlay_image = image(icon='icons/obj/drinks.dmi', icon_state=rag.on_fire? "[rag_underlay]_lit" : rag_underlay)
		underlays += underlay_image
		set_light_range(rag.light_range)
		set_light_power(rag.light_power)
		set_light_color(rag.light_color)
		set_light_on(TRUE)
	else
		set_light_on(FALSE)

/obj/item/reagent_containers/food/drinks/bottle/apply_hit_effect(mob/living/target, mob/living/user, var/hit_zone)
	var/blocked = ..()

	if(user.a_intent != I_HURT)
		return
	if(!smash_check(1))
		return //won't always break on the first hit

	// You are going to knock someone out for longer if they are not wearing a helmet.
	var/weaken_duration = 0
	if(blocked < 100)
		weaken_duration = smash_duration + min(0, force - target.getarmor(hit_zone, "melee") + 10)

	var/mob/living/carbon/human/H = target
	if(istype(H) && H.headcheck(hit_zone))
		var/obj/item/organ/affecting = H.get_organ(hit_zone) //headcheck should ensure that affecting is not null
		user.visible_message("<span class='danger'>[user] smashes [src] into [H]'s [affecting.name]!</span>")
		if(weaken_duration)
			target.apply_effect(min(weaken_duration, 5), WEAKEN, blocked) // Never weaken more than a flash!
	else
		user.visible_message("<span class='danger'>\The [user] smashes [src] into [target]!</span>")

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	if(reagents)
		user.visible_message("<span class='notice'>The contents of \the [src] splash all over [target]!</span>")
		reagents.splash(target, reagents.total_volume)

	//Finally, smash the bottle. This kills (qdel) the bottle.
	var/obj/item/broken_bottle/B = smash(target.loc, target)
	user.put_in_active_hand(B)

	return blocked

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/broken_bottle

	name = "Broken Bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9
	throwforce = 5

	throw_range = 5
	item_state = "beer"
	attack_verb = list("stabbed", "slashed", "attacked")
	sharp = 1
	edge = 0
	var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")

/obj/item/broken_bottle/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()


/obj/item/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	center_of_mass = "x=16;y=4"

/obj/item/reagent_containers/food/drinks/bottle/gin/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/gin, 100)

/obj/item/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	center_of_mass = "x=16;y=3"

/obj/item/reagent_containers/food/drinks/bottle/whiskey/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/whiskey, 100)

/obj/item/reagent_containers/food/drinks/bottle/specialwhiskey
	name = "Special Blend Whiskey"
	desc = "Just when you thought regular whiskey was good... This silky, amber goodness has to come along and ruin everything."
	icon_state = "whiskeybottle2"
	center_of_mass = "x=16;y=3"

/obj/item/reagent_containers/food/drinks/bottle/specialwhiskey/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/specialwhiskey, 100)

/obj/item/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Terrans around the galaxy."
	icon_state = "vodkabottle"
	center_of_mass = "x=17;y=3"

/obj/item/reagent_containers/food/drinks/bottle/vodka/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/vodka, 100)

/obj/item/reagent_containers/food/drinks/bottle/tequilla
	name = "Caccavo Guaranteed Quality Tequilla"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequillabottle"
	center_of_mass = "x=16;y=3"

/obj/item/reagent_containers/food/drinks/bottle/tequilla/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/tequilla, 100)

/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing."
	icon_state = "bottleofnothing"
	center_of_mass = "x=17;y=5"

/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/drink/nothing, 100)

/obj/item/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequilla, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	center_of_mass = "x=16;y=6"

/obj/item/reagent_containers/food/drinks/bottle/patron/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/patron, 100)

/obj/item/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	center_of_mass = "x=16;y=8"

/obj/item/reagent_containers/food/drinks/bottle/rum/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/rum, 100)

/obj/item/reagent_containers/food/drinks/bottle/marinerdescent
	name = "Mariner's Descent"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "marinerbottle"
	center_of_mass = "x=16;y=8"

/obj/item/reagent_containers/food/drinks/bottle/marinerdescent/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/space_drugs, 100)

/obj/item/reagent_containers/food/drinks/bottle/holywater
	name = "Flask of Holy Water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	center_of_mass = "x=17;y=10"

/obj/item/reagent_containers/food/drinks/bottle/holywater/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/water/holywater, 100)

/obj/item/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	center_of_mass = "x=17;y=3"

/obj/item/reagent_containers/food/drinks/bottle/vermouth/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/vermouth, 100)

/obj/item/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK!"
	icon_state = "kahluabottle"
	center_of_mass = "x=17;y=3"

/obj/item/reagent_containers/food/drinks/bottle/kahlua/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/coffee/kahlua, 100)

/obj/item/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	center_of_mass = "x=15;y=3"

/obj/item/reagent_containers/food/drinks/bottle/goldschlager/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/goldschlager, 100)

/obj/item/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	center_of_mass = "x=16;y=6"

/obj/item/reagent_containers/food/drinks/bottle/cognac/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/cognac, 100)

/obj/item/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	center_of_mass = "x=16;y=4"

/obj/item/reagent_containers/food/drinks/bottle/wine/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/wine, 100)

/obj/item/reagent_containers/food/drinks/bottle/absinthe
	name = "Jailbreaker Verte"
	desc = "One sip of this and you just know you're gonna have a good time."
	icon_state = "absinthebottle"
	center_of_mass = "x=16;y=6"

/obj/item/reagent_containers/food/drinks/bottle/absinthe/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/absinthe, 100)

/obj/item/reagent_containers/food/drinks/bottle/melonliquor
	name = "Emeraldine Melon Liquor"
	desc = "A bottle of 46 proof Emeraldine Melon Liquor. Sweet and light."
	icon_state = "alco-green" //Placeholder.
	center_of_mass = "x=16;y=6"

/obj/item/reagent_containers/food/drinks/bottle/melonliquor/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/melonliquor, 100)

/obj/item/reagent_containers/food/drinks/bottle/bluecuracao
	name = "Miss Blue Curacao"
	desc = "A fruity, exceptionally azure drink. Does not allow the imbiber to use the fifth magic."
	icon_state = "alco-blue" //Placeholder.
	center_of_mass = "x=16;y=6"

/obj/item/reagent_containers/food/drinks/bottle/bluecuracao/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/bluecuracao, 100)

/obj/item/reagent_containers/food/drinks/bottle/herbal
	name = "Liqueur d'Herbe"
	desc = "A bottle of the seventh-finest herbal liquor sold under a generic name in the galaxy. The back label has a load of guff about the monks who traditionally made this particular variety."
	icon_state = "herbal"
	center_of_mass = "x=16;y=6"

/obj/item/reagent_containers/food/drinks/bottle/herbal/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/herbal, 100)

/obj/item/reagent_containers/food/drinks/bottle/grenadine
	name = "Briar Rose Grenadine Syrup"
	desc = "Sweet and tangy, a bar syrup used to add color or flavor to drinks."
	icon_state = "grenadinebottle"
	center_of_mass = "x=16;y=6"

/obj/item/reagent_containers/food/drinks/bottle/grenadine/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/drink/grenadine, 100)

/obj/item/reagent_containers/food/drinks/bottle/cola
	name = "\improper Space Cola"
	desc = "Cola. in space."
	icon_state = "colabottle"
	center_of_mass = "x=16;y=6"

/obj/item/reagent_containers/food/drinks/bottle/cola/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/drink/space_cola, 100)

/obj/item/reagent_containers/food/drinks/bottle/space_up
	name = "\improper Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up_bottle"
	center_of_mass = "x=16;y=6"

/obj/item/reagent_containers/food/drinks/bottle/space_up/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/drink/space_up, 100)

/obj/item/reagent_containers/food/drinks/bottle/space_mountain_wind
	name = "\improper Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind_bottle"
	center_of_mass = "x=16;y=6"

/obj/item/reagent_containers/food/drinks/bottle/space_mountain_wind/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/drink/spacemountainwind, 100)

/obj/item/reagent_containers/food/drinks/bottle/pwine
	name = "Warlock's Velvet"
	desc = "What a delightful packaging for a surely high quality wine! The vintage must be amazing!"
	icon_state = "pwinebottle"
	center_of_mass = "x=16;y=4"

/obj/item/reagent_containers/food/drinks/bottle/pwine/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/pwine, 100)

//////////////////////////PREMIUM ALCOHOL ///////////////////////
/obj/item/reagent_containers/food/drinks/bottle/premiumvodka
	name = "Four Stripes Quadruple Distilled"
	desc = "Premium distilled vodka imported directly from the Terran Colonial Confederation."
	icon_state = "premiumvodka"
	center_of_mass = "x=17;y=3"

/obj/item/reagent_containers/food/drinks/bottle/premiumvodka/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/vodka/premium, 100)
	var/namepick = pick("Four Stripes","Gilgamesh","Novaya Zemlya","Terran","STS-35")
	var/typepick = pick("Absolut",MATERIAL_GOLD,"Quadruple Distilled","Platinum","Standard")
	name = "[namepick] [typepick]"

/obj/item/reagent_containers/food/drinks/bottle/premiumwine
	name = "Uve De Blanc"
	desc = "You feel pretentious just looking at it."
	icon_state = "premiumwine"
	center_of_mass = "x=16;y=4"

/obj/item/reagent_containers/food/drinks/bottle/premiumwine/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/wine/premium, 100)
	var/namepick = pick("Calumont","Sciacchemont","Recioto","Torcalota")
	var/agedyear = rand(2350,2550)
	name = "Chateau [namepick] De Blanc"
	desc += " This bottle is marked as [agedyear] Vintage."

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/reagent_containers/food/drinks/bottle/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	item_state = "carton"
	center_of_mass = "x=16;y=7"
	isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/orangejuice/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/drink/juice/orange, 100)

/obj/item/reagent_containers/food/drinks/bottle/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	item_state = "carton"
	center_of_mass = "x=16;y=8"
	isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/cream/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/drink/milk/cream, 100)

/obj/item/reagent_containers/food/drinks/bottle/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	item_state = "carton"
	center_of_mass = "x=16;y=8"
	isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/tomatojuice/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/drink/juice/tomato, 100)

/obj/item/reagent_containers/food/drinks/bottle/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	item_state = "carton"
	center_of_mass = "x=16;y=8"
	isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/limejuice/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/drink/juice/lime, 100)

//Small bottles
/obj/item/reagent_containers/food/drinks/bottle/small
	volume = 50
	smash_duration = 1
	atom_flags = 0 //starts closed
	rag_underlay = "rag_small"

/obj/item/reagent_containers/food/drinks/bottle/small/beer
	name = "space beer"
	desc = "Contains only water, malt and hops."
	icon_state = "beer"
	center_of_mass = "x=16;y=12"
/obj/item/reagent_containers/food/drinks/bottle/small/beer/Initialize()
	.=..()
	reagents.add_reagent(/datum/reagent/ethanol/beer, 30)

/obj/item/reagent_containers/food/drinks/bottle/small/ale
	name = "\improper Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	item_state = "beer"
	center_of_mass = "x=16;y=10"
/obj/item/reagent_containers/food/drinks/bottle/small/ale/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/ethanol/ale, 30)

//Probably not the right place for it, but no idea where else to put it without making a brand new DM and slogging through making vars from scratch.

/obj/item/reagent_containers/food/drinks/bottle/oiljug
	name = "oil jug"
	desc = "A plastic jug of engine oil. Not for human consumption."
	icon_state = "oil"
	isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/oiljug/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/lube/oil, 100)




/obj/item/reagent_containers/hypospray/autoinjector/ds_medigel
	name = "medical pack"
	desc = "A standard medi-gel container to treat life threatening injuries."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "ds_medipack"
	starts_with = list(/datum/reagent/ds_medicalgelreagent = 20)
	amount_per_transfer_from_this = 5
	volume = 20

/obj/item/reagent_containers/hypospray/autoinjector/ds_medigel/update_icon()
	return

/obj/item/reagent_containers/hypospray/autoinjector/ds_medigel/small
	name = "small medical pack"
	desc = "A small medi-gel container to treat life threatening injuries."
	starts_with = list(/datum/reagent/ds_medicalgelreagent = 5)
	volume = 5