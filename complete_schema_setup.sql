-- =============================================================
-- LONCHA COMPLETE DATABASE SCHEMA SETUP
-- Run this in Supabase SQL Editor to set up the entire database
-- =============================================================

-- 1. CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  image_url TEXT,
  description TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS public.products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  has_weights BOOLEAN DEFAULT false,
  tag TEXT,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  description TEXT,
  image_url TEXT,
  stock_quantity INTEGER DEFAULT 0,
  position INTEGER DEFAULT 0,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. PROFILES TABLE (for admin roles)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'staff')),
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. ORDERS TABLE
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    total DECIMAL(10, 2) NOT NULL,
    status TEXT DEFAULT 'Pending',
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. ORDER_ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name TEXT,
    selected_weight TEXT,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    line_total DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. DELIVERY ADDRESSES TABLE
CREATE TABLE IF NOT EXISTS delivery_addresses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    full_address TEXT NOT NULL,
    city VARCHAR(100) DEFAULT 'Accra',
    postal_code VARCHAR(20),
    phone_number VARCHAR(20),
    delivery_instructions TEXT,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. DELIVERY TRACKING TABLE
CREATE TABLE IF NOT EXISTS delivery_tracking (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    delivery_address_id UUID REFERENCES delivery_addresses(id) ON DELETE SET NULL,
    rider_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    rider_name VARCHAR(100),
    rider_phone VARCHAR(20),
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    total_distance DECIMAL(10, 2),
    estimated_duration INTEGER,
    remaining_distance DECIMAL(10, 2),
    remaining_duration INTEGER,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN (
        'pending',
        'assigned',
        'picked_up',
        'in_transit',
        'nearby',
        'delivered',
        'cancelled',
        'failed'
    )),
    assigned_at TIMESTAMP WITH TIME ZONE,
    picked_up_at TIMESTAMP WITH TIME ZONE,
    in_transit_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. RIDER LOCATION HISTORY TABLE
CREATE TABLE IF NOT EXISTS rider_location_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    delivery_tracking_id UUID NOT NULL REFERENCES delivery_tracking(id) ON DELETE CASCADE,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    speed DECIMAL(5, 2),
    bearing INTEGER,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================

CREATE INDEX IF NOT EXISTS idx_categories_name ON public.categories(name);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON public.products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_position ON public.products(position);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON public.order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_delivery_addresses_order_id ON delivery_addresses(order_id);
CREATE INDEX IF NOT EXISTS idx_delivery_addresses_coords ON delivery_addresses(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_delivery_tracking_order_id ON delivery_tracking(order_id);
CREATE INDEX IF NOT EXISTS idx_delivery_tracking_status ON delivery_tracking(status);
CREATE INDEX IF NOT EXISTS idx_delivery_tracking_rider_id ON delivery_tracking(rider_id);
CREATE INDEX IF NOT EXISTS idx_rider_location_history_tracking_id ON rider_location_history(delivery_tracking_id);
CREATE INDEX IF NOT EXISTS idx_rider_location_history_recorded_at ON rider_location_history(recorded_at);

-- =============================================================
-- DISABLE RLS FOR EASY ACCESS (DEVELOPMENT)
-- =============================================================

ALTER TABLE public.categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.products DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_addresses DISABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_tracking DISABLE ROW LEVEL SECURITY;
ALTER TABLE rider_location_history DISABLE ROW LEVEL SECURITY;

-- =============================================================
-- GRANT PERMISSIONS
-- =============================================================

GRANT ALL ON public.categories TO anon, authenticated;
GRANT ALL ON public.products TO anon, authenticated;
GRANT ALL ON public.profiles TO anon, authenticated;
GRANT ALL ON public.orders TO anon, authenticated;
GRANT ALL ON public.order_items TO anon, authenticated;
GRANT ALL ON delivery_addresses TO anon, authenticated;
GRANT ALL ON delivery_tracking TO anon, authenticated;
GRANT ALL ON rider_location_history TO anon, authenticated;

-- =============================================================
-- TRIGGERS AND FUNCTIONS
-- =============================================================

-- Function to auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        'customer'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for auto-creating profiles
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_orders_updated_at ON public.orders;
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_delivery_addresses_updated_at ON delivery_addresses;
CREATE TRIGGER update_delivery_addresses_updated_at
    BEFORE UPDATE ON delivery_addresses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_delivery_tracking_updated_at ON delivery_tracking;
CREATE TRIGGER update_delivery_tracking_updated_at
    BEFORE UPDATE ON delivery_tracking
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate distance between two points
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 DECIMAL, lon1 DECIMAL,
    lat2 DECIMAL, lon2 DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
    r DECIMAL := 6371; -- Earth radius in km
    dlat DECIMAL;
    dlon DECIMAL;
    a DECIMAL;
    c DECIMAL;
BEGIN
    dlat := RADIANS(lat2 - lat1);
    dlon := RADIANS(lon2 - lon1);
    
    a := SIN(dlat/2) * SIN(dlat/2) +
         COS(RADIANS(lat1)) * COS(RADIANS(lat2)) *
         SIN(dlon/2) * SIN(dlon/2);
    
    c := 2 * ATAN2(SQRT(a), SQRT(1-a));
    
    RETURN r * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =============================================================
-- VERIFICATION
-- =============================================================

SELECT 'Schema setup complete!' as status;

-- List all created tables
SELECT 
    tablename, 
    schemaname
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;
