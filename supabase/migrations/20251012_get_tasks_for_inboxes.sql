create or replace function public.get_tasks_for_inboxes(
  uid uuid,
  mail_keys text[],
  message_keys text[]
) returns setof jsonb
language sql
stable
as $$
  with base as (
    select t.*
    from public.tasks t
    where t.owner_id = uid
  )
  -- Mail matches
  select jsonb_build_object(
           'inbox_id', 'mail_' || lower(lm->>'type') || '_' || (lm->>'host_mail') || '_' || (lm->>'message_id'),
           'task', to_jsonb(b)
         )
  from base b
  cross join jsonb_array_elements(coalesce(b.linked_mails, '[]'::jsonb)) lm
  where ((lm->>'host_mail') || ':' || (lm->>'message_id')) = any(mail_keys)

  union all

  -- Message matches
  select jsonb_build_object(
           'inbox_id', 'message_' || lower(msg->>'type') || '_' || (msg->>'team_id') || '_' || (msg->>'message_id'),
           'task', to_jsonb(b)
         )
  from base b
  cross join jsonb_array_elements(coalesce(b.linked_messages, '[]'::jsonb)) msg
  where ((msg->>'team_id') || ':' || (msg->>'channel_id') || ':' || (msg->>'message_id')) = any(message_keys);
$$;


