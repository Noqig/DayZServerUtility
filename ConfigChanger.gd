extends Control

var main
var params
var ActivatedMods =[]
# Called when the node enters the scene tree for the first time.
func _ready():
	main = get_node("../../../Control")
	params = main.ReadConfigs()
	$ServerPort/PortLineEdit.text = params["port"]
	$ServerLocation/LocationLineEdit.text = params["location"]
	$ServerConfig/ConfigLineEdit.text = params["config"]
	$ServerCores2/CoresLineEdit.text = params["cores"]
	$DayZPath/DayzPathLineEdit.text = params["GamePath"]
	ActivatedMods = params["mods"]
	refresh_mods()
	print("config Panel Initialized")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	$Button.disabled=true
	var port = $ServerPort/PortLineEdit.text
	var location = $ServerLocation/LocationLineEdit.text
	var Config = $ServerConfig/ConfigLineEdit.text
	var Cores = $ServerCores2/CoresLineEdit.text
	var DayzPath = $DayZPath/DayzPathLineEdit.text
	var aMods = ActivatedMods
	
	var Json_String = JSON.stringify({"port" = port,"location" = location,"config"= Config,"cores"=Cores, "GamePath"=DayzPath, "mods"=ActivatedMods},"\t",false)
	main.WriteConfigs(Json_String)
	_ready()
	
func refresh_mods():
	$"ModPanel/Activated Mods".clear()
	$"ModPanel/Deactivated Mods".clear()
	var dirs = DirAccess.open(params["GamePath"]+"\\!Workshop")
	if dirs:
			dirs.list_dir_begin()
			var dir = dirs.get_next()
			while dir != "":
				if dirs.current_is_dir() and dir.begins_with("@"):
					$"ModPanel/Deactivated Mods".add_item(dir)
					if ActivatedMods.find(dir)>=0:
						$"ModPanel/Activated Mods".add_item(dir)
						$"ModPanel/Deactivated Mods".remove_item($"ModPanel/Deactivated Mods".item_count-1)
						if !DirAccess.dir_exists_absolute(params["location"]+"\\"+dir):
							copy_directory((params["GamePath"]+"\\!Workshop"+"\\"+dir),(params["location"]+"\\"+dir))
							copy_directory((params["location"]+"\\"+dir+"\\Keys"),(params["location"]+"\\keys"))
						print(dir)
				dir = dirs.get_next()
	else:
		print("meh")
	
func copy_directory(from, to):
	var Ndirectory = DirAccess.make_dir_absolute(to)
	var Odirectory = DirAccess.open(from)
	Odirectory.list_dir_begin()
	var CurF = Odirectory.get_next()
	if Odirectory:
		while CurF != "":
			if Odirectory.current_is_dir():
				print(Odirectory.current_is_dir())
				copy_directory(from+"\\"+CurF,to+"\\"+CurF)
			else:
				DirAccess.copy_absolute(from+"\\"+CurF,to+"\\"+CurF)
			CurF = Odirectory.get_next()

func _on_config_folder_btn_pressed():
	OS.shell_open(OS.get_user_data_dir())


func _on_deactivated_mod_activated(index):
	$"ModPanel/Activated Mods".add_item($"ModPanel/Deactivated Mods".get_item_text(index))
	ActivatedMods.append($"ModPanel/Deactivated Mods".get_item_text(index))
	$"ModPanel/Deactivated Mods".remove_item(index)
	print(ActivatedMods)
	$"ModPanel/Deactivated Mods".sort_items_by_text()
	$"ModPanel/Activated Mods".sort_items_by_text()

func _on_activated_mod_activated(index):
	$"ModPanel/Deactivated Mods".add_item($"ModPanel/Activated Mods".get_item_text(index))
	ActivatedMods.remove_at(ActivatedMods.find($"ModPanel/Activated Mods".get_item_text(index)))
	$"ModPanel/Activated Mods".remove_item(index)
	print(ActivatedMods)
	$"ModPanel/Deactivated Mods".sort_items_by_text()
	$"ModPanel/Activated Mods".sort_items_by_text()


func _on_dayz_folder_pressed():
	OS.shell_open(params["GamePath"]+"\\!WORKSHOP")

func _on_server_folder_pressed():
	OS.shell_open(params["location"])
