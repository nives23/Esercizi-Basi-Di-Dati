-- APPELLO 10 GIUGNO 2015

/*		ESERCIZIO 1
Scrivere una query che elimini tutti gli esordi di otite contratta e curata con successo
prima di cinque anni fa, relativi ai soli pazienti che hanno contratto nuovamente, negli
ultimi cinque anni, la stessa patologia.
*/

-- query che elimina tutti gli esordi di otite 
delete E.*
from Esordio E
where E.Patologia='Otite';

-- esordi di otite contratta e curata con successo prima di cinque anni fa
select *
from Esordio E
where E.Patologia='Otite' 
	  and E.DataGuarigione is not null
	  and year(E.DataEsordio) < year(current_date)- interval 5 year
      and year(E.DataGuarigione) < year(current_date) - interval 5 year;

-- query che elimina tutti gli esordi di otite contratta e curata con successo prima di 5 anni fa      
delete E.*
from Esordio E
where E.Patologia='Otite'
	  and E.DataGuarigione is not null
	  and year(E.DataEsordio) < year(current_date)- interval 5 year
      and year(E.DataGuarigione) < year(current_date) - interval 5 year;
      
-- query che restituisce i pazienti che hanno contratto l'otite negli ultimi 5 anni
select E.Paziente
from Esordio E
where E.Patologia='Otite'
      and year(E.DataEsordio) > year(current_date) - interval 5 year;
      
-- query richiesta 
delete E.*
from Esordio E 
	 natural join 
     (
		select *
        from Esordio E1
        where E1.Patologia='Otite'
              and E1.DataGuarigione is not null
              and year(E1.DataGuarigione) < year(current_date) - interval 5 year
              and exists
					(
						select *
						from Esordio E2
						where E2.Patologia=E1.Patologia
							  and year(E2.DataEsordio) > year(current_date) - interval 5 year
                              and E2.Paziente=E1.Paziente
                    )
     ) as D;
     
     
/*		ESERCIZIO 2
Scrivere una query che, considerati i soldi pazienti affetti da ipertensione cronica da almeno 
dieci anni trattata al massimo con due farmaci diversi, indichi il nome commerciale del farmaco
mediamente più utilizzato per curare le altre patologie cardiache croniche.
*/

create or replace view PazientiTarget as	-- pazienti con ipertensione cronica da almeno 10 anni
	select E.Paziente
	from Esordio E natural join Terapia T 
	where E.DataEsordio<current_date - interval 10 year
		and E.Patologia='Ipertensione' 
		and E.Cronica='si'
	group by E.Paziente, E.DataEsordio
	having count(distinct T.Farmaco)<=2;
    
create or replace view TotaleUtilizzi as	-- per ogni patologia cardiaca cronica che non sia l'ipertensione e per ogni farmaco che la cura, conto quanti pazienti usano quel farmaco tra i pazienti target
	select T.Patologia, T.Farmaco, count(distinct T.Paziente) as NumPazienti
    from Esordio E natural join PazientiTarget PT
         natural join Terapia T 
         inner join Patologia P on T.Patologia=P.Nome
	where P.ParteCorpo='Cuore' and P.Nome<>'Ipertensione' 
          and E.Cronica='si'
	group by T.Patologia, T.Farmaco;

select TU.Farmaco
from TotaleUtilizzi TU
group by TU.Farmaco
having avg(TU.NumPazienti)> ALL (
								select avg(TU1.NumPazienti)
                                from TotaleUtilizzi TU1 
                                where TU1.Farmaco<>TU.Farmaco
                                group by TU1.Farmaco
                                );
