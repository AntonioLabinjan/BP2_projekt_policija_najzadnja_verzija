# UPITI

 
--1) Ispiši prosječan broj godina osoba koje su prijavile digitalno nasilje. 


SELECT AVG(YEAR(S.pocetak)-YEAR(O.datum_rodenja)) AS prosjecan_broj_godina
FROM slucaj S INNER JOIN osoba O ON S.id_izvjestitelj=O.id
WHERE S.naziv LIKE '%digitalno nasilje%';

-- 2) Prikaži osobu čiji je nestanak posljednji prijavljen

SELECT O.*
FROM osoba O INNER JOIN slucaj S ON O.id=S.id_ostecenik
WHERE S.naziv LIKE '%nestala%'
ORDER BY S.pocetak DESC
LIMIT 1;

-- 3) Prikaži najčešću vrstu kažnjivog djela

SELECT KD.*
FROM kaznjiva_djela KD INNER JOIN kaznjiva_djela_u_slucaju KDS 
ON KDS.id_kaznjivo_djelo = KD.id
GROUP BY KD.id
ORDER BY COUNT(*)
LIMIT 1;


# 4) Ispišimo sve voditelje slučajeva i slučajeve koje vode
SELECT O.Ime_Prezime, S.Naziv AS 'Naziv slučaja'
FROM Zaposlenik Z
JOIN Osoba O ON Z.id_osoba = O.Id
JOIN Slucaj S ON Z.Id = S.id_voditelj;


# 5) Ispišimo slučajeve i evidencije za određenu osobu (osumnjičenika)
SELECT O.Ime_Prezime, S.Naziv AS 'Naziv slučaja', ED.opis_dogadaja, ED.datum_vrijeme, ED.id_mjesto
FROM Slucaj S
JOIN Evidencija_dogadaja ED ON S.Id = ED.id_slucaj
JOIN Osoba O ON O.Id = S.id_pocinitelj
WHERE O.Ime_Prezime = 'Ime Prezime';

# 6) Ispišimo sve osobe koje su osumnjičene za određeno KD
SELECT DISTINCT O.Ime_Prezime
FROM Osoba O
JOIN Slucaj S ON O.Id = S.id_pocinitelj
JOIN Kaznjiva_djela_u_slucaju	KDS ON S.Id = KDS.id_slucaj
JOIN Kaznjiva_djela	KD ON KDS.id_kaznjivo_djelo = KD.id
WHERE KD.Naziv = 'Naziv kaznjivog djela';

# 7) Pronađimo sve slučajeve koji sadrže KD i nisu riješeni
SELECT S.Naziv, KD.Naziv AS kaznjivo_djelo
FROM Slucaj S
INNER JOIN Kaznjiva_djela_u_slucaju KDS	ON S.id = KDS.id_slucaj
INNER JOIN Kaznjiva_djela KD ON 
KDS.id_kaznjivo_djelo= KD.id
WHERE S.Status = 'Aktivan';

# 8) Izračunajmo iznos zapljene za svaki pojedini slučaj
SELECT S.id, S.Naziv, SUM(ZA.Vrijednost) AS ukupna_vrijednost_zapljena
FROM Slucaj S
LEFT JOIN Zapljene ZA ON S.id = ZA.id_slucaj
GROUP BY S.id, S.Naziv;

# 9) Pronađi prosječnu vrijednost zapljene za pojedina kaznjivaa djela
SELECT KD.Naziv AS vrsta_kaznjivog_djela, AVG(ZA.Vrijednost) AS prosjecna_vrijednost_zapljene
FROM Kaznjiva_djela_u_slucaju KDS
JOIN Kaznjiva_djela KD ON KS.id_kaznjivo_djelo= KD.Id
JOIN Zapljene ZA ON KDS.id_slucaj	= ZA.id_slucaj
GROUP BY KD.naziv;

# 10) Pronađi sve odjele i broj zaposlenika na njima
SELECT O.Naziv AS naziv_odjela, COUNT(Z.Id) AS broj_zaposelnika
FROM Zaposlenik Z
JOIN Odjeli O ON Z.id_odjel	 = O.Id
GROUP BY O.id, O.Naziv;

