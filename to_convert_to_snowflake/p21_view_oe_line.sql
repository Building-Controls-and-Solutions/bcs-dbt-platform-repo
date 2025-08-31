-- order line table for Power BI
SELECT
    oel.order_no,
    CONVERT(date, oeh.order_date, 101) AS order_date,
    oeh.customer_id,
    oel.line_no,
    CASE
        WHEN oel.delete_flag = 'Y' THEN 'DELETED'
        WHEN oel.cancel_flag = 'Y' THEN 'CANCELLED'
        WHEN oel.complete    = 'Y' THEN 'COMPLETE'
        ELSE 'OPEN'
    END AS ord_line_status,
    oel.delete_flag,
    oel.cancel_flag,
    oel.complete,
    oel.inv_mast_uid,
    oel.item_id,
    oel.supplier_id,
    sup.supplier_name AS p21_spl_name,
    spr.supplier_key,
    spr.supplier_name AS std_name,
    spr.supplier_role,
    spr.supplier_group,
    CASE
        WHEN oel.supplier_id IN (133921, 133923) THEN 'HON'
        WHEN oel.supplier_id IN (134012)         THEN 'JCI'
        WHEN oel.supplier_id IN (133602)         THEN 'BEL'
        WHEN spr.supplier_key = 'BCS'            THEN 'BCS'
        WHEN spr.supplier_role = 'CORE'          THEN 'OMG'
        ELSE 'OTH'
    END AS supplier_cat,

    pot.po_d_ct,
    pot.po_p_ct,
    pot.po_s_ct,
    pot.po_b_ct,
    pot.po_o_ct,

    oel.qty_ordered,
    oel.qty_invoiced,
    oel.qty_canceled,
    oel.unit_quantity,
    oel.unit_price,

    oel.pricing_unit_size,
    oel.pricing_unit,
    oel.extended_price,
    CASE
        WHEN oel.pricing_unit_size = 0 THEN 0
        ELSE oel.qty_ordered / oel.pricing_unit_size * oel.unit_price
    END AS order_value,

    oel.sales_cost,
    oel.unit_size,
    CASE
        WHEN oel.unit_size = 0 THEN 0
        ELSE oel.qty_ordered / oel.unit_size * oel.sales_cost
    END AS order_cogs,

    CASE
        WHEN oel.pricing_unit_size = 0 THEN 0
        ELSE oel.qty_invoiced / oel.pricing_unit_size * oel.unit_price
    END AS invoiced_value,
    CASE
        WHEN oel.unit_size = 0 THEN 0
        ELSE oel.qty_invoiced / oel.unit_size * oel.sales_cost
    END AS invoiced_cogs,

    CASE
        WHEN (oel.delete_flag = 'Y' OR oel.cancel_flag = 'Y' OR oel.pricing_unit_size = 0) THEN 0
        ELSE (oel.qty_ordered - oel.qty_invoiced - oel.qty_canceled) / oel.pricing_unit_size * oel.unit_price
    END AS open_value,
    CASE
        WHEN (oel.delete_flag = 'Y' OR oel.cancel_flag = 'Y' OR oel.pricing_unit_size = 0) THEN 0
        ELSE (oel.qty_ordered - oel.qty_invoiced - oel.qty_canceled) / oel.unit_size * oel.sales_cost
    END AS open_cogs,

    oel.source_loc_id,
    srcloc.location_name AS source_loc_name,
    oel.ship_loc_id,
    shploc.location_name AS ship_loc_name,
    oel.assembly,

    oel.manual_price_overide,
    oel.product_group_id,
    oel.price_page_uid,
    oel.pricing_option,
    oel.sales_discount_group_id,
    oel.price_family_uid,

    oel.date_created,
    oel.created_by,
    oel.date_last_modified,
    oel.last_maintained_by
FROM p21_view_oe_hdr AS oeh
LEFT JOIN p21_view_oe_line     AS oel    ON oel.order_no   = oeh.order_no
LEFT JOIN p21_view_quote_hdr   AS qh     ON qh.oe_hdr_uid  = oeh.oe_hdr_uid
LEFT JOIN p21_view_location    AS loc    ON loc.location_id = oeh.location_id
LEFT JOIN bcs_org2             AS org    ON org.org_id     = loc.default_branch_id
LEFT JOIN p21_view_supplier    AS sup    ON sup.supplier_id = oel.supplier_id
LEFT JOIN bcs_supplier_role    AS spr    ON spr.supplier_id = oel.supplier_id
LEFT JOIN p21_view_location    AS srcloc ON srcloc.location_id = oel.source_loc_id
LEFT JOIN p21_view_location    AS shploc ON shploc.location_id = oel.ship_loc_id
LEFT JOIN (
    -- xref table in P21 to link
    SELECT
        lpo.order_number,
        lpo.line_number AS ord_line_no,
        COUNT(DISTINCT CASE WHEN poh.po_type = 'D' THEN lpo.po_no END) AS po_d_ct,
        COUNT(DISTINCT CASE WHEN poh.po_type = 'P' THEN lpo.po_no END) AS po_p_ct,
        COUNT(DISTINCT CASE WHEN poh.po_type = 'S' THEN lpo.po_no END) AS po_s_ct,
        COUNT(DISTINCT CASE WHEN poh.po_type = 'B' THEN lpo.po_no END) AS po_b_ct,
        COUNT(DISTINCT CASE WHEN poh.po_type NOT IN ('D','P','S','B') THEN lpo.po_no END) AS po_o_ct
    FROM p21_view_oe_line_po AS lpo   -- xref table in P21 to link
    LEFT JOIN p21_view_po_hdr  AS poh ON poh.po_no = lpo.po_no  -- e.g., SELECT * FROM p21_view_po_hdr WHERE po_no IN (4027103, 4016624, 4016846)
    JOIN p21_view_po_line      AS pol ON poh.po_no = pol.po_no
                                      AND lpo.po_line_number = pol.line_no  -- e.g., SELECT * FROM p21_view_po_line WHERE po_no IN (4027103, 4016624, 4016846)
    WHERE lpo.delete_flag = 'N'
      AND lpo.cancel_flag = 'N'
    GROUP BY
        lpo.order_number,
        lpo.line_number
) AS pot
    ON pot.order_number = oeh.order_no
   AND pot.ord_line_no = oel.line_no
WHERE DATEPART(year, oeh.order_date) >= 2023
ORDER BY
    oel.order_no,
    oel.line_no;
