
CREATE TYPE статус_уч_олимпиады 
  AS enum ('победитель', 
            'призер школьного этапа',
            'призер муниципального этапа',
            'призер регионального этапа',
            'призер заключительного этапа');

CREATE TYPE пол AS enum ('м', 'ж');

CREATE TYPE статус_абит 
  AS enum ('есть заявление, есть ориг_л',
            'есть заявление, ориг_л в др вузе',
            'есть заявление, нет ориг_ла',
            'нет заявления, есть ориг_л',
            'нет заявления, ориг_л на др спец_ти',
            'нет заявления, ориг_л в др вузе',
            'нет заявления, нет ориг_ла',
            'есть заявление, ориг_л на др спецти'); -- треба відсліджувати свідоцтво (ориг_л в др вузе / ориг_л на др спецти / нет ориг_ла)

-- 1
CREATE TABLE люди (
	ид_человека bigserial PRIMARY KEY,
	пол пол,
	фамилия text NOT NULL,
	имя text NOT NULL,
	отчество text,
	e_mail text,
	телефон varchar(11)
);

-- 2
CREATE TABLE вуз (
	 ид_вуза bigserial PRIMARY KEY,
	 полное_название text NOT NULL,
	 аббревиатура text,
	 адрес text NOT NULL
);

-- 3
CREATE TABLE олимпиада (
	ид_олимпиады serial PRIMARY KEY,
	название text NOT NULL,
	уровень integer CONSTRAINT level CHECK (уровень > 0 and уровень < 4),
	предмет text NOT NULL,
	UNIQUE (название, предмет)
);

-- 4
CREATE TABLE специальность (
	кодсп_ециальности serial PRIMARY KEY,
	наименование text NOT NULL UNIQUE,
	код_ОКСО varchar(8) NOT NULL UNIQUE --09.03.01
);

-- 5
CREATE TABLE предмет (
	код_предмета serial PRIMARY KEY,
	название_предмета text NOT NULL UNIQUE,
	порог integer CONSTRAINT exam_mark CHECK (порог >= 0 and порог <= 100)
);

-- 6
CREATE TABLE индивидуальные_достижения ( 
	 ид_достижения serial PRIMARY KEY,
	 название text NOT NULL UNIQUE
);

-- 7
CREATE TABLE абитуриент (
	ид_абитуриента bigserial PRIMARY KEY,
	страна text NOT NULL,
	регион text NOT NULL,
	населённый_пункт text NOT NULL,
	учебное_заведение text NOT NULL,	
	дата_рождения date CONSTRAINT birthday CHECK (дата_рождения > current_date - interval '100 years'),
	ид_человека bigint REFERENCES люди ON DELETE CASCADE ON UPDATE CASCADE
);

-- 8
CREATE TABLE документы (
  ид_абитуриента bigint REFERENCES абитуриент ON DELETE CASCADE ON UPDATE CASCADE,
  серия_паспорта varchar(10),
  номер_паспорта varchar(10),
  срок_действия_паспорта date,
  номер_свид_об_образовании varchar(20) NOT NULL 
);

-- 9
CREATE TABLE доверенное_лицо_абитуриента (
  ид_лица bigint REFERENCES люди ON DELETE CASCADE ON UPDATE CASCADE,
  ид_абитуриента bigint REFERENCES абитуриент ON DELETE CASCADE ON UPDATE CASCADE,
  отношение text, --
  PRIMARY KEY (ид_лица, ид_абитуриента) 
);

-- 10
CREATE TABLE контакты_вуза (
  ид_вуза bigint REFERENCES вуз ON DELETE CASCADE ON UPDATE CASCADE,
  телефон varchar(11),
  название text,
  e_mail text,
  PRIMARY KEY (ид_вуза, название)
);

-- 11
CREATE TABLE индивидуальные_достижения_вуза (
  ид_достижения integer REFERENCES индивидуальные_достижения ON DELETE CASCADE ON UPDATE CASCADE,
  ид_вуза bigint REFERENCES вуз ON DELETE CASCADE ON UPDATE CASCADE,
  балл integer CONSTRAINT mark CHECK (балл > 0 and балл < 11),
  PRIMARY KEY (ид_достижения, ид_вуза)
);

