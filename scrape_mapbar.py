#!/usr/bin/python
# coding=utf-8

import codecs
import re
import simplejson
import sqlite3
import sys
import time
import urllib

sys.stdout = codecs.getwriter("utf-8")(sys.stdout)

def get_station_id(c, station):
    name_split = split_station_name(station['name'])
    short_name = name_split['short_name']
    c.execute("SELECT id FROM station WHERE name = ?", (short_name,))
    row = c.fetchone()
    if row:
        return row[0]
    else:
        altname = remarks = None
        if name_split['other']:
            response = None
            while response not in ["a", "r"]:
                sys.stdout.write("%s has [a]ltname or [r]emarks: " % station['name'])
                response = sys.stdin.readline().strip()
            if response == "a":
                altname = name_split['other']
            elif response == "r":
                remarks = name_split['other']
        c.execute("INSERT INTO station (name, altname, remarks, latlon) VALUES (?, ?, ?, ?)", (short_name, altname, remarks, station['latlon']))
        return c.lastrowid

def split_station_name(name):
    return re.match(r"^(?P<short_name>.+?)(\((?P<other>.*)\))?$", name).groupdict()

def store_route(number, pinyin_number, fixed_fare, fare, times, length, stations):
    conn = sqlite3.connect("bjbus.db")
    c = conn.cursor()

    station_ids = [get_station_id(c, {'name': station['name'], 'latlon': station['stationlatlon']}) for station in stations]

    c.execute("SELECT id FROM line WHERE number = ?", (number,))
    row = c.fetchone()
    if row:
        line_id = row[0]
    else:
        c.execute("INSERT INTO line (number, pinyin_number) VALUES (?, ?)", (number, pinyin_number))
        line_id = c.lastrowid

    c.execute("SELECT id FROM route WHERE line_id = ? AND start_station_id = ? AND end_station_id = ?", (line_id, station_ids[0], station_ids[-1]))
    row = c.fetchone()
    if row:
        route_id = row[0]
    else:
        c.execute("INSERT INTO route (line_id, start_station_id, end_station_id, fixed_fare, fare, time, length) VALUES (?, ?, ?, ?, ?, ?, ?)", (line_id, station_ids[0], station_ids[-1], fixed_fare, fare, times, length))
        route_id = c.lastrowid

    c.execute("DELETE FROM route_station WHERE route_id = ?", (route_id,))
    for i, station_id in enumerate(station_ids):
        c.execute("INSERT INTO route_station(route_id, station_id, i) VALUES (?, ?, ?)", (route_id, station_id, i))

    conn.commit()
    conn.close()

def parse_route(s, scrape_return_route=True):
    search_for = "var routeByName = ";
    if search_for not in s:
        print s
        return
    s = s[s.index(search_for) + len(search_for):]

    route = simplejson.loads(fix_json(s))['route']

    name = route['routename']
    stations = route['stations']['items']
    try:
        length = float(route['totaldistance'])
    except ValueError, KeyError:
        length = None

    info = route['infomation']

    if u"单一票" in info:
        fixed_fare = True
    elif u"分段计价" in info:
        fixed_fare = False
    else:
        fixed_fare = None

    try:
        fare = float(re.search(ur"全程票价\(元\):([0-9]+\.[0-9]{2})", info).group(1))
    except AttributeError:
        fare = None

    try:
        times = re.search(ur"起点站首末车时间:(.+?);", info).group(1)
    except AttributeError:
        times = None

    number = route['commonName']
    pinyin_number = route['pinyinName']
    return_route_name = route['oppositeName']

    store_route(number, pinyin_number, fixed_fare, fare, times, length, stations)

    if scrape_return_route and return_route_name:
        scrape_route(return_route_name, False)

def scrape_route(name, scrape_return_route=True):
    print name
    response = urllib.urlopen("http://json.mapbar.com/web/getRouteByRouteName.jsp?keyword=%s&city=%s&infoFormat=2&opposite=true" % (name.encode("utf-8"), CITY))
    s = response.read()
    response.close()
    parse_route(s, scrape_return_route)

def fix_json(s):
    s = re.compile(r"^\s+([a-zA-Z_]+):", re.MULTILINE).sub(lambda m: '"%s":' % m.group(1), s)
    s = re.compile(r"'(.*?)'", re.MULTILINE).sub(lambda m: '"%s"' % m.group(1), s)
    return s

def parse_routes(s):
    s = s[s.index("var routeNamesByKey = ") + len("var routeNamesByKey = "):]
    routes = simplejson.loads(fix_json(s))['routes']['item']
    print "Found %s routes..." % len(routes)
    for route in routes:
        scrape_route(route['name'])

CITY = "北京市"

def scrape(number):
    response = urllib.urlopen("http://json.mapbar.com/web/getRouteNamesByKeyword.jsp?keyword=%s&city=%s&merge=true" % (number, CITY))
    s = response.read()
    response.close()
    parse_routes(s)

if __name__ == '__main__':
    if len(sys.argv) == 2:
        arg = sys.argv[1]
        if arg == 'other':
            scrape("快速")
            scrape("机场")
        else:
            scrape(int(arg))
    elif len(sys.argv) == 3:
        for i in range(int(sys.argv[1]), int(sys.argv[2]) + 1):
            print "%s" % i
            scrape(i)
            time.sleep(10)
        
