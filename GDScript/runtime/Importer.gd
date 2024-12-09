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

## DL EDIT the default file loading mechanism is FileAccess (See YATI.gd)
## But now we can override it dynamically.
func import(source_file: String, project_file: String = "", load_file_data := YATI.load_from_file):
	var tilemapCreator = preload("TilemapCreator.gd").new(load_file_data)
	tilemapCreator.set_add_class_as_metadata(true)
	if project_file != "":
		var ct = CustomTypes.new()
		ct.load_custom_types(project_file, load_file_data)
		tilemapCreator.set_custom_types(ct)
	## We pass in how we want to load our Tiled map.
	return tilemapCreator.create(source_file, load_file_data)

## DL EDIT
## specialized zip loading is no longer necessary to load zip files.

#
#func import_from_zip(zip_file: String, source_file_in_zip: String, project_file_in_zip: String = ""):
	#if not FileAccess.file_exists(zip_file):
		#return null
	#var za = ZipAccess.new()
	#var err = za.open(zip_file)
	#if err != OK:
		#return null
	#var tilemapCreator = preload("TilemapCreator.gd").new()
	#tilemapCreator.set_zip_access(za)
	#tilemapCreator.set_add_class_as_metadata(true)
	#if project_file_in_zip != "" and za.file_exists(project_file_in_zip):
		#var ct = CustomTypes.new()
		#ct.load_custom_types(project_file_in_zip, za)
		#tilemapCreator.set_custom_types(ct)
	#var ret = tilemapCreator.create(source_file_in_zip)
	#za.close()
	#return ret
