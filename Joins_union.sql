--List of sessions that had subscriptions (account) or orders (order)
select acs.ga_session_id as ga_session_id, 'account' as event_type
from `data-analytics-mate.DA.account_session` as acs
union distinct
select ord.ga_session_id as ga_session_id, 'order' as event_type
from  `data-analytics-mate.DA.order` as ord;

--The sum of advertising revenue and expenses by day
select
s.date,
'revenue' as type,
sum (pr.price) as revenue
from `data-analytics-mate.DA.session` as s
join `data-analytics-mate.DA.order` as o
on s.ga_session_id = o.ga_session_id
join `data-analytics-mate.DA.product` as pr
on o.item_id = pr.item_id
group by s.date
union all
select
psc.date, 'cost' as type,
sum (psc.cost) as revenue
from `data-analytics-mate.DA.paid_search_cost` as psc
group by psc.date
