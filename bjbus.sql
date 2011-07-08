
CREATE TABLE station (id INTEGER NOT NULL PRIMARY KEY, name VARCHAR(50) NOT NULL, pinyin_name VARCHAR(100) NOT NULL, altname VARCHAR(50), pinyin_altname VARCHAR(100), remarks VARCHAR(50), pinyin_remarks VARCHAR(100), lat VARCHAR(20), lon VARCHAR(20));

CREATE TABLE line (id INTEGER NOT NULL PRIMARY KEY, number VARCHAR(50) NOT NULL, pinyin_number VARCHAR(100) NOT NULL, type INTEGER NOT NULL);

CREATE TABLE route (id INTEGER NOT NULL PRIMARY KEY, line_id INTEGER NOT NULL REFERENCES line(id), start_station_id INTEGER NOT NULL REFERENCES station(id), end_station_id INTEGER NOT NULL REFERENCES station(id), fixed_fare BOOLEAN, fare REAL, start_time VARCHAR(50), end_time VARCHAR(50), length REAL);

CREATE TABLE route_station(route_id INTEGER NOT NULL REFERENCES route(id), station_id INTEGER NOT NULL REFERENCES station(id), i INTEGER NOT NULL);
