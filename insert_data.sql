-- Sử dụng database
USE canteen_db;

-- ========================================
-- 1. USERS TABLE
-- ========================================
-- Chú ý: Trong thực tế, 'password' phải là kết quả băm mật khẩu
INSERT INTO users (username, password, full_name, email, phone_number, role, status) VALUES
-- 1. Tài khoản Admin
('admin', MD5('123456'), 'Admin', 'admin@hcm.edu.vn', '0901112222', 'admin', TRUE),

-- 2. Tài khoản Quầy (Stall Staff) - Quản lý Quầy Cơm
('thietru', MD5('123456'), 'Thiết Trụ', 'thiettru@hcm.edu.vn', '0903334444', 'stall', TRUE),

-- 3. Tài khoản Quầy (Stall Staff) - Quản lý Quầy Phở/Bún
('lymouyen', MD5('123456'), 'Lý Mộ Uyển', 'lymouyen@hcm.edu.vn', '0905556666', 'stall', TRUE),

-- 4. Tài khoản Khách hàng (SV/CBNV) - Người dùng 1
('vuonglam', MD5('123456'), 'Vương Lâm', 'vuonglam@hcm.edu.vn', '0907778888', 'customer', TRUE),

-- 5. Tài khoản Khách hàng (SV/CBNV) - Người dùng 2
('hoangthiloan', MD5('123456'), 'Hoàng Thị Loan', 'hoangthiloan@hcm.edu.vn', '0909990000', 'customer', TRUE),

-- 6. Tài khoản Khách hàng bị vô hiệu hóa
('nguyenvannam', MD5('123456'), 'Nguyễn Văn Nam', 'nguyenvannam@hcm.edu.vn', '0911112222', 'customer', FALSE);

-- ========================================
-- 2. STALLS TABLE
-- ========================================
INSERT INTO stalls (name, description, manager_user_id, is_open) VALUES
('Quầy Cơm Thiết Trụ', 'Chuyên các món cơm truyền thống Việt Nam, cơm tấm, cơm chiên.', 2, TRUE),
('Quầy Phở Bún Lý Mộ Uyển', 'Chuyên phở, bún, mì, các món nước đặc trưng miền Bắc và Trung.', 3, TRUE);

-- ========================================
-- 3. FOOD_CATEGORIES TABLE
-- ========================================
INSERT INTO food_categories (name, description) VALUES
-- 1. Các món ăn chính (Cơm, Bún, Phở)
('Cơm', 'Các món cơm phục vụ bữa trưa và bữa tối.'),
('Phở/Bún/Mì', 'Các món nước truyền thống của Việt Nam.'),
('Đồ Ăn Vặt/Tráng Miệng', 'Các món ăn nhẹ, kem, chè.'),

-- 2. Đồ uống
('Đồ Uống Giải Khát', 'Nước ngọt có gas, nước đóng chai.'),
('Cà Phê/Trà', 'Các loại cà phê, trà nóng và lạnh.');

-- ========================================
-- 4. FOODS TABLE
-- ========================================
INSERT INTO foods (category_id, image, name, price, inventory, stall_id, description, is_available, updated_at, promotion) VALUES
-- Món category_id 1: Cơm (Stall 1 - Quầy Cơm Thiết Trụ)
(1, NULL, 'Cơm Gà Xối Mỡ Đặc Biệt', 45000.00, 50, 1, 'Gà xối mỡ giòn rụm, ăn kèm cơm trắng và dưa góp.', TRUE, NOW(), 10.00),
(1, NULL, 'Cơm Sườn Bì Chả', 40000.00, 60, 1, 'Sườn nướng mật ong, bì, chả trứng và nước sốt đặc trưng.', TRUE, NOW(), 10.00),
(1, NULL, 'Cơm Thịt Kho Trứng', 35000.00, 45, 1, 'Thịt ba chỉ kho tàu mềm rục với trứng cút.', TRUE, NOW(), 15.00),
(1, NULL, 'Cơm Canh Chua Cá Lóc', 55000.00, 30, 1, 'Canh chua cá lóc miền Tây, vị chua ngọt đậm đà.', TRUE, NOW(), 15.00),
(1, NULL, 'Cơm Tấm Bì Chả', 38000.00, 55, 1, 'Cơm tấm Sài Gòn truyền thống, không có sườn.', TRUE, NOW(), 20.00),
(1, NULL, 'Cơm Trắng Đơn Giản', 10000.00, 999, 1, 'Chỉ có cơm trắng.', TRUE, NOW(), 0.00),
(1, NULL, 'Cơm Xào Bò Lúc Lắc', 60000.00, 25, 1, 'Thịt bò xào với khoai tây và hành tây, sốt tiêu đen.', TRUE, NOW(), 25.00),
(1, NULL, 'Cơm Kho Quẹt Tôm Thịt', 42000.00, 40, 1, 'Thịt kho quẹt ăn kèm rau luộc theo ngày.', TRUE, NOW(), 0.00),
(1, NULL, 'Cơm Chiên Hải Sản', 48000.00, 35, 1, 'Cơm chiên tôm, mực, rau củ.', TRUE, NOW(), 30.00),
(1, NULL, 'Cơm Thập Cẩm', 45000.00, 50, 1, 'Phần cơm tự chọn 3 món mặn/xào.', TRUE, NOW(), 0.00),

