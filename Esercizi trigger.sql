/* NB: QUESTA LEZIONE NON AVEVA ESERCIZI "PER CASA" QUINDI QUESTI SONO TUTTI
ESERCIZI FATTI DAL PROFESSORE A LEZIONE, CHE IO RIPROVO A FARE */

-- ESERCIZIO 1
/* Ogni mese le visite non mutuate di un medico non possono essere più 
di 10. Realizzare un trigger che gestisca questa situazione. */
DROP TRIGGER IF EXISTS blocca_non_mutuate;

DELIMITER $$
CREATE TRIGGER blocca_non_mutuate
BEFORE INSERT ON Visita -- la condizione deve essere verificata prima dell'inserimento
FOR EACH ROW
BEGIN
	DECLARE non_mutuate_mese INTEGER DEFAULT 0;
    
    SET non_mutuate_mese=	-- conto le visite mutuate effettuate fino a quel momento
			(
				SELECT COUNT(*)
                FROM Visita V
                WHERE V.Medico=NEW.Medico
					  AND MONTH(V.Data)=MONTH(current_date)
                      AND YEAR(V.Data)=YEAR(current_date)
                      AND V.Mutuata=1
			);
            
	IF non_mutuate_mese=10 THEN
		SIGNAL sqlstate '45000'
        SET message_text= 'Visita non inseribile';
	END IF;
END $$
DELIMITER ;

-- ESERCIZIO 2
/* Ogni mese, le visite non mutuate di un medico non devono superare quelle
mutuate. Gestire questo vincolo con un trigger opportuno. */
drop trigger if exists CheckValiditaVisita;

delimiter $$
create trigger CheckValiditaVisita before insert on Visita
for each row
begin
	declare visite_mutuate_mese integer default 0;
    declare visite_non_mutuate_mese integer default 0;
    
    set visite_mutuate_mese=	-- setto la variabile che conta le visite mutuate
		(
			select count(*) + if(new.Mutuata=1, 1, 0)
            from Visita V
            where V.Medico=new.Medico and V.Mutuata=1
				  and month(V.Data)=month(current_date)
                  and year(V.Data)=year(current_date)
        );
        
	set visite_non_mutuate_mese= 	-- setto la variabile che conta le visite non mutuate
		(
			select count(*) + if(new.Mutuata=0, 1, 0)
            from Visita V
            where V.Medico=new.Medico and V.Mutuata=0
				  and month(V.Data)=month(current_date)
                  and year(V.Data)=year(current_date)
        );
        
        -- controllo la condizione
        if visite_non_mutuate_mese>=visite_mutuate_mese then
			signal sqlstate '45000'
            set message_text= 'Limite massimo visite mututate superato!';
		end if;
end $$
delimiter ;

-- ESERCIZIO 3
/* Scrivere un trigger che, ogni volta che viene inserita una nuova visita, se essa è mutuata,
imposti l’attributo Ticket in base alle fasce di reddito annue
- ticket pari a euro 36.15 se reddito fra euro 0 ed euro 15,000
- ticket pari a euro 45.25 se reddito fra euro 15,000 ed euro 25,000
- ticket pari a 50.00 euro se reddito oltre 25,000 euro.
Se la visita non è mutuata, inserire NULL. */
drop trigger if exists checkTicket;

delimiter $$
create trigger checkTicket before insert on Visita
for each row
begin
	-- variabile per reddito annuo del paziente
    set @redditoAnnuo=
			(
				select Reddito*12
                from Paziente
                where CodFiscale=new.Paziente
            );
            
	-- cotnrollo fascia reddito e settaggio del ticket
    if new.Mutuata is true then
		if @redditoAnnuo between 0 and 14999 then
			set new.Ticket=36.15;
		elseif @redditoAnnuo between 15000 and 24999 then
			set new.Ticket=45.25;
		else
			set new.Ticket=50.00;
		end if;
	else
		set new.Ticket=null;
	end if;
end $$
delimiter ;

-- ESERCIZIO 4
/* Creare e mantenere giornalmente aggiornata una ridondanza nella tabella
Medico contenente, per ciascuno, il totale di visite effettuate */
create event AggiornaTotaliVisite
on schedule every 1 day
starts '2020-04-24 23:55:00'
do 
	update Medico
    set TotaleVisite = TotaleVisite + (
										select count(*)
                                        from Visita V
                                        where V.Medico=Matricola and V.Data=current_date
                                      );