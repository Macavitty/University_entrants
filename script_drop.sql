DROP INDEX entr_id ON абитуриент;
DROP INDEX olymp_id ON олимпиада;
DROP INDEX univ_id ON вуз;
DROP INDEX subj_id ON предмет;
DROP INDEX exam_mark ON экзамен;
DROP INDEX univ_extra_mark ON индивидуальные_достижения_вуза;
DROP INDEX man_id ON люди;
DROP INDEX entr_birth ON абитуриент;
DROP INDEX entr_extra_mark ON специальность_абит; 
DROP INDEX subj_theshold ON предмет;
DROP INDEX univ_threshold ON специальность_вуза_описание;
DROP INDEX priority ON специальность_абит; 
DROP INDEX univ_spec ON специальность_вуза;
DROP INDEX man_surname ON люди;
DROP INDEX man_name ON люди;
DROP INDEX man_sec_name ON люди;
DROP INDEX man_phone ON люди;

DROP TRIGGER trigger_min_exam_marc on экзамен;
DROP TRIGGER trigger_trustee on доверенное_лицо_абитуриента;
DROP TRIGGER trigger_extra_marks on дополнительные_документы;

DROP TYPE статус_уч_олимпиады;
DROP TYPE пол;
DROP TYPE статус_абит;

DROP TABLE индивидуальные_достижения_вуза;
DROP TABLE специальность_вуза_описание;
DROP TABLE специальность_вуза;
DROP TABLE специальность_абит;
DROP TABLE специальность;
DROP TABLE контакты_вуза;
DROP TABLE олимпиада_вуза;
DROP TABLE дополнительные_документы;
DROP TABLE экзамен;
DROP TABLE документы;
DROP TABLE олимпиада;
DROP TABLE предмет;
DROP TABLE вуз;
DROP TABLE доверенное_лицо_абитуриента;
DROP TABLE абитуриент;
DROP TABLE люди;
DROP TABLE индивидуальные_достижения;