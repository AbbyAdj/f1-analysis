
SELECT 
    CONSTRUCTOR_ID,
    CONSTRUCTOR_NAME,
    NATIONALITY
FROM 
{{ ref('stg_constructors') }}
