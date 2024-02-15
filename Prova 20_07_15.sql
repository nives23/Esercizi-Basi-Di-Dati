-- Appello 20/07/2015

-- Esercizio 1
/* Scrivere una query che restituisca, se esiste, la città dalla quale proviene il maggior numero di pazienti
che hanno contratto l’acufene un numero di volte maggiore o uguale a quello degli altri pazienti della loro città.*/

-- me la costruisco ragionando a poco a poco

-- cod fiscale pazienti che hanno contratto l'acufene e relativa città 
select E.Paziente, P.Citta
from Esordio E inner join Paziente P on E.Paziente=P.CodFiscale
where E.Patologia= 'Acufene';

-- numero pazienti che hanno contratto l'acufene per ogni città
select count(*) as NumPazienti, P.Citta
from Esordio E inner join Paziente P on E.Paziente=P.CodFiscale
where E.Patologia='Acufene'
group by P.Citta;

-- citta che ha il maggior numero di pazienti che hanno contratto l'acufene
select P.Citta
from Esordio E inner join Paziente P on E.Paziente=P.CodFiscale
where E.Patologia='Acufene'
group by P.Citta
having count(*)>= all (
							select count(*)
							from Esordio E1 inner join Paziente P1 on E1.Paziente=P1.CodFiscale
                            where E1.Patologia='Acufene'
                            group by P1.Citta
					  );

-- numero di volte che un paziente ha contratto l'acufene e la città da cui proviene
select P.CodFiscale, count(*) as VolteAcufene, P.Citta
from Paziente P inner join Esordio E on P.CodFiscale=E.Paziente
where E.Patologia='Acufene' 
group by P.CodFiscale;

-- query richiesta
select P.Citta
from Paziente P inner join Esordio E on P.CodFiscale=E.Paziente
where E.Patologia='Acufene'
group by P.CodFiscale
having count(*)>=all (
					 select count(*)
					from Paziente P inner join Esordio E on P.CodFiscale=E.Paziente
					where E.Patologia='Acufene' 
					group by P.CodFiscale
                     );