-- Photos (joueurs, logos, profils) — bucket privé, 512 Ko maximum par image.
-- Chemins :
--   teams/<team_id>/players/<player_id>.jpg   teams/<team_id>/logo.jpg
--   profiles/<user_id>.jpg

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', false, 524288, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create or replace function public.can_access_photo(p_name text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select case split_part(p_name, '/', 1)
    when 'teams' then exists (
      select 1 from public.team_members m
      where m.team_id::text = split_part(p_name, '/', 2) and m.user_id = auth.uid() and not m.deleted)
    when 'profiles' then split_part(p_name, '/', 2) = auth.uid()::text || '.jpg'
    else false
  end;
$$;

create policy "photos: read" on storage.objects
  for select to authenticated using (bucket_id = 'photos' and public.can_access_photo(name));
create policy "photos: upload" on storage.objects
  for insert to authenticated with check (bucket_id = 'photos' and public.can_access_photo(name));
create policy "photos: replace" on storage.objects
  for update to authenticated using (bucket_id = 'photos' and public.can_access_photo(name))
  with check (bucket_id = 'photos' and public.can_access_photo(name));
create policy "photos: delete" on storage.objects
  for delete to authenticated using (bucket_id = 'photos' and public.can_access_photo(name));
