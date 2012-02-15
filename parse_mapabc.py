#!/usr/bin/python

from collections import defaultdict
import math
import lxml.etree
import simplejson
import sys

def parse(json):
    lines = simplejson.loads(json)
    for l in lines['list']:
        stations = []
        for s in lxml.etree.fromstring(l['stationdes'].encode('utf-8')):
            station = {}
            for data in s.getchildren():
                station[data.attrib['NAME']] = data.text
            stations.append(station)

        l['stations'] = stations

    return lines['list']

GPX_START = """<?xml version="1.0" encoding="UTF-8" ?>
<gpx xmlns="http://www.topografix.com/GPX/1/1">
"""

GPX_END = "</gpx>"

if __name__ == '__main__':
    print GPX_START
    for filename in sys.argv[1:]:
        with file(filename) as f:
            json = f.read()
        file_lines = parse(json)
        for line in file_lines:
            print ("<rte><name>%s</name>" % line['name']).encode("utf-8")
            for station in line['stations']:
                lon, lat = station['XY_COORDS'].split(";")
                print ("<rtept lat=\"%s\" lon=\"%s\"><name>%s</name></rtept>" % (lat, lon, station['NAME'])).encode("utf-8")
            print "</rte>"
    print GPX_END
