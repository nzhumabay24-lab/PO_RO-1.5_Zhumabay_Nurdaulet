-- =====================================================
-- FINAL PROJECT
-- DOMAIN: AUTO REPAIR SHOP
-- DATABASE: auto_repair_db
-- SCHEMA: auto_repair
-- PostgreSQL
-- =====================================================

create schema if not exists auto_repair;

set search_path to auto_repair;

-- =====================================================
-- PART 1: CREATE TABLES
-- =====================================================

create table if not exists customers (
    customer_id int generated always as identity primary key,
    full_name varchar(150) not null,
    phone_number varchar(15) not null,
    email varchar(120),
    registration_date date default current_date,
    unique(email)
);

create table if not exists positions (
    position_id int generated always as identity primary key,
    position_name varchar(100) not null unique,
    base_salary numeric(10,2) not null,
    check (base_salary >= 0)
);

create table if not exists employees (
    employee_id int generated always as identity primary key,
    full_name varchar(150) not null,
    position_id int not null,
    hire_date date not null,
    salary numeric(10,2) not null,
    gender varchar(10),
    foreign key (position_id)
        references positions(position_id)
        on delete restrict,
    check (salary >= 0),
    check (gender in ('male','female'))
);

create table if not exists vehicles (
    vehicle_id int generated always as identity primary key,
    customer_id int not null,
    brand varchar(50) not null,
    model varchar(50) not null,
    production_year int not null,
    plate_number varchar(20) not null unique,
    foreign key (customer_id)
        references customers(customer_id)
        on delete cascade,
    check (production_year >= 2000)
);

create table if not exists service_categories (
    category_id int generated always as identity primary key,
    category_name varchar(100) not null unique,
    description varchar(250)
);

create table if not exists services (
    service_id int generated always as identity primary key,
    category_id int not null,
    service_name varchar(150) not null,
    price numeric(10,2) not null,
    duration_hours numeric(4,1) not null,
    foreign key (category_id)
        references service_categories(category_id)
        on delete restrict,
    check (price >= 0),
    check (duration_hours >= 0)
);

create table if not exists repair_orders (
    order_id int generated always as identity primary key,
    vehicle_id int not null,
    employee_id int not null,
    order_date date not null,
    status varchar(20) default 'pending',
    notes varchar(300),

    foreign key (vehicle_id)
        references vehicles(vehicle_id)
        on delete cascade,

    foreign key (employee_id)
        references employees(employee_id)
        on delete restrict,

    check (
        status in (
            'pending',
            'in_progress',
            'completed',
            'cancelled'
        )
    ),

    check (
        order_date > date '2026-01-01'
    )
);

create table if not exists repair_order_services (
    order_service_id int generated always as identity primary key,

    order_id int not null,
    service_id int not null,

    hours_worked numeric(5,2) not null,
    hourly_rate numeric(10,2) not null,

    total_cost numeric(12,2)
    generated always as (
        hours_worked * hourly_rate
    ) stored,

    foreign key (order_id)
        references repair_orders(order_id)
        on delete cascade,

    foreign key (service_id)
        references services(service_id)
        on delete restrict,

    check (hours_worked >= 0),
    check (hourly_rate >= 0)
);

create table if not exists suppliers (
    supplier_id int generated always as identity primary key,
    supplier_name varchar(150) not null unique,
    phone varchar(20),
    city varchar(80)
);

create table if not exists spare_parts (
    part_id int generated always as identity primary key,
    supplier_id int not null,
    part_name varchar(150) not null,
    unit_price numeric(10,2) not null,
    stock_quantity int not null,

    foreign key (supplier_id)
        references suppliers(supplier_id)
        on delete restrict,

    check (unit_price >= 0),
    check (stock_quantity >= 0)
);


create table if not exists payments (
    payment_id int generated always as identity primary key,
    order_id int not null,
    payment_date date not null,
    amount numeric(12,2) not null,
    payment_method varchar(20) not null,

    foreign key (order_id)
        references repair_orders(order_id)
        on delete cascade,

    check (amount >= 0),

    check (
        payment_method in (
            'cash',
            'card',
            'transfer'
        )
    )
);

create table if not exists order_parts (
    order_part_id int generated always as identity primary key,

    order_id int not null,
    part_id int not null,

    quantity int not null,

    foreign key (order_id)
        references repair_orders(order_id)
        on delete cascade,

    foreign key (part_id)
        references spare_parts(part_id)
        on delete restrict,

    check (quantity > 0)
);
-- =====================================================
-- PART 2: ALTER TABLE
-- =====================================================

-- international phone numbers may be longer

alter table customers
alter column phone_number
type varchar(20);

-- forgot customer address

alter table customers
add column address varchar(200);

-- default city for suppliers

alter table suppliers
add column country varchar(50);

-- most suppliers are from Kazakhstan

