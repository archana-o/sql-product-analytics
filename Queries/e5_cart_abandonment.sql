
-- Q[5] — Cart Abandonment by Cart Value Bucket
-- Business question:  Cart abandonment is 70% overall — but is it the same for ₹500 carts as ₹15,000 carts? Where do we lose the most rupees?
-- What this tells us: Abandonment is highest for lower-value carts, reaching 53% for carts below ₹500, but the largest financial loss comes from higher-value carts. The ₹5,000+ buckets account for approximately ₹15.7M in GMV left on the table, making high-value carts the biggest revenue opportunity.
-- PM Action:Prioritize checkout reliability for ₹5,000+ carts and investigate payment failures, checkout errors, and other friction points. For the <₹500 bucket, investigate whether free-shipping thresholds or promotions can reduce abandonment.
-- Sanity check: Sum of atc_sessions across buckets equals total ATC sessions in the same window .



WITH session_with_amt AS (
    SELECT 
        se.session_id,
        SUM(se.quantity * se.unit_price) AS cart_amt
    FROM ecom.session_events se
    WHERE se.event_type = 'add_to_cart'
    GROUP BY se.session_id
),
cart_bucket as (
SELECT 
    sa.session_id,
    sa.cart_amt,
    CASE
        WHEN sa.cart_amt < 500 THEN '<₹500'
        WHEN sa.cart_amt < 2000 THEN '₹500–₹1,999'
        WHEN sa.cart_amt < 5000 THEN '₹2,000–₹4,999'
        WHEN sa.cart_amt < 15000 THEN '₹5,000–₹14,999'
        ELSE '₹15,000+'
    END AS cart_bucket,
	max(CASE 
	     when se.event_type='purchase' then 1 else 0
	end) as purchased_sessions
	
FROM session_with_amt sa
join ecom.session_events se on sa.session_id=se.session_id
group by sa.session_id,cart_amt

)
SELECT
        cb.cart_bucket,
		count(distinct session_id)   as atc_sessions,
		count(distinct case when cb.purchased_sessions=1 then session_id end) as purchased_sessions,
		count(distinct case when cb.purchased_sessions=0 then session_id end)  as abandoned_sessions,
		count(distinct case when cb.purchased_sessions=0 then session_id end)::numeric /  count(distinct session_id)   as abandoned_rate,
		SUM(CASE WHEN cb.purchased_sessions = 0 THEN cart_amt ELSE 0 END) AS gmv_left_on_table

  from cart_bucket cb
  group by cb.cart_bucket
  order by abandoned_rate
