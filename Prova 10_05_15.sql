-- Appello 10/06/2015

-- Esercizio 1:
/* Scrivere una query che elimini tutti gli esordi di otite contratta e curata con successo prima di cinque anni fa,
relativi ai soli pazienti che hanno contratto nuovamente, negli ultimi cinque anni, la stessa patologia. */

-- mi costruisco la soluzione ragionando a poco a poco

-- tabella che mi dice i pazienti che hanno contratto l'otite e l'hanno curata prima di cinque anni fa
select E.Paziente
from Esordio E
where E.Patologia='Otite' and year(E.DataGuarigione) < year(current_date)- interval 5 year;

-- tabella che mi dice i pazienti che hanno contratto l'otite negli ultimi 5 anni
select E.Paziente
from Esordio E
where E.Patologia='Otite' and year(E.DataEsordio) > year(current_date)- interval 5 year;

-- tabella che mi dice i pazienti che hanno contratto l'otite e l'hanno curata prima di cinque anni fa e che l'hanno avuta di nuovo negli ultimi 5 anni
select E.Paziente
from Esordio E
where E.Patologia= 'Otite' and year(E.DataGuarigione) < year(current_date) - interval 5 year
	  and E.Paziente in (
							select E1.Paziente
							from Esordio E1
							where E1.Patologia='Otite' and year(E1.DataEsordio) > year(current_date)- interval 5 year
						);
                        
-- query richiesta dall'esercizio
delete E.*
from Esordio E natural join(
							select *
							from Esordio E2
							where E2.Patologia= 'Otite' and year(E2.DataGuarigione) < year(current_date) - 5
								  and exists (
												select *
												from Esordio E1
												where E1.Paziente=E2.Paziente and E1.Patologia='Otite' and year(E1.DataEsordio) > year(current_date)- 5 
												)
					
					)as T;
					
-- Esercizio 2
/*Scrivere una query che, considerati i soli pazienti affetti da ipertensione cronica da almeno dieci anni trattata al
massimo con due farmaci diversi, indichi il nome commerciale del farmaco mediamente più utilizzato per curare
le altre patologie cardiache croniche. In caso di pari merito, il risultato deve essere vuoto. */

-- query che indica i soli pazienti affetti da ipertensione cronica da almeno 10 anni trattata al massimo con due farmaci diversi
select T.Paziente
from Esordio E natural join Terapia T 
where E.Patologia='Ipertensione' and E.Cronica='si' and E.DataEsordio+ interval 10 year< current_date
group by E.Paziente, E.DataEsordio
having count(distinct T.Farmaco)<=2;

-- query che restituisce il nome commerciale dei farmaci usati per curare tutte le patologei cardiache croniche tranne l'ipertensione
select distinct(T.Farmaco) as FarmacoUsato
from Esordio E natural join Terapia T inner join Patologia P on T.Patologia=P.Nome
where P.ParteCorpo='Cuore' and E.Cronica='si' and P.Nome<>'Ipertensione';

-- query dell'esercizio
with PazientiTarget as 
		(
        select T.Paziente
		from Esordio E natural join Terapia T 
		where E.Patologia='Ipertensione' and E.Cronica='si' and E.DataEsordio+ interval 10 year< current_date
		group by E.Paziente, E.DataEsordio
		having count(distinct T.Farmaco)<=2
        ),
        
TotaleUtilizzi as
		(
        select T.Patologia, T.Farmaco, count(distinct T.Paziente) as NumPazienti
        from Esordio E natural join PazientiTarget PT natural join Terapia T inner join Patologia P on T.Patologia=P.Nome
        where P.Nome<>'Ipertensione' and P.ParteCorpo='Cuore' and E.Cronica='si'
        group by T.Patologia, T.Farmaco
        )
        
select TU.Farmaco
from TotaleUtilizzi TU
group by TU.Farmaco
having avg(TU.NumPazienti)> all
				(
					select avg(TU1.NumPazienti)
                    from TotaleUtilizzi TU1
                    where TU.Farmaco<>TU1.Farmaco
                    group by TU1.Farmaco
                );