-- 12
CREATE TABLE дополнительные_документы (
  ид_абитуриента bigint REFERENCES абитуриент ON DELETE CASCADE ON UPDATE CASCADE,
  ид_достижения integer,
  ид_вуза bigint,
  FOREIGN KEY (ид_достижения, ид_вуза) REFERENCES индивидуальные_достижения_вуза (ид_достижения, ид_вуза) ON DELETE NO ACTION ON UPDATE CASCADE,
  PRIMARY KEY (ид_вуза, ид_абитуриента, ид_достижения)
);

-- 13
CREATE TABLE олимпиада_вуза (
  ид_олимпиады integer REFERENCES олимпиада ON DELETE CASCADE ON UPDATE CASCADE,
  ид_вуза bigint REFERENCES вуз ON DELETE CASCADE ON UPDATE CASCADE,
  статус_уч_олимпиады статус_уч_олимпиады NOT NULL, -- возможно нужно убрать нот нул
  льгота text,
  PRIMARY KEY (ид_олимпиады, ид_вуза, статус_уч_олимпиады)
);

-- 14
CREATE TABLE экзамен (
  код_предмета integer REFERENCES предмет ON DELETE NO ACTION ON UPDATE CASCADE,
  ид_абитуриента bigint REFERENCES абитуриент ON DELETE CASCADE ON UPDATE CASCADE,
  ид_вуза bigint REFERENCES вуз ON DELETE NO ACTION ON UPDATE CASCADE,
  балл integer,	--- trigger
  дата_сдачи date CONSTRAINT exam_date CHECK (дата_сдачи >= current_date - interval '4 years' and дата_сдачи <= current_date),
  PRIMARY KEY (ид_вуза, ид_абитуриента, код_предмета)   
);

-- 15
CREATE TABLE специальность_вуза (
  код_специальности bigint REFERENCES специальность ON DELETE CASCADE ON UPDATE CASCADE,
  ид_вуза bigint REFERENCES вуз ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY (код_специальности, ид_вуза)
);

