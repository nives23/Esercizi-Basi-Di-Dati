/*
Scrivere una query che restituisca nome e cognome del medico che, al 31/12//2014, aveva
visitato un numero di pazienti superiore a quelli visitati da ciascun medico della 
sua stessa specializzazione.
*/

with PazientiVisitatiPerMedico as 	-- cte che per ogni medico di ogni specializzazione mi dice il numero di pazienti visitati al 31/12/2014
(
	select M.Specializzazione, M.Matricola, count(distinct V.Paziente) as NumPazienti
	from Medico M inner join Visita V on M.Matricola=V.Medico
    where V.Data<'2014-12-31'
	group by M.Matricola
)
select M.Nome, M.Cognome		-- query che restituisce il risultato richiesto
from Medico M inner join PazientiVisitatiPerMedico PVPM on M.Matricola=PVPM.Matricola
where PVPM.NumPazienti >= all (
							select PVPM2.NumPazienti
                            from PazientiVisitatiPerMedico PVPM2
                            where PVPM2.Specializzazione=PVPM.Specializzazione
                          );
                          

/*
Scrivere una query che restituisca per ciascun principio attivo, il nome del principio attivo
e il nome commerciale di ogni farmaco utilizzato almeno una volta per tutte le patologie per
le quali è indicato. Il risultato è formato da row(PrincipioAttivo, NomeCommerciale), una per 
ogni farmaco che rispetta la condizione
*/
#non esiste un farmaco che non è stato utilizzato per tutte le patologie per le quali è indicato
select F.PrincipioAttivo, T.Farmaco
from Terapia T inner join Farmaco F on T.Farmaco=F.NomeCommerciale
group by F.PrincipioAttivo, T.Farmaco
having count(distinct T.Patologia)= (
									 select count(*) -- includo solo i farmaci per i quali il numero di patologie trattate
                                     from Indicazione I -- corrisponde al numero totale di patologie indicate per quello
                                     where I.Farmaco=T.Farmaco -- stesso farmaco
                                     );
                                     

/*
Scrivere un trigger che impedisca l'inserimento di due terapie consecutive per lo stesso paziente,
caratterizzate dallo stesso farmaco, con una posologia superiore al doppio rispetto alla precedente. 
*/

drop trigger if exists VietaTerapie;
delimiter $$
create trigger VietaTerapie
before insert on Terapia
for each row
begin
	set @terapiaPrecedente=(
								select count(*)
                                from Terapia T1
                                where T1.Paziente=new.Paziente and T1.Farmaco=new.Farmaco
                                      and T1.Posologia=0.5*new.Posologia
                                      and not exists (
													  select *
                                                      from Terapia T2
                                                      where T2.Paziente=T1.Paziente and T2.DataFineTerapia>T1.DataFineTerapia
                                                            and T2.Farmaco=T1.Farmaco
                                                      )
	);
    
    if @terapiaPrecedente = 1 then
			signal sqlstate '45000'
            set message_text='Terapia non consentita';
	end if;
end $$
delimiter ;