CREATE VIEW [dbo].[p21_view_oe_hdr]
AS

SELECT oe_hdr.*
	,CAST(oe_hdr.requested_downpayment/NULLIF(ISNULL(currency_line.exchange_rate,1),0) AS DECIMAL(19,2)) AS requested_downpayment_home
	,CAST(oe_hdr.freight_out/NULLIF(ISNULL(currency_line.exchange_rate,1),0) AS DECIMAL(19,2)) AS freight_out_home
	
--SELECT oe_hdr.order_no,
--	oe_hdr.customer_id,
--	oe_hdr.order_date,
--	oe_hdr.ship2_name,
--	oe_hdr.ship2_add1,
--	oe_hdr.ship2_add2,
--	oe_hdr.ship2_city,
--	oe_hdr.ship2_state,
--	oe_hdr.ship2_zip,
--	oe_hdr.ship2_country,
--	oe_hdr.requested_date,
--	oe_hdr.po_no,
--	oe_hdr.terms,
--	oe_hdr.ship_to_phone,
--	oe_hdr.delete_flag,
--	oe_hdr.completed,
--	oe_hdr.company_id,
--	oe_hdr.date_created,
--	oe_hdr.date_last_modified,
--	oe_hdr.last_maintained_by,
--	oe_hdr.cod_flag,
--	oe_hdr.gross_margin,
--	oe_hdr.projected_order,
--	oe_hdr.po_no_append,
--	oe_hdr.location_id,
--	oe_hdr.carrier_id,
--	oe_hdr.address_id,
--	oe_hdr.contact_id,
--	oe_hdr.corp_address_id,
--	oe_hdr.handling_charge_req_flag,
--	oe_hdr.payment_method,
--	oe_hdr.fob_flag,
--	oe_hdr.class_1id,
--	oe_hdr.class_2id,
--	oe_hdr.class_3id,
--	oe_hdr.class_4id,
--	oe_hdr.class_5id,
--	oe_hdr.rma_flag,
--	oe_hdr.taker,
--	oe_hdr.job_name,
--	oe_hdr.third_party_billing_flag,
--	oe_hdr.approved,
--	oe_hdr.source_location_id,
--	oe_hdr.packing_basis,
--	oe_hdr.delivery_instructions,
--	oe_hdr.pick_ticket_type,
--	oe_hdr.requested_downpayment,
--	oe_hdr.downpayment_invoiced,
--	oe_hdr.cancel_flag,
--	oe_hdr.will_call,
--	oe_hdr.front_counter,
--	oe_hdr.validation_status,
--	oe_hdr.oe_hdr_uid,
--	oe_hdr.source_id,
--	oe_hdr.source_code_no,
--	oe_hdr.credit_card_hold,
--	oe_hdr.freight_code_uid,
--	oe_hdr.freight_out,
--	oe_hdr.shipping_route_uid,
--	oe_hdr.invoice_batch_uid,
--	oe_hdr.exclude_rebates,
--	oe_hdr.capture_usage_default,
--	oe_hdr.job_price_hdr_uid,
--	oe_hdr.front_counter_rma,
--	oe_hdr.taxable,
--	oe_hdr.ship2_email_address,
--	oe_hdr.profit_percent,
--	oe_hdr.order_cost_basis,
--	oe_hdr.currency_line_uid,
--	dbo.p21_fn_CalcHomeAmtFromForeignAmtDec2(oe_hdr.requested_downpayment, currency_line.exchange_rate) requested_downpayment_home,
--	dbo.p21_fn_CalcHomeAmtFromForeignAmtDec2(oe_hdr.freight_out, currency_line.exchange_rate) freight_out_home
--	,oe_hdr.invoice_exch_rate_source_cd
--	,oe_hdr.order_type
--	,oe_hdr.rma_expiration_date
--	,oe_hdr.invoice_no
--	,oe_hdr.bill_to_contact_id
--	,oe_hdr.tag_hold_cancel_date
--	,oe_hdr.cost_center_tracking_option
--	,oe_hdr.skip_profit_exception_check
--	,oe_hdr.cons_backorder_processing_flag
--	,oe_hdr.restock_fee_percentage
--	,oe_hdr.expected_completion_date
--	,oe_hdr.date_order_completed
--	,oe_hdr.job_control_flag
--	,oe_hdr.apply_builder_allowance_flag
--	,oe_hdr.merchandise_credit_flag
--	,oe_hdr.req_pymt_upon_release_flag
--	,oe_hdr.pm_date
--	,oe_hdr.downpayment_percentage
--	,oe_hdr.validated_via_open_orders_flag
--	,oe_hdr.acknowledgement_date
--	,oe_hdr.product_group_cost_basis
--	,oe_hdr.expedite_date
--
--	,oe_hdr.original_promise_date
--	,oe_hdr.promise_date


FROM oe_hdr WITH (NOLOCK)
LEFT JOIN currency_line WITH (NOLOCK) on currency_line.currency_line_uid = oe_hdr.currency_line_uid
