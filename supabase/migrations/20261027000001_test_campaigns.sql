-- Tests physiques par période de la saison (journal du 2026-10-21) : chaque joueur passe trois batteries de tests
-- par saison — début, mi-saison, fin. La période est portée par chaque résultat ; null = test hors batterie.
alter table public.test_results
  add column campaign text check (campaign in ('start', 'mid', 'end'));

-- Sprint 10 m : mesuré par les Minimes B, absent du catalogue commun. Identifiant : uuidv5(NS, 'test_type:sprint_10m_s').
insert into public.test_types (id, code, name, unit, category, better, attempts, sort_order) values
  ('cfde1149-88a7-5a3f-9cde-e9968ee447c1', 'sprint_10m_s', 'Sprint 10 m', 's', 'speed', 'lower', 2, 75);

-- Power BI : la période à côté de la date (colonne ajoutée en fin de vue).
create or replace view reporting.test_results as
select r.id, r.team_id, r.player_id, r.date, r.attempt, r.value, r.remark,
       t.id as test_type_id, t.code as test_code, t.name as test_name, t.unit, t.category, t.better,
       r.campaign
from public.test_results r
join public.test_types t on t.id = r.test_type_id
where not r.deleted and not t.deleted;

grant select on reporting.test_results to powerbi_reader;