# 11) Pronađi ukupnu vrijednost zapljena po odjelu i sortiraj ih po vrijednosti silazno
SELECT Z.id_odjel, SUM(ZA.vrijednost) AS ukupna_vrijednost_zapljena
FROM Slucaj S
JOIN Zapljene ZA ON S.Id = ZA.id_slucaj
JOIN Zaposlenik Z ON S.id_voditelj= Z.Id
GROUP BY Z.id_odjel
ORDER BY ukupna_vrijednost_zapljena DESC;



# 12) Pronađi osobu koja mora odslužiti najveću ukupnu zatvorsku kaznu
SELECT O.Id, O.Ime_Prezime, SUM(KD.Predvidena_kazna) AS ukupna_kazna
FROM Osoba O
INNER JOIN Slucaj S ON O.Id = S.id_pocinitelj
INNER JOIN Kaznjiva_Djela_u_Slucaju KDS ON S.Id = KDS.id_slucaj
INNER JOIN Kaznjiva_Djela KD ON KDS.id_kaznjivo_djelo= KD.ID
WHERE KD.predvidena_kazna IS NOT NULL
GROUP BY O.id, O.ime_prezime
ORDER BY ukupna_kazna DESC
LIMIT 1;

# 13) Prikaži sva vozila i u koliko slučajeva su se oni upisali
SELECT V.*, COUNT(S.id) AS broj_slucajeva
FROM Vozilo V LEFT OUTER JOIN Osoba O ON V.id_vlasnik = O.id
INNER JOIN Slucaj S ON O.id = S.id_pocinitelj
GROUP BY V.id;

# 14) Mjesto s najviše slučajeva
SELECT M.*, COUNT(ED.id) AS broj_slucajeva
FROM Mjesto M INNER JOIN Evidencija_dogadaja ED ON  M.id = ED.id_mjesto
GROUP BY M.id 
ORDER BY broj_slucajeva DESC 
LIMIT 1;

# 15) Mjesto s najmanje slučajeva (praktički ista stvar kao ovo gore)
SELECT M.*, COUNT(ED.id) AS broj_slucajeva
FROM Mjesto M INNER JOIN Evidencija_dogadaja ED ON  M.id = ED.id_mjesto
GROUP BY M.id 
ORDER BY broj_slucajeva ASC 
LIMIT 1;

# 16) Pronađi policijskog službenika koji je vodio najviše slučajeva
SELECT
    Z.Id AS id_zaposlenika,
    O.Ime_Prezime AS ime_prezime_zaposlenika,
    COUNT(s.Id) AS broj_slucajeva
FROM Zaposlenik Z
JOIN Osoba O ON Z.id_osoba= O.Id
LEFT JOIN Slucaj S ON S.id_voditelj = Z.Id
GROUP BY Z.Id, O.Ime_Prezime
HAVING COUNT(S.Id) = (
    SELECT MAX(broj_slucajeva)
    FROM (
        SELECT COUNT(id) AS broj_slucajeva
        FROM S
        GROUP BY id_voditelj
    ) AS max_voditelj
);

# 17) Ispiši sva mjesta gdje nema evidentiranih kaznjivih djela u slučajevima(ili uopće nema slučajeva)
SELECT M.Id, M.Naziv
FROM Mjesto M
LEFT JOIN Evidencija_dogadaja ED ON M.Id = ED.id_mjesto
LEFT JOIN Slucaj S ON ED.id_slucaj= S.Id
LEFT JOIN Kaznjiva_Djela_u_Slucaju KDS ON S.Id = KDS.id_slucaj
WHERE KDS.id_slucaj IS NULL OR KDS.id_kaznjivo_djelo IS NULL
GROUP BY M.Id, M.Naziv;

#########################################################################################################################################
# POGLEDI
# 1) Ako je uz osumnjičenika povezano vozilo, onda se stvara pogled koji prati sve osumnjičenike i njihova vozila
CREATE VIEW osumnjicenici_vozila AS
SELECT
	O.id AS id_osobe,
	O.ime_prezime,
	O.datum_rodenja,
	O.oib,
	O.spol,
	O.adresa,
	O.telefon,
	O.email,
	V.id AS id_vozila,
	V.marka,
	V.model,
	V.registracija,
	V.godina_proizvodnje
