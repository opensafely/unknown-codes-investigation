WITH events AS (
        SELECT
                CONVERT(VARCHAR(7), APCS.Admission_Date, 23) AS month,
                APCS_Der.Spell_Primary_Diagnosis AS code
        FROM APCS_Der
        INNER JOIN APCS ON APCS_Der.APCS_Ident = APCS.APCS_Ident
        WHERE APCS.Admission_Date >= '2015-01-01'
)

SELECT month, code, ROUND(COUNT(*), -1) AS num
FROM events
GROUP BY month, code
ORDER BY month, code
