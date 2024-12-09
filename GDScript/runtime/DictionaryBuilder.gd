# MIT License
#
# Copyright (c) 2024 Roland Helmerichs
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends RefCounted

enum FileType {
	Xml,
	Json,
	Unknown
}

## DL EDIT
## [param get_source_data] func(path:String)->PackedByteArray: loads file binary
## Note that I gutted the file existing stuff here because that should be done
## at an earlier step, either during/before [param get_source_data]
## What we INSTEAD assume is that [param source_file] is already
## usable and passing it into other loaders (ie tilesets) will 
## understand how to verify correctness ahead of time.
func get_dictionary(source_file:String, get_source_data: Callable):
	## See YATI.gd for where this logic's gone.
	#var checked_file = source_file
	#if za:
		#if not za.file_exists(checked_file):
			#printerr("ERROR: File '" + source_file + "' not found. -> Continuing but result may be unusable")
			#return null
	#elif !FileAccess.file_exists(checked_file):
		#checked_file = source_file.get_base_dir().path_join(source_file)
		#if !FileAccess.file_exists(checked_file):
			#printerr("ERROR: File '" + source_file + "' not found. -> Continuing but result may be unusable")
			#return null
	
	## DL EDIT
	## Looking ahead, we need access to the file's data now. So let's just
	## load it into RAM now.
	## Enforce that what we are getting is a PackedByteArray by
	## strictly-typing it. Godot still doesn't support typed Callables.
	## This will throw an error if the user didn't use a valid function.
	## We can also pass either this or the resulting string into later stuff,
	## so this lets us just access the data from disk once instead of twice.
	var file_bytes:PackedByteArray = get_source_data.call(source_file)
	
	## Possibly can export file stringing to its own function and reuse.
	var type = FileType.Unknown
	var extension = source_file.get_file().get_extension()
	if ["tmx", "tsx", "xml", "tx"].find(extension) >= 0:
		type = FileType.Xml
	elif ["tmj", "tsj", "json", "tj", "tiled-project"].find(extension) >= 0:
		type = FileType.Json
	else:
		var chunk:String = file_bytes.slice(0,11).get_string_from_utf8()
		#if za:
			#var file_bytes = za.get_file(checked_file).slice(0, 11)
			#chunk = file_bytes.get_string_from_utf8()
		#else:
			#var file = FileAccess.open(checked_file, FileAccess.READ)
			#chunk = file.get_buffer(12)
			#file.close()
		
		## DL EDIT
		## These were starts_with instead of begins_with and I have no idea why?
		## Threw a compile error when I strongly-typed chunk as string.
		if chunk.begins_with("<?xml "):
			type = FileType.Xml
		elif chunk.begins_with("{ \""):
			type = FileType.Json

	## DL EDIT
	## This underlines why I suggest first-class function loading instead of
	## directly coding in new loading methods. Things become verbose and complicated.
	## since we actually already have the file loaded into RAM, we don't even need
	## the DictBuilder to load and parse it again, so we don't even actually need to pass
	## in checked_file.
	match type:
		FileType.Xml:
			## DL EDIT
			## XML building is way more complex since a lot of hardcoded stuff
			## is built in here. It'll take more work to fix.
			## ZipAccess is replaced with the raw data we got. 
			var dict_builder = preload("DictionaryFromXml.gd").new()
			return dict_builder.create(source_file, file_bytes)
		FileType.Json:
			## DL EDIT
			## JSON parsing is trivial. We don't need to branch for ZIPReader
			## because we already have the full file's data
			## without care of where it came from.
			var json = JSON.new()
			if json.parse(file_bytes.get_string_from_utf8()) == OK:
				return json.data
			#if za:
				#if json.parse(za.get_file(checked_file).get_string_from_utf8()) == OK:
					#return json.data
			#else:
				#var file = FileAccess.open(checked_file, FileAccess.READ)
				#if json.parse(file.get_as_text()) == OK:
					#file.close()
					#return json.data
		FileType.Unknown:
			printerr("ERROR: File '" + source_file + "' has an unknown type. -> Continuing but result may be unusable")

	return null