FROM Osoba O
RIGHT JOIN Vozilo V ON O.id = V.id_vlasnik
INNER JOIN Slucaj S ON O.id = S.id_pocinitelj;

# 2) Pronađi sve policajce koji su vlasnici vozila koja su starija od 10 godina
CREATE VIEW policijski_sluzbenici_stara_vozila AS
SELECT O.Ime_Prezime AS Policajac, V.Marka, V.Model, V.Godina_proizvodnje
FROM Osoba O
JOIN Zaposlenik Z ON O.Id = Z.id_osoba
JOIN Vozilo V ON O.Id = V.id_vlasnik
WHERE Z.id_radno_mjesto= (SELECT Id FROM Radno_mjesto WHERE Vrsta = 'Policajac')
AND V.Godina_proizvodnje <= YEAR(NOW()) - 10;

# 3) Napravi pogled koji će pronaći sve osobe koje su počinile kazneno djelo pljačke i pri tome su koristili pištolj (to dohvati pomoću tablice predmet) i nazovi pogled "Počinitelji oružane pljačke"
CREATE VIEW počinitelji_oružane_pljacke AS
SELECT O.ime_prezime AS pocinitelj, K.Naziv AS kazneno_djelo
FROM Osoba O
JOIN Slucaj S ON O.Id = S.id_pocinitelj
JOIN Kaznjiva_Djela_u_Slucaju KDS ON S.Id = KDS.id_slucaj
JOIN Kaznjiva_Djela KD ON KDS.id_kaznjivo_djelo	= KD.id
JOIN Predmet P ON S.id_dokaz= P.id
WHERE K.Naziv = 'Pljačka' AND P.naziv LIKE '%pištolj%';


# 4)Napravi pogled koji će izlistati sva evidentirana kaznena djela i njihov postotak pojavljivanja u slučajevima
CREATE VIEW postotak_pojavljivanja_kaznjivih_djela AS
SELECT
    KD.Naziv AS 'kaznjivo_djelo',
    COUNT(KS.id_slucaj) AS 'broj_slucajeva',
    COUNT(KS.id_slucaj) / (SELECT COUNT(*) FROM Slucaj) * 100 AS 'postotak_pojavljivanja'
FROM
    Kaznjiva_Djela KD
LEFT JOIN
    Kaznjiva_Djela_u_Slucaju KDS
ON
    KD.ID = KDS.id_kaznjivo_djelo
GROUP BY
    KD.Naziv;

# 5) Napravi pogled koji će izlistati sva evidentirana sredstva utvrđivanja istine i broj slučajeva u kojima je svako od njih korišteno
CREATE VIEW evidentirana_sredstva_utvrdivanja_istine AS
SELECT SUI.Naziv AS 'sredstvo_utvrdivanja_istine',
       COUNT(SS.Id_sui) AS 'broj_slucajeva'
FROM Sredstvo_utvrdivanja_istine SUI
LEFT JOIN Sui_slucaj SS ON SUI.id = SS.Id_sui
GROUP BY SUI.id;


# 6) Napravi pogled koji će izlistati sve slučajeve i sredstva utvrđivanja istine u njima, te izračunati trajanje svakog od slučajeva

CREATE VIEW slucajevi_sortirani_po_trajanju_sredstva AS
SELECT S.*, 
       TIMESTAMPDIFF(DAY, S.Pocetak, S.Zavrsetak) AS trajanje_u_danima, 
       GROUP_CONCAT(SUI.Naziv ORDER BY SUI.Naziv ASC SEPARATOR ', ') AS sredstva_utvrdivanja_istine
FROM Slucaj S
LEFT JOIN Sui_slucaj SS ON S.ID = SS.Id_slucaj
LEFT JOIN Sredstvo_utvrdivanja_istine SUI ON SS.Id_sui = SUI.id
GROUP BY S.id
ORDER BY trajanje_u_danima DESC;