alter table suppliers
alter column country
set default 'Kazakhstan';


-- extra business rule

alter table services
add constraint service_price_check
check (price <= 100000);

-- =====================================================
-- END OF PART 1-3
-- =====================================================

-- =====================================================
-- PART 4: TRUNCATE
-- =====================================================

truncate table
    payments,
    order_parts,
    repair_order_services,
    repair_orders,
    spare_parts,
    suppliers,
    services,
    service_categories,
    vehicles,
    employees,
    positions,
    customers
restart identity cascade;

-- =====================================================
-- PART 5: INSERT DATA
-- =====================================================

insert into customers (full_name, phone_number, email, address)
values
('Аманбай Айкен Ақылбекқызы','87010000001','aiken@mail.kz','Atyrau'),
('Әміржанқызы Асылай','87010000002','asylai1@mail.kz','Atyrau'),
('Балғабай Әсел Болатбекқызы','87010000003','asel@mail.kz','Atyrau'),
('Гарифов Ильнур Маратович','87010000004','ilnur@mail.kz','Atyrau'),
('Гайниденұлы Арслан','87010000005','arslan@mail.kz','Atyrau'),
('Ерболатқызы Каусар','87010000006','kausar@mail.kz','Atyrau'),
('Жұмабай Нұрдаулет Маратұлы','87010000007','nurdaulet@mail.kz','Atyrau'),
('Жумакулова Асылай Маратовна','87010000008','asylai2@mail.kz','Atyrau'),
('Жұмағали Айша Қанатқызы','87010000009','aisha@mail.kz','Atyrau'),
('Игілік Көркем Нұрланқызы','87010000010','korkem@mail.kz','Atyrau');

insert into positions (position_name, base_salary)
values
('Mechanic',300000),
('Senior Mechanic',450000),
('Electrician',400000),
('Manager',500000),
('Administrator',280000);

insert into employees
(full_name, position_id, hire_date, salary, gender)
values
(
'Курмашев Артур Берикович',
(select position_id from positions where position_name='Mechanic'),
'2026-02-01',
320000,
'male'
),
(
'Қамай Арнұр Бауыржанұлы',
(select position_id from positions where position_name='Senior Mechanic'),
'2026-02-05',
470000,
'male'
),
(
'Қайрақбай Инабат Тимурқызы',
(select position_id from positions where position_name='Administrator'),
'2026-02-10',
290000,
'female'
),
(
'Қадырғали Сымбат Ақылбекқызы',
(select position_id from positions where position_name='Manager'),
'2026-02-15',
520000,
'female'
),
(
'Ли Максим Юрьевич',
(select position_id from positions where position_name='Electrician'),
'2026-03-01',
420000,
'male'
);

insert into vehicles
(customer_id, brand, model, production_year, plate_number)
values
(
(select customer_id from customers where email='aiken@mail.kz'),
'Toyota','Camry',2020,'777AAA01'
),
(
(select customer_id from customers where email='asylai1@mail.kz'),
'Hyundai','Elantra',2021,'777AAA02'
),
(
(select customer_id from customers where email='asel@mail.kz'),
'Kia','Rio',2022,'777AAA03'
),
(
(select customer_id from customers where email='ilnur@mail.kz'),
'BMW','X5',2020,'777AAA04'
),
(
(select customer_id from customers where email='arslan@mail.kz'),
'Mercedes','E200',2023,'777AAA05'
),
(
(select customer_id from customers where email='kausar@mail.kz'),
'Chevrolet','Cobalt',2021,'777AAA06'
),
(
(select customer_id from customers where email='nurdaulet@mail.kz'),
'Toyota','Corolla',2022,'777AAA07'
),
(
(select customer_id from customers where email='asylai2@mail.kz'),
'Lexus','RX350',2023,'777AAA08'
),
(
(select customer_id from customers where email='aisha@mail.kz'),
'Audi','A6',2020,'777AAA09'
),
(
(select customer_id from customers where email='korkem@mail.kz'),
'Volkswagen','Passat',2021,'777AAA10'
);

insert into service_categories (category_name, description)
values
('Engine','Engine repair'),
('Electrical','Electrical systems'),
('Diagnostics','Computer diagnostics'),
('Suspension','Suspension repair'),
('Maintenance','Regular maintenance');

insert into services
(category_id, service_name, price, duration_hours)
values
(
(select category_id from service_categories where category_name='Engine'),
'Engine Repair',
80000,
8
),
(
(select category_id from service_categories where category_name='Electrical'),
'Electrical Repair',
50000,
4
),
(
(select category_id from service_categories where category_name='Diagnostics'),
'Computer Diagnostics',
15000,
1
),
(
(select category_id from service_categories where category_name='Suspension'),
'Suspension Repair',
60000,
5
),
(
(select category_id from service_categories where category_name='Maintenance'),
'Oil Change',
10000,
1
);

