<<<<<<< HEAD
# Dystopia-App-Stable v1.1.9 Alpha c

## Synopsis

Changing the World? Sigh. A very lofty dream. It is a feat few men ever really achieve, it's an idea that infects men to hope, fight, kill and to die. It was for this dream we hoped, fought , killed, starved, bled and died for in a hellish war that lasted 5 years. After fighting for so long, in the end you lose sight of what you're really fighting for; and when you lose someone you love, all those lofty dreams you fought so valiantly for suddenly lose meaning. After all, what's the point of changing the world, when you have no one left to share it with. 

## What It Does
Its a web 3.0 multimedia app with Top down RPG action game, Comics and Animated Short films, built on Decentralized storage and telling the story of 3 protagonists. It's available for mobile and PC platforms.



## Documentation by INhumanity_arts 

![Screenshot](https://github.com/Sam2much96/Dystopia-App/blob/master/source_code/resources/illustrations/cover%201.png)


## FEATURES
**(1) Auto Music shuffle:**
	This shuffles a selected music playlist (dictionary). It is in the Music singleton and uses the shuffle( function)

**(2)Globals.comicbook[1]:**
   This is a shortcut for calling the comicbook scenes. use the change_scene_to(load(...INSERT ...)) to call it. 
  check for other callable functions and variables in the globals singleton 
**(3)Debug**
	It calls debug funtions like Debug.start_debug(), Debug.stop_debug(), and passes its variables to the viewport

**(4) Fonts, Music and Videos**
	I added a couple of new Dynamic Fonts and Music funtions that can be called from the Music track node. A cinematic scene
	was added to handle all video playing functions. (Note: video player works best with .ogv video format)


**(5) Ingame Menu:**
	This is a reusable ingame menu i added to give access to all major scenes in the App


**(6) Custom input maps:**
	Added a couple of custom input maps to enable and disable the comics and game menu scenes 

**(7) Enemy kill count:**
	This is a global variable that can be an indicator of player's progress

**(8) Twitter** 

(9) Player and Enemy Effects

#(10)Touch input maps for android (zoom button), updated Scroll function for comic book 
	Added multitouch gestures for android
	-swipe to change panel
	-Double tap to zoom
**(11) Stream Animated Shorts:**
	  Stream Dystopia Anime from the app & Youtube

**(12) Interractive Environment**

**(13)FFmpeg Decoder Libraries** from 'https://github.com/kidrigger/godot-videodecoder ' are used in the Anime streaming section. I rendered the video in 720p, the game's resolution.

(14) Adaptable Ads: (depreciated)

(16) Touch input manager from https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/releases to fix the comics section ux problem
**(17) Web 3.0 functionalities**
	-Ingame Algorand Wallet (testnet)
	-NFT image parser
	-Transaction capabilities for assets and Tokens (Testnet)

**(18) Download Images, Documents and Videos:** Networking.download_image_(image url, image save path): Downloads a png image from a url and saves it at a given path 
## -Features to Fix
	
	-Fix up Game's spawnpoints (look at the Exit code in the Temple interior scene)	
	-changing pages centers new page 
	-Multitouch settings in control
	-Better Combat System
	-Comic placeholder code
	-Horizontal Swipe gestures for the Comic placeholder code
	-Auto rotate gestures for the Comic placeholder code
	-Guided view ( Controlled zoom )
	
	-Game Optimizations
	-Appodeal's SDK integration
	
	-Better Scene loading management system via global functions
	- Translation (Spanish, French, Yoruba)
## -Features to Add
	
	-Game Vibrations
	-Comic book dialogue system
	-Enemy AI (using G.O.A.P)
	-Hints system
	-Expanded Dialogue System (Word bubble system)
	-update control art with new button maps
	-Shop & Merch Store
	-Guided view system
	-Mana meter (Ogun meter)
	-NPC_2 Quests
	-New Environment(Create forest environment)
	-Create Dungeon	
	-Spritesheet animation upgrade
	-Model player & enemy characters (Rig with mixamo)
	-Translate feature using .json files
	-Multiple Languages (localization and dubbing to French and Spanish).
	-Procedurally generated sand dunes
	-Update Game instructionals visuals
	-Throw mechanics for enemy types
	-Inventory system
	-Colour changing joystick
	-Create Dungeons
	-Sandbox mechanics
	-Polygon 2d to deconstruct comic panels
	-Host game server with
		-Apache
		-SSL
		-Net tools
		-Port Forwarding
	-Reprogrammable joystick
	-Ads
		-Interstitial Ads at the end of comic book page
		-Video ads inbetwen the pilot 
		-Banner Ads over video footage

## -3rd Party Integrations
	-Admob publishing ID replacements
	-Ad integrations

