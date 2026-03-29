

-- 1) Удалить одну таблицу
DROP TABLE IF EXISTS backup_test.metrics;

-- 2) Изменить/удалить строки в другой таблице
ALTER TABLE backup_test.events_local DELETE WHERE id % 2 = 0;

-- 3) Очистить часть данных в третьей таблице
ALTER TABLE backup_test.events_s3 DELETE WHERE user_id > 400;

-- проверить что мутации завершены
SELECT * FROM system.mutations WHERE is_done = 0
--SELECT * FROM system.mutations

-- Проверка "повреждённого" состояния
SELECT 'events_local (после удаления четных id)' AS tbl, count() AS cnt FROM backup_test.events_local
UNION ALL
SELECT 'events_s3 (после удаления user_id>400)', count() FROM backup_test.events_s3;
-- metrics больше нет
