/* ---- SQL-kod mycollection_db ---- */

/* ---- SQL-kod lägg in data från import-tabellen imp_albumlista ---- */

INSERT IGNORE INTO genre(genre.Genre)
SELECT imp_albumlista.Genre
FROM imp_albumlista

INSERT IGNORE INTO recordcompany(recordcompany.RecordCompany)
SELECT imp_albumlista.RecordCompany
FROM imp_albumlista

INSERT IGNORE INTO songs(songs.title, songs.playtime, songs.genre_id)
SELECT imp_albumlista.Song, imp_albumlista.Length, genre.genre_id
FROM imp_albumlista INNER JOIN genre ON imp_albumlista.Genre = genre.Genre

INSERT IGNORE INTO artists(artists.name, artists.CompanyID)
SELECT imp_albumlista.Artist, recordcompany.CompanyID
FROM imp_albumlista INNER JOIN recordcompany ON imp_albumlista.RecordCompany = recordcompany.RecordCompany

INSERT IGNORE INTO albums(albums.title, albums.release_year, albums.CompanyID)
SELECT imp_albumlista.Album, imp_albumlista.ReleaseYear, recordcompany.CompanyID
FROM imp_albumlista INNER JOIN recordcompany ON imp_albumlista.RecordCompany = recordcompany.RecordCompany 

/* ---- SQL-kod lägg in data från import-tabellen imp_enstakasonger ---- */

INSERT IGNORE INTO recordcompany(recordcompany.RecordCompany)
SELECT imp_enstakasonger.RecordCompany
FROM imp_enstakasonger

INSERT IGNORE INTO artists(artists.name, artists.CompanyID)
SELECT DISTINCT imp_enstakasonger.Artist, recordcompany.CompanyID
FROM recordcompany INNER JOIN imp_enstakasonger ON recordcompany.RecordCompany = imp_enstakasonger.RecordCompany
WHERE NOT (imp_enstakasonger.Artist IN(SELECT artists.name FROM artists))

INSERT IGNORE INTO genre(genre.Genre)
SELECT imp_enstakasonger.Genre
FROM imp_enstakasonger INNER JOIN imp_enstakasonger ON genre.Genre = imp_enstakasonger.Genre
WHERE NOT (imp_enstakasonger.Genre IN(SELECT genre.Genre FROM genre))

INSERT IGNORE INTO albums(albums.artist_id, albums.title, albums.release_year, albums.CompanyID)
SELECT artists.artist_id, imp_enstakasonger.Album, imp_enstakasonger.ReleaseYear, artists.CompanyID
FROM artists INNER JOIN imp_enstakasonger ON artists.name = imp_enstakasonger.Artist
WHERE (imp_enstakasonger.RecordCompany IN(SELECT recordcompany.RecordCompany FROM recordcompany))

INSERT IGNORE INTO songs(songs.album_id, songs.title, songs.genre_id)
SELECT albums.album_id, imp_enstakasonger.Song, genre.genre_id
FROM imp_enstakasonger INNER JOIN albums ON albums.title = imp_enstakasonger.Album
	INNER JOIN songs ON songs.title = imp_enstakasonger.Song
	INNER JOIN genre ON genre.Genre = imp_enstakasonger.Genre
WHERE NOT (imp_enstakasonger.Song IN(SELECT songs.title FROM songs))

