-- ESERCIZI SPIEGATI DA LUI NELLE SLIDE

/* Restituire valor medio e deviazione standard delle parcelle medie
dei medici delle varie specializzazioni*/
select avg(D.ParcellaMedia) as ValoreMedio, stddev(D.ParcellaMedia) as DevStd
from (
	select avg(Parcella) as ParcellaMedia
    from Medico M
    group by Specializzazione
	) as D;
    
/*Per ogni specializzazione medica, indicarne il nome, la parcella minima
e il cognome del medico a cui appartiene*/
select M.Specializzazione, D.ParcellaMinima, M.Cognome
from Medico M natural join
	(	-- prendo le specializzazioni e le relative parcelle minime
		select M1.Specializzazione, min(M1.Parcella) as ParcellaMinima
        from Medico M1
        group by M1.Specializzazione
    ) as D
where M.Parcella=D.ParcellaMinima; -- la parcella del medico deve essere la stessa della parcella minima della subquery

/* Indicare le specializzazioni con la più alta parcella media */
select M.Specializzazione
from Medico M
group by M.Specializzazione
having avg(M.Parcella) = (
				-- calcolo della più alta parcella media
				select max(D.ParcellaMedia)
				from(
					-- calcolo media delle parcelle per ogni specializzazione
					select M1.Specializzazione, avg(M1.Parcella) as ParcellaMedia 
					from Medico M1
					group by M1.Specializzazione
					) as D
);

/* Indicare il numero di pazienti di Siena, mai visitati da Ortopedici */
with PazientiVisiteOrtopedicheSiena as
	(
		select P.CodFiscale
        from Visita V inner join Medico M on V.Medico=M.Matricola 
			inner join Paziente P on V.Paziente = P.CodFiscale
        where M.Specializzazione= "Ortopedia" and P.Citta= "Siena"
    )
select count(*)
from Paziente P natural right outer join PazientiVisiteOrtopedicheSiena PVSO 
where PVSO.CodFiscale is null;

-- Versione 2, fatta da me con la not in senza uso di CTE :)
select count(*)
from Visita V inner join Paziente P on V.Paziente=P.CodFiscale inner join Medico M1 on V.Medico=M1.Matricola
where M1.Specializzazione= "Ortopedia" and P.Citta="Siena" and P.CodFiscale not in (
		select P1.CodFiscale
        from Visita V1 inner join Medico M on V1.Medico=M.Matricola
			inner join Paziente P1 on V1.Paziente=P1.CodFiscale
        where M.Specializzazione="Ortopedia" and P1.Citta="Siena"
);

-- 
-- ESERCIZI ASSEGNATI DAL PROFESSORE A FINE SLIDE
-- 

-- ESERCIZIO 1
/* Considerata ogni specializzazione, indicarne il nome e l’incasso degli ultimi due anni*/
select M.Specializzazione, sum(M.Parcella) as Incassi
from Medico M inner join Visita V on M.Matricola = V.Medico
where year(V.Data) between year(current_date()) and year(current_date()) - interval 2 year	-- prendo solo le visite effettuate negli ultimi due anni
group by M.Specializzazione;

-- ESERCIZIO 2
/*Indicare le specializzazioni aventi medici della stessa città.*/
select M.Specializzazione
from Medico M
group by M.Specializzazione
having count(distinct M.Citta)=1;

-- ESERCIZIO 3
/*Indicare codice fiscale, nome, cognome ed età del paziente più anziano della clinica,
e il numero di volte da cui è stato visitato da ogni medico.*/
-- paziente più anziano della clinica
with PazientePiuAnziano as (
		select CodFiscale, Nome, Cognome, datediff(current_date(), DataNascita)/365 as Eta
		from Paziente 
		where DataNascita= (select min(P1.DataNascita) from Paziente P1)
)
select PPA.CodFiscale, PPA.Nome, PPA.Cognome, PPA.Eta, V.Medico, count(*) as NumVisite
from Visita V inner join PazientePiuAnziano PPA on V.Paziente=PPA.CodFiscale inner join Medico M on V.Medico=M.Matricola
group by V.Medico;

-- ESERCIZIO 4
/*Indicare la matricola dei medici che hanno effettuato più del 20% delle visite annue
della loro specializzazione in almeno due anni fra il 2010 e il 2020. */
with ContaVisiteSpec as (	-- conto le visite per ogni specializzazione dal 2010 al 2020
		select M.Specializzazione , count(*) as NumVisite
        from Medico M inner join Visita V on M.Matricola=V.Medico
        where year(V.Data) between 2010 and 2020
        group by M.Specializzazione
)
select M.Matricola
from Medico M inner join Visita V on M.Matricola=V.Medico inner join ContaVisiteSpec CVS on M.Specializzazione=CVS.Specializzazione
where year(V.Data) between 2010 and 2020
group by M.Matricola, M.Specializzazione, CVS.NumVisite
having count(*)/CVS.NumVisite*100>20;	-- condizione che verifica che siano state effettuate più del 20% delle visite annue

-- ESERCIZIO 5
/*Fra tutte le città da cui provengono più di tre pazienti con reddito superiore a 1000
Euro, indicare quelle da cui provengono almeno due pazienti che sono stati visitati più
di una volta al mese, nel corso degli ultimi 10 anni.*/
with VisiteDieci as (		-- pazienti visitati più di una volta al mese nel corso degli ultimi 10 anni
		select P.CodFiscale
		from Visita V inner join Paziente P on V.Paziente=P.CodFiscale
		where year(V.Data) between year(current_date()) and year(current_date())-interval 10 year 
		group by month(V.Data), year(V.Data)
		having count(*)>1
)
select P.Citta
from Visita V inner join Paziente P on V.Paziente=P.CodFiscale inner join VisiteDieci VD on V.Paziente=VD.CodFiscale
where P.Citta in (	
			select P1.Citta		-- città con più di 3 pazienti aventi reddito superiore a 1000
			from Paziente P1
			where P1.Reddito>1000
            group by P1.Citta
			having count(*)>3
            )
group by P.Citta
having count(*)>=2;
