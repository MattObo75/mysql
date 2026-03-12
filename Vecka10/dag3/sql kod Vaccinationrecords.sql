/* ---- SQL-kod Vaccinationrecords ---- */

/* ---- Tabeller med fält ---- */

/* ---- Patienter ---- */
CREATE TABLE Patients(PatientId INT(11),)
PatientId, 
Personnr, 
FirstName, 
LastName, 
Age,
Gender

/* ---- Vaccin ---- */
Vaccines
VaccinId,
Vaccin

/* ---- Personal ---- */
Staff
StaffId,
FirstName, 
LastName 

/* ---- Kommuner ---- */
Counties
CountyId,
County

/* ---- Platser ---- */
Locations
LocationId,
Location,
CountyId


/* ---- Vaccinationer, kopplingstabell ---- */
Vaccinations
VaccinationId,
VaccinId,
PatientId,
LocationId,
StaffId,
VaccinDate

/* ---- Lägg till Patienter från Importtabell---- */
INSERT INTO patients(patients.PersonNr, patients.FirstName, patients.LastName)
SELECT personervaccination.PersonNr, personervaccination.Fornamn,personervaccination.Efternamn
FROM personervaccination


