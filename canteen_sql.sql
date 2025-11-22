CREATE DATABASE  IF NOT EXISTS `canteen_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `canteen_db`;
-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: canteen_db
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `food_categories`
--

DROP TABLE IF EXISTS `food_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_categories` (
                                   `id` int NOT NULL AUTO_INCREMENT,
                                   `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
                                   `description` text COLLATE utf8mb4_unicode_ci,
                                   `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                                   `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                   PRIMARY KEY (`id`),
                                   UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `food_categories`
--

LOCK TABLES `food_categories` WRITE;
/*!40000 ALTER TABLE `food_categories` DISABLE KEYS */;
INSERT INTO `food_categories` VALUES (1,'Cơm','Các món cơm phục vụ bữa trưa và bữa tối.','2025-11-04 15:21:10','2025-11-04 15:21:10'),(2,'Phở/Bún/Mì','Các món nước truyền thống của Việt Nam.','2025-11-04 15:21:10','2025-11-04 15:21:10'),(3,'Đồ Ăn Vặt/Tráng Miệng','Các món ăn nhẹ, kem, chè.','2025-11-04 15:21:10','2025-11-04 15:21:10'),(4,'Đồ Uống Giải Khát','Nước ngọt có gas, nước đóng chai.','2025-11-04 15:21:10','2025-11-04 15:21:10'),(5,'Cà Phê/Trà','Các loại cà phê, trà nóng và lạnh.','2025-11-04 15:21:10','2025-11-04 15:21:10');
/*!40000 ALTER TABLE `food_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `foods`
--

DROP TABLE IF EXISTS `foods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `foods` (
                         `id` int NOT NULL AUTO_INCREMENT,
                         `category_id` int DEFAULT NULL,
                         `image` blob,
                         `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
                         `price` double NOT NULL DEFAULT '0',
                         `inventory` int NOT NULL DEFAULT '0',
                         `stall_id` int NOT NULL,
                         `description` text COLLATE utf8mb4_unicode_ci,
                         `is_available` tinyint(1) DEFAULT '1',
                         `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                         `promotion` decimal(5,2) DEFAULT '0.00' COMMENT 'Phần trăm giảm giá (0.00 đến 99.99)',
                         PRIMARY KEY (`id`),
                         KEY `category_id` (`category_id`),
                         KEY `idx_foods_stall_available` (`stall_id`,`is_available`),
                         CONSTRAINT `foods_ibfk_1` FOREIGN KEY (`stall_id`) REFERENCES `stalls` (`id`),
                         CONSTRAINT `foods_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `food_categories` (`id`),
                         CONSTRAINT `foods_chk_1` CHECK ((`price` >= 0)),
                         CONSTRAINT `foods_chk_2` CHECK ((`inventory` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=316 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `foods`
--

LOCK TABLES `foods` WRITE;
/*!40000 ALTER TABLE `foods` DISABLE KEYS */;
INSERT INTO foods (category_id, image, name, price, inventory, stall_id, description, is_available, updated_at, promotion) VALUES
                                                                                                                               (1, NULL, 'Cơm Tấm Sườn Bì', 35000, 50, 1, 'Cơm tấm sườn bì chả trứng ốp la', 1, NOW(), 0),
                                                                                                                               (1, NULL, 'Phở Bò Tái', 45000, 40, 1, 'Phở bò tái lăn nước dùng đậm đà', 1, NOW(), 0),
                                                                                                                               (2, NULL, 'Bún Bò Huế', 40000, 35, 1, 'Bún bò chuẩn vị Huế có giò heo', 1, NOW(), 5),
                                                                                                                               (1, NULL, 'Cơm Gà Xối Mỡ', 32000, 60, 2, 'Đùi gà góc tư chiên giòn', 1, NOW(), 0),
                                                                                                                               (3, NULL, 'Mì Quảng Gà', 30000, 45, 2, 'Mì quảng gà ta, bánh đa giòn', 1, NOW(), 0),
                                                                                                                               (2, NULL, 'Hủ Tiếu Nam Vang', 38000, 50, 1, 'Hủ tiếu tôm thịt gan cật', 1, NOW(), 0),
                                                                                                                               (4, NULL, 'Trà Sữa Trân Châu', 25000, 100, 3, 'Trà sữa thái xanh trân châu đường đen', 1, NOW(), 10),
                                                                                                                               (4, NULL, 'Cà Phê Sữa Đá', 15000, 100, 3, 'Cà phê phin đậm đặc', 1, NOW(), 0),
                                                                                                                               (5, NULL, 'Bánh Mì Thịt Nướng', 20000, 80, 4, 'Bánh mì thịt nướng than hoa', 1, NOW(), 0),
                                                                                                                               (5, NULL, 'Xôi Mặn Thập Cẩm', 15000, 70, 4, 'Xôi nếp dẻo topping lạp xưởng chà bông', 1, NOW(), 0),
                                                                                                                               (1, NULL, 'Cơm Rang Dưa Bò', 40000, 30, 2, 'Cơm rang giòn hạt, bò mềm', 1, NOW(), 0),
                                                                                                                               (3, NULL, 'Mì Ý Sốt Bò Băm', 35000, 40, 5, 'Spaghetti sốt cà chua bò băm', 1, NOW(), 0),
                                                                                                                               (4, NULL, 'Nước Ép Cam', 25000, 50, 3, 'Cam vắt nguyên chất không đường', 1, NOW(), 0),
                                                                                                                               (4, NULL, 'Sinh Tố Bơ', 30000, 40, 3, 'Bơ sáp béo ngậy, ít sữa', 1, NOW(), 5),
                                                                                                                               (5, NULL, 'Bánh Tráng Trộn', 15000, 90, 4, 'Bánh tráng trộn full topping', 1, NOW(), 0),
                                                                                                                               (2, NULL, 'Bún Chả Hà Nội', 45000, 30, 1, 'Bún chả kẹp tre nướng than', 1, NOW(), 0),
                                                                                                                               (1, NULL, 'Cơm Cá Kho Tộ', 35000, 25, 2, 'Cơm trắng cá lóc kho tộ', 1, NOW(), 0),
                                                                                                                               (3, NULL, 'Bún Đậu Mắm Tôm', 55000, 40, 1, 'Mẹt tá lả chả cốm thịt luộc', 1, NOW(), 15),
                                                                                                                               (5, NULL, 'Gỏi Cuốn Tôm Thịt', 10000, 150, 4, 'Gỏi cuốn tôm thịt chấm mắm nêm', 1, NOW(), 0),
                                                                                                                               (4, NULL, 'Trà Đào Cam Sả', 28000, 60, 3, 'Trà đào miếng lớn, thanh mát', 1, NOW(), 10),
                                                                                                                               (2, NULL, 'Miến Gà', 30000, 40, 2, 'Miến dong gà ta xé phay', 1, NOW(), 0),
                                                                                                                               (3, NULL, 'Mì Cay 7 Cấp Độ', 45000, 50, 5, 'Mì cay hải sản cấp độ 1', 1, NOW(), 0),
                                                                                                                               (1, NULL, 'Cơm Văn Phòng (Set)', 40000, 60, 2, 'Set cơm trưa đổi món theo ngày', 1, NOW(), 0),
                                                                                                                               (4, NULL, 'Sữa Chua Trân Châu', 20000, 80, 3, 'Sữa chua Hạ Long cốt dừa', 1, NOW(), 5),
                                                                                                                               (5, NULL, 'Bánh Bao Trứng Muối', 18000, 50, 4, 'Bánh bao nhân thịt 2 trứng cút 1 muối', 1, NOW(), 0),
                                                                                                                               (2, NULL, 'Bánh Canh Cua', 50000, 30, 1, 'Bánh canh bột lọc cua nguyên con', 0, NOW(), 0), -- Món này hết hàng (is_available = 0)
                                                                                                                               (3, NULL, 'Nui Xào Bò', 32000, 40, 5, 'Nui xào bò lúc lắc', 1, NOW(), 0),
                                                                                                                               (4, NULL, 'Nước Suối Lavie', 8000, 200, 3, 'Chai 500ml', 1, NOW(), 0),
                                                                                                                               (1, NULL, 'Cháo Lòng', 25000, 40, 2, 'Cháo lòng dồi sả ớt', 1, NOW(), 0),
                                                                                                                               (5, NULL, 'Khoai Tây Chiên', 20000, 100, 5, 'Khoai tây chiên lắc phô mai', 1, NOW(), 10);
