--Percentage of sessions with purchases for each country
SELECT country,
COUNT(DISTINCT ord.ga_session_id) / COUNT (DISTINCT sp.ga_session_id) * 100 AS session_with_orders_percent,  
COUNT (DISTINCT sp.ga_session_id) AS session_cnt  
FROM `data-analytics-mate.DA.session_params`  sp
LEFT JOIN  `data-analytics-mate.DA.order` ord
ON sp.ga_session_id = ord.ga_session_id
GROUP BY country
ORDER BY session_cnt DESC;


--Open Rate calculation by country
SELECT
  es.letter_type AS letter_type,
  COUNT(DISTINCT es.id_message) AS email_sent_cnt,
  COUNT(eo.id_message) AS email_open_cnt,
  COUNT(DISTINCT eo.id_message) / count (DISTINCT es.id_message) AS open_rate
FROM `data-analytics-mate.DA.email_sent` es
LEFT JOIN `data-analytics-mate.DA.email_open` eo
ON es.id_message = eo.id_message
LEFT JOIN `data-analytics-mate.DA.account_session` acs
ON es.id_account = acs.account_id
LEFT JOIN `data-analytics-mate.DA.session_params` sp
ON acs.ga_session_id = sp.ga_session_id
WHERE sp.country = 'United States'
GROUP BY es.letter_type
ORDER BY open_rate DESC
LIMIT 1;


--The number of products sold and total sales revenue in a specific category for each country on a specific continent
SELECT sp.country as country,
SUM (pr.price) as revenue,
COUNT (ord.ga_session_id) as count_of_orders
FROM `data-analytics-mate.DA.order` as ord
JOIN `data-analytics-mate.DA.session` as s
ON ord.ga_session_id = s.ga_session_id
JOIN `data-analytics-mate.DA.product` as pr
ON ord.item_id = pr.item_id
LEFT JOIN `data-analytics-mate.DA.session_params` as sp
ON s.ga_session_id = sp.ga_session_id
where pr.category = 'Beds' and sp.continent = 'Europe'
group by sp.country
order by count_of_orders DESC

