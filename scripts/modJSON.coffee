
fs = require 'fs'
path = require 'path'
_ = require 'lodash'

DATA_FOLDER_PATH = 'files'
RESULT_FILE = 'result.json'
resultPath = path.join DATA_FOLDER_PATH, RESULT_FILE

JSONdata = require '../files/data.json'

PTPET_PROP = "propertyToPhaseEndTime"
PETTP_PROP = "phaseEndTimeToProperty"

PTPET_CLASS_REGEX = /^propertyToPhaseEndTime_(.*)$/
PETTP_CLASS_REGEX = /^phaseEndTimeToProperty_(.*)$/

parseAndModJSON = (data)->
	for key, value of data
		if value?.classes?
			# console.log '> has classes', value
			classes = value.classes.split ' '
			for testedClass in classes

				if PTPET_CLASS_REGEX.test testedClass
					result = testedClass.match(PTPET_CLASS_REGEX)[1]
					console.log '> Found PTPET class for variable:', result
					setImportProp value, PTPET_PROP, result

				if PETTP_CLASS_REGEX.test testedClass
					result = testedClass.match(PETTP_CLASS_REGEX)[1]
					console.log '> Found PETTP class for variable:', result
					setImportProp value, PETTP_PROP, result

		if typeof(value) is 'object'
			# Process JSON file recursively
			parseAndModJSON value

	# Return modified object
	return data


setImportProp = (obj, prop, value)->
	if obj.import?
		obj.import[prop] = value
	else
		obj.import = {}
		obj.import[prop] = value


modifiedJSON = JSON.stringify parseAndModJSON(JSONdata)

fs.writeFile resultPath, modifiedJSON, (err)->
	if err
		console.log 'Error writing result file', err
	else
		console.log 'Result file written.'
