extends Node

var file = File.new()

func load_translation_file(filepath,delim = "|") -> Dictionary:
	var dict = {}
	filepath = ProjectSettings.localize_path(filepath)
	file.open(filepath,File.READ)
	var data = Array(file.get_as_text(true).split("\n"))
	file.close()
	if data[0].split(delim)[0] == "locale":
		dict = translation_file_to_dictionary(filepath,delim)
	else:
		var parent = filepath.split("/")[filepath.split("/").size() - 2]
		dict = translation_file_to_dictionary(filepath,delim,[parent])
	return dict

func translation_file_to_dictionary(path : String, delimiter : String = "|",languages = []) -> Dictionary:
	var exists = Directory.new().file_exists(path)
	if not exists:
		return {}
	var dictionary = {}
	file.open(path,File.READ)
	var lines = file.get_as_text(true).split("\n")
	file.close()
	if languages.size() == 0:
		var lang_data = lines[0]
		var language_lines = lang_data.split(delimiter)
		if not language_lines[0] == "locale":
			return {}
		if language_lines.size() <= 1:
			return {}

		var lsize = language_lines.size()
		var lindex = 1
		while lindex < lsize:
			languages.append(language_lines[lindex])
			lindex += 1
	
	for lang in languages:
		var smdc = {lang:{}}
		dictionary.merge(smdc)
	var translation_count = 0
	var size = lines.size()
	var index = 1
	while index < size:
		var line = lines[index]
		if line == "":
			index += 1
			continue
		var line_split = line.split(delimiter)
		var split_size = line_split.size() - 1
		if split_size + 1 == 1:
			index += 1
			continue
		if split_size < languages.size():
			index += 1
			continue
		var translation_string = line_split[0]
		var tlindex = 0
		while tlindex < languages.size():
			var lang = languages[tlindex]
			dictionary[lang].merge({translation_string:line_split[tlindex + 1]})
			tlindex += 1
		index += 1
		translation_count += 1
	return dictionary