# 7) Napiši pogled koji će u jednu tablicu pohraniti sve izvještaje vezane uz pojedine slučajeve
CREATE VIEW izvjestaji_za_slucajeve AS
SELECT S.Naziv AS Slucaj, I.Naslov AS naslov_izvjestaja, I.Sadrzaj AS sadrzaj_izvjestaja, O.Ime_Prezime AS autor_izvjestaja
FROM Izvjestaji I
INNER JOIN Slucaj S ON I.id_slucaj	 = S.ID
INNER JOIN Osoba O ON I.id_autor	= O.Id;

# 8) Napravi pogled koji će izlistati sve osobe i njihove odjele. Ukoliko osoba nije policajac te nema odjel (odjel je NULL), neka se uz tu osobu napiše "Osoba nije policijski službenik"
CREATE VIEW osobe_odjeli AS
SELECT O.ime_prezime AS ime_osobe,
       CASE
           WHEN Z.id_radno_mjesto
           IS NOT NULL THEN OD.Naziv
           ELSE 'Osoba nije policijski službenik'
       END AS naziv_odjela
FROM Osoba O
LEFT JOIN Zaposlenik Z ON O.Id = Z.id_osoba
LEFT JOIN Odjeli OD ON Z.id_odjel= OD.Id;


# 9) Napravi pogled koji će ispisati sve voditelje slučajeva, ukupan broj slučajeva koje vode, ukupan broj rješenjih slučajeva, ukupan broj nerješenih slučajeva i postotak rješenosti
CREATE VIEW voditelji_slucajevi_pregled AS
SELECT
    O.ime_prezime AS voditelj,
    COUNT(S.ID) AS ukupan_broj_slucajeva,
    SUM(CASE WHEN S.Status = 'riješen' THEN 1 ELSE 0 END) AS ukupan_broj_rijesenih_slucajeva,
    SUM(CASE WHEN S.Status = 'aktivan' THEN 1 ELSE 0 END) AS ukupan_broj_nerijesenih_slucajeva,
    (SUM(CASE WHEN S.Status = 'riješen' THEN 1 ELSE 0 END) / COUNT(S.ID)) * 100 AS postotak_rjesenosti
FROM
    Osoba O
LEFT JOIN
    Slucaj S ON O.ID = S.id_voditelj
GROUP BY
    Voditelj;

# 10) Napravi POGLED koji će prikazivati statistiku zapljena za svaku vrstu kaznenog djela (prosjek, minimum, maksimum  (za vrijednosti) i broj predmeta)
CREATE VIEW StatistikaZapljenaPoKaznenomDjelu AS
SELECT
    KD.Naziv AS 'vrsta_kaznjivog_djela',
    AVG(Z.vrijednost) AS 'Prosječna_vrijednost_zapljena',
    MAX(Z.vrijednost) AS 'Najveća_vrijednost_zapljena',
    MIN(Z.vrijednost) AS 'Najmanja_vrijednost_zapljena',
    COUNT(Z.id) AS 'Broj_zapljenjenih_predmeta'
FROM Zapljene Z
JOIN Slucaj S ON Z.id_slucaj	 = S.ID
JOIN Kaznjiva_Djela_u_Slucaju KDS ON S.ID = KDS.id_slucaj
JOIN Kaznjiva_Djela KD ON KDS.id_kaznjivo_djelo = KD.id
GROUP BY KD.Naziv;


SELECT * From StatistikaZapljenaPoKaznenomDjelu;
DROP VIEW StatistikaZapljenaPoKaznenomDjelu;

# 11) Napravi POGLED koji će za svaki slučaj izračunati ukupnu zatvorsku kaznu, uz ograničenje da maksimalna zakonska zatvorska kazna u RH iznosi 50 godina. Ako ukupna kazna premaši 50, postaviti će se na 50 uz odgovarajuće upozorenje
CREATE VIEW ukupna_predvidena_kazna_po_slucaju AS
SELECT S.ID AS 'slucaj_id',
       S.Naziv AS 'naziv_slucaja',
       CASE
           WHEN SUM(KD.predvidena_kazna) > 50 THEN 50
           ELSE SUM(KD.predvidena_kazna)
       END AS 'ukupna_predvidena_kazna',
       CASE
           WHEN SUM(KD.Predvidena_kazna) > 50 THEN 'Maksimalna zakonska zatvorska kazna iznosi 50 godina'
           ELSE NULL
       END AS 'Napomena'
