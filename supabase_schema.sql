-- =============================================
-- REDLINE - Supabase Schema
-- Rabia & Harun parfüm yönetim sistemi
-- =============================================

-- Products
create table products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text,
  gender_category text check (gender_category in ('Kadın', 'Erkek', 'Unisex')),
  image_url text,
  passive boolean default false,
  created_at timestamptz default now()
);

-- Customers (Cariler)
create table customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  passive boolean default false,
  created_at timestamptz default now()
);

-- Batches (Partiler)
create table batches (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz default now()
);

-- Batch Items (Parti kalemleri - depo bazlı)
create table batch_items (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid references batches(id),
  product_id uuid references products(id),
  bought integer not null default 0,
  buy_price numeric not null default 0,
  sale_price numeric not null default 0,
  depo text default '56depo',
  created_at timestamptz default now()
);

-- Batch Costs (Parti maliyetleri)
create table batch_costs (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid references batches(id),
  veli numeric default 0,
  rabia numeric default 0,
  harun numeric default 0,
  kasa numeric default 0,
  kargo numeric default 0,
  diger numeric default 0,
  aciklama text,
  created_at timestamptz default now()
);

-- Sales (Satışlar)
create table sales (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id),
  product_id uuid references products(id),
  batch_id uuid references batches(id),
  batch_item_id uuid references batch_items(id),
  seller text check (seller in ('Rabia', 'Harun')),
  sale_type text check (sale_type in ('Normal satış', 'Fire/Bozuk', 'Hibe')),
  qty integer not null default 1,
  total numeric not null default 0,
  cost numeric not null default 0,
  paid boolean default false,
  paid_amount numeric default 0,
  cancelled boolean default false,
  depo text,
  user_email text,
  created_at timestamptz default now()
);

-- Payments (Ödemeler)
create table payments (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id),
  amount numeric not null,
  note text,
  user_email text,
  created_at timestamptz default now()
);

-- Payment Allocations
create table payment_allocations (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid references payments(id),
  sale_id uuid references sales(id),
  amount numeric not null,
  created_at timestamptz default now()
);

-- Periods (Dönemler)
create table periods (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sponsor numeric default 0,
  rabia numeric default 0,
  harun numeric default 0,
  product_cost numeric default 0,
  shipping_cost numeric default 0,
  rabia_contribution numeric default 0,
  harun_contribution numeric default 0,
  rabia_net_odeme numeric,
  harun_net_odeme numeric,
  rabia_distribution numeric,
  harun_distribution numeric,
  is_open boolean default true,
  created_at timestamptz default now(),
  closed_at timestamptz
);

-- Partner Ledger
create table partner_ledger (
  id uuid primary key default gen_random_uuid(),
  partner_name text check (partner_name in ('Veli', 'Rabia', 'Harun')),
  contribution numeric default 0,
  debt numeric default 0,
  profit_share numeric default 0,
  updated_at timestamptz default now()
);

-- Preorders (Ön siparişler)
create table preorders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id),
  created_by text,
  note text,
  status text default 'beklemede',
  created_at timestamptz default now()
);

-- Preorder Items
create table preorder_items (
  id uuid primary key default gen_random_uuid(),
  preorder_id uuid references preorders(id),
  product_id uuid references products(id),
  qty integer not null default 1,
  created_at timestamptz default now()
);

-- Audit Log
create table audit_log (
  id uuid primary key default gen_random_uuid(),
  action text,
  entity_type text,
  entity_name text,
  details jsonb,
  user_email text,
  created_at timestamptz default now()
);

-- =============================================
-- İlk veriler: Partner Ledger
-- =============================================
insert into partner_ledger (partner_name, contribution, debt, profit_share) values
  ('Veli', 0, 0, 0),
  ('Rabia', 0, 0, 0),
  ('Harun', 0, 0, 0);

-- =============================================
-- RLS Policies (tüm tablolar için)
-- =============================================
alter table products enable row level security;
alter table customers enable row level security;
alter table batches enable row level security;
alter table batch_items enable row level security;
alter table batch_costs enable row level security;
alter table sales enable row level security;
alter table payments enable row level security;
alter table payment_allocations enable row level security;
alter table periods enable row level security;
alter table partner_ledger enable row level security;
alter table preorders enable row level security;
alter table preorder_items enable row level security;
alter table audit_log enable row level security;

-- Authenticated kullanıcılar her şeyi yapabilir
create policy "auth_all" on products for all to authenticated using (true) with check (true);
create policy "auth_all" on customers for all to authenticated using (true) with check (true);
create policy "auth_all" on batches for all to authenticated using (true) with check (true);
create policy "auth_all" on batch_items for all to authenticated using (true) with check (true);
create policy "auth_all" on batch_costs for all to authenticated using (true) with check (true);
create policy "auth_all" on sales for all to authenticated using (true) with check (true);
create policy "auth_all" on payments for all to authenticated using (true) with check (true);
create policy "auth_all" on payment_allocations for all to authenticated using (true) with check (true);
create policy "auth_all" on periods for all to authenticated using (true) with check (true);
create policy "auth_all" on partner_ledger for all to authenticated using (true) with check (true);
create policy "auth_all" on preorders for all to authenticated using (true) with check (true);
create policy "auth_all" on preorder_items for all to authenticated using (true) with check (true);
create policy "auth_all" on audit_log for all to authenticated using (true) with check (true);

-- Galeri için products tablosu herkese açık (public)
create policy "public_read_products" on products for select to anon using (true);
