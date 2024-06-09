#APPELLO 31 GENNAIO 2015

/*		ESERCIZIO 1
Scrivere una query che restituisca la dose giornaliera media dei farmaci indicati
per la cura di sole patologie intestinali
*/
select avg(I.DoseGiornaliera) as MediaDoseGiornaliera
from Indicazione I inner join Patologia P1 on I.Patologia=P1.Nome
where P1.ParteCorpo='Intestino' and 
      I.Farmaco not in (
						select I1.Farmaco
                        from Indicazione I1 inner join Patologia P on I1.Patologia=P.Nome
                        where P.ParteCorpo<>'Intestino'
                        );


/* 		ESERCIZIO 2
Scrivere una query che restituisca, per il sesso maschile e per quello femminile, 
rispettivamente, il numero di pazienti attualmente affetti da ipertensione, 
trattata con lo stesso farmaco da più di venti anni.
*/

select P.Sesso, count(distinct T.Paziente) as NumPazienti
from Paziente P inner join Terapia T on P.CodFiscale=T.Paziente
where T.Patologia='Ipertensione' and 
	  T.DataFineTerapia is null and
      T.Farmaco in (
						select T1.Farmaco
                        from Terapia T1 inner join Paziente P1 on T1.Paziente=P1.CodFiscale
                        where T1.Paziente=T.Paziente and
                              T1.Patologia=T.Patologia and
                              T1.DataFineTerapia is null and
                              T1.DataInizioTerapia < current_date - interval 20 year
                        )
group by P.Sesso;


/* 	ESERCIZIO 3
Scrivere una query che, considerate le sole patologie muscolari, elimini gli esordi 
conclusi con guarigione relativi a pazienti che hanno contratto, e curato con successo,
almeno due di tali patologie.
*/

-- query che mi restituisce solo le patologie muscolari
select P.Nome
from Patologia P
where P.ParteCorpo='Muscoli';

-- pazienti che hanno contratto e curato almeno due patologie muscolari
select E.Paziente
from Esordio E inner join Patologia P on E.Patologia=P.Nome
where P.ParteCorpo='Muscoli' and
      E.DataGuarigione is not null and
      E.Paziente in (
						select E1.Paziente
                        from Esordio E1 inner join Patologia P1 on E1.Patologia=P1.Nome
                        where P1.ParteCorpo='Muscoli' and
                              E1.Patologia<>E.Patologia and
                              E1.DataGuarigione is not null
                    );

                    
-- query richiesta
delete E2.*
from Esordio E2 inner join Patologia P2 on E2.Patologia=P2.Nome
     natural join(
			select E.Paziente
			from Esordio E inner join Patologia P on E.Patologia=P.Nome
			where P.ParteCorpo='Muscoli' and
				  E.DataGuarigione is not null and
				  E.Paziente in (
						select E1.Paziente
                        from Esordio E1 inner join Patologia P1 on E1.Patologia=P1.Nome
                        where P1.ParteCorpo='Muscoli' and
                              E1.Patologia<>E.Patologia and
                              E1.DataGuarigione is not null
                    ) 
     ) as D
where P2.ParteCorpo='Muscoli' and E2.DataGuarigione is not null;
                    

