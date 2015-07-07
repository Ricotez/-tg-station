/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/hardpoint = "error"			//The name used to save this organ to associative lists. The default is error, to make it easier to spot when an organ does not set this value properly.
	var/mob/owner = null
	var/status = 0
	var/organtype = ORGAN_ORGANIC
	var/status_flags				//Any special status flags set for this organ. Different from var/status in that status is used exclusively for organ-related statuses.
	var/datum/organ/organdatum		//The organdatum this organ is associated with.
	var/list/suborgans = list()
	var/datum/dna/dna = null		//The DNA stored in this organ.

/**
  * Overwrite the DNA stored in this organ.
  * Uses copy_dna to accomplishes this, so nothing will happen to the original DNA.
  * Note that we do not modify the DNA of the suborgans in this proc.
  * @input D: The target DNA to base the overwrite on.
 **/
/obj/item/organ/proc/set_dna(var/datum/dna/D)
	if(!dna)
		dna = new/dna(owner)
		dna.holder_organ = src
	dna.copy_dna(D)

/**
  * Set the owner of this organ and call set_owner on all of its suborgans.
  * Also updates the organsystem.
  * This proc is recursive because if the owner of an organ changes, it also changes for all suborgans.
  * (Cutting off a head also cuts off the brain.)
  *
  * @param O	The new organ owner. Can be null if the organ has no owner.
 **/
/obj/item/organ/proc/set_owner(var/mob/O)
	owner = O
	for(organname in suborgans)
		suborgans[organname].set_owner(O)
		if(O)
			suborgans[organname].organsystem = O.organsystem
		else
			suborgans[organname].organsystem = null

/**
  * Adds a suborgan to the organdatum that corresponds with its hardpoint, but only if there actually exists an organdatum for that hardpoint.
  *
  * @param O	The new organ to be added.
  * @return		Whether the organ was succesfully added. It won't be if the datum doens't exist, or already contains an organ.
 **/
/obj/item/organ/proc/add_suborgan(var/obj/item/O)
	var/datum/organ/hardpoint = suborgans[O.hardpoint]
	if(suborgans[O.list_name])
	var/datum
	suborgans[O.list_name] = O

/obj/item/organ/proc/remove_suborgan(var/name)
	var/obj/item/organ =

/obj/item/organ/heart
	name = "heart"
	hardpoint = "heart"
	icon_state = "heart-on"
	desc = "Some days, your heart is just not in it."
	var/beating = 1

/obj/item/organ/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"

/obj/item/organ/heart/examine(mob/user)
	if(beating)
		user << "It's still beating. Ew"
	else
		user << "It stopped beating."

/obj/item/organ/appendix
	name = "appendix"
	list_name = "appendix"
	icon_state = "appendix"
	desc = "The greyshirt among the organs."
	var/inflamed = 1

/obj/item/organ/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
	else
		icon_state = "appendix"


//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm

//Old Datum Limbs:
// code/modules/unused/limbs.dm


/obj/item/organ/limb
	name = "limb"
	var/body_part = null
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/list/embedded_objects = list()



/obj/item/organ/limb/chest
	name = "chest"
	hardpoint = "chest"
	desc = "Not a treasure chest, sadly."
	icon_state = "chest"
	max_damage = 200
	body_part = CHEST






/obj/item/organ/limb/head
	name = "head"
	hardpoint = "head"
	desc = "What a way to get a-head in life..."
	icon_state = "head"
	max_damage = 200
	body_part = HEAD
	var/mob/living/carbon/brain/brainmob = null //We're not using this until someone is beheaded.

/obj/item/organ/limb/head/examine(mob/user)
	..()
	var/obj/item/brain/B = suborgans("brain")
	if(brain)
		if(brain.brainmob && brain.brainmob.client)
			user << "You see a faint spark of life in their eyes."
		else
			user << "Their eyes are completely lifeless. Perhaps they will regain some of their luster later."
	else
		user << "There's no brain in this head."

/**
  *	Transforms a person into a brainmob. Since the brain will still be inside of the head, we can just use transfer_identity() on the brain.
  * Call this upon beheading someone to properly transfer their mind to their head.
 **/
/obj/item/organ/limb/head/proc/transfer_identity()
	var/obj/item/organ/brain/brain = suborgans["brain"]
	brain.transfer_identity(owner)

/**
  *
 **/
