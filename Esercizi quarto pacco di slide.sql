-- ESERCIZI SPIEGATI DAL PROF NELLE SLIDE

/* Indicare nome, cognome e specializzazione dei medici che hanno
effettuato visite eccetto che il giorno 1° Marzo 2013*/
select M.Nome, M.Cognome, M.Specializzazione
from Medico M
where M.Matricola in (
					select V.Medico	-- prendo tutti i medici che hanno effettuato almeno una visita
                    from Visita V
                    )
	 and M.Matricola not in(
							select V.Medico		-- escludo tutti i medici che hanno effettuato visite il 1/03/2013
                            from Visita V
                            where V.Data="2013-03-1"
                            );
                            
/* Indicare il numero degli otorini aventi parcella più alta della media
delle parcelle dei medici della loro specializzazione*/
select count(*) as NumeroDottori
from Medico M
where M.Specializzazione="Otorinolaringoiatria" and
	  M.Parcella>(
				select avg(M1.Parcella)		-- calcolo la parcella media degli otorini
                from Medico M1
                where M1.Specializzazione ="Otorinolaringoiatria"
                );

/* Indicare il reddito massimo ed il nome e cognome di chi lo detiene*/
select P1.Reddito, P1.Nome, P1.Cognome
from Paziente P1
where P1.Reddito=(
				select max(P.Reddito) as RedditoMassimo	-- calcolo il reddito massimo
				from Paziente P
                );
                
/*Indicare nome e cognome dei pazienti che non sono mai stati visitati dal medico
avente la parcella più alta fra tutti i medici della clinica*/
select P.Nome, P.Cognome	-- prendo il nome ed il cognome dei pazienti
from Paziente P
where P.CodFiscale not in(
				select V.Paziente	-- che non si trovano nella tabella visita
                from Visita V
                where V.Medico in(		-- in corrispondenza dei record in cui il medico ha la parcella massima
						select Matricola M1
                        from Medico M1
                        where M1.Parcella=(
								select max(M.Parcella) as ParcellaMax	-- calcolo parcella più alta
								from Medico M
						)
				)
	  
      );

/* Indicare il numero di pazienti di età superiore a 50 anni visitati dai cardiologi di
Pisa aventi parcella inferiore alla media delle parcelle dei cardiologi. */
-- versione fatta da me
select count(distinct P.CodFiscale) as NumPazienti -- prendo il numero dei pazienti
from Paziente P
where datediff(current_date(), P.DataNascita)/365 >50	-- di età superiore a 50
	  and P.CodFiscale in(	-- che sono stati visitati
			select V.Paziente
            from Visita V inner join Medico M on V.Medico=M.Matricola
            where M.Specializzazione="Cardiologia" and M.Citta="Pisa" -- dai cardiologi di pisa
                  and M.Parcella<( -- la cui parcella è inferiore a quella media dei cardiologi
								   select avg(M1.Parcella) 
								   from Medico M1
				                   where M1.Specializzazione="Cardiologia"
                                   )
        );
        
-- versione del professore
select count(distinct CodFiscale)
from Paziente P inner join Visita V on P.CodFiscale=V.Paziente
where current_date>P.DataNascita+ interval 50 year and
	  V.Medico in (
			select M.Matricola
            from Medico M 
            where M.Specializzazione="Cardiologia" and M.Citta="Pisa" and
				  M.Parcella<(select avg(M2.Parcella)
							  from Medico M2
                              where M2.Specializzazione="Cardiologia"
                              )
      );
      
/* Indicare la matricola dei medici che hanno visitato per la prima volta 
almeno un paziente nel mese di ottobre 2013*/
select V.Medico
from Visita V
where V.Data between "2013-10-1" and "2013-10-31"
      and V.Paziente not in(
					select V1.Paziente
                    from Visita V1
                    where V.Medico=V1.Medico and V1.Data<V.Data
                    );
                    
