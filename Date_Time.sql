--event_timestamp into separate components: year, month, day, hour, minute, second.
select
timestamp_micros(event_timestamp) as event_timestamp,
EXTRACT (year from timestamp_micros(event_timestamp)) as year,
EXTRACT (month from timestamp_micros(event_timestamp)) as month,
EXTRACT (day from timestamp_micros(event_timestamp)) as day,
EXTRACT (hour from timestamp_micros(event_timestamp)) as hour,
EXTRACT (minute from timestamp_micros(event_timestamp)) as minute,
EXTRACT (second from timestamp_micros(event_timestamp)) as second
from `data-analytics-mate.DA.event_params` as ep;

----|year |month |revenue |cost |
select
  extract(year  from dt) as year,
  extract(month from dt) as month,
  sum(revenue) as revenue,
  sum(cost)    as cost
from (
  select
    s.date as dt,
    sum(pr.price) as revenue,
    0 as cost
  from `data-analytics-mate.DA.session` as s
  join `data-analytics-mate.DA.order`   as o
    on s.ga_session_id = o.ga_session_id
  join `data-analytics-mate.DA.product` as pr
    on o.item_id = pr.item_id
  group by s.date
  union all
  select
    psc.date as dt,
    0 as revenue,
    sum(psc.cost) as cost
  from `data-analytics-mate.DA.paid_search_cost` as psc
  group by psc.date
) t
group by year, month
order by year, month