-- Món category_id 2: Phở/Bún/Mì (Stall 2 - Quầy Phở Bún Lý Mộ Uyển)
(2, NULL, 'Phở Bò Tái Nạm', 50000.00, 70, 2, 'Phở bò Hà Nội truyền thống, nước dùng thanh ngọt.', TRUE, NOW(), 5.00),
(2, NULL, 'Bún Chả Hà Nội', 45000.00, 65, 2, 'Thịt nướng than hoa, chả viên, bún rối và rau thơm.', TRUE, NOW(), 5.00),
(2, NULL, 'Mì Quảng Gà', 55000.00, 40, 2, 'Mì Quảng với thịt gà, trứng cút và đậu phộng.', TRUE, NOW(), 10.00),
(2, NULL, 'Bún Bò Huế Đặc Biệt', 50000.00, 50, 2, 'Bún bò cay, chả cua, móng giò và tiết.', TRUE, NOW(), 10.00),
(2, NULL, 'Phở Gà Lá Chanh', 45000.00, 60, 2, 'Phở với thịt gà xé và lá chanh thơm lừng.', TRUE, NOW(), 15.00),
(2, NULL, 'Hủ Tiếu Nam Vang Khô', 52000.00, 35, 2, 'Hủ tiếu khô trộn với tôm, thịt xá xíu, gan.', TRUE, NOW(), 15.00),
(2, NULL, 'Bún Riêu Cua', 40000.00, 55, 2, 'Bún riêu cua đồng, có thêm đậu hũ và huyết.', TRUE, NOW(), 12.00),
(2, NULL, 'Mì Trứng Xào Giòn', 45000.00, 30, 2, 'Mì được chiên giòn, ăn kèm rau và thịt xào.', TRUE, NOW(), 12.00),
(2, NULL, 'Bánh Canh Cua', 58000.00, 25, 2, 'Bánh canh bột lọc/bột gạo với thịt cua.', TRUE, NOW(), 10.00),
(2, NULL, 'Phở Chay Rau Củ', 35000.00, 20, 2, 'Phở chay thanh đạm, nước dùng từ rau củ.', TRUE, NOW(), 10.00),

-- Món category_id 3: Đồ Ăn Vặt/Tráng Miệng (Cả 2 quầy đều có)
(3, NULL, 'Bánh Mì Thịt Nướng', 25000.00, 100, 1, 'Bánh mì Việt Nam với thịt nướng, pate, rau thơm.', TRUE, NOW(), 0.00),
(3, NULL, 'Chè Đậu Đỏ', 15000.00, 80, 1, 'Chè đậu đỏ nấu nước cốt dừa, ăn nóng hoặc lạnh.', TRUE, NOW(), 0.00),
(3, NULL, 'Kem Que Các Loại', 10000.00, 200, 1, 'Kem que đa dạng vị: vani, chocolate, dâu.', TRUE, NOW(), 0.00),
(3, NULL, 'Bánh Flan Caramel', 20000.00, 50, 1, 'Bánh flan mềm mịn với caramel ngọt ngào.', TRUE, NOW(), 0.00),
(3, NULL, 'Sữa Chua Dẻo Trái Cây', 18000.00, 60, 1, 'Sữa chua dẻo kết hợp trái cây tươi.', TRUE, NOW(), 0.00),
(3, NULL, 'Bánh Bao Nhân Thịt', 15000.00, 90, 2, 'Bánh bao hấp với nhân thịt, trứng, nấm.', TRUE, NOW(), 0.00),
(3, NULL, 'Chè Ba Màu', 18000.00, 70, 2, 'Chè ba màu truyền thống, ngọt mát.', TRUE, NOW(), 0.00),
(3, NULL, 'Xôi Xéo', 20000.00, 50, 2, 'Xôi xéo với đậu xanh và hành phi.', TRUE, NOW(), 0.00),
(3, NULL, 'Bánh Chuối Nướng', 12000.00, 45, 2, 'Bánh chuối nướng thơm lừng, béo ngậy.', TRUE, NOW(), 0.00),
(3, NULL, 'Rau Câu Dừa', 10000.00, 100, 2, 'Rau câu dừa mát lạnh, thơm béo.', TRUE, NOW(), 0.00),

