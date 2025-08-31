{{ config(
    materialized='view'
) }}

-- Sample staging model
-- This demonstrates the basic structure of a staging model

with source as (
    select * from {{ source('raw', 'sample_data') }}
),

renamed as (
    select
        id,
        created_at,
        current_timestamp() as loaded_at
    from source
)

select * from renamed