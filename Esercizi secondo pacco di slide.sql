-- ESERCIZIO 1 
/*Indicare l’incasso totale degli ultimi due anni, realizzato grazie alle visite dei
medici cardiologi della clinica.*/
select sum(V.Mutuata) as IncassoTotale
from Medico M INNER JOIN Visita V ON M.Matricola=V.Medico
where M.Specializzazione="Cardiologia" AND 
	  YEAR(V.Data) BETWEEN YEAR(current_date) AND YEAR(current_date())- INTERVAL 2 year; 
      
-- ESERCIZIO 2
/* Indicare il numero di pazienti di sesso femminile che, nel quarantesimo anno
d’età, sono stati visitati, una o più volte, sempre dallo stesso gastroenterologo. */
SELECT COUNT(DISTINCT V1.Paziente) AS NumeroPazienti
FROM Visita V1 INNER JOIN Visita V2 ON (V2.Medico = V1.Medico AND V2.Paziente = V1.Paziente)
	INNER JOIN Medico M ON (V1.Medico=M.Matricola)
WHERE M.Specializzazione= "Gastroenterologia" AND
		V1.Paziente IN (SELECT P.CodFiscale
						FROM Paziente P
						WHERE YEAR(V1.Data)=YEAR(P.DataNascita) + INTERVAL 40 YEAR AND P.Sesso= "F");
                        
-- ESERCIZIO 3
/* Indicare l'età media dei pazienti mai visitati da ortopedici */
SELECT AVG(YEAR(current_date())- YEAR(P.DataNascita)) as EtaMedia
FROM Visita V INNER JOIN Medico M ON V.Medico=M.Matricola INNER JOIN Paziente P ON V.Paziente=P.CodFiscale
WHERE M.Specializzazione <> "Ortopedia" ;

-- ESERCIZIO 4
/*Indicare nome e cognome dei pazienti che sono stati visitati non meno di due
volte dalla dottoressa Gialli Rita.*/
SELECT P.Nome, P.Cognome
FROM Visita V1 INNER JOIN Visita V2 ON (V1.Medico=V2.Medico AND V1.Paziente=V2.Paziente AND V1.Data<>V2.Data) 
	 INNER JOIN Paziente P ON V1.Paziente=P.CodFiscale
WHERE V1.Medico IN (SELECT M.Matricola
					FROM Medico M
                    WHERE M.Nome="Rita" AND M.Cognome="Gialli");
                    
-- ESERCIZIO 5
/*Indicare il reddito medio dei pazienti che sono stati visitati solo da medici con
parcella superiore a 100 euro, negli ultimi sei mesi.*/
SELECT AVG(P.Reddito) AS RedditoMedio
FROM Visita V INNER JOIN Paziente P ON V.Paziente=P.CodFiscale INNER JOIN Medico M ON V.Medico=M.Matricola 
WHERE M.Parcella>100 AND V.Data>=DATE_SUB(current_date(), INTERVAL 6 MONTH);