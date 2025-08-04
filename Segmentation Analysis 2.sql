/* Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than $5000,
	- Regular: Customers with at least 12 months of history but spending $5000 or less,
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH customer_spending AS (
SELECT
	c.customer_key,
	SUM(f.sales_amount) AS total_spending,
	DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT 
	COUNT(customer_key) AS total_customers,
	customer_segment
FROM (
SELECT
	customer_key,
	CASE
		WHEN total_spending > 5000 AND lifespan >= 12 THEN 'VIP'
		WHEN total_spending <= 5000 AND lifespan >= 12 THEN 'Regular'
		WHEN lifespan < 12 THEN 'New'
	END AS customer_segment
FROM customer_spending) AS t
GROUP BY customer_segment
ORDER BY total_customers DESC