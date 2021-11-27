#!/usr/bin/python3

# Generate CSV for import into Google Sheets and coding

import json
from csv import DictWriter

FIELDNAMES = ['id', 'part', 'step', 'metaphor', 'style', 'time']

PHASE = 'main' # 'pilot'

def writeCSV(data, part, extrafields):
	with open(PHASE + '-results-' + part + '.csv', 'w') as outFile:
		writer = DictWriter(outFile, FIELDNAMES + extrafields)

		writer.writeheader();
		writer.writerows(data);


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
		partB.append(d);

#	print(d)

writeCSV(partA, 'A', ['response'])
writeCSV(partB, 'B', [])

