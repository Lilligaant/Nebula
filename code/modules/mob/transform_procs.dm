/mob/living/carbon/human/proc/monkeyize()
	if (HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/obj/item/W in src)
		if (W==w_uniform) // will be torn
			continue
		drop_from_inventory(W)
	refresh_visible_overlays()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	set_status(STAT_STUN, 1)
	icon = null
	set_invisibility(101)
	for(var/t in get_external_organs())
		qdel(t)
	var/atom/movable/overlay/animation = new /atom/movable/overlay(src)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	flick("h2monkey", animation)
	sleep(48)
	//animation = null

	DEL_TRANSFORMATION_MOVEMENT_HANDLER(src)
	set_status(STAT_STUN, 0)
	UpdateLyingBuckledAndVerbStatus()
	set_invisibility(initial(invisibility))

	if(!species.primitive_form) //If the creature in question has no primitive set, this is going to be messy.
		gib()
		return

	for(var/obj/item/W in src)
		drop_from_inventory(W)
	set_species(species.primitive_form)
	dna.SetSEState(global.MONKEYBLOCK,1)
	dna.SetSEValueRange(global.MONKEYBLOCK,0xDAC, 0xFFF)

	to_chat(src, "<B>You are now [species.name]. </B>")
	qdel(animation)

	return src

/mob/new_player/AIize()
	spawning = 1
	return ..()

/mob/living/carbon/human/AIize(move=1) // 'move' argument needs defining here too because BYOND is dumb
	if (HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/t in get_external_organs())
		qdel(t)
	QDEL_NULL_LIST(worn_underwear)
	return ..(move)