FROM Slucaj S
LEFT JOIN Kaznjiva_djela_u_slucaju KDS ON S.ID = KDS.id_slucaj
LEFT JOIN Kaznjiva_djela KD ON KDS.id_kaznjivo_djelo		= KD.ID
GROUP BY S.id, S.naziv;

# 12)Napiši POGLED koji će za sve policijske službenike dohvatiti njihovu dob i godine staža (ukoliko je još aktivan, oduzimat ćemo od trenutne godine godinu zaposlenja, a ako je umirovljen, oduzimat će od godine umirovljenja godinu zaposlenja)
# Onda dodat još stupac koji prati dali je umirovljen ili aktivan
CREATE VIEW pogled_policijskih_sluzbenika AS
SELECT
    O.Id AS zaposlenik_id,
    O.Ime_Prezime AS ime_prezime_osobe,
    O.datum_rodenja AS datum_rodenja_osobe,
    DATEDIFF(CURRENT_DATE, Z.Datum_zaposlenja) AS Godine_Staza,
    CASE
        WHEN Z.datum_izlaska_iz_sluzbe IS NOT NULL AND Z.Datum_izlaska_iz_sluzbe <= CURRENT_DATE THEN 'Da'
        ELSE 'Ne'
    END AS Umirovljen
FROM Osoba O
INNER JOIN Zaposlenik Z ON O.Id = Z.id_osoba;

# 13) Napravi pogled koji će dohvaćati sve osumnjičenike, zajedno s kažnjivim djelima za koja su osumnjičeni
CREATE VIEW pogled_osumnjicene_osobe_ AS
SELECT DISTINCT O.Ime_Prezime, KD.Naziv AS 'naziv_kaznjivog_djela'
FROM Osoba O
JOIN Slucaj S ON O.Id = S.id_pocinitelj
JOIN Kaznjiva_djela_u_slucaju KDS ON S.Id = KD.id_slucaj
JOIN Kaznjiva_djela K ON KD.id_kaznjivo_djelo = KD.id;

# 14) Napravi pogled koji će izlistati sve pse i broj slučajeva na kojima je svaki od njih radio. U poseban stupac dodaj broj riješenih slučajeva od onih na kojima su radili. Zatim izračunaj postotak rješenosti slučajeva za svakog psa i to dodaj u novi stupac
CREATE VIEW pregled_pasa AS
SELECT
    PA.Id AS pas_id,
    PA.Oznaka AS OznakaPsa,
    O.Ime_Prezime AS Vlasnik,
    COUNT(S.Id) AS broj_slucajeva,
    SUM(CASE WHEN S.Status = 'Riješen' THEN 1 ELSE 0 END) AS broj_rijesenih,
    (SUM(CASE WHEN S.Status = 'Riješen' THEN 1 ELSE 0 END) / COUNT(S.Id) * 100) AS postotak_rijesenosti
FROM
    Pas AS PA
LEFT JOIN Slucaj AS S ON PA.Id = S.id_pas
LEFT JOIN Osoba AS O ON PA.Id_trener = O.Id
GROUP BY
    P.Id;

# 15) Nadogradi prethodni POGLED tako da pronalazi najefikasnijeg psa, s najvećim postotkom rješenosti
CREATE VIEW najefikasniji_pas AS
SELECT
    pas_id,
    oznaka_psa,
    vlasnik,
    broj_slucajeva,
    broj_rijesenih,
    postotak_rijesenosti
FROM
    pregled_pasa
WHERE
    postotak_rijesenosti = (SELECT MAX(postotak_rijesenosti) FROM pregled_pasa);

-- 16) Napravi pogled koji prikazuje broj kazni zboog brze vožnje u svakom gradu u proteklih mjesec dana. Zatim pomoću upita ispiši grad
-- u kojem je bilo najviše kazni zbog brze vožnje u proteklih mjesec dana.

