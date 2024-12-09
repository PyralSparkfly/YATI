class_name YATI

## DL EDIT
## Okay, so this is a small namespace for some functions that we can pass in
## by default. This lets us supply default behaviors and "first class support"
## for file loading methods without limiting our codebase.

## DL EDIT
## Also, as a small tip:
## because preload("") everywhere is ugly, we can use constant refs
## to make our code a little easier to read and update. It's how I often
## faked namespaces for static functions in GDScript.

const IMPORTER := preload("Importer.gd")
 # now you can use YATI.IMPORTER.import() instead of a big preload string.
const DICTIONARY_BUILDER := preload("DictionaryBuilder.gd")
const TILEMAP_CREATOR := preload("TilemapCreator.gd")
const TILESET_CREATOR := preload("TilesetCreator.gd")

## DL EDIT
## This is notable because now, file loading is 100% decoupled from how we
## parse data itself. No one has to modify YATI to add new ways to load files.
## If they want to add new files, they just have to create a function in their
## own scripts that take a string and return a Callable. Extra functional
## arguments can be applied after the path with Callable.bind(...)

## DL EDIT First, I ripped out the file exist verification and loading to separate functions.

#region FileAccess

## Returns either [param source_file] if it exists or
## whatever mutation was done to it here. I assume sanitizing of some sort.
## We now no longer have to hard-code this FileAccess call into the parser.
## Let the user decide if they want/need to use it.
static func get_existing_file_path(source_file:String)->String:
	var checked_file:String = source_file
	if !FileAccess.file_exists(checked_file):
		checked_file = source_file.get_base_dir().path_join(source_file)
		if !FileAccess.file_exists(checked_file):
			printerr("ERROR: File '" + source_file + "' not found. -> Continuing but result may be unusable")
	return checked_file

## Load from file
static func load_from_file(source_file:String)->PackedByteArray:
	## TODO return PackedByteArray() if file does not exist.
	
	# Since we mutate the file string only in this function, we don't have to
	# branch how the file is detected when trying to just parse the data itself.
	var checked_file:String = get_existing_file_path(source_file)
	return FileAccess.get_file_as_bytes(checked_file)

## I'm figuring out weird stuff don't mind me.
static func load_resource(source_file:String)->Resource:
		var exists = ResourceLoader.exists(source_file, "Image")
		if exists:
			return load(source_file)
		return null

#endregion

## DL EDIT then I add support for ZIPReader here.

#region ZIPReader

## Load from an open zip file.
static func load_from_open_zip(source_file:String, zip:ZIPReader)->PackedByteArray:
	return zip.read_file(source_file)

## Load from a zip file, read, and close.
static func load_from_zip(source_file:String, zip_path:String)->PackedByteArray:
	var zip := ZIPReader.new()
	var data := PackedByteArray()
	## TODO return PackedByteArray() if zip does not exist.
	zip.open(zip_path)
	data = load_from_open_zip(source_file, zip)
	zip.close()
	return data

#endregion

#region Helper functions

## DL EDIT pulled this out. That sure does do stuff.
static func cleanup_path(path: String) -> String:
	while true:
		var path_arr = path.split("/")
		var is_clean: bool = true
		for i in range(1, path_arr.size()):
			if path_arr[i] == "..":
				path_arr[i] = ""
				path_arr[i-1] = ""
				is_clean = false
				break
			if path_arr[i] == ".":
				path_arr[i] = ""
				is_clean = false
		var new_path = ""
		for t in path_arr:
			if t == "": continue
			if new_path != "":
				new_path += "/"
			if t != "":
				new_path += t
		if is_clean:
			return new_path
		path = new_path
	return ""


## DL EDIT
## Decouple image loading from file fetching,
## and return a usable texture based on the result.
static func load_texture_from_buffer(path:String, data:PackedByteArray)->ImageTexture:
	var tex:ImageTexture = null
	if data.is_empty():
		return ImageTexture.new()
	var image = Image.new()
	var extension:String = path.get_extension().to_lower()
	match extension:
		"png":
			image.load_png_from_buffer(data)
		"jpg", "jpeg":
			image.load_jpg_from_buffer(data)
		"bmp":
			image.load_bmp_from_buffer(data)
	return tex.create_from_image(image)

#endregion

## Write more ways to load if you would like...
