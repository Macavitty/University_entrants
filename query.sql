Запит: серед напрямків, на які данний абітурієнт подав документи вибрати ті на які він точно проходить,
		тобто: кількість людей, що мають вищі бали (індивидуальні досягнення + екзамен (для кожного внз свої!!!)),
		за вийнятком тих, що мають оригінали на інших напрямках ТА пріоритет на цих напрамках дорівнює 1,
		не перевищує квоти


CREATE OR REPLACE FUNCTION usefull_func(in entrant bigint, out "специальность" text, out "вуз" text, out "город" text)
RETURNS SETOF record
AS
$$ 
	select distinct наименование, полное_название, substring(адрес, 0, strpos(адрес, ','))
				from специальность_вуза_описание
				natural join (select ид_вуза, код_специальности, count (*) num -- num - загальна кількість людей, яких слід враховувати
								from (select ид_вуза, код_специальности, coalesce(exs+id, exs, id) this_summ -- бали екзамен + ід
												from (select ид_абитуриента, ид_вуза, код_специальности, sum(балл) exs
														from специальность_абит
														natural join специальность_вуза_описание
														natural join экзамен 
														where балл >= порог
														group by (ид_абитуриента, код_специальности, ид_вуза)) as foo -- бали екзамен 
												left join (select ид_абитуриента, ид_вуза, sum(балл) id 
															from специальность_абит
															natural join дополнительные_документы
															natural join индивидуальные_достижения_вуза 
															group by (ид_абитуриента, ид_вуза)) as bar -- бали за ід
												using (ид_абитуриента, ид_вуза)
												where ид_абитуриента = entrant
												group by (ид_абитуриента, код_специальности, ид_вуза, exs, id)) as this_entr -- піддослідний
								join (select  ид_абитуриента, ид_вуза, код_специальности, coalesce(exs+id, exs, id) others_summ -- бали екзамен + ід
												from (select ид_абитуриента, ид_вуза, код_специальности, sum(балл) exs
														from специальность_абит
														natural join специальность_вуза_описание
														natural join экзамен 
														where балл >= порог
														group by (ид_абитуриента, код_специальности, ид_вуза)) as foo -- бали екзамен 
												left join (select ид_абитуриента, ид_вуза, sum(балл) id 
															from специальность_абит
															natural join дополнительные_документы
															natural join индивидуальные_достижения_вуза 
															group by (ид_абитуриента, ид_вуза)) as bar -- бали за ід
												using (ид_абитуриента, ид_вуза)
												where ид_абитуриента in (select a.ид_абитуриента -- для тих, хто на тому ж самому напрямку (та у тому ж внз), що й піддослідний
																			from специальность_абит as a
																			join специальность_абит as b using (код_специальности, ид_вуза) 
																			where a.ид_абитуриента != b.ид_абитуриента and b.ид_абитуриента = entrant)
												and ид_абитуриента not in (select ид_абитуриента -- вийняток
																			from специальность_абит
																			join (select a.ид_абитуриента, код_специальности, ид_вуза
																							from специальность_абит as a
																							join специальность_абит as b using (код_специальности, ид_вуза) 
																							where a.ид_абитуриента != b.ид_абитуриента and b.ид_абитуриента = entrant) as qux
																			using (ид_абитуриента)
																			where приоритет = 1 
																			and статус_абит in ('есть заявление, есть ориг_л', 'нет заявления, есть ориг_л'))
												group by (ид_абитуриента, код_специальности, ид_вуза, exs, id)) as others -- інші
								using (ид_вуза, код_специальности)
								where others_summ >= this_summ
								group by (ид_вуза, код_специальности)) as baz
				natural join специальность
				natural join вуз
				where количество_мест >= num;
$$
LANGUAGE SQL;

select * from usefull_func(16914);

-- DROP FUNCTION usefull_func(bigint);