/obj/item/organ/limb/head/attackby(var/obj/item/O as obj, var/mob/user as mob, params) //Copied from MMI
	user.changeNext_move(CLICK_CD_MELEE)
	var/obj/item/organ/brain/brain = suborgans["brain"]
	if(istype(O,/obj/item/organ/brain))
		var/obj/item/organ/brain/newbrain = O
		if("brain" in suborgans)
			user << "<span class='warning'>There's already a brain in this head!</span>"
			return
		if(!newbrain.brainmob)
			user << "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain!</span>"
			return

		visible_message("[user] sticks \a [newbrain] into \the [src].")
		add_suborgan(newbrain)
		newbrain.loc = src
		user.drop_item()

		return

	if(istype(O,/obj/item/weapon/circular_saw))
		if(brain)
			playsound(src.loc, 'sound/weapons/circsawhit.ogg', 100, 1)
			user.visible_message("[user] starts cutting into \the [src] with \the [O].", \
								 "<span class='notice'>You start cutting into \the [src] with \the [O]...</span>", \
								 "<span class='italics'>You hear the sound of a saw.</span>")

			if(do_after(user, 40))
				B = remove_suborgan("brain")
				if(brain)
					user.put_in_hands(B) //Give the brain to the surgeon
					user << "<span class='notice'>You pull the brain out of the head.</span>"
				else
					user << "<span class='notice'>Something else removed the brain before you were done.</span>"

		else
			user << "<span class='notice'>There is no brain in this head!</span>"

	..()

/obj/item/organ/limb/l_arm
	name = "left arm"
	hardpoint = "l_arm"
	desc = "Looks like someone has been disarmed."
	icon_state = "l_arm"
	max_damage = 75
	body_part = ARM_LEFT


/obj/item/organ/limb/l_leg
	name = "left leg"
	hardpoint = "l_arm"
	desc = "Looks like someone's leg legged it."
	icon_state = "l_leg"
	max_damage = 75
	body_part = LEG_LEFT


/obj/item/organ/limb/r_arm
	name = "right arm"
	hardpoint = "r_arm"
	desc = "Looks like someone has been disarmed."
	icon_state = "r_arm"
	max_damage = 75
	body_part = ARM_RIGHT


/obj/item/organ/limb/r_leg
	name = "right leg"
	hardpoint = "r_leg"
	desc = "Looks like someone's leg legged it."
	icon_state = "r_leg"
	max_damage = 75
	body_part = LEG_RIGHT



//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/organ/limb/proc/take_damage(brute, burn)
	if(owner && (owner.status_flags & GODMODE))	return 0	//godmode
	brute	= max(brute,0)
	burn	= max(burn,0)


	if(type == ORGAN_ROBOTIC) //This makes robolimbs not damageable by chems and makes it stronger
		brute = max(0, brute - 5)
		burn = max(0, burn - 4)

	var/can_inflict = max_damage - (brute_dam + burn_dam)
	if(!can_inflict)	return 0

	if((brute + burn) < can_inflict)
		brute_dam	+= brute
		burn_dam	+= burn
	else
		if(brute > 0)
			if(burn > 0)
				brute	= round( (brute/(brute+burn)) * can_inflict, 1 )
				burn	= can_inflict - brute	//gets whatever damage is left over
				brute_dam	+= brute
				burn_dam	+= burn
			else
				brute_dam	+= can_inflict
		else
			if(burn > 0)
				burn_dam	+= can_inflict
			else
				return 0
	return update_organ_icon()


//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/organ/limb/proc/heal_damage(brute, burn, var/robotic)

	if(robotic && type != ORGAN_ROBOTIC) // This makes organic limbs not heal when the proc is in Robotic mode.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	if(!robotic && type == ORGAN_ROBOTIC) // This makes robolimbs not healable by chems.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	brute_dam	= max(brute_dam - brute, 0)
	burn_dam	= max(burn_dam - burn, 0)
	return update_organ_icon()


//Returns total damage...kinda pointless really
/obj/item/organ/limb/proc/get_damage()
	return brute_dam + burn_dam


//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/organ/limb/proc/update_organ_icon()
	if(type == ORGAN_ORGANIC) //Robotic limbs show no damage - RR
		var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
		var/tburn	= round( (burn_dam/max_damage)*3, 1 )
		if((tbrute != brutestate) || (tburn != burnstate))
			brutestate = tbrute
			burnstate = tburn
			return 1
		return 0

//Remove all embedded objects from all limbs on the human mob
/mob/living/carbon/human/proc/remove_all_embedded_objects()
	var/turf/T = get_turf(src)

	for(var/obj/item/organ/limb/L in organs)
		for(var/obj/item/I in L.embedded_objects)
			L.embedded_objects -= I
			I.loc = T

	clear_alert("embeddedobject")

/mob/living/carbon/human/proc/has_embedded_objects()
	. = 0
	for(var/obj/item/organ/limb/L in organs)
		for(var/obj/item/I in L.embedded_objects)
			return 1


//Returns a display name for the organ.
/datum/organ/proc/getDisplayName() //Added "Chest" and "Head" just in case, this may not be needed
	switch(hardpoint)
		if("l_leg")		return "left leg"
		if("r_leg")		return "right leg"
		if("l_arm")		return "left arm"
		if("r_arm")		return "right arm"
		if("chest")     return "chest"
		if("head")		return "head"
		else			return hardpoint