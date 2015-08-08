local STRINGS = GLOBAL.STRINGS

STRINGS.CHARACTER_TITLES.teemo = "Captain Teemo"
STRINGS.CHARACTER_NAMES.teemo = "Captain Teemo"
STRINGS.CHARACTER_DESCRIPTIONS.teemo = "Size doesn't mean everything."
STRINGS.CHARACTER_QUOTES.teemo = "\"on duty !! \""
STRINGS.CHARACTERS.TEEMO = GLOBAL.require "speech_teemo"
STRINGS.NAMES.TEEMO = "Teemo"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TEEMO = 
{
	GENERIC = "It's Teemo!",
	ATTACKER = "That Teemo looks shifty...",
	MURDERER = "Murderer!",
	REVIVER = "Teemo, friend of ghosts.",
	GHOST = "Teemo could use a heart.",
}

PrefabFiles = {
	"teemo",
	"noxious_trap",
	"explode_noxious_trap",
	"toxic_effect_by_teemo",
	"blind_dart",
	"blind_effect",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/teemo.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/teemo.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/teemo.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/teemo.xml" ),

    Asset( "IMAGE", "bigportraits/teemo.tex" ),
    Asset( "ATLAS", "bigportraits/teemo.xml" ),
	
	Asset( "IMAGE", "images/map_icons/teemo.tex" ),
	Asset( "ATLAS", "images/map_icons/teemo.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_teemo.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_teemo.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_teemo.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_teemo.xml" ),
    
	Asset( "IMAGE", "images/inventoryimages/blind_dart.tex" ),
    Asset( "ATLAS", "images/inventoryimages/blind_dart.xml" ),
    
	Asset( "IMAGE", "images/inventoryimages/noxious_trap.tex" ),
    Asset( "ATLAS", "images/inventoryimages/noxious_trap.xml" ),

    Asset( "IMAGE", "images/hud/teemotab.tex" ),
   	Asset( "ATLAS", "images/hud/teemotab.xml" ),

    Asset("SOUNDPACKAGE", "sound/teemo.fev"),
    Asset("SOUND", "sound/teemo.fsb"),
    
}

RemapSoundEvent( "dontstarve/characters/teemo/death_voice", "teemo/characters/teemo/death_voice" )
RemapSoundEvent( "dontstarve/characters/teemo/hurt", "teemo/characters/teemo/hurt" )
RemapSoundEvent( "dontstarve/characters/teemo/talk_LP", "teemo/characters/teemo/talk_LP" )
RemapSoundEvent( "dontstarve/characters/teemo/emote", "teemo/characters/teemo/emote" )
RemapSoundEvent( "dontstarve/characters/teemo/ghost_LP", "teemo/characters/teemo/ghost_LP" )

AddModCharacter("teemo", "MALE")
AddMinimapAtlas("images/map_icons/teemo.xml")

-- アイテムの名前 item name
STRINGS.NAMES.BLIND_DART = "Blind Dart"

-- @@ RECIPE @@ --
-- レシピの名前 recipe name
STRINGS.NAMES.NOXIOUS_TRAP = "Noxious Trap"
-- レシピの説明 recipe note
STRINGS.RECIPE_DESC.NOXIOUS_TRAP = "Mushroom Trap"

local teemoTab = AddRecipeTab(
    "Teemo Items" -- rec_str
    ,998 -- rec_sort
    ,GLOBAL.resolvefilepath("images/hud/teemotab.xml") -- rec_atlas
    ,"teemotab.tex" -- rec_icon
    ,"teemo" -- rec_owner_tag
    )

local noxious_trap = AddRecipe(
    "noxious_trap" -- name
    ,{GLOBAL.Ingredient("red_cap", 1)} -- ingredients
    ,teemoTab -- tab
    ,GLOBAL.TECH.NONE -- level
    ,nil -- placer
    ,nil -- min_spacing
    ,nil -- nounlock
    ,nil -- numtogive
    ,"teemo" -- builder_tag
    ,GLOBAL.resolvefilepath("images/inventoryimages/noxious_trap.xml") -- atlas
    --,"noxious_trap.tex" -- image (name + .tex)
    --, -- lockedatlas
    --, -- lockedimage
    )

