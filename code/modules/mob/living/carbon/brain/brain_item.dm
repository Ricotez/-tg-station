/obj/item/organ/brain
	name = "brain"
	desc = "A piece of juicy meat found in a person's head."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain"
	force = 1.0
	w_class = 2.0
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")
	var/mob/living/carbon/brain/brainmob = null


/obj/item/organ/brain/New()
	..()
	//Shifting the brain "mob" over to the brain object so it's easier to keep track of. --NEO
	spawn(5)
		if(brainmob && brainmob.client)
			brainmob.client.screen.len = null //clear the hud


/**
  * Transfers a person from their original mob to a brainmob inside of this brain.
  * Relies on the organ's owner now, so please call this BEFORE the brain is removed from a mob or the owner var will be set to null.
 **/
/obj/item/organ/brain/proc/transfer_identity()
	if(!owner)
		return
	name = "[H]'s brain"
	brainmob = new(src)
	brainmob.name = owner.real_name
	brainmob.real_name = owner.real_name
	brainmob.dna = owner.dna
	brainmob.timeofhostdeath = owner.timeofdeath
	if(owner.mind)
		owner.mind.transfer_to(brainmob)
	if(organdatum && organdatum.parent) //If the organdatum is not null, this brain is a suborgan. We check for the parent just in case.
		brainmob << "<span class='notice'>You feel slightly disoriented. That's normal when you're just \a [organdatum.parent.getDisplayName()]."
	else
		brainmob << "<span class='notice'>You feel slightly disoriented. That's normal when you're just a brain.</span>"


/obj/item/organ/brain/examine(mob/user)
	..()
	if(brainmob && brainmob.client)
		user << "You can feel the small spark of life still left in this one."
	else
		user << "This one seems particularly lifeless. Perhaps it will regain some of its luster later."


/obj/item/organ/brain/attack(mob/living/carbon/M, mob/user)
	if(!istype(M))
		return ..()

	add_fingerprint(user)

	if(user.zone_sel.selecting != "head")
		return ..()

	var/mob/living/carbon/human/H = M
	if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
		user << "<span class='warning'>You're going to need to remove their head cover first!</span>"
		return

//since these people will be dead M != usr

	var/B = null
	if(M.organsystem)
		var/datum/organ/C = M.getorgan("brain")
		B = C.organitem
	else
		B = M.getorgan(/obj/item/organ/brain)
	if(!B)
		user.drop_item()
		for(var/mob/O in viewers(M, null))
			if(O == (user || M))
				continue
			if(M == user)
				O << "[user] inserts [src] into \his head!"
			else
				O << "[M] has [src] inserted into \his head by [user]."

		if(M != user)
			M << "<span class='notice'>[user] inserts [src] into your head.</span>"
			user << "<span class='notice'>You insert [src] into [M]'s head.</span>"
		else
			user << "<span class='notice'>You insert [src] into your head.</span>"	//LOL

		//this might actually be outdated since barring badminnery, a debrain'd body will have any client sucked out to the brain's internal mob. Leaving it anyway to be safe. --NEO
		if(M.key)
			M.ghostize()

		if(brainmob.mind)
			brainmob.mind.transfer_to(M)
		else
			M.key = brainmob.key

		qdel(brainmob)

		M.internal_organs += src
		if(M.organsystem)
			var/datum/organ/setter = M.getorgan("brain")
			setter.set_organitem(src)
		loc = null

		//Update the body's icon so it doesnt appear debrained anymore
		if(ishuman(M))
			H.update_hair(0)

	else
		..()

/obj/item/organ/brain/alien
	name = "alien brain"
	desc = "We barely understand the brains of terrestial animals. Who knows what we may find in the brain of such an advanced species?"
	icon_state = "brain-alien"
	origin_tech = "biotech=7"

/obj/item/organ/brain/Destroy() //copypasted from MMIs.
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	..()
