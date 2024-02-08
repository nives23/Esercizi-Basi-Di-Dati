-- WINDOW FUNCTIONS
/* NB: QUESTA LEZIONE NON AVEVA ESERCIZI "PER CASA" QUINDI QUESTI SONO TUTTI
ESERCIZI FATTI DAL PROFESSORE A LEZIONE, CHE IO RIPROVO A FARE */

-- ESERCIZIO 1
/* Scrivere una query che indichi, per ogni cardiologo, la matricola, la parcella,
e la parcella media della sua specializzazione*/
select M.Matricola, M.Parcella, avg(M.Parcella) over() as PercellaMediaSpec
from Medico M
where M.Specializzazione='Cardiologia';

-- ESERCIZIO 2
/* Scrivere una query che indichi, per ogni medico, la matricola, la
specializzazione, la parcella, e la parcella media della sua specializzazione */
select M.Matricola, M.Specializzazione, M.Parcella, avg(M.Parcella) over(partition by M.Specializzazione) as ParcellaMediaSpec	-- qui indico la media delle parcelle per ogni specializzazione
from Medico M;

select M.Matricola, M.Specializzazione, M.Parcella, avg(M.Parcella) over() as PercellaMediaSpec	-- qui indico la media delle parcelle di TUTTE le specializzazioni
from Medico M;

-- ESERCIZIO 3
/* Assegnare un numero a ogni medico nella sua specializzazione */
select M.Matricola, M.Specializzazione, row_number() over(partition by M.Specializzazione)
from Medico M;

-- ESERCIZIO 4
/* Classificare i medici in base alla loro convenienza. Restituire matricola,
cognome, specializzazione, parcella e posizione in classifica. 
(NB: Le parcelle più basse sono più convenienti e quindi avranno un rank migliore) */
select M.Matricola, M.Cognome, M.Specializzazione, M.Parcella, dense_rank() over(order by M.Parcella)
from Medico M;

-- ESERCIZIO 5
/* Effettuare una classifica dei medici di ogni specializzazione dipendentemente 
dalla loro parcella, partendo dalla più alta. Restituire matricola, cognome, 
specializzazione, parcella e posizione in classifica. 
(NB: In questo caso il rank è tanto più piccolo, e quindi migliore, quanto più la parcella è alta) */
select M.Matricola, M.Cognome, M.Specializzazione, M.Parcella, rank() over(partition by M.Specializzazione order by M.Parcella desc)
from Medico M;

-- ESERCIZIO 6
/* Stilare una classifica dei medici in base al numero di visite effettuate.
Restituire cognome, specializzazione, numero di viste effettuate, posizione
nella classifica generale, e posizione nella classifica per specializzazione. */
with visite as	-- cte per avere il numero delle visite associato ad ogni medico
(
	select V.Medico, M.Cognome, M.Specializzazione, count(*) as Visite
    from Visita V inner join Medico M on V.Medico=M.Matricola
    group by V.Medico
)
select VV.Cognome, VV.Specializzazione, VV.Visite, rank() over(order by VV.Visite desc) as GlobalRank,
       rank() over(partition by VV.Specializzazione order by VV.Visite desc) as SpecRank
from visite VV;

-- ESERCIZIO 7
/*Considerare le visite otorinolaringoiatriche dal 2010 al 2019, restituire, per
ciascuna, matricola del medico, codice fiscale del paziente, data, e data della
visita precedente del paziente con un medico della stessa specializzazione */
select V.Medico, V.Paziente, V.Data, lag(V.Data, 1) over(partition by V.Paziente order by V.Data) as VisitaPrec
from Visita V inner join Medico M on V.Medico=M.Matricola
where M.Specializzazione='Otorinolaringoiatria' and year(V.Data) between 2010 and 2019;

-- ESERCIZIO 8
/*Date le visite cardiologiche dei pazienti ‘aaa1’, ‘bbc4’ e ‘ccc2’ nel triennio
2012-2014, restituirne, per ciascuna, matricola del medico, codice fiscale del
paziente, data, e data della prima visita effettuata dal paziente con quel medico*/
select V.Medico, V.Paziente, V.Data, first_value(V.Data) over w as PrimaVisita
from Visita V
where V.Paziente in ('aaa1', 'bbc4', 'ccc2') and year(V.Data) between 2012 and 2014
window w as (partition by V.Medico, V.Paziente order by V.Data);

-- ESERCIZIO 9
/* Scrivere una funzione analytics che, per ogni terapia conclusa del paziente
‘ttw2’, restituisca il farmaco, la durata e la durata media rispetto alla terapia
precedente e successiva con lo stesso farmaco */
with durata as
(
		select T.Farmaco, T.DataInizioTerapia, datediff(T.DataFineTerapia, T.DataInizioTerapia) as Durata
        from Terapia T
        where T.Paziente = 'ttw2' and T.DataFineTerapia is not null
)
select D.Farmaco, D.Durata, D.DataInizioTerapia, avg(D.Durata) over W as DurataMediaTerapia
from durata D
window W as (order by D.DataInizioTerapia rows between 1 preceding and 1 following);

-- ESERCIZIO 10
/* Considerate le visite ortopediche di ogni paziente, scrivere una query analytics
che restituisca codice fiscale del paziente, matricola del medico, la sua parcella,
il numero di visite ortopediche effettuate fino a quel momento, e la spesa
sostenuta dal paziente per tali visite */
select V.Paziente, V.Medico, M.Parcella, count(*) over W as NumVisite, sum(M.Parcella) over W as Spesa
from Visita V inner join Medico M on V.Medico=M.Matricola
where M.Specializzazione = 'Ortopedia'
window W as (
				partition by V.Paziente
                order by V.Data
                rows between unbounded preceding and current row
			);