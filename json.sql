--Задача 1

/*Поставщик продукта «матча» (японский зелёный чай) прислал сертификат соответствия на товар:

{
    "product_name": "чай матча",
    "date": "23.07.2023",
    "signed": [
        "Морковкин А.А.",
        "Зеленая Е.А."
    ],
    "weight": 200,
    "country": "Вьетнам"   
} 
Добавьте этот сертификат в таблицу conformity_certs.*/

--Решение:

INSERT INTO crispy_selery.conformity_certs(product_id, cert)
SELECT 
    p.id,
    '{
        "product_name": "чай матча",
        "date": "23.07.2023",
        "signed": [
            "Морковкин А.А.",
            "Зеленая Е.А."
        ],
        "weight": 200,
        "country": "Вьетнам"   
    }'::jsonb
FROM crispy_selery.products p
WHERE p.name = 'матча';



--Задача 2
/*У сертификата качества на сельдерей такая структура:

{
    "product_name": "сельдерей",
    "certifications": [
        {
            "date": "01.06.2023",
            "number": 123,
            "result": "very good"
        },
        {
            "date": "01.07.2023",
            "number": 456,
            "result": "good"
        },
        {
            "date": "01.08.2023",
            "number": 789,
            "result": "very good"
        }
    ]
} 
При этом точное количество объектов в массиве certifications неизвестно.
Найдите сертификат качества на продукт «сельдерей» и выведите результат его 
последней сертификации (значение по ключу result) в формате text.Чтобы найти 
последний элемент json-массива, примените отрицательную индексацию.*/

--Решение:

SELECT cert -> 'certifications'-> -1 ->> 'result'
FROM crispy_selery.conformity_certs
WHERE cert ->> 'product_name' = 'сельдерей'




--Задача 3
/*Это образец сертификата качества на миндальное молоко:

{
    "cert_date": "01.09.2023",
    "cert_number": 12345,
    "product_name": "миндальное молоко",
    "signed": [
        "Иванов И.И.",
        "Петров П.П."
    ]
} 
Найдите фактический сертификат в таблице conformity_certs и посчитайте, 
сколько человек его подписали — signed.*/

--Решение:

SELECT JSONB_ARRAY_LENGTH(cert ->'signed')
FROM crispy_selery.conformity_certs cc
JOIN crispy_selery.products p ON cc.product_id = p.id
WHERE cert ->> 'product_name' = 'миндальное молоко'




--Задача 4
/*Вот сертификат качества на сельдерей:

{
    "product_name": "сельдерей",
    "certifications": [
        {
            "date": "01.06.2023",
            "number": 123,
            "result": "very good"
        },
        {
            "date": "01.07.2023",
            "number": 456,
            "result": "good"
        },
        {
            "date": "01.08.2023",
            "number": 789,
            "result": "very good"
        }
    ]
} 
Обновите значение в таблице conformity_certs. Для этого измените номер первой 
сертификации в массиве certifications. Правильное значение номера — 101.*/

--Решение:

UPDATE crispy_selery.conformity_certs
SET cert = jsonb_set(cert, '{certifications, 0, number}', '101'::jsonb)
WHERE product_id IN (
    SELECT id 
    FROM crispy_selery.products 
    WHERE name = 'сельдерей'
)
AND cert @> '{"certifications": [{"number": 123}]}';



--Задача 5
/*По сертификату на сельдерей пришло дополнение. Нужно добавить к нему следующую пару ключ-значение:

"country": "Россия" 
Обновите значение в таблице conformity_certs.*/

--Решение:

UPDATE crispy_selery.conformity_certs
SET cert = cert || '{"country": "Россия"}'::jsonb
WHERE product_id IN (
    SELECT id 
    FROM crispy_selery.products 
    WHERE name = 'сельдерей'
);



--Задача 6
/*По новым стандартам фамилии подписантов больше не указываются в сертификате качества. 
Исправьте сертификат на миндальное молоко и уберите из него ключ signed и его значение.*/

--Решение:

UPDATE crispy_selery.conformity_certs
SET cert = cert - 'signed'
WHERE product_id IN (
    SELECT id 
    FROM crispy_selery.products 
    WHERE name = 'миндальное молоко'
);

