---Optimized query showing revenue generated through Organic Search. After optimization, the query processes 7.54 MB of data
SELECT
  SUM(p.price) AS revenue,
  sp.channel
FROM `DA.order` o
JOIN `DA.product` p
  ON o.item_id = p.item_id
JOIN `DA.session_params` sp
  ON o.ga_session_id = sp.ga_session_id
WHERE sp.channel = 'Organic Search'
group by 2;

-- Optimization Results
--Reduced data volume by filtering only active users
--Improved performance through pre-aggregation of large tables
--Optimized JOIN operations to avoid unnecessary duplication
--Lower computational cost while preserving the same business metrics
--Query is scalable for large datasets--Тільки активні акаунти
WITH active_accounts AS (
  SELECT id
  FROM `DA.account`
  WHERE is_unsubscribed = 0
),
--Попередньо агрегуємо email_open та email_visit
email_open_agg AS (
  SELECT id_message, id_account
  FROM `DA.email_open`
  GROUP BY id_message, id_account
),
email_visit_agg AS (
  SELECT id_message, id_account
  FROM `DA.email_visit`
  GROUP BY id_message, id_account
),
--Тільки потрібні колонки з session_params
account_os AS (
  SELECT acs.account_id, sp.operating_system
  FROM `DA.account_session` acs
  JOIN `DA.session_params` sp
    ON acs.ga_session_id = sp.ga_session_id
)
--Основний запит
SELECT
  aos.operating_system,
  COUNT(DISTINCT es.id_message) AS sent_msg,
  COUNT(DISTINCT eo.id_message) AS open_msg,
  COUNT(DISTINCT ev.id_message) AS visit_msg,
  ROUND(COUNT(DISTINCT eo.id_message) * 100.0 / COUNT(DISTINCT es.id_message), 2) AS open_rate,
  ROUND(COUNT(DISTINCT ev.id_message) * 100.0 / COUNT(DISTINCT es.id_message), 2) AS click_rate,
  ROUND(COUNT(DISTINCT ev.id_message) * 100.0 / NULLIF(COUNT(DISTINCT eo.id_message),0), 2) AS ctor
FROM active_accounts a
JOIN `DA.email_sent` es
  ON a.id = es.id_account
LEFT JOIN email_open_agg eo
  ON es.id_message = eo.id_message AND es.id_account = eo.id_account
LEFT JOIN email_visit_agg ev
  ON es.id_message = ev.id_message AND es.id_account = ev.id_account
JOIN account_os aos
  ON a.id = aos.account_id
GROUP BY aos.operating_system;
