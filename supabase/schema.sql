-- =====================================================================
-- Carty database
-- Run this whole file ONCE in: Supabase Dashboard -> SQL Editor -> New query
-- =====================================================================

-- ---------- 1. Tables ------------------------------------------------

-- One row per user (created automatically by the trigger below).
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  username    text,
  full_name   text,
  phone       text,
  avatar_url  text,
  created_at  timestamptz not null default now()
);

create table if not exists public.categories (
  id          bigint generated always as identity primary key,
  name        text not null unique,
  image_url   text,
  sort_order  int not null default 0
);

create table if not exists public.products (
  id           bigint generated always as identity primary key,
  category_id  bigint not null references public.categories (id) on delete cascade,
  name         text not null,
  price        numeric(10, 2) not null check (price >= 0),
  unit         text not null default 'piece',
  image_url    text,
  unique (category_id, name)
);

create table if not exists public.cart_items (
  id          bigint generated always as identity primary key,
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  product_id  bigint not null references public.products (id) on delete cascade,
  quantity    int not null check (quantity > 0),
  created_at  timestamptz not null default now(),
  unique (user_id, product_id)          -- one row per product per user
);

create table if not exists public.orders (
  id              bigint generated always as identity primary key,
  user_id         uuid not null default auth.uid() references auth.users (id) on delete cascade,
  address         text not null,
  payment_method  text not null,
  instructions    text[] not null default '{}',
  total           numeric(10, 2) not null,
  status          text not null default 'pending',
  created_at      timestamptz not null default now()
);

create table if not exists public.order_items (
  id            bigint generated always as identity primary key,
  order_id      bigint not null references public.orders (id) on delete cascade,
  product_id    bigint references public.products (id) on delete set null,
  product_name  text not null,          -- copied, so old orders stay correct
  unit_price    numeric(10, 2) not null, -- even if the product changes later
  quantity      int not null check (quantity > 0)
);

-- ---------- 2. Row Level Security -----------------------------------
-- RLS = each user can only see / change THEIR OWN rows.
-- Without this, anyone with your publishable key could read every cart.

alter table public.profiles    enable row level security;
alter table public.categories  enable row level security;
alter table public.products    enable row level security;
alter table public.cart_items  enable row level security;
alter table public.orders      enable row level security;
alter table public.order_items enable row level security;

create policy "Read own profile"   on public.profiles for select to authenticated using (id = auth.uid());
create policy "Update own profile" on public.profiles for update to authenticated using (id = auth.uid());

create policy "Anyone can read categories" on public.categories for select using (true);
create policy "Anyone can read products"   on public.products   for select using (true);

create policy "Read own cart"   on public.cart_items for select to authenticated using (user_id = auth.uid());
create policy "Add to own cart" on public.cart_items for insert to authenticated with check (user_id = auth.uid());
create policy "Edit own cart"   on public.cart_items for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Delete own cart" on public.cart_items for delete to authenticated using (user_id = auth.uid());

create policy "Read own orders"   on public.orders for select to authenticated using (user_id = auth.uid());
create policy "Create own orders" on public.orders for insert to authenticated with check (user_id = auth.uid());

create policy "Read own order items" on public.order_items for select to authenticated
  using (exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));
create policy "Create own order items" on public.order_items for insert to authenticated
  with check (exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));

-- ---------- 3. Create a profile for every new user ------------------
-- Works for email sign-up (username/phone) AND Google/Apple (full_name/avatar).

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, username, full_name, phone, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data ->> 'username',
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    new.raw_user_meta_data ->> 'phone',
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- 4. place_order: cart -> order in ONE transaction --------
-- The total is calculated on the server from real prices,
-- so a user cannot change the price from the app.

