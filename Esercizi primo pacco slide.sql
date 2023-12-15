/* SIA DATO IL SEGUENTE SCHEMA DI TABELLA:
STUDENTE (Matricola, Cognome, Nome, DataNascita, DataIscrizione, DataLaurea,
NumeroEsamiSostenuti, Facolta) 
*/

-- Esercizio 1 --
/* Indicare la matricola degli studenti che non si erano ancora laureati il 15 luglio 2005*/

select Matricola
from STUDENTE
where DataLaurea>'2005-07-15';

-- Esercizio 2 --
/*Indicare matricola e cognome degli studenti il cui percorso di studi è durato (o dura da) oltre sei anni*/
select Matricola, Cognome
from STUDENTE
where (DataLaurea IS NOT NULL AND DataLaurea>DataIscrizione+INTERVAL 6 YEAR) OR (DataLaurea IS NULL AND DataIscrizione<current_date - INTERVAL 6 YEAR);

-- Esercizio 3 --
/*Indicare nome, cognome ed età degli studenti laureati quest’anno in Lettere (durata standard 5 anni a ciclo
unico), non fuori corso e come minimo con un anticipo di sei mesi rispetto alla durata standard.*/
select Nome, Cognome, (YEAR(current_date)-YEAR(DataNascita)) AS Eta
from STUDENTE
where YEAR(DataLaurea)=YEAR(current_date) AND 
	  (YEAR(DataLaurea) - YEAR(DataIscrizione) <5 OR YEAR(DataLaurea)-YEAR(DataIscrizione) = 5 AND MONTH(DataLaurea)<=6) 
      AND Facolta='Lettere';
      
-- Esercizio 4 --
/*Indicare matricola e cognome degli studenti laureati fuori corso, cioè oltre il mese di Aprile del 6° anno,
nell’anno accademico 2009-2010*/
select Matricola, Cognome
from Studente
where DataLaurea IS NOT NULL and (YEAR(DataLaurea)='2009' or year(DataLaurea)='2010') and 
	  (year(DataLaurea)>year(DataIscrizione)+6) or
      (year(DataLaurea)>year(DataIscrizione)+6 and month(DataLaurea)>4);