insert into suppliers (supplier_name, phone, city)
values
('Auto Parts Atyrau','87071111111','Atyrau'),
('KazParts','87072222222','Almaty'),
('Motor World','87073333333','Astana'),
('Best Spare Parts','87074444444','Atyrau'),
('Auto Expert','87075555555','Aktobe');

insert into spare_parts
(supplier_id, part_name, unit_price, stock_quantity)
values
(
(select supplier_id from suppliers where supplier_name='Auto Parts Atyrau'),
'Brake Pads',
15000,
50
),
(
(select supplier_id from suppliers where supplier_name='KazParts'),
'Battery',
35000,
20
),
(
(select supplier_id from suppliers where supplier_name='Motor World'),
'Spark Plug',
5000,
100
),
(
(select supplier_id from suppliers where supplier_name='Best Spare Parts'),
'Air Filter',
4000,
70
),
(
(select supplier_id from suppliers where supplier_name='Auto Expert'),
'Oil Filter',
3000,
80
);

insert into repair_orders
(vehicle_id, employee_id, order_date, status, notes)
values
(
(select vehicle_id from vehicles where plate_number='777AAA01'),
(select employee_id from employees where full_name='Курмашев Артур Берикович'),
'2026-04-01',
'pending',
'Engine inspection'
),
(
(select vehicle_id from vehicles where plate_number='777AAA02'),
(select employee_id from employees where full_name='Қамай Арнұр Бауыржанұлы'),
'2026-04-02',
'in_progress',
'Electrical issue'
),
(
(select vehicle_id from vehicles where plate_number='777AAA03'),
(select employee_id from employees where full_name='Ли Максим Юрьевич'),
'2026-04-03',
'completed',
'Diagnostics'
),
(
(select vehicle_id from vehicles where plate_number='777AAA04'),
(select employee_id from employees where full_name='Курмашев Артур Берикович'),
'2026-04-04',
'cancelled',
'Client cancelled'
),
(
(select vehicle_id from vehicles where plate_number='777AAA05'),
(select employee_id from employees where full_name='Қамай Арнұр Бауыржанұлы'),
'2026-04-05',
'pending',
'Suspension problem'
);

-- INSERT ... SELECT

insert into repair_order_services
(order_id, service_id, hours_worked, hourly_rate)
select
r.order_id,
s.service_id,
2,
10000
from repair_orders r
cross join services s
where r.order_id <= 5
and s.service_id = 3;

insert into order_parts
(order_id, part_id, quantity)
values
(
    (select order_id from repair_orders where order_id = 1),
    (select part_id from spare_parts where part_name = 'Brake Pads'),
    2
),
(
    (select order_id from repair_orders where order_id = 2),
    (select part_id from spare_parts where part_name = 'Battery'),
    1
),
(
    (select order_id from repair_orders where order_id = 3),
    (select part_id from spare_parts where part_name = 'Spark Plug'),
    4
),
(
    (select order_id from repair_orders where order_id = 4),
    (select part_id from spare_parts where part_name = 'Air Filter'),
    1
),
(
    (select order_id from repair_orders where order_id = 5),
    (select part_id from spare_parts where part_name = 'Oil Filter'),
    2
);

insert into payments
(order_id, payment_date, amount, payment_method)
values
(
(select order_id from repair_orders where order_id=1),
'2026-05-10',
20000,
'card'
),
(
(select order_id from repair_orders where order_id=2),
'2026-05-10',
35000,
'cash'
),
(
(select order_id from repair_orders where order_id=3),
'2026-05-10',
15000,
'transfer'
),
(
(select order_id from repair_orders where order_id=4),
'2026-05-10',
10000,
'card'
),
(
(select order_id from repair_orders where order_id=5),
'2026-05-10',
25000,
'cash'
);

-- =====================================================
-- PART 6: UPDATE
-- =====================================================

-- order completed

update repair_orders
set status = 'completed'
where order_id = 1;

-- synchronize employee salary with position salary

update employees e
set salary = p.base_salary
from positions p
where e.position_id = p.position_id;

-- =====================================================
-- PART 7: DELETE
-- =====================================================

-- remove cancelled orders for audit check

begin;

delete from repair_orders
where status = 'cancelled'
returning order_id;

rollback;

-- =====================================================
-- PART 8: ROLES
-- =====================================================

do $$
begin
    if not exists (
        select 1
        from pg_roles
        where rolname = 'auto_repair_readonly'
    ) then
        create role auto_repair_readonly;
    end if;
end
$$;

do $$
begin
    if not exists (
        select 1
        from pg_roles
        where rolname = 'auto_repair_writer'
    ) then
        create role auto_repair_writer;
    end if;
end
$$;

-- writers can create orders but cannot modify them later

revoke update
on repair_orders
from auto_repair_writer;
