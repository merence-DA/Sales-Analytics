--Percentage of fulfillment of accumulated income from accumulated goals (predict) by day
with revenue_usd as (
  select
    s.date,
    sum(pr.price) as revenue,
    0 as predict
  from `data-analytics-mate.DA.session` as s
  join `data-analytics-mate.DA.order`   as o
    on s.ga_session_id = o.ga_session_id
  join `data-analytics-mate.DA.product` as pr
    on o.item_id = pr.item_id
  group by s.date ),
  predict_usd as (
  select
    date,
    0 as revenue,
    predict
  from `data-analytics-mate.DA.revenue_predict`
  ),
unioned as (
  select
    date,
    sum(revenue) as revenue,
    0 as predict
  from revenue_usd
  group by date
  union all
  select
    date,
    0 as revenue,
    sum(predict) as predict
  from predict_usd
  group by date
),
final as (
  select
    date,
    sum(revenue) as revenue,
    sum(predict) as predict
  from unioned
  group by date
)
select
date,
revenue,
sum (revenue) over (order by date) as acc_revenue,
predict,
sum (predict) over (order by date) as acc_predict,
sum (revenue) over (order by date) / sum (predict) over (order by date) * 100 as percent
from final;

--Resulting set
--| Continent | Revenue | Revenue from Mobile | Revenue from Desktop
with revenue_std as (
select
  sp.continent,
  sum (p.price) as revenue,
  sum (case when device = 'mobile' then p.price end) as revenue_from_mobile,
  sum (case when device = 'desktop' then p.price end) as revenue_from_desktop,
from `DA.order` o
join `DA.product` p
on o.item_id = p.item_id
join `DA.session_params` sp
on o.ga_session_id = sp.ga_session_id
group by sp.continent ),
--| Account Count | Verified Account | Session Count |
account_info as (
select
sp.continent,
count (distinct acs.account_id) as account_cnt,
count (distinct case when acc.is_verified = 1 then acc.id end) as verified_account,
count (distinct sp.ga_session_id) as session_cnt,
from `DA.session_params` sp
left join `DA.account_session` acs
on sp.ga_session_id = acs.ga_session_id
left join `DA.account` as acc
on acs.account_id = acc.id
group by sp.continent )
  select
    account_info.continent,
    revenue_std.revenue,
    revenue_std.revenue_from_mobile,
    revenue_std.revenue_from_desktop,
    revenue_std.revenue / sum (revenue_std.revenue) over () *100 as percent_Revenue_from_Total,
    account_info.account_cnt,
    account_info.verified_account,
    account_info.session_cnt
from account_info
left join revenue_std
on account_info.continent = revenue_std.continent

