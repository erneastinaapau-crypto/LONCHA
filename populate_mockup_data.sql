-- Clear existing data
TRUNCATE TABLE public.products CASCADE;
TRUNCATE TABLE public.categories CASCADE;

-- Insert Categories
INSERT INTO public.categories (name, image_url, description, created_at) VALUES
  ('Modern Kitchens', 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400', 'Contemporary kitchen designs', NOW()),
  ('Kitchen Cabinets', 'https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=400', 'Custom cabinetry solutions', NOW()),
  ('Countertops', 'https://images.unsplash.com/photo-1556912173-3db996ea6c3d?w=400', 'Premium countertop materials', NOW()),
  ('Interior Design', 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=400', 'Professional interior design services', NOW());

-- Insert Products (20 mock kitchen/interior items)
INSERT INTO public.products (name, price, has_weights, tag, category_id, description, image_url, stock_quantity, position, created_at) VALUES
  -- Modern Kitchens
  ('Contemporary Kitchen Set', 2500.00, false, null, (SELECT id FROM public.categories WHERE name = 'Modern Kitchens'), 'Complete modern kitchen with sleek cabinetry and appliances', 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600', 45, 1, NOW()),
  ('Luxury Kitchen Design', 3500.00, false, 'BEST SELLER', (SELECT id FROM public.categories WHERE name = 'Modern Kitchens'), 'High-end kitchen with premium finishes and smart features', 'https://images.unsplash.com/photo-1556910103-1c02745a30bf?w=600', 32, 2, NOW()),
  ('Minimalist Kitchen', 1800.00, false, null, (SELECT id FROM public.categories WHERE name = 'Modern Kitchens'), 'Clean and simple modern kitchen design', 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600', 60, 3, NOW()),
  ('Open Concept Kitchen', 2200.00, false, null, (SELECT id FROM public.categories WHERE name = 'Modern Kitchens'), 'Spacious open-plan kitchen with island', 'https://images.unsplash.com/photo-1556909172-e856b4ecf5e8?w=600', 28, 4, NOW()),
  ('Smart Kitchen Setup', 2800.00, false, null, (SELECT id FROM public.categories WHERE name = 'Modern Kitchens'), 'Integrated smart technology kitchen solution', 'https://images.unsplash.com/photo-1556910103-1c02745a30bf?w=600', 75, 5, NOW()),
  
  -- Kitchen Cabinets
  ('Custom Oak Cabinets', 1200.00, false, 'BEST SELLER', (SELECT id FROM public.categories WHERE name = 'Kitchen Cabinets'), 'Handcrafted solid oak cabinets with soft-close hardware', 'https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=600', 22, 6, NOW()),
  ('Modern White Cabinets', 950.00, false, null, (SELECT id FROM public.categories WHERE name = 'Kitchen Cabinets'), 'Sleek white lacquer cabinets with minimalist design', 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600', 18, 7, NOW()),
  ('Dark Walnut Cabinets', 1400.00, false, null, (SELECT id FROM public.categories WHERE name = 'Kitchen Cabinets'), 'Rich walnut cabinets with premium hardware', 'https://images.unsplash.com/photo-1556910103-1c02745a30bf?w=600', 15, 8, NOW()),
  ('Shaker Style Cabinets', 850.00, false, null, (SELECT id FROM public.categories WHERE name = 'Kitchen Cabinets'), 'Classic shaker cabinets with modern twist', 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600', 30, 9, NOW()),
  ('Glass Door Cabinets', 1100.00, false, null, (SELECT id FROM public.categories WHERE name = 'Kitchen Cabinets'), 'Contemporary cabinets with glass display doors', 'https://images.unsplash.com/photo-1556909172-e856b4ecf5e8?w=600', 25, 10, NOW()),
  
  -- Countertops
  ('Granite Countertop Set', 1500.00, false, 'BEST SELLER', (SELECT id FROM public.categories WHERE name = 'Countertops'), 'Premium granite countertops with elegant edge profiles', 'https://images.unsplash.com/photo-1556912173-3db996ea6c3d?w=600', 35, 11, NOW()),
  ('Quartz Countertops', 1300.00, false, null, (SELECT id FROM public.categories WHERE name = 'Countertops'), 'Durable quartz countertops in various colors', 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600', 28, 12, NOW()),
  ('Marble Countertops', 1800.00, false, null, (SELECT id FROM public.categories WHERE name = 'Countertops'), 'Luxurious marble countertops with unique patterns', 'https://images.unsplash.com/photo-1556910103-1c02745a30bf?w=600', 20, 13, NOW()),
  ('Butcher Block Countertops', 600.00, false, null, (SELECT id FROM public.categories WHERE name = 'Countertops'), 'Warm wood butcher block countertops', 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600', 40, 14, NOW()),
  ('Concrete Countertops', 900.00, false, null, (SELECT id FROM public.categories WHERE name = 'Countertops'), 'Modern industrial concrete countertops', 'https://images.unsplash.com/photo-1556912173-3db996ea6c3d?w=600', 18, 15, NOW()),
  
  -- Interior Design
  ('Living Room Design Package', 800.00, false, null, (SELECT id FROM public.categories WHERE name = 'Interior Design'), 'Complete living room design consultation', 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=600', 90, 16, NOW()),
  ('Bedroom Design Service', 600.00, false, 'BEST SELLER', (SELECT id FROM public.categories WHERE name = 'Interior Design'), 'Professional bedroom design and space planning', 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600', 55, 17, NOW()),
  ('Kitchen Design Consultation', 500.00, false, null, (SELECT id FROM public.categories WHERE name = 'Interior Design'), 'Expert kitchen design advice and planning', 'https://images.unsplash.com/photo-1556910103-1c02745a30bf?w=600', 70, 18, NOW()),
  ('Full Home Interior Design', 2500.00, false, null, (SELECT id FROM public.categories WHERE name = 'Interior Design'), 'Complete home interior design package', 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=600', 42, 19, NOW()),
  ('Office Space Design', 450.00, false, null, (SELECT id FROM public.categories WHERE name = 'Interior Design'), 'Modern home office design solutions', 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600', 65, 20, NOW());

-- Verify insertion
SELECT 
  'Products' as table_name, 
  COUNT(*) as row_count 
FROM public.products
UNION ALL
SELECT 
  'Categories' as table_name, 
  COUNT(*) as row_count 
FROM public.categories;
