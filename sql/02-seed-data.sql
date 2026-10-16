-- Sample data for the SQL lab (10 customers, 5 categories, 15 products, 20 orders)

INSERT INTO customers (first_name, last_name, email, city, country, signup_date) VALUES
  ('Ama',     'Mensah',   'ama.mensah@example.com',     'Accra',      'Ghana',          '2025-01-14'),
  ('Kofi',    'Boateng',  'kofi.boateng@example.com',   'Kumasi',     'Ghana',          '2025-02-03'),
  ('Sarah',   'Johnson',  'sarah.johnson@example.com',  'Seattle',    'United States',  '2025-02-20'),
  ('Michael', 'Chen',     'michael.chen@example.com',   'Toronto',    'Canada',         '2025-03-11'),
  ('Fatima',  'Okafor',   'fatima.okafor@example.com',  'Lagos',      'Nigeria',        '2025-04-02'),
  ('James',   'Smith',    'james.smith@example.com',    'London',     'United Kingdom', '2025-04-18'),
  ('Priya',   'Patel',    'priya.patel@example.com',    'Mumbai',     'India',          '2025-05-07'),
  ('Lucas',   'Silva',    'lucas.silva@example.com',    'São Paulo',  'Brazil',         '2025-06-21'),
  ('Emma',    'Brown',    'emma.brown@example.com',     'New York',   'United States',  '2025-07-30'),
  ('Yaw',     'Asante',   'yaw.asante@example.com',     NULL,         'Ghana',          '2025-09-12');

INSERT INTO categories (name) VALUES
  ('Electronics'), ('Books'), ('Home'), ('Sports'), ('Clothing');

INSERT INTO products (name, category_id, price, stock) VALUES
  ('Wireless Headphones', 1, 89.99, 40),
  ('USB-C Charger',       1, 19.99, 150),
  ('Smart Watch',         1, 199.00, 25),
  ('Bluetooth Speaker',   1, 49.50, 0),
  ('Cloud Computing 101', 2, 34.95, 60),
  ('Learning SQL',        2, 42.00, 35),
  ('Kubernetes in Action',2, 54.99, 20),
  ('Coffee Maker',        3, 79.00, 15),
  ('Desk Lamp',           3, 24.99, 80),
  ('Yoga Mat',            4, 29.99, 55),
  ('Running Shoes',       4, 119.00, 30),
  ('Water Bottle',        4, 14.50, 200),
  ('Hoodie',              5, 45.00, 70),
  ('T-Shirt',             5, 15.00, 120),
  ('Rain Jacket',         5, 95.00, 0);

INSERT INTO orders (customer_id, order_date, status) VALUES
  (1, '2025-03-01', 'delivered'),   -- 1
  (2, '2025-03-15', 'delivered'),   -- 2
  (3, '2025-04-02', 'delivered'),   -- 3
  (1, '2025-04-20', 'delivered'),   -- 4
  (4, '2025-05-05', 'cancelled'),   -- 5
  (5, '2025-05-18', 'delivered'),   -- 6
  (3, '2025-06-01', 'delivered'),   -- 7
  (6, '2025-06-14', 'shipped'),     -- 8
  (7, '2025-07-03', 'delivered'),   -- 9
  (1, '2025-07-22', 'delivered'),   -- 10
  (8, '2025-08-09', 'delivered'),   -- 11
  (9, '2025-08-30', 'shipped'),     -- 12
  (2, '2025-09-10', 'delivered'),   -- 13
  (5, '2025-09-25', 'pending'),     -- 14
  (3, '2025-10-04', 'shipped'),     -- 15
  (6, '2025-10-18', 'delivered'),   -- 16
  (7, '2025-11-02', 'pending'),     -- 17
  (9, '2025-11-20', 'delivered'),   -- 18
  (1, '2025-12-05', 'shipped'),     -- 19
  (4, '2025-12-15', 'pending');     -- 20

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (1, 1, 1, 89.99),  (1, 2, 2, 19.99),
  (2, 5, 1, 34.95),  (2, 6, 1, 42.00),
  (3, 3, 1, 199.00),
  (4, 10, 1, 29.99), (4, 12, 3, 14.50),
  (5, 11, 1, 119.00),
  (6, 13, 2, 45.00), (6, 14, 3, 15.00),
  (7, 7, 1, 54.99),  (7, 6, 1, 42.00), (7, 5, 1, 34.95),
  (8, 8, 1, 79.00),
  (9, 1, 2, 89.99),
  (10, 11, 1, 119.00), (10, 12, 2, 14.50),
  (11, 9, 2, 24.99), (11, 2, 1, 19.99),
  (12, 3, 1, 199.00), (12, 1, 1, 89.99),
  (13, 14, 4, 15.00),
  (14, 10, 2, 29.99),
  (15, 13, 1, 45.00), (15, 8, 1, 79.00),
  (16, 6, 2, 42.00),
  (17, 3, 1, 199.00),
  (18, 9, 1, 24.99), (18, 12, 1, 14.50), (18, 14, 2, 15.00),
  (19, 7, 1, 54.99),
  (20, 2, 3, 19.99);
