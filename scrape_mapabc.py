#!/usr/bin/python
# coding=utf-8

import codecs
import re
import simplejson
import sqlite3
import sys
import time
import urllib
from xml.dom import minidom

sys.stdout = codecs.getwriter("utf-8")(sys.stdout)

def parse_stations(route):
    KEYS = ["name", "ename", "X", "Y"]
    dom = minidom.parseString(route['xml'].encode("utf-8"))
    stations = []
    station = {}
    for node in dom.childNodes[0].childNodes:
        if node.tagName in KEYS:
            if node.tagName in station:
                raise Exception("Station parse error.")
            station[node.tagName] = node.firstChild.data
        if all(k in station for k in KEYS):
            stations.append(station)
            station = {}
    return stations

def split_station_name(name):
    return re.match(ur"^(?P<short_name>.+?)([\(（](?P<other>.*)[\)）])?$", name).groupdict()

def get_station_id(cursor, station):
    name_split = split_station_name(station['name'])
    pinyin_name_split = split_station_name(station['ename'])

    short_name, pinyin_short_name = name_split['short_name'], pinyin_name_split['short_name']
    if "(" in short_name or ")" in short_name:
        sys.stdout.write("(%s|%s) is wrong. Give correct version: " % (short_name, pinyin_short_name))
        response = sys.stdin.readline().strip()
        short_name, pinyin_short_name = response.split("|")
    cursor.execute("SELECT id FROM station WHERE name = ?", (short_name,))
    row = cursor.fetchone()
    if row:
        return row[0]
    else:
        altname = remarks = pinyin_altname = pinyin_remarks = None
        if name_split['other']:
            response = None
            while response not in ["a", "r"]:
                sys.stdout.write("(%s|%s) has [a]ltname or [r]emarks: " % (station['name'], station['ename']))
                response = sys.stdin.readline().strip()
            if response == "a":
                altname, pinyin_altname = name_split['other'], pinyin_name_split['other']
            elif response == "r":
                remarks, pinyin_remarks = name_split['other'], pinyin_name_split['other']
        cursor.execute("INSERT INTO station (name, altname, remarks, pinyin_name, pinyin_altname, pinyin_remarks, lat, lon) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", (short_name, altname, remarks, pinyin_short_name, pinyin_altname, pinyin_remarks, station['X'], station['Y']))
        return cursor.lastrowid

BUS = 1
SUBWAY = 2

def parse_route(cursor, route):
    number, pinyin_number = route['linenum'], route['elinenum']

    if u"地铁" in unicode(number) or u"城铁" in unicode(number):
        type = SUBWAY
        number, pinyin_number = route['name'], route['ename']
        number = number[:number.index("(")]
        pinyin_number = pinyin_number[:pinyin_number.index("(")]
        sys.stdout.write("Found subway (%s|%s).\n" % (number, pinyin_number))
    else:
        type = BUS

    stations = parse_stations(route)

    cursor.execute("SELECT id FROM line WHERE number = ?", (number,))
    row = cursor.fetchone()
    if row:
        line_id = row[0]
    else:
        cursor.execute("INSERT INTO line (number, pinyin_number, type) VALUES (?, ?, ?)", (number, pinyin_number, type))
        line_id = cursor.lastrowid

    station_ids = [get_station_id(cursor, s) for s in stations]

    cursor.execute("SELECT id FROM route WHERE line_id = ? AND start_station_id = ? AND end_station_id = ?", (line_id, station_ids[0], station_ids[-1]))
    row = cursor.fetchone()
    if row:
        route_id = row[0]
    else:
        fixed_fare = bool(int(route['farecalculationmodel']))
        fare = float(route['ticketfare']) / 100
        start_time, end_time = route['firstvehiclehour'], route['finalvehiclehour']
        length = float(route['length']) / 1000
        cursor.execute("INSERT INTO route (line_id, start_station_id, end_station_id, fixed_fare, fare, start_time, end_time, length) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", (line_id, station_ids[0], station_ids[-1], fixed_fare, fare, start_time, end_time, length))
        route_id = cursor.lastrowid

    cursor.execute("DELETE FROM route_station WHERE route_id = ?", (route_id,))
    for i, station_id in enumerate(station_ids):
        cursor.execute("INSERT INTO route_station(route_id, station_id, i) VALUES (?, ?, ?)", (route_id, station_id, i))

def parse(s):
    conn = sqlite3.connect("bjbus.db")
    cursor = conn.cursor()

    if "[" not in s:
        print "NOT"
        return

    s = s[s.index("["):s.rindex("]")+1]
    route_list = simplejson.loads(s)

    for route in route_list:
        parse_route(cursor, route)

    conn.commit()
    conn.close()

def scrape(n, name):
    page = 1
    page_size = 20
    while True:
        print name, page
        url = "http://search1.mapabc.com/sisserver?config=BusLine&enc=utf-8&cityCode=010&busName=%s&batch=%s&pageSum=1&number=%s&webname=api.mapabc.com&skey=43FC0BC27C18FA7E6A18C077F844D8A7&resType=json&flag=1&ctx=1833251&a_nocache=115502301144&ver=2.0"
        url = "http://search1.mapabc.com/sisserver?highLight=false&config=BusLine&ver=2.0&busName=%s&cityCode=010&enc=utf-8&resType=json&resData=1&a_k=fd9451c6128710ffbc37d9481b002ff36665d039ee0febfd85df0ad471ebcf9204192849326faba3&batch=%s&number=%s&ctx=1532742"
        response = urllib.urlopen(url % (n, page, page_size))
        s = response.read()
        response.close()
        json = s[s.index("{"):s.rindex("}")+1]
        response = simplejson.loads(json)
        count = int(response['count'])
        with file("scrape/%s-%02d.json" % (name, page), "w") as f:
            f.write(json)
        if count <= page * page_size:
            break
        page += 1
        time.sleep(10)

if __name__ == '__main__':
    if len(sys.argv) == 2:
        arg = sys.argv[1]
        if arg == "ditie":
            scrape("地铁", "ditie")
        elif arg == "jichang":
            scrape("机场", "jichang")
        else:
            scrape(int(arg), "%03d" % int(arg))
    elif len(sys.argv) == 3:
        for i in range(int(sys.argv[1]), int(sys.argv[2]) + 1):
            print "%s" % i
            scrape(i, "%03d" % i)

