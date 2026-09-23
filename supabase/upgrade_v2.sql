-- =====================================================================
-- Carty v2 upgrade: favorites, product descriptions, "popular" flag,
-- saved delivery address on the profile.
--
-- Run this whole file ONCE in Supabase -> SQL Editor -> New query,
-- AFTER schema.sql. It is safe to run again (it skips what exists).
-- =====================================================================

-- ---------- 1. New columns ------------------------------------------

alter table public.products add column if not exists description text;
alter table public.products add column if not exists is_popular boolean not null default false;
alter table public.profiles add column if not exists address text;

-- ---------- 2. Favorites (wishlist) ---------------------------------

create table if not exists public.favorites (
  user_id     uuid   not null default auth.uid() references auth.users (id) on delete cascade,
  product_id  bigint not null references public.products (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (user_id, product_id)
);

alter table public.favorites enable row level security;

drop policy if exists "Read own favorites"   on public.favorites;
drop policy if exists "Add own favorites"    on public.favorites;
drop policy if exists "Delete own favorites" on public.favorites;

create policy "Read own favorites"   on public.favorites for select to authenticated using (user_id = auth.uid());
create policy "Add own favorites"    on public.favorites for insert to authenticated with check (user_id = auth.uid());
create policy "Delete own favorites" on public.favorites for delete to authenticated using (user_id = auth.uid());

-- ---------- 3. Profiles: allow creating your own row ----------------
-- (needed for accounts created before the trigger existed)

drop policy if exists "Insert own profile" on public.profiles;
create policy "Insert own profile" on public.profiles for insert to authenticated with check (id = auth.uid());

-- ---------- 4. Product descriptions ---------------------------------

update public.products p
set description = case c.name
    when 'Fruits'     then 'Hand-picked and naturally sweet. Delivered fresh from local farms in the Jordan Valley.'
    when 'Vegetables' then 'Crisp, fresh and full of flavour. Washed and packed the same day it is harvested.'
    when 'Dairy'      then 'Rich and creamy, kept cold from the farm to your door. Best enjoyed within a few days.'
    when 'Bakery'     then 'Baked every morning in our partner bakery for a soft inside and a golden crust.'
    when 'Meat'       then 'Premium quality, halal certified and cut fresh. Keep refrigerated and cook within 2 days.'
    when 'Beverages'  then 'Refreshing and ready to enjoy. Serve chilled for the best taste.'
    else 'Fresh quality product from Carty.'
  end
from public.categories c
where c.id = p.category_id
  and p.description is null;

-- ---------- 5. Popular products (shown on the Home screen) ----------

update public.products
set is_popular = true
where name in ('Red Apple', 'Banana', 'Strawberry', 'Fresh Milk', 'Croissant',
               'Chicken Breast', 'Tomato', 'Orange Juice');
