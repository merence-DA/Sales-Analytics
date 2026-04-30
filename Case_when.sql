--Continent with the highest revenue from purchases made from mobile devices
SELECT
 sp.continent as continent,
sum(pr.price) as revenue,
sum (case when sp.device = 'mobile' then pr.price end) / sum(pr.price) *100 as revenue_from_mobile_percent
FROM `data-analytics-mate.DA.order` as ord
JOIN `data-analytics-mate.DA.session` as s
ON ord.ga_session_id = s.ga_session_id
JOIN `data-analytics-mate.DA.product` as pr
ON ord.item_id = pr.item_id
LEFT JOIN `data-analytics-mate.DA.session_params` as sp
ON s.ga_session_id = sp.ga_session_id
GROUP BY sp.continent
  ORDER BY SUM(pr.price) DESC;

--Percentage of sessions where no language is specified
SELECT
sp.browser as browser,
count (sp.ga_session_id) as session_cnt,
count (distinct case when sp.language is null then sp.ga_session_id end) as session_cnt_with_empty_language,
count (distinct case when sp.language is null then sp.ga_session_id end) /
count (sp.ga_session_id) * 100 as session_cnt_with_empty_language_percent
FROM `data-analytics-mate.DA.session_params` as sp
GROUP BY sp.browser;

--Percentage of income from total income by continent
SELECT
sp.continent as continent,
sum(pr.price) as revenue,
sum (case when pr.category = 'Bookcases & shelving units' then pr.price end) as revenue_from_bookcases,
sum (case when pr.category = 'Bookcases & shelving units' then pr.price end) / sum(pr.price) * 100 as revenue_from_bookcases_percent
FROM `data-analytics-mate.DA.order` as ord
JOIN `data-analytics-mate.DA.session` as s
ON ord.ga_session_id = s.ga_session_id
JOIN `data-analytics-mate.DA.product` as pr
ON ord.item_id = pr.item_id
LEFT JOIN `data-analytics-mate.DA.session_params` as sp
ON s.ga_session_id = sp.ga_session_id
GROUP BY sp.continent


