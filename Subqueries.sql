--Sessions that generated more than 2 events by country
select sp.country as country, count (sp.ga_session_id) as session_cnt
from `data-analytics-mate.DA.session_params` as sp
join (
  select
evp.ga_session_id
from `data-analytics-mate.DA.event_params` as evp
group by evp.ga_session_id
having count (*) > 2
) as event_s
on sp.ga_session_id = event_s.ga_session_id
group by sp.country
order by count (sp.ga_session_id) desc;

--The number of events of a certain type, but only for those sessions where there were more than 2 of any events in total within the session
select
  count(*) as total_user_engagement_events
from `data-analytics-mate.DA.event_params` as evp
join (
    select
      evp.ga_session_id
    from `data-analytics-mate.DA.session` as s
    join `data-analytics-mate.DA.event_params` as evp
      on s.ga_session_id = evp.ga_session_id
    group by evp.ga_session_id
    having count(*) > 2
) as ses_ev
  on evp.ga_session_id = ses_ev.ga_session_id
where evp.event_name = 'user_engagement';

