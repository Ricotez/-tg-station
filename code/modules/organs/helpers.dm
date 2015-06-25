/mob/proc/getorgan()
	return
/mob/living/carbon/getorgan(organ)
	if(organsystem) //If the mob has an organ system, you should give the name of the organ, i.e. "brain"
		return organsystem.getorgan(organ)
	return (locate(organ) in internal_organs) //If the mob does not have an organ system, we fall back on the old system where you give the path, i.e. /obj/item/organ/brain

mob/living/carbon/exists(var/organname)
	if(organsystem)
		var/datum/organ/O = getorgan(organname)
		return O.exists()
	else
		return 1

/mob/proc/getlimb()
	return

/mob/living/carbon/human/getlimb(typepath)
	return (locate(typepath) in organs)

mob/proc/exists(var/organname)
	return 1
