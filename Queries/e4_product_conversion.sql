
-- Q[4] — [ PDP Engagement: High-View, Low-Cart Products]
-- Business question: Which products attract eyeballs but don't get added to cart? Those are either pricing problems, image problems, or stock problems.
-- What this tells us: Products with high views but low ATC rates relative to their category median are losing potential conversions despite attracting customer interest. These SKUs are strong candidates for merchandising investigation because the issue may be related to price, product imagery, or stock availability.
-- PM Action: Hand the top 10 flagged SKUs to the merchandising PM and investigate one hypothesis per SKU: price, image, or stock.
-- Sanity check: add_to_cart_sessions <= views for every product. atc_rate between 0 and 1.




with product_details as (
select 
        p.product_id    as product_id,
		p.product_name   as product_name,
		c.category_name  as category,
		count(distinct case when se.event_type='product_view' then se.session_id end)   as VIEWS,
		count(distinct case when se.event_type='add_to_cart' then se.session_id end)    as add_to_cart_sessions,
		count(distinct case when se.event_type='add_to_cart' then se.session_id end)::numeric / nullif(count(distinct case when se.event_type='product_view' then se.session_id end),0)  as atc_rate
		
	from ecom.products p 
	join ecom.categories c on p.category_id=c.category_id
	join ecom.session_events se on se.product_id=p.product_id
	group by   p.product_id  ,
		p.product_name,
		c.category_name

		), 
        category_median_atc as ( 
                                                SELECT
												pd.category,
												PERCENTILE_CONT (0.5)
												within group(order by pd.atc_rate)   as category_atc_median
												from product_details pd
												group by category
		)
		select 
		        pd.product_id,
				pd.product_name,
				pd.category,
				pd.views,
				pd.add_to_cart_sessions,
				pd.atc_rate,
				pd.atc_rate / nullif(category_atc_median,0)  as atc_rate_vs_category_median,
				rank() over(order by pd.views desc)  as views_rank,
				rank() over(order by pd.atc_rate desc )  as atc_rate_rank
			from product_details pd 
			join category_median_atc cm on pd.category=cm.category
		
