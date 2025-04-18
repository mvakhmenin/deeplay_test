-- Запрос для получения истории по игорку
SELECT PlayerID, Date, Type, Status
FROM src.player_status_final
WHERE PlayerID = 3 AND Type = 'Auto' -- указать ID игрока и тип разметки
ORDER BY Date

-- Запрос для получения фактических статусов игороков на текущую дату
SELECT 
    PlayerID,
    if (maxIf(Date, Status = 'Detected') > maxIf(Date, Status = 'Amnisted' AND Type = 'Manual'), 'Detected', 'Amnisted') 
    									AS current_status_man,
    if (maxIf(Date, Status = 'Detected') < now()::date, 'Amnisted', 'Detected') 
    									AS current_status_auto
FROM src.player_status_final
GROUP BY PlayerID
ORDER BY 1

-- Запрос для получения фактических статусов игороков на <конретный момент времени>
SELECT 
    PlayerID,
    if (maxIf(Date, Status = 'Detected') > maxIf(Date, Status = 'Amnisted' AND Type = 'Manual'), 'Detected', 'Amnisted') 
    									AS current_status_man,
    if (maxIf(Date, Status = 'Detected') < '2025-01-07'::date, 'Amnisted', 'Detected')  -- указать <конкретный момент времени>
    									AS current_status_auto
FROM src.player_status_final
WHERE Date <= '2025-01-07'  -- указать <конкретный момент времени>
GROUP BY PlayerID
ORDER BY 1