-- Món category_id 4: Đồ Uống Giải Khát (Cả 2 quầy đều có)
(4, NULL, 'Nước Ngọt Coca Cola', 15000.00, 300, 1, 'Coca Cola lon 330ml.', TRUE, NOW(), 0.00),
(4, NULL, 'Nước Ngọt Pepsi', 15000.00, 300, 1, 'Pepsi lon 330ml.', TRUE, NOW(), 0.00),
(4, NULL, 'Nước Suối Aquafina', 10000.00, 500, 1, 'Nước suối đóng chai 500ml.', TRUE, NOW(), 0.00),
(4, NULL, 'Nước Cam Ép', 25000.00, 80, 1, 'Nước cam ép tươi 100%.', TRUE, NOW(), 0.00),
(4, NULL, 'Trá Xanh C2', 12000.00, 200, 1, 'Trà xanh C2 chai 455ml.', TRUE, NOW(), 0.00),
(4, NULL, 'Nước Tăng Lực Red Bull', 18000.00, 150, 2, 'Red Bull lon 250ml.', TRUE, NOW(), 0.00),
(4, NULL, 'Nước Tăng Lực Sting', 15000.00, 180, 2, 'Sting chai 330ml.', TRUE, NOW(), 0.00),
(4, NULL, 'Nước Ép Dứa', 25000.00, 70, 2, 'Nước dứa ép tươi, không đường.', TRUE, NOW(), 0.00),
(4, NULL, '7Up', 15000.00, 200, 2, '7Up lon 330ml.', TRUE, NOW(), 0.00),
(4, NULL, 'Nước Chanh Muối', 20000.00, 100, 2, 'Nước chanh muối tươi mát.', TRUE, NOW(), 0.00),

-- Món category_id 5: Cà Phê/Trà (Cả 2 quầy đều có)
(5, NULL, 'Cà Phê Đen Nóng', 15000.00, 150, 1, 'Cà phê đen truyền thống, đậm vị.', TRUE, NOW(), 0.00),
(5, NULL, 'Cà Phê Sữa Nóng', 18000.00, 150, 1, 'Cà phê sữa đá hoặc nóng.', TRUE, NOW(), 0.00),
(5, NULL, 'Cà Phê Sữa Đá', 20000.00, 180, 1, 'Cà phê sữa đá mát lạnh.', TRUE, NOW(), 0.00),
(5, NULL, 'Trà Đào Cam Sả', 25000.00, 100, 1, 'Trá đào cam sả thơm ngon, giải nhiệt.', TRUE, NOW(), 0.00),
(5, NULL, 'Trà Sữa Trân Châu', 30000.00, 120, 1, 'Trà sữa trân châu đường đen.', TRUE, NOW(), 0.00),
(5, NULL, 'Cà Phê Đen Đá', 18000.00, 150, 2, 'Cà phê đen đá truyền thống.', TRUE, NOW(), 0.00),
(5, NULL, 'Bạc Xỉu Đá', 22000.00, 130, 2, 'Bạc xỉu đá thơm béo.', TRUE, NOW(), 0.00),
(5, NULL, 'Trà Chanh', 15000.00, 120, 2, 'Trà chanh tươi mát lạnh.', TRUE, NOW(), 0.00),
(5, NULL, 'Trà Sữa Thái', 28000.00, 100, 2, 'Trà sữa Thái đậm vị, ngọt ngào.', TRUE, NOW(), 0.00),
(5, NULL, 'Sữa Tươi Trân Châu Đường Đen', 32000.00, 90, 2, 'Sữa tươi trân châu đường đen thơm béo.', TRUE, NOW(), 0.00);

