extends Control

var ControlWindow = preload("res://ConfigScreen.tscn")
var w
var RunTime =0.0
var serverInterrupt = false
var Confile ="user://ServerUtilConfig.txt"

# server Configs :3
var sPort = "2302" # Server Port :3
var sLocation = "" # Server Path :3
var sConf = "serverDZ.cfg" # Server Config File Name :3
var sCores = "8" # Server CPU Core Count :3
var sMods ="" #soon 
var gPath = "" # Game Path :3 Important for Mods :3

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().set_embedding_subwindows(false)
	if CheckForConfigs():
		refreshText()
	else:
		ShowWindow()
	print(sMods)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_instance_valid(w):
		RunTime +=delta
		if RunTime >= 5:
			startServer()
	else:
		RunTime=0
		
func refreshText():
	$Label.text = "Starting server in 5 Seconds with Following Configuration:\n" + PrintConfigs() + "\nPress ESC to change Config"

func _input(event):
	if event.as_text() == "Escape":
		ShowWindow()
	else:
		pass
	
func PrintConfigs():
	return JSON.stringify(ReadConfigs(),"\t").replace("{","").replace('"',"").replace(":"," =").replace("}","").replace("[","").replace("]","").replace(",","").replace("mods =","mods: ")
	
func ReadConfigs():
	var file = FileAccess.open(Confile,FileAccess.READ)
	var JOUT = JSON.parse_string(file.get_as_text())
	sPort = JOUT["port"]
	sLocation = JOUT["location"]
	sConf = JOUT["config"]
	sMods=""
	for n in len(JOUT["mods"]):
		sMods += ""+JOUT["mods"][n]+";"
	return JOUT
	
func CheckForConfigs():
	var file = FileAccess.file_exists(Confile)
	return file
	
func WriteConfigs(json):
	print()
	var file = FileAccess.open(Confile,FileAccess.WRITE)
	file.store_string(json)
	

func ShowWindow():
	if is_instance_valid(w):
		return
	serverInterrupt = true
	w = ControlWindow.instantiate()
	add_child(w)
	w.visible = true
	w.title = "Configure Server"

func startServer():
	OS.create_process(sLocation +"\\DayZServer_x64.exe",["-config="+sConf, "-port="+sPort,"-cpuCount="+sCores,''+'-mod='+sMods+''],false)
	get_tree().quit()