/* Una visita di controllo è una visita in cui un medico visita un paziente
già visitato precedentemente almeno una volta. Indicare medico, paziente e data
delle visite di controllo del mese di Gennaio 2016 */
select V.Medico, V.Paziente, V.Data
from Visita V
where month(V.Data)=1 and year(V.Data)=2016 and 
	  exists (
				select *
                from Visita V1
                where V.Paziente=V1.Paziente and V.Medico=V1.Medico and V1.Data<V.Data
              );

-- STORED PROCEDURE
/* Creare una stored procedure che mostra tutte le specializzazioni della clinica */
drop procedure if exists mostra_spec;
delimiter $$
create procedure mostra_spec()
	begin
		select distinct Specializzazione
		from Medico;
	end $$
    
delimiter ;

call mostra_spec();

-- 
-- ESERCIZI ASSEGNATI DAL PROFESSORE A FINE SLIDE
--

-- ESERCIZIO 1
/* Indicare cognome e nome dei pazienti visitati almeno una volta da tutti
i cardiologi di Pisa nel primo trimestre del 2015 */
select P.Cognome, P.Nome
from Paziente P 
where not exists(
			select *
            from Medico M
            where M.Specializzazione = "Cardiologia" and M.Citta="Pisa"
				and not exists(
						select *
                        from Visita V
                        where V.Medico=M.Matricola and V.Paziente=P.CodFiscale
							and year(V.Data)=2015 and month(V.Data) between 1 and 3
						)
			);
            
-- ESERCIZIO 2
/* Selezionare cognome e specializzazione dei medici la cui parcella è superiore alla 
media delle parcelle della loro specializzazione e che, nell'anno 2011, hanno visitato
almeno un paziente che non avevano mai visitato prima */
with ParcelleMedieSpec as (	-- cte per media parcelle per ogni specializzazione
		select avg(Parcella) as ParcellaMedia
		from Medico
		group by Specializzazione)

select distinct M.Cognome, M.Specializzazione
from Medico M natural join ParcelleMedieSpec PMS
where M.Parcella>PMS.ParcellaMedia 
	  and M.Matricola in(
			select V.Medico		-- la matricola del medico si deve trovare nella tabella visite
            from Visita V 
            where YEAR(V.Data)=2011 and 
				V.Paziente not in (
					select V1.Paziente	-- il paziente non deve aver effettuato una visita precedentemente con quel medico
                    from Visita V1
                    where V.Medico=V1.Medico and V1.Data<V.Data
                )
      );

-- ESERCIZIO 3
/* Scrivere una query che restituisca nome e cognome del medico che, al 31/12/2014,
aveva visitato un numero di pazienti superiore a quelli visitati da ciascun medico
della sua stessa specializzazione*/
with NumPazientiPerMedico as (		-- vedo ogni medico quante visite ha fatto al 31/12/2014
		select count(*) as NumVisite, M.Specializzazione, M.Matricola
        from Medico M inner join Visita V on M.Matricola=V.Medico
        where V.Data<="2014-12-31" 
        group by M.Matricola
)

select M.Nome, M.Cognome, M.Specializzazione	-- prendo nome e cognome dei medici
from Medico M natural join NumPazientiPerMedico NPPM
group by M.Specializzazione
having max(NPPM.NumVisite);

-- ESERCIZIO 4
/* Scrivere una query che restituisca il codice fiscale dei pazienti che sono stati visitati 
sempre dal medico avente la parcella più alta, in tutte le specializzazioni. Se, anche per una 
sola specializzazione, non vi è un unico medico avente la parcella più alta la query non deve
restituire alcun risultato */
with ParcellaMaxSpec as ( -- cte che mi dà il medico di ogni specializzazione con la parcella più alta
		select M.Matricola, M.Specializzazione
		from Medico M
		group by M.Specializzazione
		having max(M.Parcella)
)

select P.CodFiscale
from Paziente P
where P.CodFiscale in (
		select V.Paziente
        from Visita V inner join ParcellaMaxSpec PMS on V.Medico=PMS.Matricola
);



