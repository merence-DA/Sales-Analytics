--Percentage of monthly expenses from total expenses for the entire period
select
  extract(month from date) as month,
  sum(cost) / sum(sum(cost)) over () * 100 as percent_of_total
from `data-analytics-mate.DA.paid_search_cost`
group by month
order by month

--A query that returns a list of unique accounts with the date the email was first sent for each account
select
  account_id,
  min(email_date) as first_sent_date
from (
  select
    acs.account_id,
    date_add(s.date, interval a.send_interval day) as email_date 
  from `data-analytics-mate.DA.email_sent` es
  join `data-analytics-mate.DA.account_session` acs
    on es.id_account = acs.account_id
  join `data-analytics-mate.DA.session` s
    on acs.ga_session_id = s.ga_session_id
  join `data-analytics-mate.DA.account` a
    on es.id_account = a.id
) as t
group by account_id;
--OR
select account_id, first_sent_date
from (
  select
    acs.account_id,
    date_add(s.date, interval a.send_interval day) as first_email_date,
    row_number() over (partition by acs.account_id order by date_add(s.date, interval a.send_interval day)) as rn
  from `data-analytics-mate.DA.email_sent` es
  join `data-analytics-mate.DA.account_session` acs
    on es.id_account = acs.account_id
  join `data-analytics-mate.DA.session` s
    on acs.ga_session_id = s.ga_session_id
  join `data-analytics-mate.DA.account` a
    on es.id_account = a.id
) t
where rn = 1;

--A SQL query that returns unique account IDs, the total number of emails sent for each account, and their ranking by the number of emails sent in descending order.
select
account_id,
total_emails,
dense_rank() over (order by total_emails desc) as account_rank
from (
  select
    a.id as account_id,
    count (es.id_message) as total_emails
  from `data-analytics-mate.DA.email_sent` es
  join `data-analytics-mate.DA.account` a
    on es.id_account = a.id
    group by 1
)
order by total_emails desc;

-- Percentage of fulfillment of accumulated income from accumulated goals (predict) by day
select
date,
revenue,
sum (revenue) over (order by date) as acc_revenue,
predict,
sum (predict) over (order by date) as acc_predict,
sum (revenue) over (order by date) / sum (predict) over (order by date) * 100 as percent
from(
select
date,
  sum(revenue) as revenue,
  sum(predict)    as predict
from (
  select
    s.date,
    sum(pr.price) as revenue,
    0 as predict
  from `data-analytics-mate.DA.session` as s
  join `data-analytics-mate.DA.order`   as o
    on s.ga_session_id = o.ga_session_id
  join `data-analytics-mate.DA.product` as pr
    on o.item_id = pr.item_id
  group by s.date
  union all
  select
    date,
    0 as revenue,
    predict
  from `data-analytics-mate.DA.revenue_predict`
) union_t
group by date );

--Percentage of emails out of the total that were sent to each account within each month and the dates of the first and last emails sent for each account in the month
SELECT
distinct sent_month,
id_account,
account_sent/total_sent*100 as sent_msg_percent_from_this_month,
first_sent_date,
last_sent_date
FROM (
SELECT
--Перетворюємо дату так, щоб вона представляла собою перший день місяця
DATE_TRUNC(DATE_ADD(se.date, INTERVAL es.sent_date DAY), MONTH) as sent_month,
--Загальна кількість листів, відправлених за місяць всім акаунтам
COUNT(id_message) OVER(PARTITION BY DATE_TRUNC(DATE_ADD(se.date, INTERVAL es.sent_date DAY), MONTH)) AS total_sent,
--Кількість листів, відправлених акаунту за місяць
COUNT(id_message) OVER(PARTITION BY id_account, DATE_TRUNC(DATE_ADD(se.date, INTERVAL es.sent_date DAY), MONTH)) AS account_sent,
--мін так макс обчислюємо в рамках кожного акаунту і місяця
--Визначає дату першого надсилання
MIN (DATE_ADD(se.date, INTERVAL es.sent_date DAY)) OVER (partition by id_account,DATE_TRUNC(DATE_ADD(se.date, INTERVAL es.sent_date DAY), MONTH)) as first_sent_date,
--Визначає дату останнього надсилання
MAX (DATE_ADD(se.date, INTERVAL es.sent_date DAY)) OVER (partition by id_account,DATE_TRUNC(DATE_ADD(se.date, INTERVAL es.sent_date DAY), MONTH)) as last_sent_date,
id_account,
id_message
FROM `DA.email_sent` es
join `DA.account_session` ass
on es.id_account=ass.account_id
join `DA.session` se
on ass.ga_session_id=se.ga_session_id
)