/*!40000 ALTER TABLE `foods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_foods`
--

DROP TABLE IF EXISTS `order_foods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_foods` (
                               `id` int NOT NULL AUTO_INCREMENT,
                               `order_id` int NOT NULL,
                               `food_id` int NOT NULL,
                               `quantity` int NOT NULL DEFAULT '1',
                               `price_at_order` double NOT NULL DEFAULT '0',
                               PRIMARY KEY (`id`),
                               KEY `order_id` (`order_id`),
                               KEY `food_id` (`food_id`),
                               CONSTRAINT `order_foods_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
                               CONSTRAINT `order_foods_ibfk_2` FOREIGN KEY (`food_id`) REFERENCES `foods` (`id`),
                               CONSTRAINT `order_foods_chk_1` CHECK ((`quantity` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_foods`
--

LOCK TABLES `order_foods` WRITE;
/*!40000 ALTER TABLE `order_foods` DISABLE KEYS */;
INSERT INTO `order_foods` VALUES (1,1,230,1,28000),(2,2,230,1,28000),(3,3,230,1,28000),(4,4,210,1,28000),(5,5,230,1,28000),(6,6,309,1,58000),(7,7,309,1,58000),(8,8,309,1,58000),(9,9,309,1,58000),(10,10,230,1,28000),(11,11,290,2,35000),(12,12,309,1,58000),(13,12,230,1,28000),(14,12,286,1,45000),(15,13,230,1,28000),(16,14,210,1,28000),(17,15,314,4,40000),(18,16,314,6,40000);
/*!40000 ALTER TABLE `order_foods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
                          `id` int NOT NULL AUTO_INCREMENT,
                          `user_id` int NOT NULL,
                          `stall_id` int NOT NULL,
                          `total_price` double NOT NULL DEFAULT '0',
                          `status` enum('new_order','confirmed','in_delivery','delivered') COLLATE utf8mb4_unicode_ci DEFAULT 'new_order',
                          `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                          `delivery_location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                          `payment_method` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                          PRIMARY KEY (`id`),
                          KEY `idx_orders_user_status` (`user_id`,`status`),
                          KEY `idx_orders_stall_date` (`stall_id`,`created_at`),
                          CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
                          CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`stall_id`) REFERENCES `stalls` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,1,2,28000,'new_order','2025-11-15 05:50:09','37 Tôn Đức Thắng','COD'),(2,1,2,28000,'new_order','2025-11-15 06:04:08','37 Tôn Đức Thắng','COD'),(3,1,2,28000,'new_order','2025-11-15 06:39:36','37 Tôn Đức Thắng','COD'),(4,1,1,28000,'confirmed','2025-11-15 09:38:44','37 Tôn Đức Thắng','COD'),(5,1,2,28000,'new_order','2025-11-15 06:54:57','37 Tôn Đức Thắng','COD'),(6,1,5,58000,'new_order','2025-11-15 06:57:33','37 Tôn Đức Thắng','COD'),(7,1,5,58000,'new_order','2025-11-15 07:04:10','37 Tôn Đức Thắng','COD'),(8,1,5,58000,'confirmed','2025-11-15 09:38:14','37 Tôn Đức Thắng','COD'),(9,1,5,58000,'new_order','2025-11-15 07:25:36','37 Tôn Đức Thắng','COD'),(10,1,2,28000,'new_order','2025-11-15 07:30:11','37 Tôn Đức Thắng','COD'),(11,1,1,70000,'delivered','2025-11-15 09:41:17','37 Tôn Đức Thắng','COD'),(12,1,5,131000,'in_delivery','2025-11-15 09:38:08','37 Tôn Đức Thắng','COD'),(13,4,2,28000,'new_order','2025-11-15 09:30:13','37 Tôn Đức Thắng','COD'),(14,2,1,28000,'confirmed','2025-11-19 16:23:08','37 Tôn Đức Thắng','Banking'),(15,4,1,160000,'delivered','2025-11-19 12:51:16','37 Tôn Đức Thắng','Banking'),(16,4,1,240000,'confirmed','2025-11-19 16:23:01','37 Tôn Đức Thắng','Banking');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `persistent_logins`
--

DROP TABLE IF EXISTS `persistent_logins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `persistent_logins` (
                                     `username` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
                                     `series` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
                                     `token_hash` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
                                     `expires` timestamp NOT NULL,
                                     PRIMARY KEY (`series`),
                                     KEY `username` (`username`),
                                     CONSTRAINT `persistent_logins_ibfk_1` FOREIGN KEY (`username`) REFERENCES `users` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `persistent_logins`
--

LOCK TABLES `persistent_logins` WRITE;
/*!40000 ALTER TABLE `persistent_logins` DISABLE KEYS */;
INSERT INTO `persistent_logins` VALUES ('admin','09c39cf6-07f5-4735-9f35-e52cf62940e1','a2e6ef3fdc1d853e6a8ec951985bf1cf3dc4acd26c5af888cafc0ac2abb49c32','2025-12-08 18:01:40'),('admin','0f5faa7b-7827-483d-a427-4b464984b69e','270a604d7b27d6a1272287f0a1edd322e6768f9c167a5c659e4fda5569241ca7','2025-12-08 06:42:44'),('admin','1572aac0-1f92-45e5-9071-ccf29d5187bc','e3fca015a0c9d891c445811de113afc81c2e30bc1b172125ee42d73f3cb8f23e','2025-12-14 23:50:13'),('admin','21103ad1-5b1f-4b2e-9725-0ea4430a4646','838df1f6e2fbcf5f4da880f5bc6d58aedb6e4630738f484e6188aa212389a0a8','2025-12-14 23:57:21'),('admin','2b06e033-3601-4567-8055-5c65b8c582bd','429565664d57e98b77622ba8df39a41e1226aeb5d7bc38fca8b33cc6924d5f4f','2025-12-14 23:39:22'),('thietru','3e16a4d6-2622-4a97-b4b9-f5966810ff24','8d9fdb9c772e0166ac14a8ba16e55b8f8835bb8f673bf50d78422408c0d9e465','2025-12-08 05:04:21'),('admin','5bf0758f-9483-4700-a3cf-ee4ce0af313f','8a01d6725b72e60983d963bd0f62c6a7c4a0a0d063bf2efb9a2058d916debde8','2025-12-14 23:38:47'),('admin','5d2a4d39-117c-4283-8749-3b3100d6b8a0','7f9b9da0291030995cb459e654e8d80fb66fe3cb4547a9bcbfa90979b59d95a6','2025-12-14 23:32:20'),('admin','6e99ee29-88f0-4d53-9fde-30f71f64d9da','503d3002bc23d28c56f49ac6b96ec0d6d7e60248ba3742334a76c5fc0c2c2a9f','2025-12-14 22:28:33'),('admin','6fa3d17d-4672-419a-8928-5b704ce71a93','8b7b0762f6951cf27608a4980f4fcee1c1afb2b6d3c3775b9944472ad2394d77','2025-12-14 23:13:05'),('admin','73c51c7f-3398-4468-aae1-771fbdb4ed54','fe613a63a8fd262fd93ae20b9919ba52a66e011380dd5f4c3d9da95208fa9659','2025-12-08 04:51:46'),('admin','84190db2-52e2-4760-ba48-9bb263bc9430','0069cd8257805a54347fca91fb6f215fcdd28ea0ad6a2d6c0a707efd230c3440','2025-12-14 23:53:14'),('admin','87248bf8-1b71-4416-a75d-7f6bd916bba2','f3fa292f97a6addd10874b75df0850f7186ac8f03232039b086d14e3d3e740ec','2025-12-14 22:06:43'),('admin','9398b366-5fc3-46f8-b3c5-05bb6c7f3fed','4c3f5b2ee4a6279dcfcd470c1bafb05cdabbb890782dc6c7885fc955eeaf8bd3','2025-12-14 23:05:26'),('admin','943df243-4018-4d08-a46d-8a79403fcf54','b60f90c0f4b05aae100c5f4f6cf08163b6ba3f5a8bf104469bafe70793d7ff34','2025-12-14 23:04:57'),('admin','a15bfe2a-dc8e-41e6-aeb6-8363abf4f50e','a3318ebc86c6a887b1d4b3b7c2f5f12bc311d9b82c0c46fbf07fb1a86cab84c0','2025-12-08 04:27:18'),('admin','cae73d78-83d7-4dff-8f71-7144c577a297','19017b2eb5e0a94659f680a0c62acef9987d58536377d4497ca2fe8bbf81ea6f','2025-12-08 04:46:23'),('admin','d0439eb5-d0bb-48b2-8c77-8a42724bdb62','fae633556036e739022df0be118ef2d37e6a06ab9cf0138d8a3ff012f5c6fcc3','2025-12-08 06:38:25'),('admin','dbdf0c09-5c66-4f79-8750-04583e96242c','b7009d79660aebd84d11fb42dabfc6a324a10e188769435ad895f6195289a3f1','2025-12-15 00:03:59'),('admin','eea76fc1-7064-454d-bd3e-4c442ac8e006','0aa30dd69a80d3942886e3e394e027e8b561d0e7b5f2474fc48b6347ef3ff356','2025-12-14 13:34:51'),('admin','f62bf6d3-7a7b-4212-93e4-732aa26d54c6','09b39eb81761898f7c859a27d07c82d1ca9e2abb3136f4b2431bc0230cee94b2','2025-12-14 23:11:09');
/*!40000 ALTER TABLE `persistent_logins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stalls`
--

DROP TABLE IF EXISTS `stalls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stalls` (
                          `id` int NOT NULL AUTO_INCREMENT,
                          `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
                          `description` text COLLATE utf8mb4_unicode_ci,
                          `manager_user_id` int NOT NULL,
                          `is_open` tinyint(1) DEFAULT '1',
                          PRIMARY KEY (`id`),
                          UNIQUE KEY `manager_user_id` (`manager_user_id`),
                          CONSTRAINT `stalls_ibfk_1` FOREIGN KEY (`manager_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stalls`
--

LOCK TABLES `stalls` WRITE;
/*!40000 ALTER TABLE `stalls` DISABLE KEYS */;
INSERT INTO `stalls` VALUES (1,'Quầy Cơm Gia Đình','Phục vụ các món cơm Việt Nam truyền thống, canh theo ngày.',2,1),(2,'Phở & Bún Ba Miền','Đặc sản phở bò, bún bò Huế, mì Quảng và các món nước khác.',3,1),(3,'Cà Phê & Trà Sữa Tươi','Chuyên cà phê pha máy, trà trái cây và trà sữa.',1,1),(4,'Ăn Vặt Xì Trum','Các món ăn vặt được yêu thích như kem, chè, bánh tráng trộn.',4,1),(5,'Fast Food & Pasta','Phục vụ burger, khoai tây chiên, và các loại pasta.',5,1),(6,'Sinh Tố Trái Cây Tươi','Chuyên các loại nước ép, sinh tố tươi và detox.',6,1);
/*!40000 ALTER TABLE `stalls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `statistics`
--

DROP TABLE IF EXISTS `statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `statistics` (
                              `id` int NOT NULL AUTO_INCREMENT,
                              `stat_date` date NOT NULL,
                              `stall_id` int DEFAULT NULL,
                              `food_id` int DEFAULT NULL,
                              `orders_count` int DEFAULT '0',
                              `revenue` double DEFAULT '0',
                              `quantity_sold` int DEFAULT '0',
                              PRIMARY KEY (`id`),
                              UNIQUE KEY `stat_date` (`stat_date`,`stall_id`,`food_id`),
                              KEY `stall_id` (`stall_id`),
                              KEY `food_id` (`food_id`),
                              CONSTRAINT `statistics_ibfk_1` FOREIGN KEY (`stall_id`) REFERENCES `stalls` (`id`),
                              CONSTRAINT `statistics_ibfk_2` FOREIGN KEY (`food_id`) REFERENCES `foods` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `statistics`
--

LOCK TABLES `statistics` WRITE;
/*!40000 ALTER TABLE `statistics` DISABLE KEYS */;
/*!40000 ALTER TABLE `statistics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
                         `id` int NOT NULL AUTO_INCREMENT,
                         `photo` blob,
                         `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
                         `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
                         `full_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
                         `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                         `phone_number` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                         `role` enum('admin','stall','customer') COLLATE utf8mb4_unicode_ci DEFAULT 'customer',
                         `status` tinyint(1) DEFAULT NULL,
                         `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                         PRIMARY KEY (`id`),
                         UNIQUE KEY `username` (`username`),
                         UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,NULL,'admin','e10adc3949ba59abbe56e057f20f883e','Admin','admin@hcm.edu.vn','0901112222','admin',1,'2025-11-04 13:00:31'),(2,_binary 'uploads/avatars/avatar-de-thuong-33_20251117_224113_347_1.jpg','thietru','25d55ad283aa400af464c76d713c07ad','Thiết Trụ','thiettru@hcm.edu.vn','0903334444','stall',1,'2025-11-04 13:00:31'),(3,NULL,'lymouyen','e10adc3949ba59abbe56e057f20f883e','Lý Mộ Uyển','lymouyen@hcm.edu.vn','0905556666','stall',1,'2025-11-04 13:00:31'),(4,_binary 'uploads/avatars/avatar-cute-72_20251117_222522_606_1.png','vuonglam','e10adc3949ba59abbe56e057f20f883e','Thức','thuc@hcm.edu.vn','0907778888','customer',1,'2025-11-04 13:00:31'),(5,NULL,'hoangthilang','e10adc3949ba59abbe56e057f20f883e','Hoàng Thị Loan','hoangthiloan@hcm.edu.vn','0909990000','customer',1,'2025-11-04 13:00:31'),(6,NULL,'nguyenvannam','e10adc3949ba59abbe56e057f20f883e','Nguyễn Văn Nam','nguyenvannam@hcm.edu.vn','0911112222','customer',0,'2025-11-04 13:00:31'),(9,NULL,'nguyenvannam1','e10adc3949ba59abbe56e057f20f883e','Nguyễn Văn Minh','nguyenvannam@mail.com','0982109103','customer',1,'2025-11-19 13:09:32');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-20 18:33:45