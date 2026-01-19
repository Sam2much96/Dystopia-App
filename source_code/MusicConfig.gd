extends Resource
class_name MusicConfig

# All music and sfx configuration in a separate resources file

# each of the tile id's and fuunctions
#add more controls to this script, it breaks the singleton
export (bool) var enable 
export (bool) var sfx_on
#export (int) var volume # volume controller code is not yet written
export (int) var play_back_position : int
export (int) var track_length : int

export(String, FILE, "*.ogg") var music_track : String = ""

	
	


export (Dictionary) var default_playlist : Dictionary ={
	0:"res://music/The Road Warrior.ogg",
	1:"res://music/Astrolife chike san.ogg",
	2:"res://music/chike san afro 1.ogg",
	3:"res://music/chike san afro 2.ogg",
	4:"res://music/chike san afro 3.ogg",
	5:"res://music/paranoia.ogg",
	6: "res://music/Inhumanity Game Track 3.ogg",
	7: "res://music/Track 1-1.ogg",
	8:"res://music/Marble Tower 4.ogg",
	9:"res://music/Camel.ogg",
	10:"res://music/Death Temple.ogg"
}



export (Dictionary) var comic_sfx : Dictionary = {
	0: 'res://sounds/book_flip.1.ogg',
	1:'res://sounds/book_flip.10.ogg',
	2:'res://sounds/book_flip.2.ogg',
	3:'res://sounds/book_flip.3.ogg',
	4:'res://sounds/book_flip.4.ogg',
	5:'res://sounds/book_flip.5.ogg',
	6:'res://sounds/book_flip.6.ogg',
	7:'res://sounds/book_flip.7.ogg',
	8:'res://sounds/book_flip.8.ogg',
	9:'res://sounds/book_flip.9.ogg'
}

export (Dictionary) var ui_sfx : Dictionary = {
	0:'res://sounds/Menu1A.ogg',
	1:'res://sounds/Menu1B.ogg',
}


export (Dictionary) var item_use_sfx : Dictionary = {
	0: "res://sounds/item_collected.ogg"
}

export (Dictionary) var blood_fx : Dictionary = {
	0 :"res://sounds/blood-spilling.ogg" 
	
}

export (Dictionary) var hit_sfx : Dictionary = {
	0:'res://sounds/Dragon Ball Z Punch Sound Effect N°9.wav',
	1:'res://sounds/Dragon Ball Z Punch Sound Effect N°10.wav',
	2:'res://sounds/Dragon Ball Z Punch Sound Effect N°11.wav',
	3:'res://sounds/Dragon Ball Z Punch Sound Effect N°12.wav',
	4:'res://sounds/Dragon Ball Z Punch Sound Effect N°13.wav',
	5:'res://sounds/Dragon Ball Z Punch Sound Effect N°14.wav',
	6:'res://sounds/Dragon Ball Z Punch Sound Effect N°15.wav',
	7:'res://sounds/Dragon Ball Z Punch Sound Effect N°16.wav',
	8:'res://sounds/Dragon Ball Z Punch Sound Effect N°17.wav',
	9:'res://sounds/Dragon Ball Z Punch Sound Effect N°18.wav',
	10:'res://sounds/Dragon Ball Z Punch Sound Effect N°19.wav',
	11:'res://sounds/Dragon Ball Z Punch Sound Effect N°20.wav',
	12:'res://sounds/Dragon Ball Z Punch Sound Effect N°21.wav',
	13:'res://sounds/Dragon Ball Z Punch Sound Effect N°22.wav',
	14:'res://sounds/Dragon Ball Z Punch Sound Effect N°23.wav',
	15:'res://sounds/Dragon Ball Z Punch Sound Effect N°24.wav',
	16:'res://sounds/Dragon Ball Z Punch Sound Effect N°25.wav'

}

export (Dictionary) var grass_sfx : Dictionary  = {0:'res://sounds/Fantozzi-SandR3.ogg'}

export (Dictionary) var wind_sfx : Dictionary = {
	0:'res://sounds/wind_2.ogg',
	1: 'res://sounds/gogeta-gogeta-instant-teleportation-sound-effect.ogg'
	}

export (Dictionary) var sword_sfx : Dictionary = {
	0 : "res://sounds/Dragon Ball Z Trunks Sword In Sound Effect n°2.wav",
	1 : "res://sounds/Dragon Ball Z Trunks Sword In Sound Effect n°4.wav",
	2 : "res://sounds/Dragon Ball Z Trunks Sword Out Sound Effect n°1.wav",
	3 : "res://sounds/Dragon Ball Z Trunks Sword Slash Sound Effect n°4.wav",
	4 : "res://sounds/Dragon Ball Z Trunks Sword Slash Sound Effect n°5.wav",
	5 : "res://sounds/Dragon Ball Z Trunks Sword Slash Sound Effect n°6.wav",
	6 : "res://sounds/Dragon Ball Z Trunks Sword Slash Sound Effect n°7.wav",
	7 : "res://sounds/Dragon Ball Z Trunks Sword Slash Sound Effect n°8.wav",
	8 : "res://sounds/Dragon Ball Z Trunks Sword Slash Sound Effect n°9.wav"
}

export (Dictionary) var nokia_soundpack : Dictionary = {
	0: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/bad_melody.ogg",
	1: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip1.ogg",
	2: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip2.ogg",
	3: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip3.ogg",
	4: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip4.ogg",
	5: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip5.ogg",
	6: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip6.ogg",
	7: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip7.ogg",
	8: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip8.ogg",
	9: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip9.ogg",
	10: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip10.ogg",
	11: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip11.ogg",
	12: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip12.ogg",
	13: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip13.ogg",
	14: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip14.ogg",
	15: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/C5.ogg",
	16: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/crust.ogg",
	17: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/good1.ogg",
	18 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/good2.ogg",
	19 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/good3.ogg",
	20 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/hit1.ogg",
	21 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/hit2.ogg",
	22 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/hit3.ogg",
	23 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/hit4.ogg",
	24 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/hit5.ogg",
	25 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/hit6.ogg",
	26 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/jingle1.ogg",
	27 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/negative1.ogg",
	28 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/negative2.ogg",
	29 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/odd1.ogg",
	30 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/odd2.ogg",
	31 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/odd3.ogg",
	32 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/odd4.ogg",
	33 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/ring1.ogg",
	34 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/soundtest.ogg",
}



# Audio FX Enumeration
# Matches The Audio Fx Layout Arrangement In Audio Bus Layout
enum FX {AMPLIFY, BAND_LIMIT_FILTER, BAND_PASS_FILTER, CAPTURE, CHORUS, COMPRESSOR, 
DELAY, DISTORTION, EQ, EQ10, EQ21, EQ6, FILTER, HIGH_PASS_FILTER, HIGH_SHELF_FILTER,
LIMITER, LOW_PASS_FILTER, LOW_SHELF_FILTER, NOTCH_FILTER, PANNER, PHASER, PITCH_SHIFT,
RECORD, REVERB, SPECTRUM_ANALYSER, STERIO_ENCHANCE
 }
