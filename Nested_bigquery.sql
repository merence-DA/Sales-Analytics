--The share of events that have the mark session_engaged = 1 out of all events where there is a value in this field by device
with events as (
  select
    ep.ga_session_id,
    sp.device,
    case when params.value.string_value = '1' then 1 else 0 end as engaged_flag
  from `DA.event_params` as ep, unnest(event_params) as params
  join `DA.session_params` as sp
    on ep.ga_session_id = sp.ga_session_id
  where params.key = 'session_engaged' and params.value.string_value is not null
)
select
  device,
  concat(
    cast(round(sum(engaged_flag) * 100.0 / count(*), 2) as string), '%'
  ) as engaged_share
from events
group by device;

--Percentage of page_title events containing the word YouTube among all events with event records by continent
with YouTube_page_titles as (
  select
    ep.ga_session_id,
    sp.continent,
    case when params.value.string_value like '%YouTube%' then 1 else 0 end as page_title
  from `DA.event_params` as ep
  cross join unnest(ep.event_params) as params
  join `DA.session_params` as sp
    on ep.ga_session_id = sp.ga_session_id
  where params.key = 'page_title'
    and params.value.string_value is not null
)
select
  continent,
  sum(page_title) as youtube_count,
  count(*) as total_count,
  round(
    sum(page_title) * 100.0 / count(*)
    , 2
  ) as page_title_percent
from YouTube_page_titles
group by continent
order by continent
