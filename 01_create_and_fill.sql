-- ДЗ 13: Создание тестовой БД, таблиц и заполнение данными

CREATE DATABASE IF NOT EXISTS backup_test;

-- Таблица на локальном диске (политика по умолчанию)
CREATE TABLE IF NOT EXISTS backup_test.events_local
(
    id          UInt64,
    event_date  Date,
    user_id     UInt32,
    action      String,
    created_at  DateTime
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, id);

-- Таблица с политикой хранения S3 (данные в MinIO)
CREATE TABLE IF NOT EXISTS backup_test.events_s3
(
    id          UInt64,
    event_date  Date,
    user_id     UInt32,
    action      String,
    created_at  DateTime
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, id)
SETTINGS storage_policy = 's3_main';

-- Ещё одна таблица (для проверки восстановления нескольких таблиц)
CREATE TABLE IF NOT EXISTS backup_test.metrics
(
    ts        DateTime,
    name      String,
    value     Float64
)
ENGINE = MergeTree()
ORDER BY (ts, name);

-- Заполнение данными
INSERT INTO backup_test.events_local
SELECT
    number AS id,
    toDate('2024-01-01') + (number % 100) AS event_date,
    (number % 1000) AS user_id,
    ['click', 'view', 'submit', 'login'][(number % 4) + 1] AS action,
    now() - (number % 86400) AS created_at
FROM numbers(5000);

INSERT INTO backup_test.events_s3
SELECT
    number AS id,
    toDate('2024-02-01') + (number % 50) AS event_date,
    (number % 500) AS user_id,
    ['open', 'close', 'scroll'][(number % 3) + 1] AS action,
    now() - (number % 3600) AS created_at
FROM numbers(3000);

INSERT INTO backup_test.metrics
SELECT
    now() - (number * 60) AS ts,
    concat('metric_', toString(number % 10)) AS name,
    rand() / 1e6 AS value
FROM numbers(1000);

-- Проверка
SELECT 'events_local' AS tbl, count() AS cnt FROM backup_test.events_local
UNION ALL
SELECT 'events_s3', count() FROM backup_test.events_s3
UNION ALL
SELECT 'metrics', count() FROM backup_test.metrics;
