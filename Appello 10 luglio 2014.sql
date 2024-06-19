# 10 luglio 2014
/* ESERCIZIO 1
Scrivere una query che, considerate le sole terapie finalizzate alla cura di patologie 
cardiache, restituisca, per ciascuna di esse, il nome della patologia e il farmaco 
più utilizzato per curarla. La soluzione proposta deve presupporre che, data una patologia 
cardiaca, tale farmaco possa non essere unico.
*/
-- terapie per patologie cardiache
select T.*
from Terapia T inner join Patologia P on T.Patologia=P.Nome
where P.ParteCorpo='cuore';

-- per ogni patologia cardiaca il numero dei farmaci usati per curarla
with NumFarmaciPerPatologia as (
	select T.Patologia, T.Farmaco, count(T.Farmaco) as NumUtilizzi
	from Terapia T inner join Patologia P on T.Patologia=P.Nome
	where P.ParteCorpo='cuore'
	group by T.Patologia, T.Farmaco
)
select NFPP.Patologia, NFPP.Farmaco
from NumFarmaciPerPatologia NFPP 
where NFPP.NumUtilizzi>= all(
							select NFPP1.NumUtilizzi
                            from NumFarmaciPerPatologia NFPP1 
                            where NFPP.Patologia=NFPP1.Patologia
                            );

/* ESERCIZIO 2
Scrivere una query che restituisca nome, cognome e reddito dei pazienti di sesso femminile 
che al 15 Giugno 2010 risultavano affetti, oltre alle eventuali altre, da un’unica patologia 
cronica, con invalidità superiore al 50%, e non l’avevano mai curata con alcun farmaco fino 
a quel momento.
*/
select PT.Nome, PT.Cognome, PT.Reddito
from Esordio E inner join Patologia P on E.Patologia=P.Nome
	 inner join Paziente PT on E.Paziente=PT.CodFiscale
where E.Cronica='si' and P.Invalidita>50 
      and PT.Sesso='F' and E.DataEsordio<'2010-06-15' 
      and PT.CodFiscale not in (
						    select T.Paziente
                            from Terapia T
                            where T.Paziente=E.Paziente and T.Patologia=E.Patologia
                                  and T.DataInizioTerapia<'2010-06-15'
                        );


/*  ESERCIZIO 3
Scrivere una query che restituisca, per tutte le patologie, nessuna esclusa, 
il nome della patologia e il numero di pazienti di età superiore a quarant’anni 
che l’hanno contratta almeno due volte, la seconda delle quali
con gravità superiore alla prima, comunque sempre in forma non cronica
*/
-- per ogni patologia e per ogni paziente di almeno 40 anni mi trovo la data del primo esordio 
-- in assoluto, per le patologie contratte almeno due volte
with PrimoEsordio as ( 
	select E.Patologia, E.Paziente, min(E.DataEsordio) as DataEsordio	
    from Esordio E inner join Paziente P on E.Paziente=P.CodFiscale
    where P.DataNascita + interval 40 year < current_date
          and not exists (
							select *
                            from Esordio E2
                            where E2.Paziente=E.Paziente and E2.Patologia=E.Patologia
                                  and E2.Cronica<>'no'
                          )
	group by E.Patologia, E.Paziente
    having count(*)>=2
),
PrimoEsordioGravita as (	-- mi prendo la gravita del primo esordio
	select PE.*, E.Gravita
    from Esordio E natural join PrimoEsordio PE
)
select P.Nome, IF(D.Patologia IS NULL, 0, D.NumeroPazienti) AS TotPazienti
from Patologia P left outer join(
					 select E.Patologia, count(distinct E.Paziente) as NumeroPazienti
					 from PrimoEsordioGravita PEG inner join Esordio E on PEG.Paziente=E.Paziente and PEG.Patologia=E.Patologia and PEG.DataEsordio<E.DataEsordio
					 where datediff(E.DataEsordio, PEG.DataEsordio)=( 
																	 select min(datediff(E2.DataEsordio, PEG2.DataEsordio))
																	 from PrimoEsordioGravita PEG2 inner join Esordio E2 on PEG2.Paziente = E2.Paziente
																		  and PEG2.Patologia = E2.Patologia and PEG2.DataEsordio < E2.DataEsordio
																	 where E2.Paziente = E.Paziente and E2.Patologia=E.Patologia
																	)
					        and PEG.Gravita < E.Gravita
					 group by E.Patologia
 ) as D
on P.Nome = D.Patologia;
