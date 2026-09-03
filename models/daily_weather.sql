WITH daily_weather AS (

    SELECT
        DATE(TO_TIMESTAMP_NTZ(DATA:time::NUMBER, 0)) AS daily_weather,
        DATA:weather[0]:main::STRING AS weather,
        DATA:main:temp::FLOAT - 273.15 AS temp,
        DATA:main:pressure::FLOAT AS pressure,
        DATA:main:humidity::FLOAT AS humidity,
        DATA:clouds:all::FLOAT AS clouds

    FROM {{ source('demo', 'weather_table') }}

),

daily_weather_agg AS (

    SELECT
        daily_weather,
        weather,
        ROUND(AVG(temp), 2) AS avg_temp,
        ROUND(AVG(pressure), 2) AS avg_pressure,
        ROUND(AVG(humidity), 2) AS avg_humidity,
        ROUND(AVG(clouds), 2) AS avg_clouds

    FROM daily_weather

    GROUP BY
        daily_weather,
        weather

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY daily_weather
        ORDER BY COUNT(*) DESC
    ) = 1

)

SELECT *
FROM daily_weather_agg