
fs = require 'fs'
path = require 'path'

DATA_FOLDER_PATH = 'files'
RESULT_FILE = 'result.json'
resultPath = path.join DATA_FOLDER_PATH, RESULT_FILE

JSONdata = require '../files/data.json'

PTPET_PROP = "propertyToPhaseEndTime"
PETTP_PROP = "phaseEndTimeToProperty"

PTPET_CLASS_REGEX = /^propertyToPhaseEndTime_(.*)$/
PETTP_CLASS_REGEX = /^phaseEndTimeToProperty_(.*)$/

propList = []

parseAndModJSON = (data)->

	for key, value of data
		if value?.classes?
			# console.log '> has classes', value
			classes = value.classes.split ' '
			for testedClass in classes

				if PTPET_CLASS_REGEX.test testedClass
					timerProp = testedClass.match(PTPET_CLASS_REGEX)[1]
					console.log '> Found PTPET class for variable:', timerProp
					setImportProp value, PTPET_PROP, timerProp
					registerProperty propList, timerProp

				if PETTP_CLASS_REGEX.test testedClass
					timerProp = testedClass.match(PETTP_CLASS_REGEX)[1]
					console.log '> Found PETTP class for variable:', timerProp
					setImportProp value, PETTP_PROP, timerProp
					registerProperty propList, timerProp

		if typeof(value) is 'object'
			# Process JSON file recursively
			parseAndModJSON value

	# Return modified object
	return data


setImportProp = (obj, prop, propertyValue)->
	if obj.import?
		obj.import[prop] = propertyValue
	else
		obj.import = {}
		obj.import[prop] = propertyValue

registerProperty = (array, prop)->
	if array.indexOf(prop) is -1
		array.push prop


setNewProperties = (data)->
	for key, value of data
		if key is 'properties'
			# Add new properties to properties list
			for prop in propList
				value[value.length] = prop

		if typeof(value) is 'object'
			# Process JSON file recursively
			setNewProperties value

	# Return modified object
	return data


######################################### Let's do this !

modifiedJSON = parseAndModJSON(JSONdata)

modifiedJSONwithNewProps = setNewProperties modifiedJSON, propList

resultJSON = JSON.stringify modifiedJSONwithNewProps


fs.writeFile resultPath, resultJSON, (err)->
	if err
		console.log 'Error writing result file', err
	else
		console.log 'Result file written.'
