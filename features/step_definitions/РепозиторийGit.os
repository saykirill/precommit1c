﻿// Реализация шагов BDD-фич/сценариев c помощью фреймворка https://github.com/artbear/1bdd
#Использовать 1commands
#Использовать asserts

Перем БДД; //контекст фреймворка 1bdd
Перем Лог;

// Метод выдает список шагов, реализованных в данном файле-шагов
Функция ПолучитьСписокШагов(КонтекстФреймворкаBDD) Экспорт
	БДД = КонтекстФреймворкаBDD;

	ВсеШаги = Новый Массив;

	ВсеШаги.Добавить("ЯУстанавливаюPrecommitВРабочийКаталогСПараметрами");
	ВсеШаги.Добавить("ВРабочемКаталогеУстановленPrecommit");
	ВсеШаги.Добавить("ФайлХукаВРепозиторииРабочегоКаталогаСодержит");

	Возврат ВсеШаги;
КонецФункции

// Реализация шагов

// Процедура выполняется перед запуском каждого сценария
Процедура ПередЗапускомСценария(Знач Узел) Экспорт
	
КонецПроцедуры

// Процедура выполняется после завершения каждого сценария
Процедура ПослеЗапускаСценария(Знач Узел) Экспорт
	
КонецПроцедуры

// Я устанавливаю Precommit в рабочий каталог с параметрами "Параметры"
Процедура ЯУстанавливаюPrecommitВРабочийКаталогСПараметрами(Знач Параметры) Экспорт

	ПараметрыКоманды = Новый Массив;
	ПараметрыКоманды.Добавить(ОбъединитьПути(КаталогПроекта(), "v8files-extractor.os"));
	ПараметрыКоманды.Добавить("--install");
	Если ЗначениеЗаполнено(Параметры) Тогда
		ПараметрыКоманды.Добавить(ЗаменитьШаблоныВПараметрахКоманды(Параметры));
	КонецЕсли;

	Команда = Новый Команда;

	Команда.УстановитьКоманду("oscript");
	Команда.УстановитьКодировкуВывода(КодировкаТекста.UTF8);
	Команда.УстановитьРабочийКаталог(РабочийКаталог());
	Команда.ДобавитьПараметры(ПараметрыКоманды);

	Лог.Отладка("Устанавливаем precommit1c с параметрами %1", СтрСоединить(Команда.ПолучитьПараметры(), " "));

	КодВозврата = Команда.Исполнить();

	Если КодВозврата <> 0 Тогда
		Лог.Ошибка("Получен ненулевой код возврата " + КодВозврата + ". Выполнение скрипта остановлено!");
		ВызватьИсключение СокрЛП(Команда.ПолучитьВывод());
	Иначе
		Лог.Отладка("Код возврата равен 0");
	КонецЕсли;

КонецПроцедуры

// Файл хука в репозитории рабочего каталога содержит "Параметры"
Процедура ФайлХукаВРепозиторииРабочегоКаталогаСодержит(Знач Параметры) Экспорт
	СтрокаШага = СтрШаблон("файл "".git/hooks/pre-commit"" в рабочем каталоге содержит ""oscript -encoding=utf-8 .git/hooks/v8files-extractor.os --git-precommit src %1""",
							Параметры);
	БДД.ВыполнитьШаг(СтрокаШага);
КонецПроцедуры

//в рабочем каталоге установлен precommit
Процедура ВРабочемКаталогеУстановленPrecommit() Экспорт
	ПроверяемСуществованиеФайлаВРабочемКаталоге(".git/hooks");
	ПроверяемСуществованиеФайлаВРабочемКаталоге(".git/hooks/v8Reader");
	ПроверяемСуществованиеФайлаВРабочемКаталоге(".git/hooks/tools");
	ПроверяемСуществованиеФайлаВРабочемКаталоге(".git/hooks/v8Reader/V8Reader.epf");
	ПроверяемСуществованиеФайлаВРабочемКаталоге(".git/hooks/pre-commit");
	ПроверяемСуществованиеФайлаВРабочемКаталоге(".git/hooks/v8files-extractor.os");
	ПроверяемСуществованиеФайлаВРабочемКаталоге(".git/hooks/tools/v8unpack.exe");
	ПроверяемСуществованиеФайлаВРабочемКаталоге(".git/hooks/tools/mxl2txt.epf");
КонецПроцедуры

//{ Служебные методы

Функция РабочийКаталог()
	Возврат БДД.ПолучитьИзКонтекста("РабочийКаталог");
КонецФункции

Функция КаталогПроекта()
	Возврат БДД.ПолучитьИзКонтекста("КаталогПроекта");
КонецФункции

Процедура ПроверяемСуществованиеФайлаВРабочемКаталоге(ПутьКФайлу)
	Файл = Новый Файл(ОбъединитьПути(РабочийКаталог(), ПутьКФайлу));
	Ожидаем.Что(Файл.Существует(), ПутьКФайлу + " должен существовать, а это не так!").ЭтоИстина();
КонецПроцедуры

Функция ЗаменитьШаблоныВПараметрахКоманды(Знач ПараметрыКоманды)
	Рез = СтрЗаменить(ПараметрыКоманды, "<КаталогПроекта>", ЭкранированныйПуть(КаталогПроекта()));
	Рез = СтрЗаменить(Рез, "<РабочийКаталог>", ЭкранированныйПуть(РабочийКаталог()));
	Возврат Рез;
КонецФункции

Функция ЭкранированныйПуть(Знач Путь)
	Рег = Новый РегулярноеВыражение("(?<!\\)\\(?!\\)");
	Рез = Рег.Заменить(Путь, "\\");
	Возврат Рез;
КонецФункции

//}

Лог = Логирование.ПолучитьЛог("bdd");
