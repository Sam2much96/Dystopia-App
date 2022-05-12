<<<<<<< HEAD
# Dystopia-App-Stabe v1.1.9
''''
Documentation by INhumanity_arts 

''''
FEATURES
(1) Auto Music shuffle:
	This shuffles a selected music playlist (dictionary). It is in the Music singleton and uses the shuffle( function)

(2)Globals.comicbook[1]
	This is a shortcut for calling the comicbook scenes. use the change_scene_to(load(...INSERT ...)) to call it. 
	check for other callable functions and variables in the globals singleton 
(3)Debug
	It calls debug funtions like Debug.start_debug(), Debug.stop_debug(), and passes its variables to the viewport

(4) Fonts, Music and Videos
	I added a couple of new Dynamic Fonts and Music funtions that can be called from the Music track node. A cinematic scene
	was added to handle all video playing functions. (Note: video player works best with .ogv video format)


(5) Ingame Menu:
	This is a reusable ingame menu i added to give access to all major scenes in the App


(6) Custom input maps:
	Added a couple of custom input maps to enable and disable the comics and game menu scenes 

(7) Enemy kill count:

(8) Twitter Login & Comments

(9) Player and Enemy Effects

(10)Touch input maps for android (zoom button), updated Scroll function for comic book 
	Added multitouch gestures for android
	-swipe to change panel
	-Double tap to zoom
(11) Watch Anime:
	  Stream Dystopia Anime from the app

(12)Environment animation

(13)FFmpeg Decoder Libraries from 'https://github.com/kidrigger/godot-videodecoder ' are used in the Anime streaming section. I rendered the
	video in 720p, the game's resolution.

(14) Adaptable Ads
		A part of my partnership with Appodeal, i implemented their SDK, Facebook's SDK, and Admob into the app for mobile builds.
(15) Storing video files and loading video streams are now global functions
		'func GLobals.store_video_files(_body)', and Globals._Video_Stream(node , stream, _sound, viewport). The mobile engine doesn't handle high-res videos well.
(16) I implemented A touch input manager from https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/releases to fix the comics section ux problem
(17) The Project uses a custom AndroidManifest.xml, backup_rule.xml, build.grade and config.gradle scripts to build for android.
-Features to Fix
	-Enemy Animation 
	-Fix up Game's spawnpoints (look at the Exit code in the Temple interior scene)
	-Fix up game's assets and animation
	-auto enemy spawner
	-Idol autosave
	-A better state machine
	-Cinematic video loading code system	
	-changing pages centers new page 
	-Multitouch settings in control
	-Better Combat System
	-Comic placeholder code
	-Joystick code
	-Horizontal Swipe gestures for the Comic placeholder code
	-Auto rotate gestures for the Comic placeholder code
	-Guided view ( Controlled zoom )
	-Pond FX to follow player
	-Game Optimizations
	-Appodeal's SDK integration
-Features to Add
	-Achievement System 
	-Game Vibrations
	-Comic book dialogue system
	-Improve game loading speed
	-Enemy AI (using G.O.A.P)
	-Hints system
	-Expanded Dialogue System (Word bubble system)
	-update control art with new button maps
	-Ingame Tokens	
	-Add multiplayer Network and DLC network code/singleton
	-Shop & Merch Store
	-Guided view system
	-Login UI
	-Mana meter (Ogun meter)
	-NPC_2 Quests
	-New Environment(Create forest environment)
	-Create Dungeon	
	-YouTube load video
	-Global scenes system
	-Spritesheet animation upgrade
	-UI art upgrade
	-Model player & enemy characters (Rig with mixamo)
	-Translate feature using .json files
	-Attack sfx
	-Multiple Languages (localization and dubbing to French and Spanish).
	-Procedurally generated sand dunes
	-Update Game instructionals visuals
	-Throw mechanics for enemy types
	-Inventory system
	-Colour changing joystick
	-Save Email
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
-Bugs to fix
	-Player scent mechanics
	-Debug double instance
	-Form entering breaks
	-GodotAppodeal is broken (lol). I won't bother to fix it
-Builds to Add
	-IOS builds
	-HTML5 build for the comic placeholder
	-
-Building with Ads
	Build with gradle 7.0.2 and upgrade the gradle wrapper and Android Manifest.xml in GodotAppodeal.1.0.1-release.aar
[![Watch a playtest trailer video](https://img.youtube.com/vi/WLTgP-Axb-g/hqdefault.jpg)](https://youtu.be/WLTgP-Axb-g)	
Import and compile with Godot IDE from source with linked libraries. Build with Gradle 7.0.2-all Copy the Android.xml file before compiling and change the gradle wrapper version in /android/build/gradle/wrapper/gradle-wrapper.properties to '7.0.2-all' 
...
distributionUrl = "https\://services.gradle.org/distributions/gradle-7.0.2-all.zip"
...
.
=======

>>>>>>> d773880c57d821ca303684a28b90f394507dabd8
