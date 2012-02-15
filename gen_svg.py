#!/usr/bin/python

import math
import sys

SVG_START = """<?xml version="1.0" standalone="no" ?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="100%" height="100%" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<script xlink:href="SVGPan.js"/>
<g id="viewport" transform="translate(200,200)">
"""

SVG_END = "</g></svg>"

def weight2color(w):
    if w == 1 or w == 2:
        return "200,200,200"
    elif w == 3:
        return "180,180,180"
    elif w == 4:
        return "170,170,170"
    elif w == 5:
        return "160,160,160"
    elif w == 6:
        return "150,150,150"
    elif w == 7:
        return "140,140,140"
    elif w == 8:
        return "130,130,130"
    elif w == 9:
        return "120,120,120"
    else:
        return "100,100,100"

def absolute(v, scale, min_v, max_v):
    return scale * (v - min_v) / (max_v - min_v)

def lng2x(lng):
    return lng

def lat2y(lat):
    return math.log(math.tan(math.pi / 4 + lat * (math.pi / 180) / 2))

MIN_Y, MAX_Y = lat2y(41), lat2y(38)

def svg_segments(input, output):
    output.write(SVG_START)

    min_x, min_y, max_x, max_y = None, None, None, None

    segments = []

    height = width = 1000

    for line in input:
        lng1, lat1, lng2, lat2, weight = line.split(" ")
        lng1, lat1, lng2, lat2 = map(float, [lng1, lat1, lng2, lat2])
        weight = int(weight)

        x1, x2 = map(lng2x, [lng1, lng2])
        y1, y2 = map(lat2y, [lat1, lat2])

        min_x = min(min_x or x1, x1, x2)
        min_y = min(min_y or y1, y1, y2)
        max_x = max(max_x or x1, x1, x2)
        max_y = max(max_y or y1, y1, y2)

        segments.append((x1, y1, x2, y2, weight))

    for x1, y1, x2, y2, weight in segments:
        ax1 = absolute(x1, width, min_x, max_x)
        ax2 = absolute(x2, width, min_x, max_x)
        ay1 = absolute(y1, height, max_y, min_y)
        ay2 = absolute(y2, height, max_y, min_y)

        output.write("""<line x1="%s" y1="%s" x2="%s" y2="%s" style="stroke:rgb(%s);stroke-width:0.1" />\n""" % (ax1, ay1, ax2, ay2, weight2color(weight)))

    output.write(SVG_END)

if __name__ == '__main__':
    svg_segments(sys.stdin, sys.stdout)
