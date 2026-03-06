/* ---- SQL-kod Databas: mycollection_db ---- */

/* ---- Tabeller med fält ---- */

/* ---- Artists – artist info ---- */
/* ---- Albums – album, länkade till Artists ---- */
/* ---- Songs – lagrar låtar, länkade till Albums ---- */
/* ---- Media – lagrar mediumtyper (CD, vinyl, mp3, Other) för varje sång ---- */

/* ---- Skapa tabeller ---- */
CREATE TABLE Artists (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE Albums (
    album_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    release_year YEAR NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id) ON DELETE CASCADE
);

CREATE TABLE Media (
    media_id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('CD', 'Vinyl', 'MP3', 'Other') NOT NULL
);

CREATE TABLE Songs (
    song_id INT AUTO_INCREMENT PRIMARY KEY,
    album_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    playtime_seconds INT NOT NULL,
    media_id INT NOT NULL,
    FOREIGN KEY (album_id) REFERENCES Albums(album_id) ON DELETE CASCADE,
    FOREIGN KEY (media_id) REFERENCES Media(media_id)
);

/* ---- Procedurer och funktioner ---- */

/* ---- Vilka album finns för en artist? ---- */
DELIMITER |
CREATE PROCEDURE GetAlbumsByArtist(IN artist_name VARCHAR(100))
BEGIN
    SELECT a.title AS Album, a.release_year AS Year
    FROM Albums a
    JOIN Artists ar ON a.artist_id = ar.artist_id
    WHERE ar.name = artist_name;
END |

/* ---- Vilka låtar finns för en artist? ---- */
DELIMITER |
CREATE PROCEDURE GetSongsByArtist(IN artist_name VARCHAR(100))
BEGIN
    SELECT s.title AS Song, a.title AS Album, s.playtime_seconds AS Duration
    FROM Songs s
    JOIN Albums a ON s.album_id = a.album_id
    JOIN Artists ar ON a.artist_id = ar.artist_id
    WHERE ar.name = artist_name;
END |

/* ---- Hur många album har en viss artist? ---- */
DELIMITER |
CREATE FUNCTION CountAlbumsByArtist(artist_name VARCHAR(100))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE album_count INT;
    SELECT COUNT(*) INTO album_count
    FROM Albums a
    JOIN Artists ar ON a.artist_id = ar.artist_id
    WHERE ar.name = artist_name;
    RETURN album_count;
END |

/* ---- Hur många album finns från ett visst år? ---- */
DELIMITER |
CREATE FUNCTION CountAlbumsByYear(album_year YEAR)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE year_count INT;
    SELECT COUNT(*) INTO year_count
    FROM Albums
    WHERE release_year = album_year;
    RETURN year_count;
END |

/* ---- Vilka album finns ett visst utgivningsår, om något? ---- */
DELIMITER |
CREATE PROCEDURE GetAlbumsByYear(IN album_year YEAR)
BEGIN
    SELECT title AS Album, artist_id
    FROM Albums
    WHERE release_year = album_year;
END |

/* ---- Vilka låtar finns för ett vist medium (cd, vinyl, mpg etc) ---- */
DELIMITER |
CREATE PROCEDURE GetSongsByMedia(IN media_type ENUM('CD', 'Vinyl', 'MP3', 'Other'))
BEGIN
    SELECT s.title AS Song, a.title AS Album, ar.name AS Artist
    FROM Songs s
    JOIN Albums a ON s.album_id = a.album_id
    JOIN Artists ar ON a.artist_id = ar.artist_id
    JOIN Media m ON s.media_id = m.media_id
    WHERE m.type = media_type;
END |

/* ---- Vilka låtar har en speltid på max 3 minuter? ---- */
DELIMITER |
CREATE PROCEDURE GetShortSongs()
BEGIN
    SELECT s.title AS Song, a.title AS Album, s.playtime AS Duration
    FROM Songs s
    JOIN Albums a ON s.album_id = a.album_id
    WHERE s.playtime <= '00:03:00';
END |

/* ----	ARTISTER ---- */
INSERT INTO Artists (name) VALUES
('Taylor Swift'),
('The Weeknd'),
('Gyllene Tider');

/* ----	ALBUM ---- */
INSERT INTO Albums (artist_id, title, release_year) VALUES
(1, 'The Life of a Showgirl', 2025),
(1, 'Reputation', 2017),
(2, 'Hurry Up Tomorrow', 2025),
(2, 'After Hours',2023),
(3, 'Hux Flux', 2023),
(3, 'Moderna Tider', 1981),
(3, 'Parkliv!', 1990);

/* ----	LÅTAR ---- */
INSERT INTO Songs (album_id, title, playtime, media_id) VALUES
(1, 'The Fate of Ophelia', '00:03:46', 4),
(1, 'Elizabeth Taylor', '00:03:28', 4),
(1, 'Opalite', '00:03:55', 4),
(2, '…Ready for It?', '00:03:28', 3),
(2, 'End Game (featuring Ed Sheeran and Future)', '00:04:04', 3),
(3, 'Wake Me Up (with Justice)', '00:05:08', 1),
(3, 'Cry for Me', '00:03:44', 1),
(3, 'São Paulo" (with Anitta)', '00:05:02', 1),
(4, 'Alone Again', '00:04:10', 3),
(4, 'Too Late', '00:03:59', 3),
(5, 'Gyllene Tider igen', '00:02:13', 1),
(5, 'Chans', '00:03:31', 1),
(6, 'Vänta på mej!', '00:02:51', 2),
(6, 'Tuff tuff tuff (som ett lokomotiv)', '00:03:07', 2),
(7, 'Skicka ett vykort, älskling', '00:02:31', 2),
(7, 'Himmel No. 7', '00:05.10', 2);

/* ----	MEDIA ---- */
INSERT INTO Media (type) VALUES
('CD'),
('Vinyl'),
('MP3'),
('Other');

/* ----	Exempel view: Vilka album finns för en artist? ---- */
SELECT * 
FROM view_albums_by_artist
WHERE Artist = 'Taylor Swift';

/* ---- Exempel view: Vilka låtar finns för en artist? ---- */
SELECT * 
FROM view_songs_by_artist
WHERE Artist = 'The Weeknd';

/* ---- Exempel view: Hur många album har en viss artist? ---- */
SELECT * 
FROM view_album_counts_by_artist
WHERE Artist = 'Gyllene Tider';

/* ---- Exempel view: Hur många album finns från ett visst år? ---- */
SELECT * 
FROM view_album_counts_by_year
WHERE Year = 1990;

/* ---- Exempel view: Vilka album finns ett visst utgivningsår, om något? ---- */
SELECT * 
FROM view_albums_by_year
WHERE Year = 2020;

/* ---- Vilka låtar finns för ett vist medium (cd, vinyl, mpg etc) ---- */
SELECT * 
FROM view_songs_by_media
WHERE Media = 'Vinyl';

/* ---- Vilka låtar har en speltid på max 3 minuter? ---- */
SELECT * 
FROM view_short_songs;

/* ---- OLIKA EXEMPELFRÅGOR ---- */
SELECT * 
FROM view_music_dashboard
WHERE Artist = 'Gyllene Tider';

SELECT Artist, Album, Song, Duration
FROM view_music_dashboard
WHERE Duration < '00:03:00';

SELECT Artist, Album, AlbumYear
FROM view_music_dashboard
WHERE AlbumYear = 2020;

SELECT Artist, Album, Song, Media
FROM view_music_dashboard
WHERE Media = 'Vinyl';

