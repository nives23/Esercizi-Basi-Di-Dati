-- ESERCIZI SVOLTI A LEZIONE DAL PROFESSORE --

/* Scrivere una stored procedure che stampi la parcella media di una
specializzazione specificata come parametro*/

drop procedure if exists parcella_media_spec;

delimiter $$
create procedure parcella_media_spec(in _specializzazione varchar(100))
	begin
		select avg(M.Parcella)
        from Medico M
        where M.Specializzazione= _specializzazione;
    end $$
delimiter ;

call parcella_media_spec('Ortopedia');

-- --- --- --- --- --- --- ---
/*Scrivere una stored procedure che restituisca il numero di pazienti visitati da
medici di una data specializzazione, ricevuta come parametro*/
drop procedure if exists num_pazienti_visite_spec;

delimiter $$
create procedure num_pazienti_visite_spec(in _specializzazione varchar(100), out tot_pazienti int)
	begin
		select count(distinct V.Paziente) into tot_pazienti
        from Visita V inner join Medico M on V.Medico=M.Matricola
        where M.Specializzazione= _specializzazione;
    end $$
delimiter ;

call num_pazienti_visite_spec('Neurologia', @numPazienti);

select @numPazienti;

-- --- --- --- --- --- --- ---
/*Scrivere una stored procedure che riceva come parametro un intero t e una
specializzazione s e restituisca in uscita true se il numero di visite della specializzazione
s nel mese in corso è superiore a t, false se è inferiore, e NULL se è uguale */
drop procedure if exists visite_sopra_soglia;

delimiter $$
create procedure visite_sopra_soglia(in _t int, in _s varchar(100), out pass boolean)
	begin
		declare visite_mese_attuale int default 0;
        set visite_mese_attuale=(
									select count(*)
                                    from Visita V inner join Medico M on V.Medico=M.Matricola
                                    where M.Specializzazione=_s and month(V.Data)=month(current_date)
										  and year(V.Data)=year(current_date)
								);
		
        if visite_mese_attuale<_t then
			set pass=false;
		elseif visite_mese_attuale>_t then
			set pass=true;
		else
			set pass=null;
		end if;
    end $$
delimiter ;

call visite_sopra_soglia(9, 'Cardiologia', @controllo);

select @controllo;

-- --- --- --- --- --- --- ---
/* Scrivere una stored procedure che restituisca la data in cui un paziente, il cui codice fiscale è
passato come parametro, è stato visitato per la prima volta, e il nome e cognome del medico
che lo ha visitato in tale circostanza. In caso di più medici, per semplicità, selezionarne uno. */
drop procedure if exists prima_visita;

delimiter $$
create procedure prima_visita(in cf_ varchar(16), out dataVisita date, out nomeDott varchar(100), out cognomeDott varchar(100))
	begin
		select min(V.Data) into dataVisita
        from Visita V
        where V.Paziente=cf_;
        
        select M.Nome, M.Cognome into nomeDott, cognomeDott
        from Medico M inner join Visita V on M.Matricola=V.Medico
        where V.Data=dataVisita and V.Paziente=cf_
        limit 1;
    end $$
delimiter ;

call prima_visita('aaa1', @primaVisita, @dottoreN, @dottoreC);

select @primaVisita, @dottoreN, @dottoreC; -- chiamata priva di significato che mi serve solo per capire se stampa qualcosa o no

-- --- --- --- --- --- --- ---
/* Scrivere una stored procedure che riceve in ingresso un intero i
e stampa a video i primi i interi separati da virgola, in ordine crescente*/
drop procedure if exists stampa_interi;

delimiter $$
create procedure stampa_interi(in i int)
begin
	declare s varchar(255) default '1';
    declare c int default 2;
    
    while c<=i do
		set s=concat(s, ' ,',c);
        set c=c+1;
	end while;
    
    select s;
end $$
delimiter ;

call stampa_interi(7);

-- --- --- --- --- --- --- ---
/* Scrivere una stored procedure che riceve in ingresso un intero i
e stampa a video i numeri dispari da 1 a i, separati da virgola */
drop procedure if exists stampa_dispari;

delimiter $$
create procedure stampa_dispari(in i int)
begin
	declare s varchar(255) default ' ';
    declare c int default 1;
    
    if i>0 then
		set s='1';
	end if;
    
    scan: loop
		set c=c+1;
        
        if c=i+1 then
			leave scan;
		end if;
        
        if(c%2)=0 then
			iterate scan;
		else 
			set s=concat(s, ',', c);
		end if;
	end loop;
    
    select s;
end $$
delimiter ;

call stampa_dispari(10);

-- --- --- --- --- --- --- ---
/* Scrivere una stored procedure che riceve in ingresso una specializzazione s
e restituisca i codici fiscali dei pazienti visitati da un solo medico di s,
in una stringa del tipo “codFiscale1, ... , codFiscaleN” */
drop procedure if exists PazientiSingoloMedico;

delimiter $$
create procedure PazientiSingoloMedico(in spec_ char, out codF_ varchar(255))
begin
	declare finito integer default 0;
    declare codfiscale varchar(255) default ' ';
    
    -- dichiarazione del cursore
    declare cursoreCodici cursor for
		select V.Paziente
        from Visita V inner join Medico M on V.Medico=M.Matricola
        where M.Specializzazione=spec_
        group by V.Paziente
        having count(distinct V.Medico)=1;
	
    -- dichiaro l'handler per il cursore
    declare continue handler 
		for not found set finito=1;
        
	open cursoreCodici; -- apertura cursore
    
    -- ciclo di fetch per il prelievo
    preleva: loop
		fetch cursoreCodici into codfiscale;
        if finito=1 then
			leave preleva;
		end if;
        set codF_ = concat(codfiscale, ';', codF_);
	end loop preleva;
    
    close cursoreCodici;	-- chiusura cursore
        
end $$
delimiter ;

set @cf='';
call PazientiSingoloMedico('Ortopedia', @cf);
select @cf as CodiciPazienti;

