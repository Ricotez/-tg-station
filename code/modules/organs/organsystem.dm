//This is the second part to organdata, but not as important as the organ datums.
//An organsystem is really just a convenient way to define different structures of organs, so you don't have to define them in every mob's constructor individually.
//Creating an organsystem is easy, just look at the examples.
//By the way, remember that these are just the datums, the "reservations" of organ spaces.
//You'll still need to fill them up with actual physical organs in the mob constructor.

//Also, please remember that this system is OPTIONAL. If you don't give a mob an organsystem, it will use the old system with list/organs and list/internal_organs.


/datum/organsystem
	var/list/organlist = new/list()
	var/mob/owner = null
	var/obj/item/organ/coreitem = null		//The item that forms the core of this organsystem. Will usually be the chest.
	var/datum/organ/limb/coredata = null	//The data associated with the core item. Of lesser importance, given that the core item cannot be removed from an organsystem.

	New(var/mob/O)
		owner = O

/datum/organsystem/proc/getorgan(var/name)
	return organlist[name]


/**
  * Set the owner of this organsystem and all organs contained in it.
  * This will recursively go through all organs to ensure their owners are all properly set.
  * @input O: The new owner. Has to be a mob.
 **/
/datum/organsystem/proc/set_owner(var/mob/O)
	owner = O
	core.set_owner(var/mob/O)

/**
  * Override the DNA of all organs in this organsystem.
  *	For example when user injects themselves with a syringe.
  * Note that this proc works iteratively rather than recursively, and changes only the DNA of the organlist.
  *	@input D: The DNA to base the overwrite on.
 **/
/datum/organsystem/proc/set_dna(var/datum/dna/D)
	for(var/limbname in organlist)
		var/datum/organ/organdata = organlist[limbname]
		organdata.set_dna(D)

/datum/organsystem/proc/remove_organ(var/list_name)
	return organlist.Remove(list_name)


/datum/organsystem/Destroy()
	for(var/datum/organ/O in organlist)
		if(O.organitem)
			qdel(O.organitem)
		qdel(O)
	..()

/datum/organsystem/humanoid //All humanoids have the following basic structure.

	New(var/mob/O)
		..(O)
		var/obj/item/organ/current
		coreitem = new/obj/item/organ/limb/chest()
		coredata = new/datum/organ/limb/chest(null, coreitem) //The coredata has no parent, and its item is of course the coreitem.
		core.set_organitem(coreitem)
		organlist["chest"]	= core
		organlist["head"]	= new/datum/organ/limb/head(core, new/obj/item/organ/limb/head())
		organlist["l_arm"]	= new/datum/organ/limb/l_arm(core, new/obj/item/organ/limb/l_arm())
		organlist["r_arm"]	= new/datum/organ/limb/r_arm(core, new/obj/item/ogan/limb/r_arm())
		organlist["l_leg"]	= new/datum/organ/limb/l_leg(core, new/obj/item/organ/limb/l_leg())
		organlist["r_leg"]	= new/datum/organ/limb/r_leg(core, new/obj/item/organ/limb/r_leg())
		var/H = organlist["head"]
		organlist["brain"]	= new/datum/organ/brain(H, new/obj/item/organ/brain())

/datum/organsystem/humanoid/human //Only humans have appendices and hearts.

	New(var/mob/O)
		..(O)
		organlist["appendix"]	= new/datum/organ/appendix(core, new/obj/item/organ/appendix())
		organlist["heart"]		= new/datum/organ/heart(core, new/obj/item/organ/heart())