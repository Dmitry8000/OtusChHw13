-- ДЗ 13: Проверка после восстановления

DROP DATABASE backup_test;
--drop DATABASE  backup_test_corrupted;
-- Ожидаемые количества строк (как до порчи):
-- events_local: 5000
-- events_s3:    3000
-- metrics:      1000

SELECT 'events_local' AS tbl, count() AS cnt FROM backup_test.events_local
UNION ALL
SELECT 'events_s3', count() FROM backup_test.events_s3
UNION ALL
SELECT 'metrics', count() FROM backup_test.metrics;
