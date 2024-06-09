-- APPELLO 29-06-15
/*		ESERCIZIO 1
Scrivere una query che restituisca le patologie curate sempre con il farmaco meno costoso fra
tutti quelli indicati. Se, data una patologia, esiste più di un farmaco meno costoso, questi
possono essere stati usati intercambiabilmente. 
*/

-- per ogni patologia mostro il farmaco di costo minimo che lo cura
create or replace view FarmacoMinimoPerPatologia as
	select I.Patologia, I.Farmaco, min(F.Costo) as Costo
    from Indicazione I inner join Farmaco F on I.Farmaco=F.NomeCommerciale
    group by I.Patologia;
     
select T.Patologia
from Terapia T natural join FarmacoMinimoPerPatologia FMPP 
group by T.Patologia
having count(*)=(
					select count(*)
                    from Terapia T1
                    where T1.Patologia=T.Patologia
                );

