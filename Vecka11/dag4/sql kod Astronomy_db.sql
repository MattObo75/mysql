/* ---- SQL-kod Uppgift 2 Astronomy_db ---- */

/* ----
Entity		Description
Constellations	Star regions
Stars		Individual stars
SpectralClasses	Star classification
DeepSkyObjects	Galaxies, nebulae, clusters
Planets		Orbit stars
Moons		Orbit planets

Constellation
- has MANY stars
- has MANY deep sky objects

Star
- belongs to ONE constellation
- belongs to ONE spectral class
- can have MANY planets

Planet
- belongs to ONE star
- can have MANY moons

Moon
- belongs to ONE planet		---- */

/* ---- Create table Spectral Classes ---- */
CREATE TABLE SpectralClasses (
    spectral_id INT AUTO_INCREMENT PRIMARY KEY,
    class_letter CHAR(1) UNIQUE NOT NULL,
    colour VARCHAR(50),
    temperature INT
);

/* ---- Create table Constellations ---- */
CREATE TABLE Constellations (
    constellation_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    hemisphere CHAR(1),
    planets_in_const INT
);

/* ---- Create table Stars ---- */
/* ---- Foreign keys: constellation_id, spectral_id ---- */
CREATE TABLE Stars (
    star_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    distance_ly DECIMAL(8,2),

    constellation_id INT,
    spectral_id INT,

    FOREIGN KEY (constellation_id)
        REFERENCES Constellations(constellation_id),

    FOREIGN KEY (spectral_id)
        REFERENCES SpectralClasses(spectral_id)
);

/* ---- Create table Deep Sky Objects ---- */
/* ---- Foreign key: constellation_id ---- */
CREATE TABLE DeepSkyObjects (
    dso_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    magnitude DECIMAL(4,2),
    ra_dec VARCHAR(50),
    distance_ly DECIMAL(12,2),
    ngc VARCHAR(20),
    messier VARCHAR(20),

    constellation_id INT,

    FOREIGN KEY (constellation_id)
        REFERENCES Constellations(constellation_id)
);

/* ---- Create table Planets ---- */
/* ---- Foreign key: star_id ---- */
CREATE TABLE Planets (
    planet_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    diameter INT,
    temperature_k INT,
    temperature_c INT,

    star_id INT,

    FOREIGN KEY (star_id)
        REFERENCES Stars(star_id)
);

/* ---- Create table Moons ---- */
/* ---- Foreign key: planet_id ---- */
CREATE TABLE Moons (
    moon_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    distance_1000km INT,
    period_days DECIMAL(8,3),
    magnitude DECIMAL(4,2),

    planet_id INT,

    FOREIGN KEY (planet_id)
        REFERENCES Planets(planet_id)
);

/* ---- data must be inserted like this: 
1. SpectralClasses
2. Constellations
3. Stars
4. DeepSkyObjects
5. Planets
6. Moons
---- */

/* ---- INSERT INTO from Imported_StarsConstellations ---- */
INSERT INTO SpectralClasses (class_letter, colour, temperature)
SELECT DISTINCT
    Spectral_Class,
    Colour,
    Temperature
FROM Imported_StarsConstellations
WHERE Spectral_Class IS NOT NULL;

INSERT INTO Constellations (name, hemisphere, planets_in_const)
SELECT DISTINCT
    Constellation,
    Hemisphere,
    Planets_in_Const
FROM Imported_StarsConstellations;

/* ---- INSERT INTO from Imported_DeepSkyConstellations ---- */
INSERT INTO Constellations (name)
SELECT DISTINCT d.Constellation
FROM Imported_DeepSkyConstellations d
LEFT JOIN Constellations c
       ON c.name = d.Constellation
WHERE c.name IS NULL;

/* ---- INSERT INTO from Imported_StarsConstellations ---- */
INSERT INTO Stars (name, distance_ly, constellation_id, spectral_id)
SELECT
    i.Star,
    MIN(i.Distance_LY),
    c.constellation_id,
    s.spectral_id
FROM Imported_StarsConstellations i
JOIN Constellations c
     ON c.name = i.Constellation
JOIN SpectralClasses s
     ON s.class_letter = i.Spectral_Class
WHERE i.Star IS NOT NULL
AND i.Star <> 'Okänt'
GROUP BY i.Star;