-- -- ========================================
-- -- 5. ORDERS TABLE
-- -- ========================================
-- -- Đơn hàng từ khách hàng vuonglam (user_id = 4)
-- INSERT INTO orders (user_id, stall_id, total_price, status, created_at, delivery_location, payment_method) VALUES
-- (4, 1, 85000.00, 'delivered', '2024-11-01 11:30:00', 'Phòng A101', 'cash'),
-- (4, 2, 95000.00, 'delivered', '2024-11-02 12:15:00', 'Phòng A101', 'momo'),
-- (4, 1, 120000.00, 'delivered', '2024-11-05 11:45:00', 'Phòng A101', 'cash'),
-- (4, 2, 50000.00, 'in_delivery', '2024-11-10 12:00:00', 'Phòng A101', 'banking'),
-- (4, 1, 60000.00, 'confirmed', '2024-11-14 11:20:00', 'Phòng A101', 'cash'),

-- -- Đơn hàng từ khách hàng hoangthiloan (user_id = 5)
-- (5, 1, 75000.00, 'delivered', '2024-11-03 12:00:00', 'Phòng B205', 'cash'),
-- (5, 2, 105000.00, 'delivered', '2024-11-04 11:30:00', 'Phòng B205', 'momo'),
-- (5, 1, 95000.00, 'delivered', '2024-11-06 12:30:00', 'Phòng B205', 'banking'),
-- (5, 2, 85000.00, 'delivered', '2024-11-07 11:45:00', 'Phòng B205', 'cash'),
-- (5, 1, 110000.00, 'confirmed', '2024-11-12 12:10:00', 'Phòng B205', 'momo'),

-- -- Đơn hàng từ cả 2 khách
-- (4, 1, 130000.00, 'delivered', '2024-11-08 12:20:00', 'Phòng A101', 'banking'),
-- (5, 2, 70000.00, 'delivered', '2024-11-09 11:55:00', 'Phòng B205', 'cash'),
-- (4, 2, 115000.00, 'new_order', '2024-11-14 12:30:00', 'Phòng A101', 'momo'),
-- (5, 1, 88000.00, 'new_order', '2024-11-14 12:35:00', 'Phòng B205', 'cash');

-- -- ========================================
-- -- 6. ORDER_FOODS TABLE
-- -- ========================================
-- -- Chi tiết đơn hàng 1 (user_id=4, stall_id=1, total=85000)
-- INSERT INTO order_foods (order_id, food_id, quantity, price_at_order) VALUES
-- (1, 1, 1, 45000.00), -- Cơm Gà Xối Mỡ Đặc Biệt
-- (1, 2, 1, 40000.00), -- Cơm Sườn Bì Chả

-- -- Chi tiết đơn hàng 2 (user_id=4, stall_id=2, total=95000)
-- (2, 11, 1, 50000.00), -- Phở Bò Tái Nạm
-- (2, 12, 1, 45000.00), -- Bún Chả Hà Nội

-- -- Chi tiết đơn hàng 3 (user_id=4, stall_id=1, total=120000)
-- (3, 7, 2, 60000.00), -- Cơm Xào Bò Lúc Lắc x2

-- -- Chi tiết đơn hàng 4 (user_id=4, stall_id=2, total=50000)
-- (4, 14, 1, 50000.00), -- Bún Bò Huế Đặc Biệt

-- -- Chi tiết đơn hàng 5 (user_id=4, stall_id=1, total=60000)
-- (5, 1, 1, 45000.00), -- Cơm Gà Xối Mỡ Đặc Biệt
-- (5, 23, 1, 15000.00), -- Chè Đậu Đỏ

-- -- Chi tiết đơn hàng 6 (user_id=5, stall_id=1, total=75000)
-- (6, 3, 1, 35000.00), -- Cơm Thịt Kho Trứng
-- (6, 2, 1, 40000.00), -- Cơm Sườn Bì Chả

-- -- Chi tiết đơn hàng 7 (user_id=5, stall_id=2, total=105000)
-- (7, 13, 1, 55000.00), -- Mì Quảng Gà
-- (7, 11, 1, 50000.00), -- Phở Bò Tái Nạm

-- -- Chi tiết đơn hàng 8 (user_id=5, stall_id=1, total=95000)
-- (8, 4, 1, 55000.00), -- Cơm Canh Chua Cá Lóc
-- (8, 2, 1, 40000.00), -- Cơm Sườn Bì Chả

-- -- Chi tiết đơn hàng 9 (user_id=5, stall_id=2, total=85000)
-- (9, 12, 1, 45000.00), -- Bún Chả Hà Nội
-- (9, 17, 1, 40000.00), -- Bún Riêu Cua

