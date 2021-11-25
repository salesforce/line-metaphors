#!/usr/bin/python3

import json

f = open('data/results.csv')
data = []
for line in f.readlines():
    data.append(json.loads(line))

p = {}
for d in data:
    
    if not d['id'] in p:
        p[d['id']] = {'A': 0, 'B': 0}

    p[d['id']][d['part']] += 1

for k in p.keys():
    print(k, p[k]['A'], p[k]['B'])