/* ---- INSERT INTO from Imported_DeepSkyConstellations ---- */
INSERT INTO DeepSkyObjects
(name, magnitude, ra_dec, distance_ly, ngc, messier, constellation_id)
SELECT
    i.DeepSkyObject,
    i.Magnitude,
    i.Ra_Dec,
    i.Distance_LY,
    i.NGC,
    i.Messier,
    c.constellation_id
FROM Imported_DeepSkyConstellations i
JOIN Constellations c
     ON c.name = i.Constellation;

/* ---- INSERT INTO from Imported_PlanetsMoons ---- */
INSERT INTO Planets
(name, diameter, temperature_k, temperature_c, star_id)
SELECT DISTINCT
    i.Planet,
    i.Diameter,
    i.Temperature_K,
    i.Temperature_C,
    s.star_id
FROM Imported_PlanetsMoons i
JOIN Stars s
     ON s.name = i.Star
WHERE i.Planet IS NOT NULL;

INSERT INTO Moons
(name, distance_1000km, period_days, magnitude, planet_id)
SELECT
    i.Moon,
    i.Distance_1000km,
    i.Period_days,
    i.Magnitude,
    p.planet_id
FROM Imported_PlanetsMoons i
JOIN Planets p
     ON p.name = i.Planet
WHERE i.Moon IS NOT NULL;

/* ---- SQL Queries ---- */
/* ---- 1. Show Constellations with DeepSkyObjects in the northern hemisphere ---- */
SELECT DISTINCT c.name AS 'Constellations'
FROM Constellations c
INNER JOIN DeepSkyObjects d
     ON c.constellation_id = d.constellation_id
WHERE c.hemisphere = 'N';

/* ---- 2. Show planets with moons ---- */
SELECT DISTINCT
    p.name AS Planet,
    m.name AS Moon
FROM Planets p
JOIN Moons m
     ON p.planet_id = m.planet_id
ORDER BY p.name;

/* ---- 3. Show planets without moons ---- */
SELECT p.name
FROM Planets p
LEFT JOIN Moons m
       ON p.planet_id = m.planet_id
WHERE m.moon_id IS NULL;

/* ---- 4. Show all Stars that don't belong to Spectral Class 'W' ---- */
SELECT s.name
FROM Stars s
LEFT JOIN SpectralClasses sc
       ON s.spectral_id = sc.spectral_id
WHERE sc.class_letter <> 'W'
   OR sc.class_letter IS NULL;

/* ---- 5. Show number of stars per Constellation ---- */
SELECT
    c.name AS Constellation,
    COUNT(s.star_id) AS 'Number of stars'
FROM Constellations c
LEFT JOIN Stars s
       ON c.constellation_id = s.constellation_id
GROUP BY c.constellation_id, c.name

/* ---- 6. Show all Constellations with exoplanets ---- */
SELECT DISTINCT c.name AS 'Constellation'
FROM Constellations c
JOIN Stars s
     ON c.constellation_id = s.constellation_id
JOIN Planets p
     ON s.star_id = p.star_id
ORDER BY c.name;


/* ---- stored function 'TravelTimeYears' that calculates the traveltime in years to the stars ---- */
/* ----
1 light year = 9,460,730,472,580.8 km
time = distance / speed

Formula:
years =	(distance_ly × 9.4607e12) / (100000 × 24 × 365) 
---- */

DELIMITER $$

CREATE FUNCTION TravelTimeYears(distance_ly DOUBLE)
RETURNS DOUBLE
DETERMINISTIC
BEGIN
    DECLARE speed_kmh DOUBLE DEFAULT 100000;
    DECLARE km_per_lightyear DOUBLE DEFAULT 9460730472580.8;
    DECLARE hours_per_year DOUBLE DEFAULT 24 * 365;

    DECLARE travel_years DOUBLE;

    SET travel_years =
        (distance_ly * km_per_lightyear) /
        (speed_kmh * hours_per_year);

    RETURN travel_years;

END$$
DELIMITER ;

/* ---- Procedure that runs the function TravelTimeYears ---- */
DELIMITER $$

CREATE PROCEDURE ShowStarTravelTimes_Text()
BEGIN

    SELECT
        CONCAT(
            'Travel time to ',
            name,
            ' (',
            distance_ly,
            ' ly) is ',
            ROUND(TravelTimeYears(distance_ly),0),
            ' years.'
        ) AS Travel_Info
    FROM Stars
    WHERE distance_ly IS NOT NULL;

END$$

DELIMITER ;

/* ---- Run with: ---- */
CALL ShowStarTravelTimes_Text();