create or replace function public.place_order(
  p_address text,
  p_payment_method text,
  p_instructions text[] default '{}'
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

  insert into public.orders (user_id, address, payment_method, instructions, total)
  values (v_user_id, p_address, p_payment_method, coalesce(p_instructions, '{}'), v_total)
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

grant execute on function public.place_order(text, text, text[]) to authenticated;

-- ---------- 5. Seed data (same products as the course version) -----

insert into public.categories (name, image_url, sort_order) values
  ('Fruits',     'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400', 1),
  ('Vegetables', 'https://images.unsplash.com/photo-1518843875459-f738682238a6?w=400', 2),
  ('Dairy',      'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400', 3),
  ('Bakery',     'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400', 4),
  ('Meat',       'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400', 5),
  ('Beverages',  'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400', 6)
on conflict (name) do nothing;

insert into public.products (category_id, name, price, unit, image_url)
select c.id, v.name, v.price, v.unit, v.image_url
from (values
  ('Fruits', 'Red Apple',  2.99, 'kg',    'https://www.themealdb.com/images/ingredients/Apple.png'),
  ('Fruits', 'Banana',     1.49, 'bunch', 'https://www.themealdb.com/images/ingredients/Banana.png'),
  ('Fruits', 'Orange',     1.99, 'kg',    'https://www.themealdb.com/images/ingredients/Orange.png'),
  ('Fruits', 'Strawberry', 3.49, 'box',   'https://www.themealdb.com/images/ingredients/Strawberries.png'),

  ('Vegetables', 'Tomato',   1.29, 'kg',   'https://www.themealdb.com/images/ingredients/Tomato.png'),
  ('Vegetables', 'Carrot',   0.99, 'kg',   'https://www.themealdb.com/images/ingredients/Carrots.png'),
  ('Vegetables', 'Broccoli', 2.49, 'head', 'https://www.themealdb.com/images/ingredients/Broccoli.png'),
  ('Vegetables', 'Cucumber', 1.19, 'kg',   'https://www.themealdb.com/images/ingredients/Cucumber.png'),

  ('Dairy', 'Fresh Milk',     2.29, 'L',    'https://www.themealdb.com/images/ingredients/Milk.png'),
  ('Dairy', 'Yogurt',         1.79, 'cup',  'https://www.themealdb.com/images/ingredients/Yogurt.png'),
  ('Dairy', 'Cheddar Cheese', 4.99, 'pack', 'https://www.themealdb.com/images/ingredients/Cheddar%20Cheese.png'),
  ('Dairy', 'Butter',         3.49, 'pack', 'https://www.themealdb.com/images/ingredients/Butter.png'),

  ('Bakery', 'White Bread',      1.99, 'loaf',  'https://www.themealdb.com/images/ingredients/Bread.png'),
  ('Bakery', 'Croissant',        0.79, 'piece', 'https://cdn.pixabay.com/photo/2014/07/22/09/59/bread-399286_640.jpg'),
  ('Bakery', 'Blueberry Muffin', 1.29, 'piece', 'https://www.themealdb.com/images/ingredients/Blueberries.png'),
  ('Bakery', 'Bagel',            0.99, 'piece', 'https://www.themealdb.com/images/ingredients/Sesame%20Seed.png'),

  ('Meat', 'Chicken Breast', 6.99,  'kg', 'https://www.themealdb.com/images/ingredients/Chicken%20Breast.png'),
  ('Meat', 'Ground Beef',    8.99,  'kg', 'https://www.themealdb.com/images/ingredients/Beef.png'),
  ('Meat', 'Salmon Fillet',  11.99, 'kg', 'https://www.themealdb.com/images/ingredients/Salmon.png'),
  ('Meat', 'Lamb Chops',     9.99,  'kg', 'https://www.themealdb.com/images/ingredients/Lamb.png'),

  ('Beverages', 'Orange Juice',    2.49, 'L',      'https://www.themealdb.com/images/ingredients/Orange%20Juice.png'),
  ('Beverages', 'Sparkling Water', 1.49, 'bottle', 'https://www.themealdb.com/images/ingredients/Water.png'),
  ('Beverages', 'Green Tea',       3.99, 'box',    'https://www.themealdb.com/images/ingredients/Tea.png'),
  ('Beverages', 'Ground Coffee',   6.49, 'bag',    'https://www.themealdb.com/images/ingredients/Coffee.png')
) as v(category, name, price, unit, image_url)
join public.categories c on c.name = v.category
on conflict (category_id, name) do nothing;