/mob/living/carbon/AIize()
	if (HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(101)
	return ..()

/mob/proc/AIize(move=1)
	if(client)
		sound_to(src, sound(null, repeat = 0, wait = 0, volume = 85, channel = sound_channels.lobby_channel))// stop the jams for AIs


	var/mob/living/silicon/ai/O = new (loc, global.using_map.default_law_type,,1)//No MMI but safety is in effect.
	O.set_invisibility(0)
	O.aiRestorePowerRoutine = 0
	if(mind)
		mind.transfer_to(O)
		O.mind.original = O
	else
		O.key = key

	if(move)
		var/obj/loc_landmark
		for(var/obj/abstract/landmark/start/sloc in global.landmarks_list)
			if (sloc.name != "AI")
				continue
			if (locate(/mob/living) in sloc.loc)
				continue
			loc_landmark = sloc
		if (!loc_landmark)
			for(var/obj/abstract/landmark/tripai in global.landmarks_list)
				if (tripai.name == "tripai")
					if((locate(/mob/living) in tripai.loc) || (locate(/obj/structure/aicore) in tripai.loc))
						continue
					loc_landmark = tripai
		if (!loc_landmark)
			to_chat(O, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.")
			for(var/obj/abstract/landmark/start/sloc in global.landmarks_list)
				if (sloc.name == "AI")
					loc_landmark = sloc
		O.forceMove(loc_landmark ? loc_landmark.loc : get_turf(src))
		O.on_mob_init()

	O.add_ai_verbs()

	O.rename_self("ai",1)
	spawn(0)	// Mobs still instantly del themselves, thus we need to spawn or O will never be returned
		qdel(src)
	return O

//human -> robot
/mob/living/carbon/human/proc/Robotize(var/supplied_robot_type = /mob/living/silicon/robot)
	if (HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	QDEL_NULL_LIST(worn_underwear)
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	refresh_visible_overlays()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(101)
	for(var/t in get_external_organs())
		qdel(t)

	var/mob/living/silicon/robot/O = new supplied_robot_type( loc )

	O.set_gender(gender)
	O.set_invisibility(0)

	if(!mind)
		mind_initialize()
		mind.assigned_role = ASSIGNMENT_ROBOT
	mind.active = TRUE
	mind.transfer_to(O)
	if(O.mind && O.mind.assigned_role == ASSIGNMENT_ROBOT)
		O.mind.original = O
		var/mmi_type = SSrobots.get_mmi_type_by_title(O.mind.role_alt_title ? O.mind.role_alt_title : O.mind.assigned_role)
		if(mmi_type)
			O.mmi = new mmi_type(O)
			O.mmi.transfer_identity(src)

	O.dropInto(loc)
	O.job = ASSIGNMENT_ROBOT
	callHook("borgify", list(O))
	O.Namepick()

	qdel(src) // Queues us for a hard delete
	return O

/mob/living/carbon/human/proc/corgize()
	if (HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	refresh_visible_overlays()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(101)
	for(var/t in get_external_organs())	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/corgi/new_corgi = new /mob/living/simple_animal/corgi (loc)
	new_corgi.a_intent = I_HURT
	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	qdel(src)
	return

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='warning'>Sorry but this mob type is currently unavailable.</span>")
		return

	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)

	refresh_visible_overlays()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(101)

	for(var/t in get_external_organs())
		qdel(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = I_HURT


	to_chat(new_mob, "You suddenly feel more... animalistic.")
	spawn()
		qdel(src)
	return

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='warning'>Sorry but this mob type is currently unavailable.</span>")
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = I_HURT
	to_chat(new_mob, "You feel more... animalistic.")

	qdel(src)

/* Certain mob types have problems and should not be allowed to be controlled by players.
 *
 * This proc is here to force coders to manually place their mob in this list, hopefully tested.
 * This also gives a place to explain -why- players shouldnt be turn into certain mobs and hopefully someone can fix them.
 */
/mob/proc/safe_animal(var/MP)

//Bad mobs! - Remember to add a comment explaining what's wrong with the mob
	if(!MP)
		return 0	//Sanity, this should never happen.

	if(ispath(MP, /mob/living/simple_animal/construct/behemoth))
		return 0 //I think this may have been an unfinished WiP or something. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/armoured))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/wraith))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/builder))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

//Good mobs!
	if(ispath(MP, /mob/living/simple_animal/cat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/corgi))
		return 1
	if(ispath(MP, /mob/living/simple_animal/crab))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/carp))
		return 1
	if(ispath(MP, /mob/living/simple_animal/mushroom))
		return 1
	if(ispath(MP, /mob/living/simple_animal/shade))
		return 1
	if(ispath(MP, /mob/living/simple_animal/tomato))
		return 1
	if(ispath(MP, /mob/living/simple_animal/mouse))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/bear))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/retaliate/parrot))
		return 1

	//Not in here? Must be untested!
	return 0


/mob/living/carbon/human/proc/zombify()
	ChangeToHusk()
	mutations |= MUTATION_CLUMSY
	src.visible_message("<span class='danger'>\The [src]'s skin decays before your very eyes!</span>", "<span class='danger'>Your entire body is ripe with pain as it is consumed down to flesh and bones. You ... hunger. Not only for flesh, but to spread this gift.</span>")
	if (src.mind)
		if (src.mind.assigned_special_role == "Zombie")
			return
		src.mind.assigned_special_role = "Zombie"
	log_admin("[key_name(src)] has transformed into a zombie!")
	SET_STATUS_MAX(src, STAT_WEAK, 5)
	if (should_have_organ(BP_HEART))
		adjust_blood(species.blood_volume - vessel.total_volume)
	for (var/o in get_external_organs())
		var/obj/item/organ/organ = o
		organ.vital = 0
		if (!BP_IS_PROSTHETIC(organ))
			organ.rejuvenate(1)
			organ.max_damage *= 3
			organ.min_broken_damage = FLOOR(organ.max_damage * 0.75)
	verbs += /mob/living/proc/breath_death
	verbs += /mob/living/proc/consume
	playsound(get_turf(src), 'sound/hallucinations/wail.ogg', 20, 1)