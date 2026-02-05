-- ==========================================
-- EGEA CONTROL - SCRIPT DE MIGRACIÓN UNIFICADA
-- Consolidación de MAIN y PRODUCTIVITY en VPS
-- ==========================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Crear esquemas para organizar los recursos óptimamente
CREATE SCHEMA IF NOT EXISTS main;
CREATE SCHEMA IF NOT EXISTS productivity;

-- ==========================================
-- ESQUEMA: main (Antiguo MAIN)
-- ==========================================

CREATE TABLE main.profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id uuid UNIQUE, -- Relación con el sistema de auth
    full_name text NOT NULL,
    email text NOT NULL UNIQUE,
    phone text,
    role text NOT NULL DEFAULT 'operario',
    status text NOT NULL DEFAULT 'activo',
    avatar_url text,
    name text, -- redundante pero mantenido por compatibilidad
    public_url text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE main.groups (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    color text DEFAULT '#3B82F6',
    description text,
    is_active boolean DEFAULT true,
    created_by uuid REFERENCES main.profiles(id),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE main.profile_groups (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id uuid REFERENCES main.profiles(id) ON DELETE CASCADE,
    group_id uuid REFERENCES main.groups(id) ON DELETE CASCADE,
    role text DEFAULT 'miembro',
    joined_at timestamptz DEFAULT now()
);

CREATE TABLE main.screens (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    screen_type text NOT NULL DEFAULT 'data',
    screen_group text,
    template_id uuid, -- se definirá abajo
    next_screen_id uuid,
    refresh_interval_sec integer DEFAULT 30,
    header_color text DEFAULT '#000000',
    is_active boolean DEFAULT true,
    dashboard_section text,
    dashboard_order integer,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE main.screen_data (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    screen_id uuid REFERENCES main.screens(id) ON DELETE CASCADE,
    data jsonb NOT NULL DEFAULT '{}',
    state text NOT NULL DEFAULT 'pendiente',
    status text NOT NULL DEFAULT 'pendiente',
    start_date date,
    end_date date,
    due_date date,
    location text,
    responsible_profile_id uuid REFERENCES main.profiles(id),
    assigned_to uuid, -- compatible con legacy
    checkin_token text,
    "order" integer DEFAULT 0,
    title text,
    description text,
    priority text DEFAULT 'normal',
    client_name text,
    client_address text,
    client_phone text,
    order_data jsonb DEFAULT '{}',
    metadata jsonb DEFAULT '{}',
    location_metadata jsonb DEFAULT '{}',
    work_site_id uuid,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE main.vehicles (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    type text NOT NULL DEFAULT 'otro',
    license_plate text,
    plate text, -- redundancia legacy
    vehicle_type text DEFAULT 'furgoneta',
    capacity integer DEFAULT 1,
    current_km integer DEFAULT 0,
    status text DEFAULT 'disponible',
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE main.task_vehicles (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id uuid REFERENCES main.screen_data(id) ON DELETE CASCADE,
    vehicle_id uuid REFERENCES main.vehicles(id) ON DELETE CASCADE,
    assigned_at timestamptz DEFAULT now()
);

CREATE TABLE main.system_config (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    key text NOT NULL UNIQUE,
    value jsonb NOT NULL,
    description text,
    category text DEFAULT 'general',
    updated_by uuid,
    updated_at timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now()
);

-- ==========================================
-- ESQUEMA: productivity (Antiguo PRODUCTIVITY)
-- ==========================================

CREATE TABLE productivity.comercial_customers (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    contact_name text,
    email text,
    phone text,
    address text,
    city text,
    postal_code text,
    region text,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE productivity.comercial_orders (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number text NOT NULL UNIQUE,
    customer_id uuid REFERENCES productivity.comercial_customers(id),
    created_by uuid, -- vincular a main.profiles en el futuro
    admin_code text,
    status text DEFAULT 'PENDIENTE_PAGO',
    customer_name text,
    customer_company text,
    contact_name text,
    email text,
    phone text,
    delivery_address text,
    delivery_city text,
    delivery_region text,
    delivery_location_url text,
    delivery_date date,
    fabric text,
    quantity_total integer DEFAULT 0,
    lines jsonb DEFAULT '[]',
    documents jsonb DEFAULT '[]',
    notes text,
    internal_notes text,
    carrier_company text,
    shipment_number text,
    region text, -- redundante
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE productivity.produccion_work_orders (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    comercial_order_id uuid REFERENCES productivity.comercial_orders(id) ON DELETE SET NULL,
    work_order_number text,
    order_number varchar(100) NOT NULL,
    admin_code varchar(100),
    customer_name varchar(255),
    status varchar(50) DEFAULT 'PENDIENTE',
    priority integer DEFAULT 0,
    fabric varchar(255),
    color varchar(100),
    quantity_total integer DEFAULT 0,
    quantity integer DEFAULT 0,
    product_type text,
    packages_count integer,
    scanned_packages integer DEFAULT 0,
    tracking_number varchar(255),
    shipment_number text,
    carrier_company text,
    shipping_date timestamptz,
    due_date timestamptz,
    start_date timestamptz,
    end_date timestamptz,
    region varchar(100),
    delivery_address text,
    contact_name varchar(255),
    phone varchar(50),
    notes text,
    notes_internal text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE productivity.almacen_inventory (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    work_order_id uuid REFERENCES productivity.produccion_work_orders(id) ON DELETE SET NULL,
    order_number text NOT NULL,
    rack text,
    shelf text,
    status text NOT NULL DEFAULT 'EN_ALMACEN',
    packaging_type text,
    weight_kg numeric,
    dimensions_cm text,
    notes text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE productivity.almacen_shipments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tracking_number text,
    carrier_name text,
    shipment_date timestamptz,
    status text DEFAULT 'PENDIENTE',
    recipient_name text,
    delivery_address text,
    delivery_city text,
    delivery_phone text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE productivity.shipment_packages (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id uuid REFERENCES productivity.comercial_orders(id),
    package_number integer NOT NULL,
    units_count integer NOT NULL DEFAULT 0,
    weight_kg numeric,
    height_cm numeric,
    width_cm numeric,
    length_cm numeric,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- ==========================================
-- AUDITORÍA Y REGISTROS (Consolidados)
-- ==========================================

CREATE TABLE main.audit_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid,
    action text NOT NULL,
    resource text,
    resource_id uuid,
    details jsonb DEFAULT '{}',
    ip_address text,
    timestamp timestamptz DEFAULT now()
);

-- Agregar índices para optimizar búsquedas frecuentes
CREATE INDEX idx_screen_data_screen_id ON main.screen_data(screen_id);
CREATE INDEX idx_comercial_orders_number ON productivity.comercial_orders(order_number);
CREATE INDEX idx_work_orders_order_number ON productivity.produccion_work_orders(order_number);
