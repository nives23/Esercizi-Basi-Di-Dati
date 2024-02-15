-- Appello 29/06/2015

-- Esercizio 1
/* Scrivere una query che restituisca le patologie curate sempre con il farmaco meno costoso fra tutti quelli indicati. 
Se, data una patologia, esiste più di un farmaco meno costoso, questi possono essere stati usati intercambiabilmente. */

-- mi costruisco la soluzione ragionando a poco a poco

-- per ogni patologia il farmaco meno costoso
/*(pensavo mi servisse il costo minimo del farmaco per ogni patologia, invece
conviene ragionare solo sul farmaco più economico dopo)
*/
select P.Nome, I.Farmaco, min(F.Costo) as CostoMinimo
from Patologia P inner join Indicazione I on P.Nome=I.Patologia 
	 inner join Farmaco F on I.Farmaco=F.NomeCommerciale
group by P.Nome;


-- esercizio
with FarmacoPiuEconomico as (	-- considero i farmaci meno costosi
	select I.Farmaco, min(F.Costo) as CostoMinimo
	from Indicazione I inner join Farmaco F on I.Farmaco=F.NomeCommerciale
	group by I.Patologia
    )
select T.Patologia
from Terapia T inner join Farmaco F on T.Farmaco=F.NomeCommerciale
	 natural join FarmacoPiuEconomico FPE
group by T.Patologia
having count(*)=(		-- il conteggio delle terapie associato alla patologia curata col farmaco meno costoso
					select count(*)		-- deve essere lo stesso di quello senza condizioni così siamo sicuri che sia stato curato SEMPRE allo stesso modo
                    from Terapia T1	
                    where T.Patologia=T1.Patologia
                );
                