-- -- Chi tiết đơn hàng 10 (user_id=5, stall_id=1, total=110000)
-- (10, 9, 2, 48000.00), -- Cơm Chiên Hải Sản x2
-- (10, 22, 1, 15000.00), -- Bánh Mì Thịt Nướng

-- -- Chi tiết đơn hàng 11 (user_id=4, stall_id=1, total=130000)
-- (11, 10, 2, 45000.00), -- Cơm Thập Cẩm x2
-- (11, 2, 1, 40000.00), -- Cơm Sườn Bì Chả

-- -- Chi tiết đơn hàng 12 (user_id=5, stall_id=2, total=70000)
-- (12, 20, 2, 35000.00), -- Phở Chay Rau Củ x2

-- -- Chi tiết đơn hàng 13 (user_id=4, stall_id=2, total=115000)
-- (13, 19, 2, 58000.00), -- Bánh Canh Cua x2

-- -- Chi tiết đơn hàng 14 (user_id=5, stall_id=1, total=88000)
-- (14, 8, 2, 42000.00), -- Cơm Kho Quẹt Tôm Thịt x2
-- (14, 24, 2, 10000.00); -- Kem Que Các Loại x2

-- -- ========================================
-- -- 7. STATISTICS TABLE (Optional)
-- -- ========================================
-- -- Thống kê doanh thu và số lượng bán cho một số ngày
-- INSERT INTO statistics (stat_date, stall_id, food_id, orders_count, revenue, quantity_sold) VALUES
-- -- Ngày 2024-11-01 - Quầy 1
-- ('2024-11-01', 1, 1, 5, 225000.00, 5),
-- ('2024-11-01', 1, 2, 8, 320000.00, 8),
-- ('2024-11-01', 1, 3, 4, 140000.00, 4),

-- -- Ngày 2024-11-01 - Quầy 2
-- ('2024-11-01', 2, 11, 6, 300000.00, 6),
-- ('2024-11-01', 2, 12, 7, 315000.00, 7),

-- -- Ngày 2024-11-02 - Quầy 1
-- ('2024-11-02', 1, 1, 6, 270000.00, 6),
-- ('2024-11-02', 1, 4, 3, 165000.00, 3),
-- ('2024-11-02', 1, 7, 4, 240000.00, 4),

-- -- Ngày 2024-11-02 - Quầy 2
-- ('2024-11-02', 2, 14, 5, 250000.00, 5),
-- ('2024-11-02', 2, 17, 6, 240000.00, 6),

-- -- Ngày 2024-11-03 - Quầy 1
-- ('2024-11-03', 1, 2, 10, 400000.00, 10),
-- ('2024-11-03', 1, 9, 5, 240000.00, 5),

-- -- Ngày 2024-11-03 - Quầy 2
-- ('2024-11-03', 2, 11, 8, 400000.00, 8),
-- ('2024-11-03', 2, 13, 4, 220000.00, 4),

-- -- Ngày 2024-11-04 - Quầy 1
-- ('2024-11-04', 1, 1, 7, 315000.00, 7),
-- ('2024-11-04', 1, 10, 5, 225000.00, 5),

-- -- Ngày 2024-11-04 - Quầy 2
-- ('2024-11-04', 2, 12, 9, 405000.00, 9),
-- ('2024-11-04', 2, 14, 6, 300000.00, 6),

-- -- Ngày 2024-11-05 - Quầy 1
-- ('2024-11-05', 1, 7, 8, 480000.00, 8),
-- ('2024-11-05', 1, 8, 6, 252000.00, 6),

-- -- Ngày 2024-11-05 - Quầy 2
-- ('2024-11-05', 2, 11, 10, 500000.00, 10),
-- ('2024-11-05', 2, 19, 3, 174000.00, 3);

-- -- ========================================
-- -- KẾT THÚC INSERT DATA
-- -- ========================================
-- -- Tóm tắt dữ liệu đã insert:
-- -- - 6 users (1 admin, 2 stall staff, 3 customers)
-- -- - 2 stalls (Quầy Cơm và Quầy Phở Bún)
-- -- - 5 food categories
-- -- - 50 foods (10 Cơm, 10 Phở/Bún/Mì, 10 Đồ Ăn Vặt, 10 Đồ Uống, 10 Cà Phê/Trà)
-- -- - 14 orders (với nhiều trạng thái khác nhau)
-- -- - 26 order_foods items
-- -- - 22 statistics records

-- SELECT 'Data insertion completed successfully!' AS message;
