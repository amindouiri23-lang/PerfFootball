-- Power BI : les réponses aux questionnaires de bien-être lancés seuls (sans séance, migration
-- 20261021000001) comptent aussi. Date de la réponse : celle de la séance ou du questionnaire.
create or replace view reporting.wellness as
select w.id, w.team_id, w.session_id, w.player_id, coalesce(s.date, q.date) as date,
       w.sleep_hours, w.sleep_quality, w.fatigue, w.soreness, w.stress, w.mood,
       w.sleep_quality + w.fatigue + w.soreness + w.stress + w.mood as total_score, w.remark,
       w.survey_id
from public.wellness w
left join public.sessions s on s.id = w.session_id and not s.deleted
left join public.wellness_surveys q on q.id = w.survey_id and not q.deleted
where not w.deleted and (s.id is not null or q.id is not null);

grant select on reporting.wellness to powerbi_reader;
