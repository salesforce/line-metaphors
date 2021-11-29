#!/usr/bin/python3

# Generate CSV for import into Google Sheets and coding

import json
from csv import DictWriter

FIELDNAMES = ['id', 'part', 'step', 'metaphor', 'style', 'time']

PHASE = 'main' # 'pilot'

# https://stackoverflow.com/questions/1986152/why-doesnt-python-have-a-sign-function
def sign(x):
	return -1 if x < 0 else (1 if x > 0 else 0)

def writeCSV(data, part, extrafields, fieldnames=FIELDNAMES):
	with open(PHASE + '-results-' + part + '.csv', 'w') as outFile:
		writer = DictWriter(outFile, fieldnames + extrafields)

		writer.writeheader();
		writer.writerows(data);

def findCrossings(series1, series2):
	crossings = []
	for i in range(1, len(series1)):
		if sign(series1[i-1]['y']-series2[i-1]['y']) != sign(series1[i]['y']-series2[i]['y']):

			# https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection#Given_two_line_equations
			# series1 is y=ax+c
			c = series1[i-1]['y']
			a = (series1[i]['y']-series1[i-1]['y'])/(series1[i]['x']-series1[i-1]['x'])

			# series 2 is y=bx+d
			d = series2[i-1]['y']
			b = (series2[i]['y']-series2[i-1]['y'])/(series2[i]['x']-series2[i-1]['x'])
	
			x = (d-c)/(a-b)
			y = a*x+c

			crossings.append({
				'index': i,
				'x':	 x+series1[i-1]['x'],
				'y':	 y
			})

	return crossings

def closestX(series, reference):
	closest = series[0]
	for s in series:
		if abs(s['x']-reference['x']) < abs(closest['x']-reference['x']):
			closest = s

	return closest

f = open('public/data/main-results.jsonl')
results = []
for line in f.readlines():
	results.append(json.loads(line))

results.sort(key=lambda v: v['id'][-6:] + '-' + v['part'])

partA = []
partB = []

previousID = ''
previousPart = 'X'
step = 0
for r in results:
	id = r['id'][-6:]
	if id != previousID or r['part'] != previousPart:
		step = 1
	else:
		step += 1

	previousPart = r['part']
	previousID = id

	d = {
		'id':		id,
		'step':		step,
		'part':		r['part'],
		'metaphor': r['metaphor'],
		'style':	r['style'],
		'time':		r['time']
	}

	if r['part'] == 'A':
		d['response'] = r['answer']
		partA.append(d)
	else:
		partB.append(d)

#	print(d)

writeCSV(partA, 'A', ['response'])
writeCSV(partB, 'B', [])

crossings = []
# Line crossings
for r in results:
	if r['part'] == 'B' and r['metaphor'] == 'cross':
		refcrossing = findCrossings(r['refdata'], r['focusdata'])[0]
		# print(refcrossing)
	
		usercrossings = findCrossings(r['refdata'], r['userdata'])

		d = {
			'id':			r['id'],
			'stepID':		r['stepID'],
			'metaphor':		r['metaphor'],
			'style':		r['style'],
			'step':			r['step'],
			'numCrossings':	len(usercrossings),
			'crossingX':	refcrossing['x']
		}
		if len(usercrossings) >= 1:
			closest = closestX(usercrossings, refcrossing)
			d['closestX'] = closest['x']
			d['distance'] = closest['x']-refcrossing['x']
			d['absDistance'] = abs(closest['x']-refcrossing['x'])
		else:
			d['closestX'] = -1
			d['distance'] = -1
			d['absDistance'] = -1

		crossings.append(d)

writeCSV(crossings, 'crossings', [], ['id', 'stepID', 'metaphor', 'style', 'step', 'numCrossings', 'crossingX', 'closestX', 'distance', 'absDistance'])