CREATE VIEW brza_voznja_gradovi AS
SELECT M.naziv, COUNT(*) AS broj_kazni_za_brzu_voznju
FROM mjesto M INNER JOIN Evidencija_dogadaja ED ON M.id=ED.id_mjesto INNER JOIN slucaj S ON ED.id_slucaj=S.id
WHERE S.naziv LIKE '%brza voznja%' AND ED.datum_vrijeme >= (NOW() - INTERVAL 1 MONTH)
GROUP BY M.naziv;

SELECT *
FROM brza_voznja_gradovi
ORDER BY broj_kazni_za_brzu_voznju DESC
LIMIT 1; 

-- 17) Napravi pogled koji prikazuje sve osobe koje su skrivile više od 2 prometne nesreće u posljednjih godinu dana. 
-- Zatim napravi upit koji će prikazati osobu koja je skrivila najviše prometnih nesreća u posljednjih godinu dana.

CREATE VIEW osoba_prometna_nesreca AS
SELECT O.*, COUNT(*) AS broj_prometnih_nesreca
FROM osoba O
INNER JOIN slucaj S ON O.id = S.id_pocinitelj
INNER JOIN evidencija_dogadaja ED ON S.id = ED.id_slucaj
WHERE ED.datum_vrijeme >= (NOW() - INTERVAL 1 YEAR) AND S.naziv LIKE '%prometna nesreca%'
GROUP BY O.id
HAVING broj_prometnih_nesreca > 2;


SELECT *
FROM osoba_prometna_nesreca
ORDER BY broj_prometnih_nesreca DESC
LIMIT 1;


# 18) Napravi pogled koji će pronaći sva kažnjiva djela koja su se događala u slučajevima
# Zatim napravi upit kojim ćemo moći pronalaziti kažnjiva djela za određeno mjesto po id-ju
CREATE VIEW kaznjiva_djela_na_mjestu AS
SELECT ED.id_mjesto, KD.Naziv, KD.Opis
FROM Kaznjiva_djela_u_slucaju KDS
JOIN Kaznjiva_Djela KD ON KDS.id_kaznjivo_djelo = KD.ID
JOIN Evidencija_Dogadaja ED ON KDS.id_slucaj = ED.id_slucaj;

SELECT * FROM Kaznjiva_Djela_Na_Mjestu WHERE ED.id_mjesto = 1;


# 19) Napravi pogled koji će dohvatiti sve osobe, slučajeve koje su počinili i KD u njima
CREATE VIEW osobe_kaznjiva_djela AS
SELECT DISTINCT O.Ime_Prezime, KD.Naziv, S.id, S.opis AS id_slucaj
FROM Osoba O
JOIN Slucaj S ON O.Id = S.id_pocinitelj
JOIN Kaznjiva_djela_u_slucaju KDS ON S.Id = KDS.id_slucaj
JOIN Kaznjiva_djela KD ON KDS.id_kaznjivo_djelo = K.id;



# 20) Napravi pogled koji će ispisati sve slučajeve i evidentirane događaje za osobe.
# Podaci će se zatim moći filtrirati (npr. po imenu i prezimenu)
# Ispišimo slučajeve i evidencije za određenu osobu (osumnjičenika)

CREATE VIEW slucajevi_dogadaji_osoba AS
SELECT S.Naziv AS 'Naziv slučaja', ED.opis_dogadaja, ED.datum_vrijeme, ED.id_mjesto, O.Ime_Prezime
FROM Slucaj S
JOIN Evidencija_dogadaja ED ON S.Id = ED.id_slucaj
JOIN Osoba O ON O.Id = S.id_pocinitelj;



#21) Napravi pogled koji će dohvaćati sve događaje koji su vezani za slučajeve koji sadrže određeno kažnjivo djelo
CREATE VIEW Dogadaji_Kaznjiva_Djela AS
SELECT ED.Opis_Dogadaja, ED.Datum_Vrijeme, KD.Naziv AS 'Naziv kaznjivog djela'
FROM Evidencija_Dogadaja ED
JOIN Slucaj S ON ED.id_slucaj = S.Id
JOIN Kaznjiva_Djela_u_Slucaju KDS ON S.Id = KDS.id_slucaj
JOIN Kaznjiva_Djela KD ON KDS.id_kaznjivo_djelo = KD.Id;

