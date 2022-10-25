WITH events AS (
    SELECT
        CONVERT(VARCHAR(7), ConsultationDate, 23) AS month,
        CTV3Code AS code
    FROM CodedEvent
    WHERE ConsultationDate >= '2015-01-01'
)

SELECT month, code, ROUND(COUNT(*), -1) AS num
FROM events
GROUP BY month, code
ORDER BY month, code
