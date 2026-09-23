-- =====================================================================
-- Carty v3 upgrade: map location (latitude / longitude)
--
-- Run this whole file ONCE in Supabase -> SQL Editor -> New query,
-- AFTER schema.sql and upgrade_v2.sql. Safe to run again.
-- =====================================================================

-- ---------- 1. New columns ------------------------------------------

alter table public.orders   add column if not exists latitude  double precision;
alter table public.orders   add column if not exists longitude double precision;
alter table public.profiles add column if not exists latitude  double precision;
alter table public.profiles add column if not exists longitude double precision;

-- ---------- 2. place_order now also saves the map location ----------
-- The old 3-parameter version is removed first; otherwise Postgres would
-- keep two versions and the app's call would be ambiguous.

drop function if exists public.place_order(text, text, text[]);

create or replace function public.place_order(
  p_address text,
  p_payment_method text,
  p_instructions text[] default '{}',
  p_latitude double precision default null,
  p_longitude double precision default null
)
returns bigint
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_user_id  uuid := auth.uid();
  v_total    numeric(10, 2);
  v_order_id bigint;
begin
  if v_user_id is null then
    raise exception 'Not logged in';
  end if;

  select coalesce(sum(p.price * c.quantity), 0)
    into v_total
    from public.cart_items c
    join public.products p on p.id = c.product_id
   where c.user_id = v_user_id;

  if v_total = 0 then
    raise exception 'Cart is empty';
  end if;

  insert into public.orders
    (user_id, address, payment_method, instructions, total, latitude, longitude)
  values
    (v_user_id, p_address, p_payment_method, coalesce(p_instructions, '{}'),
     v_total, p_latitude, p_longitude)
  returning id into v_order_id;

  insert into public.order_items (order_id, product_id, product_name, unit_price, quantity)
  select v_order_id, p.id, p.name, p.price, c.quantity
    from public.cart_items c
    join public.products p on p.id = c.product_id
   where c.user_id = v_user_id;

  delete from public.cart_items where user_id = v_user_id;

  return v_order_id;
end;
$$;

grant execute on function
  public.place_order(text, text, text[], double precision, double precision)
  to authenticated;
