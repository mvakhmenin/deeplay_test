-- Создание рабочей БД
CREATE DATABASE src;

-- Создание таблицы для автоматической разметки
CREATE TABLE IF NOT EXISTS src.player_lables_auto 
(
	DetectedAt Date,
	PlayerID INT
)
ENGINE = MergeTree() 
PARTITION BY toYYYYMM(DetectedAt) 
ORDER BY (PlayerID, DetectedAt);

-- Создание таблицы для ручной разметки
CREATE TABLE IF NOT EXISTS src.player_lables_man 
(
	Date Date,
	PlayerID INT,
	Status String
)
ENGINE = MergeTree() 
PARTITION BY toYYYYMM(Date) 
ORDER BY (PlayerID, Date)

-- Создание таблицы, объединяющей разметки в единую структуру
CREATE TABLE src.player_status_final
(
	Date Date,
	PlayerID INT,
	Status String, -- Статус игорка (для Auto всегда Detected, для Manual = Detected или Amnisted)
	Type String, -- тип разметки (Auto или Manual)
	expired Nullable(Date) -- дата истечения срока дейтствия блокировки (для Auto всегда NULL, для Manual = дата статуса Amnisted)
)
ENGINE = MergeTree() 
PARTITION BY toYYYYMM(Date) 
ORDER BY (PlayerID, Date)

-- Создание материализованного представления для переноса данных из таблицы с автоматической разметкой в целевую
-- Данные будут переносится, как только они будут добавлены в таблицу-источник src.player_lables_auto
CREATE MATERIALIZED VIEW src.player_lables_auto_mv TO src.player_status_final
AS SELECT toDate(DetectedAt) AS Date, 
		 PlayerID, 
		 'Detected' AS Status, -- для автоматической разметки всегда Detected, если запись для игорка существует
		 'Auto' AS Type
FROM src.player_lables_auto

-- Создание материализованного представления для переноса данных из таблицы с ручной разметкой в целевую
-- Данные будут переносится, как только они будут добавлены в таблицу-источник src.player_lables_man
CREATE MATERIALIZED VIEW src.player_lables_man_mv TO src.player_status_final
AS SELECT Date, 
		 PlayerID, 
		 Status, 
		 'Manual' AS Type,
		 if(Status='Amnisted', Date, NULL) AS expired -- дата истечения срока дейтствия блокировки (только для ручной разметки)
FROM src.player_lables_man