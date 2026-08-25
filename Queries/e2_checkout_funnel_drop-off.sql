-- Q[2] — Checkout Funnel Drop-off by Entry Channel
-- Business question: Where is checkout leaking, and is the leak the same across paid social vs organic search?
-- What this tells us: Organic has slightly better checkout completion than paid, but the difference is small. The largest leakage for both channels occurs between `begin_checkout` and `add_address`, while shipping and payment drop-offs are very similar across channels.
-- PM Action: Investigate the address step by breaking down the drop-off by device, product/category, and acquisition campaign to identify whether a specific segment is driving the leakage.
-- Sanity check: Every later step count must be ≤ the prior step. If not, your query is wrong 




with step as (
select 
       sc. channel,
       se.session_id,
	  max( CASE
	         when se.event_type='begin_checkout'  then 1
			 when se.event_type='add_address'  then 2
			 when se.event_type='select_shipping'  then 3
			 when se.event_type='add_payment'  then 4
			 when se.event_type='purchase'  then 5
			 else 0
	  end):: integer as max_step

	from ecom.session_events se join 
	ecom.session_channels sc on se.session_id=sc.session_id
	group by 1,2
),
leaking as (
      SELECT
	          channel,
			  COUNT(*) FILTER (WHERE max_step >= 1) AS begin_checkout,
              COUNT(*) FILTER (WHERE max_step >= 2) AS address,
              COUNT(*) FILTER (WHERE max_step >= 3) AS shipping,
              COUNT(*) FILTER (WHERE max_step >= 4) AS payment,
              COUNT(*) FILTER (WHERE max_step >= 5) AS purchased
		from step
		group by channel
)
	select 
	         channel,
			  begin_checkout,
              address,
              shipping  ,
              payment,
              purchased,
			  (begin_checkout-address)*100.00/nullif(begin_checkout,0)  as drop_address_pct,
			  (address-shipping) *100.00 /nullif(address,0) as drop_shipping_pct,
			  (shipping-payment) *100.00 /nullif(shipping,0)  as drop_payment_pct,
			  (begin_checkout-purchased)*100.00 /nullif(begin_checkout,0) as drop_final_pct
		 from leaking
	where channel in ('paid','organic')
			 
