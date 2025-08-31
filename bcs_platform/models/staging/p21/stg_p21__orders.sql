{{
    config(
        materialized='view',
        tags=['staging', 'p21']
    )
}}

with source as (
    select * from {{ source('p21_ingestion', 'OE_HDR') }}
    where "_meta/op" != 'd'  -- Exclude deleted records
),

renamed as (
    select
        -- Primary Keys
        ORDER_NO as order_number,
        
        -- Foreign Keys
        CUSTOMER_ID as customer_id,
        LOCATION_ID as location_id,
        COMPANY_ID as company_id,
        INVOICE_NO as invoice_number,
        
        -- Order Details
        PO_NO as purchase_order_number,
        ORDER_TYPE as order_type,
        ORDER_TYPE_CUST as order_type_customer,
        
        -- Dates
        ORDER_DATE::date as order_date,
        PROMISE_DATE::date as promise_date,
        REQUESTED_DATE::date as requested_date,
        DATE_ORDER_COMPLETED::date as order_completed_date,
        
        -- Ship To Information
        SHIP2_NAME as ship_to_name,
        SHIP2_ADD1 as ship_to_address_1,
        SHIP2_ADD2 as ship_to_address_2,
        SHIP2_ADD3 as ship_to_address_3,
        SHIP2_CITY as ship_to_city,
        SHIP2_STATE as ship_to_state,
        SHIP2_ZIP as ship_to_zip,
        SHIP2_COUNTRY as ship_to_country,
        
        -- Financial Metrics
        FREIGHT_OUT as freight_amount,
        FREIGHT_TAX as freight_tax_amount,
        GROSS_MARGIN as gross_margin,
        PROFIT_PERCENT as profit_percent,
        
        -- Status Flags
        case when COMPLETED = 'Y' then true else false end as is_completed,
        case when CANCEL_FLAG = 'Y' then true else false end as is_cancelled,
        case when DELETE_FLAG = 'Y' then true else false end as is_deleted,
        case when RMA_FLAG = 'Y' then true else false end as is_rma,
        case when TAXABLE = 'Y' then true else false end as is_taxable,
        
        -- Metadata
        DATE_CREATED as created_at,
        DATE_LAST_MODIFIED as modified_at,
        FLOW_PUBLISHED_AT as ingested_at,
        "_meta/op" as cdc_operation
        
    from source
)

select * from renamed