///////////////////////////////////
// POWERS
///////////////////////////////////

/datum/dna/gene/basic/nobreath
	name="No Breathing"
	activation_messages=list("You feel no need to breathe.")
	mutation=mNobreath

/datum/dna/gene/basic/nobreath/New()
	block=GLOB.NOBREATHBLOCK

/datum/dna/gene/basic/remoteview
	name="Remote Viewing"
	activation_messages=list("Your mind expands.")
	mutation=mRemote

/datum/dna/gene/basic/remoteview/New()
	block=GLOB.REMOTEVIEWBLOCK

/datum/dna/gene/basic/remoteview/activate(mob/M, connected, flags)
	..(M,connected,flags)
	add_verb(M, /mob/living/carbon/human/proc/remoteobserve)

/datum/dna/gene/basic/regenerate
	name="Regenerate"
	activation_messages=list("You feel better.")
	mutation=mRegen

/datum/dna/gene/basic/regenerate/New()
	block=GLOB.REGENERATEBLOCK

/datum/dna/gene/basic/increaserun
	name="Super Speed"
	activation_messages=list("Your leg muscles pulsate.")
	mutation=mRun

/datum/dna/gene/basic/increaserun/New()
	block=GLOB.INCREASERUNBLOCK

/datum/dna/gene/basic/remotetalk
	name="Telepathy"
	activation_messages=list("You expand your mind outwards.")
	mutation=mRemotetalk

/datum/dna/gene/basic/remotetalk/New()
	block=GLOB.REMOTETALKBLOCK

/datum/dna/gene/basic/remotetalk/activate(mob/M, connected, flags)
	..(M,connected,flags)
	add_verb(M, /mob/living/carbon/human/proc/remotesay)

/datum/dna/gene/basic/morph
	name="Morph"
	activation_messages=list("Your skin feels strange.")
	mutation=mMorph

/datum/dna/gene/basic/morph/New()
	block=GLOB.MORPHBLOCK

/datum/dna/gene/basic/morph/activate(var/mob/M)
	..(M)
	add_verb(M, /mob/living/carbon/human/proc/morph)

/* Not used on bay
/datum/dna/gene/basic/heat_resist
	name="Heat Resistance"
	activation_messages=list("Your skin is icy to the touch.")
	mutation=mHeatres

	New()
		block=GLOB.COLDBLOCK

	can_activate(var/mob/M,var/flags)
		if(flags & MUTCHK_FORCED)
			return !(/datum/dna/gene/basic/cold_resist in M.active_genes)
		// Probability check
		var/_prob = 15
		if(COLD_RESISTANCE in M.mutations)
			_prob=5
		if(probinj(_prob,(flags&MUTCHK_FORCED)))
			return 1

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "cold[fat]_s"
*/

/datum/dna/gene/basic/cold_resist
	name="Cold Resistance"
	activation_messages=list("Your body is filled with warmth.")
	mutation=COLD_RESISTANCE

	New()
		block=GLOB.FIREBLOCK

	can_activate(var/mob/M,var/flags)
		if(flags & MUTCHK_FORCED)
			return 1
		//	return !(/datum/dna/gene/basic/heat_resist in M.active_genes)
		// Probability check
		var/_prob=30
		//if(mHeatres in M.mutations)
		//	_prob=5
		if(probinj(_prob,(flags&MUTCHK_FORCED)))
			return 1

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "fire[fat]_s"

/datum/dna/gene/basic/noprints
	name="No Prints"
	activation_messages=list("Your fingers feel numb.")
	mutation=mFingerprints

	New()
		block=GLOB.NOPRINTSBLOCK

/datum/dna/gene/basic/noshock
	name="Shock Immunity"
	activation_messages=list("Your skin feels strange.")
	mutation=mShock

	New()
		block=GLOB.SHOCKIMMUNITYBLOCK

/datum/dna/gene/basic/midget
	name="Midget"
	activation_messages=list("Your skin feels rubbery.")
	mutation=mSmallsize

	New()
		block=GLOB.SMALLSIZEBLOCK

	can_activate(var/mob/M,var/flags)
		// Can't be big and small.
		if(HULK in M.mutations)
			return 0
		return ..(M,flags)

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.pass_flags |= 1

	deactivate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.pass_flags &= ~1 //This may cause issues down the track, but offhand I can't think of any other way for humans to get passtable short of varediting so it should be fine. ~Z

/datum/dna/gene/basic/hulk
	name="Hulk"
	activation_messages=list("Your muscles hurt.")
	mutation=HULK

	New()
		block=GLOB.HULKBLOCK

	can_activate(var/mob/M,var/flags)
		// Can't be big and small.
		if(mSmallsize in M.mutations)
			return 0
		return ..(M,flags)

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		if(fat)
			return "hulk_[fat]_s"
		else
			return "hulk_[g]_s"

	OnMobLife(var/mob/living/carbon/human/M)
		if(!istype(M)) return
		if(M.health <= 25)
			M.mutations.Remove(HULK)
			M.update_mutations()		//update our mutation overlays
			to_chat(M, "<span class='warning'>You suddenly feel very weak.</span>")
			M.Weaken(3)
			M.emote("collapse")

/datum/dna/gene/basic/xray
	name="X-Ray Vision"
	activation_messages=list("The walls suddenly disappear.")
	mutation=XRAY

	New()
		block=GLOB.XRAYBLOCK

/datum/dna/gene/basic/tk
	name="Telekenesis"
	activation_messages=list("You feel smarter.")
	mutation=TK
	activation_prob=15

	New()
		block=GLOB.TELEBLOCK
	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "telekinesishead[fat]_s"
