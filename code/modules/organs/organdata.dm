//IMPORTANT: Think of organdata as a "reservation" for organ spaces in a mob.
//It gives a container type that can stay constant while the actual organ itself changes.
//This system is based on Bay's, so thanks to whichever coder originally designed it.
//But unlike Bay's system, we store most of the organ-related data in physical organs. These datums really are nothing more than "reservations".
// |- Ricotez

/datum/organ
	var/name = "organ"
	var/mob/owner = null
	var/status = ORGAN_REMOVED		//Status of organ. 0 is a normal, human organ, but it starts out at ORGAN_REMOVED in case you want to add empty organ slots to an organsystem. See _DEFINES/organ.dm for possible statuses..
	var/vital = 0					//Whether this organ is vital. Doesn't do anything right now, if it stays that way this can be removed. |- Ricotez
	var/destroyed_dam = 0 			//Amount of (brute) damage to count in damage checks if status of this organ is set to ORGAN_DESTROYED. Only applies to limbs right now. |- Ricotez
	var/can_be_damaged = 0 			//Whether this organ can take damage. Keep this 0 for anything that is not a limb, unless you want to extend the damage system to all organs. |- Ricotez

	var/datum/organ/parent			//The organ this organ is a part of. For example, of this is the brain, its parent will be the head.
	var/list/datum/organ/children	//The organs that are a part of this organ. For example, if this is the chest, its children will contain arms, legs and probably also a heart and appendix.

	var/organitem_type = /obj/item/organ	//Typepath of the organ item(s) this datum may be associated with.
	var/obj/item/organ/organitem			//The actual physical organ item this datum is associated with.

/datum/organ/proc/get_icon(var/icon/race_icon, var/icon/deform_icon)
	return icon('icons/mob/human.dmi',"blank")


/datum/organ/New(var/datum/organ/P)
	if(P)
		parent = P
		if(!parent.children)
			parent.children = list()
		parent.children.Add(src)
	return ..()

/datum/organ/proc/remove_organitem() //Use this for surgical removal of an organ. Don't forget to do something about the organitem.
	status = ORGAN_REMOVED
	var/obj/item/organ/O = organitem
	organitem = null
	return O

/datum/organ/proc/destroy_organitem() //Use this for forceful removal of an organ. Does not actually destroy the organ, you will have to qdel the return value for that.
	status = ORGAN_DESTROYED
	var/obj/item/organ/O = organitem
	organitem = null
	return O

/datum/organ/proc/set_organitem(var/obj/item/organ/O) //Sets this organ's organitem, but only if it does not already have an organitem.
	if(O && !organitem && istype(O, organitem_type))
		organitem = O
		status = organitem.status

/datum/organ/proc/exists() //Decide whether this organ has a pysical representation in the body right now.
	return organitem && !(status & ORGAN_DESTROYED) && !(status & ORGAN_REMOVED)
	//Usually it's enough to just check if an organitem is there, because it should be removed iff ORGAN_DESTROYED or ORGAN_REMOVED are true.
	//But in case you want to test something, you can also just set a limb's status to ORGAN_DESTROYED or ORGAN_REMOVED by varediting it without removing the physical item.
	//As far as the code is concerned, the limb is missing if either of those are true.


/datum/organ/brain
	name = "brain"
	vital = 1
	organitem_type = /obj/item/organ/brain

/datum/organ/heart
	name = "heart"
	vital = 1
	organitem_type = /obj/item/organ/heart

/datum/organ/appendix
	name = "appendix"
	organitem_type = /obj/item/organ/appendix