-- 16
CREATE TABLE специальность_вуза_описание (
  код_специальности bigint,
  ид_вуза bigint,
  код_предмета integer REFERENCES предмет ON DELETE CASCADE ON UPDATE CASCADE,
  порог integer CHECK (порог > 0 and порог < 101),
  количество_мест integer NOT NULL,
  PRIMARY KEY (код_специальности, ид_вуза, код_предмета),
  FOREIGN KEY (ид_вуза, код_специальности) REFERENCES специальность_вуза (ид_вуза, код_специальности) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 17
CREATE TABLE специальность_абит (
  код_специальности integer,
  ид_вуза bigint,
  ид_абитуриента bigint REFERENCES абитуриент ON DELETE CASCADE ON UPDATE CASCADE,
  ид_олимпиады integer REFERENCES олимпиада ON DELETE RESTRICT ON UPDATE CASCADE, 
  статус_уч_олимпиады статус_уч_олимпиады CHECK ((ид_олимпиады IS NULL AND статус_уч_олимпиады IS NULL) OR (ид_олимпиады IS NOT NULL AND статус_уч_олимпиады IS NOT NULL)),
  приоритет integer NOT NULL CONSTRAINT priority CHECK (приоритет > 0 AND приоритет < 16),
  статус_абит статус_абит NOT NULL,
  FOREIGN KEY (ид_вуза, код_специальности) REFERENCES специальность_вуза (ид_вуза, код_специальности) ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY (ид_вуза, код_специальности, ид_абитуриента)
);




-- порог <= бал за іспит <= 100 
CREATE OR REPLACE FUNCTION func_min_exam_mark() RETURNS TRIGGER AS $$
BEGIN
  IF NOT (EXISTS (SELECT код_предмета FROM предмет WHERE код_предмета = NEW.код_предмета)) 
    THEN RAISE NOTICE 'Предмета с кодом % не существует', new.код_предмета; RETURN NULL;
  END IF;
  IF NEW.балл < (SELECT порог FROM предмет WHERE код_предмета = NEW.код_предмета) 
    THEN RAISE NOTICE 'Балл абитуриента (%) ниже порогового (%)', new.балл, (SELECT порог FROM предмет WHERE код_предмета = NEW.код_предмета); RETURN NULL;
  END IF;
  IF NEW.балл > 100
    THEN RAISE NOTICE 'Балл абитуриента выше 100'; RETURN NULL;
  END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER trigger_min_exam_mark
    BEFORE INSERT OR UPDATE ON "экзамен" FOR ROW
    EXECUTE PROCEDURE func_min_exam_mark();


-- абітуріент може бути чиїмось представником, якщо він є повнолітнім
CREATE OR REPLACE FUNCTION func_trustee() RETURNS TRIGGER AS $$
DECLARE 
  age integer = cast((current_date - (SELECT дата_рождения FROM абитуриент WHERE NEW.ид_лица = ид_абитуриента))/365 as integer);
  new_entrant_id_in_people bigint = (SELECT ид_человека FROM абитуриент WHERE NEW.ид_абитуриента = ид_абитуриента);
BEGIN
  IF NEW.ид_лица IN (SELECT ид_человека FROM абитуриент)
    THEN 
      IF NEW.ид_лица = new_entrant_id_in_people
        THEN RAISE NOTICE 'Абитуриент не может являтся дов. лицом самого себя'; RETURN NULL;
      END IF;
      IF age < 18
        THEN RAISE NOTICE 'Несовершеннолетний не может являтся дов. лицом'; RETURN NULL;
      END IF;
  END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER trigger_trustee
    BEFORE INSERT OR UPDATE ON "доверенное_лицо_абитуриента" FOR ROW
    EXECUTE PROCEDURE func_trustee();
    
    
-- сума балов за ід не може бути вишче 10  // цілком даремна функція, але нехай буде
CREATE OR REPLACE FUNCTION func_extra_marks() RETURNS TRIGGER AS $$
DECLARE 
  current_mark integer = (select sum(балл) from индивидуальные_достижения_вуза 
                          natural join дополнительные_документы natural join абитуриент 
                          group by ид_абитуриента, ид_вуза 
                          having ид_абитуриента = new.ид_абитуриента and ид_вуза = new.ид_вуза);
  adding_mark integer = (select балл from индивидуальные_достижения_вуза where new.ид_достижения = ид_достижения and new.ид_вуза = ид_вуза);
BEGIN
  IF  current_mark + adding_mark > 10
    THEN RAISE NOTICE 'За индивидуальные достижения не может быть более 10 баллов'; RETURN NULL;
  END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER trigger_extra_marks
    BEFORE INSERT OR UPDATE ON "дополнительные_документы" FOR ROW
    EXECUTE PROCEDURE func_extra_marks();
    
-- заради безпеки ще має бути перевірка оригиналів

    
CREATE INDEX entr_id ON абитуриент USING hash(ид_абитуриента);
CREATE INDEX olymp_id ON олимпиада USING hash(ид_олимпиады);
CREATE INDEX univ_id ON вуз USING hash(ид_вуза);
CREATE INDEX subj_id ON предмет USING hash(код_предмета);
CREATE INDEX exam_mark ON экзамен USING btree(балл);
CREATE INDEX univ_extra_mark ON индивидуальные_достижения_вуза USING btree(ид_достижения, ид_вуза);
CREATE INDEX man_id ON люди USING hash(ид_человека);
CREATE INDEX entr_birth ON абитуриент USING btree(дата_рождения);
CREATE INDEX entr_extra_mark ON специальность_абит USING btree(ид_вуза, код_специальности, ид_абитуриента); 
CREATE INDEX subj_theshold ON предмет using btree(порог);
CREATE INDEX univ_threshold ON специальность_вуза_описание using btree(порог);
CREATE INDEX priority ON специальность_абит USING btree(приоритет); 
CREATE INDEX univ_spec ON специальность_вуза USING btree(код_специальности, ид_вуза);
CREATE INDEX man_surname ON люди USING btree(фамилия);
CREATE INDEX man_name ON люди USING btree(имя);
CREATE INDEX man_sec_name ON люди USING btree(отчество);
CREATE INDEX man_phone ON люди USING btree(телефон);

---
----
-----
----
---
-- local (university_entrants):
-- люди                           250_000
-- экзамен 						  236_210
-- специальность_абит 			  225_068
-- абитуриент                     150_000
-- документы 					  150_000
-- доверенное_лицо_абитуриента    110_000 
-- специальность_вуза_описание    70_019
-- специальность_вуза             24_149
-- дополнительные_документы  	  8_785
-- индивидуальные_достижения_вуза 1_757
-- олимпиада_вуза 				  1_000
-- олимпиада 				   	  800
-- контакты_вуза                  676 
-- вуз                            502
-- специальность                  72
-- предмет                        31
-- индивидуальные_достижения 	  16