# 22) Napravi pogled koji će dohvaćati sve slučajeve u posljednjih N dna (stavljeno je 10000)
CREATE VIEW Slucajevi_u_posljednjih_n_dana AS
SELECT 
    S.ID AS id_slucaj,
    S.Naziv AS Naziv_slucaja,
    S.Status,
    S.id_voditelj,
    O.ime_prezime AS ime_i_prezime_voditelja
FROM 
    Slucaj S
JOIN 
    Zaposlenik Z ON S.id_voditelj = Z.id
JOIN 
    Osoba O ON O.id = Z.id_osoba
WHERE 
    S.Pocetak BETWEEN CURDATE() - INTERVAL 10000 DAY AND CURDATE(); # OVAJ INTERVAL MIJENJAMO PREMA POTREBI
##############################################################################################################################################
# 23) Napiši pogled koja će dohvaćati slučajeve koji sadrže određeno kazneno djelo i sortirati ih po vrijednosti zapljene silazno
CREATE VIEW Slucajevi_po_kaznjivom_djelu AS
SELECT
    Slucaj.id AS SlucajID,
    Slucaj.naziv AS NazivSlucaja,
    ukupna_vrijednost_zapljena AS UkupneZapljene
FROM
    Slucaj
JOIN
    Kaznjiva_djela_u_slucaju ON Slucaj.id = Kaznjiva_djela_u_slucaju.id_slucaj
JOIN
    Kaznjiva_djela ON Kaznjiva_djela_u_slucaju.id_kaznjivo_djelo = Kaznjiva_djela.id
LEFT JOIN
    Zapljene ON Slucaj.id = Zapljene.id_slucaj
GROUP BY
    Slucaj.id, Slucaj.naziv
ORDER BY
    UkupneZapljene DESC;


DROP VIEW Slucajevi_po_kaznjivom_djelu;
SELECT * FROM Slucajevi_po_kaznjivom_djelu WHERE NazivSlucaja LIKE('%krađa%');
SELECT * FROM Slucaj WHERE Naziv LIKE('%krađa%');
select * from zapljene WHERE id_slucaj  = 4;
# 24) Napiši pogled koja će ispisati sve slučajeve i za svaki slučaj ispisati voditelja i ukupan iznos zapljena. Ako nema pronađenih slučajeva, neka nas obavijesti o tome
# Pretvoreno u pogled
CREATE VIEW Podaci_o_slucajevima_zapljenama AS

SELECT
    Slucaj.id AS Slucaj_ID,
    Osoba.ime_prezime AS Voditelj_ime_prezime,
    COALESCE(SUM(Zapljene.Vrijednost), 0) AS Ukupan_iznos_zapljena
FROM
    Slucaj
JOIN
    Zaposlenik ON Slucaj.id_voditelj = Zaposlenik.id
JOIN
    Osoba ON Zaposlenik.id_osoba = Osoba.id
LEFT JOIN
    Zapljene ON Slucaj.id = Zapljene.id_slucaj
GROUP BY
    Slucaj.id, Osoba.ime_prezime;

SELECT * FROM Podaci_o_slucajevima_zapljenama;
# 25) Napravi pogled koji će prikazati slučajeve koji su počeli u zadnjih n dana
CREATE VIEW Slucajevi_u_posljednjih_n_dana AS
SELECT 
    S.ID AS id_slucaj,
    S.Naziv AS Naziv_slucaja,
    S.Status,
    S.id_voditelj,
    O.ime_prezime AS ime_i_prezime_voditelja
FROM 
    Slucaj S
JOIN 
    Zaposlenik Z ON S.id_voditelj = Z.id
JOIN 
    Osoba O ON O.id = Z.id_osoba
WHERE 
    S.Pocetak BETWEEN CURDATE() - INTERVAL 10000 DAY AND CURDATE(); # OVAJ INTERVAL MIJENJAMO PREMA POTREBI
DROP VIEW Slucajevi_u_posljednjih_n_dana;
SELECT * FROM Slucajevi_u_posljednjih_n_dana;
SELECT * FROM slucaj;
