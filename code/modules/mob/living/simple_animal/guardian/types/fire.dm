//Fire
/mob/living/simple_animal/hostile/guardian/fire
	a_intent = "help"
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_sound = 'sound/items/Welder.ogg'
	attacktext = "sears"
	damage_coeff = list(BRUTE = 0.8, BURN = 0.8, TOX = 0.8, CLONE = 0.8, STAMINA = 0, OXY = 0.8)
	range = 10
	playstyle_string = "As a Chaos type, you have only light damage resistance, but will ignite any enemy you bump into. In addition, your melee attacks will cause human targets to see everyone as you."
	environment_smash = 1
	magic_fluff_string = "..And draw the Wizard, bringer of endless chaos!"
	tech_fluff_string = "Boot sequence complete. Crowd control modules activated. Holoparasite swarm online."

/mob/living/simple_animal/hostile/guardian/fire/Life() //Dies if the summoner dies
	..()
	if(summoner)
		summoner.ExtinguishMob()
		summoner.adjust_fire_stacks(-20)

/mob/living/simple_animal/hostile/guardian/fire/AttackingTarget()
	if(..())
		if(ishuman(target) && target != summoner)
			spawn(0)
				new /obj/effect/hallucination/delusion(target.loc,target,force_kind="custom",duration=200,skip_nearby=0, custom_icon = src.icon_state, custom_icon_file = src.icon)

/mob/living/simple_animal/hostile/guardian/fire/Crossed(AM as mob|obj)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/Bumped(AM as mob|obj)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/Bump(AM as mob|obj)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/proc/collision_ignite(AM as mob|obj)
	if(istype(AM, /mob/living/))
		var/mob/living/M = AM
		if(!hasmatchingsummoner(M) && M != summoner && M.fire_stacks < 7)
			M.fire_stacks = 7
			M.IgniteMob()
