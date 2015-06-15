/mob/living/carbon/human/movement_delay()
	if(dna)
		. += dna.species.movement_delay(src)

	. += ..()
	. += config.human_delay

	//This part is based on Baycode. |- Ricotez

	//If we're riding in a wheelchair, we need to only check our hands.
	/*
	if(istype(buckled, /obj/structure/bed/chair/wheelchair))
		. += get_penalty_for_limb(/datum/organ/limb/l_arm)
		. += get_penalty_for_limb(/datum/organ/limb/r_arm)
	*/
	//If we're not, we need to check our legs.
	//else
	. += get_penalty_for_limb("l_leg")
	. += get_penalty_for_limb("r_leg")


mob/living/carbon/human/proc/get_penalty_for_limb(limb)
	var/datum/organ/limb/E = organsystem.getorgan(limb)
	//Doubled values because we don't have separate arms/hands and legs/feet yet. Obviously need to be halved once that is the case.
	if(!E || !E.exists())
		. += 8
	if(E.status & ORGAN_SPLINTED)
		. += 1
	else if(E.status & ORGAN_BROKEN)
		. += 3

/mob/living/carbon/human/Process_Spacemove(var/movement_dir = 0)

	if(..())
		return 1

	//Do we have a working jetpack
	if(istype(back, /obj/item/weapon/tank/jetpack) && isturf(loc)) //Second check is so you can't use a jetpack in a mech
		var/obj/item/weapon/tank/jetpack/J = back
		if((movement_dir || J.stabilization_on) && J.allow_thrust(0.01, src))
			return 1
	if(istype(wear_suit, /obj/item/clothing/suit/space/hardsuit) && isturf(loc)) //Second check is so you can't use a jetpack in a mech
		var/obj/item/clothing/suit/space/hardsuit/C = wear_suit
		if(C.jetpack)
			if((movement_dir || C.jetpack.stabilization_on) && C.jetpack.allow_thrust(0.01, src))
				return 1

	return 0


/mob/living/carbon/human/slip(var/s_amount, var/w_amount, var/obj/O, var/lube)
	if(isobj(shoes) && (shoes.flags&NOSLIP) && !(lube&GALOSHES_DONT_HELP))
		return 0
	.=..()

/mob/living/carbon/human/experience_pressure_difference()
	playsound(src, 'sound/effects/space_wind.ogg', 50, 1)
	if(shoes && shoes.flags&NOSLIP)
		return 0
	. = ..()

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return shoes && shoes.negates_gravity()

/mob/living/carbon/human/Move(NewLoc, direct)
	..()
	if(shoes)
		if(!lying)
			if(loc == NewLoc)
				if(!has_gravity(loc))
					return
				var/obj/item/clothing/shoes/S = shoes
				S.step_action()

