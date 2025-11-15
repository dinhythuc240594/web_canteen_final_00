# TESTCASE - Hệ Thống Quản Lý Canteen

## Mục lục
1. [Test CRUD Operations](#1-test-crud-operations)
   - [1.1. Test CRUD Món ăn (Food)](#11-test-crud-món-ăn-food)
   - [1.2. Test CRUD Người dùng (User)](#12-test-crud-người-dùng-user)
   - [1.3. Test CRUD Quầy hàng (Stall)](#13-test-crud-quầy-hàng-stall)
   - [1.4. Test CRUD Đơn hàng (Order)](#14-test-crud-đơn-hàng-order)
   - [1.5. Test CRUD Danh mục (Category)](#15-test-crud-danh-mục-category)
2. [Test Chức năng Người dùng](#2-test-chức-năng-người-dùng)
   - [2.1. Đăng nhập/Đăng xuất](#21-đăng-nhậpđăng-xuất)
   - [2.2. Xem danh sách món ăn](#22-xem-danh-sách-món-ăn)
   - [2.3. Quản lý giỏ hàng](#23-quản-lý-giỏ-hàng)
   - [2.4. Đặt hàng](#24-đặt-hàng)
   - [2.5. Xem lịch sử đơn hàng](#25-xem-lịch-sử-đơn-hàng)
   - [2.6. Quản lý quầy (Stall Owner)](#26-quản-lý-quầy-stall-owner)
   - [2.7. Quản lý Admin](#27-quản-lý-admin)

---

## 1. Test CRUD Operations

### 1.1. Test CRUD Món ăn (Food)

#### TC_FOOD_001: Tạo món ăn mới (Create)
**Mô tả:** Test tạo món ăn mới thành công

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- User đã có quầy hàng được gán

**Các bước thực hiện:**
1. Truy cập `/foods?action=create`
2. Điền form với thông tin:
   - Tên món: "Phở Bò"
   - Giá: 50000
   - Tồn kho: 100
   - Danh mục: Chọn một danh mục
3. Click nút "Lưu"

**Kết quả mong đợi:**
- Món ăn được tạo thành công
- Redirect về `/foods?action=list`
- Món ăn mới xuất hiện trong danh sách

---

#### TC_FOOD_002: Tạo món ăn - Không có quyền
**Mô tả:** Test tạo món ăn khi không phải stall owner

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "customer" hoặc "admin"

**Các bước thực hiện:**
1. Truy cập `/foods?action=create`

**Kết quả mong đợi:**
- Redirect về `/home`
- Không thể truy cập trang tạo món ăn

---

#### TC_FOOD_003: Tạo món ăn - Chưa đăng nhập
**Mô tả:** Test tạo món ăn khi chưa đăng nhập

**Điều kiện tiên quyết:**
- Chưa đăng nhập

**Các bước thực hiện:**
1. Truy cập `/foods?action=create`

**Kết quả mong đợi:**
- Redirect về `/login`

---

#### TC_FOOD_004: Xem danh sách món ăn (Read - List)
**Mô tả:** Test xem danh sách món ăn

**Các bước thực hiện:**
1. Truy cập `/foods?action=list`

**Kết quả mong đợi:**
- Hiển thị danh sách món ăn
- Có phân trang nếu có nhiều món ăn
- Có thể tìm kiếm theo tên hoặc giá

---

#### TC_FOOD_005: Xem chi tiết món ăn (Read - Detail)
**Mô tả:** Test xem chi tiết một món ăn

**Các bước thực hiện:**
1. Truy cập `/foods?id=1&action=detail`

**Kết quả mong đợi:**
- Hiển thị đầy đủ thông tin món ăn:
  - Tên món
  - Giá
  - Tồn kho
  - Hình ảnh
  - Danh mục
  - Quầy hàng

---

#### TC_FOOD_006: Cập nhật món ăn (Update)
**Mô tả:** Test cập nhật thông tin món ăn

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- Món ăn thuộc về quầy của user

**Các bước thực hiện:**
1. Truy cập `/foods?id=1&action=update`
2. Sửa thông tin:
   - Giá: 55000
   - Tồn kho: 80
3. Click nút "Cập nhật"

**Kết quả mong đợi:**
- Món ăn được cập nhật thành công
- Redirect về `/foods?action=list`
- Thông tin mới được hiển thị

---

#### TC_FOOD_007: Cập nhật món ăn - Không phải chủ quầy
**Mô tả:** Test cập nhật món ăn không thuộc quầy của user

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- Món ăn thuộc về quầy khác

**Các bước thực hiện:**
1. Truy cập `/foods?id=X&action=update` (X là ID món ăn của quầy khác)

**Kết quả mong đợi:**
- Trả về lỗi 403 Forbidden
- Thông báo: "Bạn không có quyền chỉnh sửa hoặc xóa món này"

---

#### TC_FOOD_008: Xóa món ăn (Delete)
**Mô tả:** Test xóa món ăn

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- Món ăn thuộc về quầy của user

**Các bước thực hiện:**
1. Truy cập `/foods?id=1&action=delete`
2. Xác nhận xóa

**Kết quả mong đợi:**
- Món ăn được xóa thành công
- Redirect về `/foods?action=list`
- Món ăn không còn trong danh sách

---

#### TC_FOOD_009: Xóa món ăn - Không phải chủ quầy
**Mô tả:** Test xóa món ăn không thuộc quầy của user

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- Món ăn thuộc về quầy khác

**Các bước thực hiện:**
1. Truy cập `/foods?id=X&action=delete` (X là ID món ăn của quầy khác)

**Kết quả mong đợi:**
- Trả về lỗi 403 Forbidden
- Thông báo: "Bạn không có quyền chỉnh sửa hoặc xóa món này"

---

#### TC_FOOD_010: Ẩn nút tạo món khi xem quầy khác
**Mô tả:** Test ẩn nút "Tạo món ăn" khi xem quầy không phải của user

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- User có quầy với ID = 1
- Có quầy khác với ID = 2

**Các bước thực hiện:**
1. Truy cập `/foods?action=list&stallId=2`

**Kết quả mong đợi:**
- Nút "Thêm món ăn mới" không hiển thị
- Chỉ hiển thị danh sách món ăn của quầy ID = 2

---

#### TC_FOOD_011: Hiển thị nút tạo món khi xem quầy của mình
**Mô tả:** Test hiển thị nút "Tạo món ăn" khi xem quầy của chính user

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- User có quầy với ID = 1

**Các bước thực hiện:**
1. Truy cập `/foods?action=list&stallId=1`

**Kết quả mong đợi:**
- Nút "Thêm món ăn mới" hiển thị
- Có thể click để tạo món ăn mới

---

### 1.2. Test CRUD Người dùng (User)

#### TC_USER_001: Tạo người dùng mới (Create) - Admin
**Mô tả:** Test admin tạo người dùng mới

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin?action=users`
2. Click nút "Tạo người dùng mới"
3. Điền form:
   - Username: "testuser"
   - Full Name: "Test User"
   - Email: "test@example.com"
   - Phone: "0123456789"
   - Role: "customer"
4. Click "Lưu"

**Kết quả mong đợi:**
- Người dùng được tạo thành công
- Mật khẩu mặc định: "123456"
- Người dùng mới xuất hiện trong danh sách

---

#### TC_USER_002: Tạo người dùng - Không phải Admin
**Mô tả:** Test tạo người dùng khi không phải admin

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "customer" hoặc "stall"

**Các bước thực hiện:**
1. Truy cập `/admin?action=createUser`

**Kết quả mong đợi:**
- Redirect về `/home`
- Không thể tạo người dùng

---

#### TC_USER_003: Xem danh sách người dùng (Read - List)
**Mô tả:** Test xem danh sách người dùng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin?action=users`

**Kết quả mong đợi:**
- Hiển thị danh sách tất cả người dùng
- Có thể lọc theo role
- Hiển thị thông tin: username, email, role, status

---

#### TC_USER_004: Cập nhật người dùng (Update)
**Mô tả:** Test cập nhật thông tin người dùng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin?action=users`
2. Click nút "Sửa" trên một người dùng
3. Sửa thông tin (ví dụ: Full Name)
4. Click "Cập nhật"

**Kết quả mong đợi:**
- Thông tin người dùng được cập nhật thành công
- Thông tin mới được hiển thị

---

#### TC_USER_005: Xóa người dùng (Delete)
**Mô tả:** Test xóa người dùng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin?action=users`
2. Click nút "Xóa" trên một người dùng
3. Xác nhận xóa

**Kết quả mong đợi:**
- Người dùng được xóa thành công
- Người dùng không còn trong danh sách

---

#### TC_USER_006: Khóa/Mở khóa người dùng (Toggle Status)
**Mô tả:** Test khóa/mở khóa tài khoản người dùng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin?action=users`
2. Click nút "Khóa" hoặc "Mở khóa" trên một người dùng

**Kết quả mong đợi:**
- Trạng thái người dùng được thay đổi
- Người dùng bị khóa không thể đăng nhập

---

### 1.3. Test CRUD Quầy hàng (Stall)

#### TC_STALL_001: Tạo quầy hàng mới (Create) - Admin
**Mô tả:** Test admin tạo quầy hàng mới

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin?action=stalls`
2. Click nút "Tạo quầy mới"
3. Điền form:
   - Tên quầy: "Quầy Cơm"
   - Mô tả: "Chuyên cơm trưa"
   - Manager User ID: Chọn một user có role = "stall"
4. Click "Lưu"

**Kết quả mong đợi:**
- Quầy hàng được tạo thành công
- Quầy mới xuất hiện trong danh sách

---

#### TC_STALL_002: Tạo quầy hàng - Stall Owner
**Mô tả:** Test stall owner tạo quầy hàng cho chính mình

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"

**Các bước thực hiện:**
1. Truy cập `/admin?action=createStall` (POST)
2. Gửi form với thông tin quầy

**Kết quả mong đợi:**
- Quầy hàng được tạo thành công
- Manager User ID tự động gán cho user hiện tại

---

#### TC_STALL_003: Xem danh sách quầy hàng (Read - List)
**Mô tả:** Test xem danh sách quầy hàng

**Các bước thực hiện:**
1. Truy cập `/store?action=list`

**Kết quả mong đợi:**
- Hiển thị danh sách tất cả quầy hàng
- Hiển thị thông tin: tên quầy, mô tả, trạng thái (mở/đóng)

---

#### TC_STALL_004: Xem chi tiết quầy hàng (Read - Detail)
**Mô tả:** Test xem chi tiết quầy hàng

**Các bước thực hiện:**
1. Truy cập `/store?action=detail&id=1`

**Kết quả mong đợi:**
- Hiển thị đầy đủ thông tin quầy hàng
- Hiển thị danh sách món ăn của quầy

---

#### TC_STALL_005: Cập nhật quầy hàng (Update)
**Mô tả:** Test cập nhật thông tin quầy hàng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin" hoặc "stall"
- Nếu là stall, phải là chủ quầy

**Các bước thực hiện:**
1. Truy cập `/admin?action=stalls`
2. Click nút "Sửa" trên một quầy
3. Sửa thông tin (ví dụ: mô tả)
4. Click "Cập nhật"

**Kết quả mong đợi:**
- Thông tin quầy được cập nhật thành công
- Thông tin mới được hiển thị

---

#### TC_STALL_006: Xóa quầy hàng (Delete)
**Mô tả:** Test xóa quầy hàng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin?action=stalls`
2. Click nút "Xóa" trên một quầy
3. Xác nhận xóa

**Kết quả mong đợi:**
- Quầy hàng được xóa thành công
- Quầy không còn trong danh sách

---

#### TC_STALL_007: Mở/Đóng quầy hàng (Toggle Status)
**Mô tả:** Test mở/đóng quầy hàng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- User là chủ quầy

**Các bước thực hiện:**
1. Truy cập `/stall`
2. Click nút "Mở cửa" hoặc "Đóng cửa"

**Kết quả mong đợi:**
- Trạng thái quầy được thay đổi
- Trạng thái mới được hiển thị

---

### 1.4. Test CRUD Đơn hàng (Order)

#### TC_ORDER_001: Tạo đơn hàng (Create) - Thông qua Checkout
**Mô tả:** Test tạo đơn hàng từ giỏ hàng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "customer"
- Đã có món ăn trong giỏ hàng

**Các bước thực hiện:**
1. Truy cập `/cart`
2. Điền địa chỉ giao hàng
3. Chọn phương thức thanh toán
4. Click "Đặt hàng"

**Kết quả mong đợi:**
- Đơn hàng được tạo thành công
- Redirect về trang thành công
- Giỏ hàng được xóa
- Trạng thái đơn hàng: "new_order"

---

#### TC_ORDER_002: Tạo đơn hàng - Giỏ hàng trống
**Mô tả:** Test tạo đơn hàng khi giỏ hàng trống

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "customer"
- Giỏ hàng trống

**Các bước thực hiện:**
1. Truy cập `/cart`
2. Click "Đặt hàng" (nếu nút hiển thị)

**Kết quả mong đợi:**
- Hiển thị trang lỗi
- Thông báo: "Giỏ hàng trống. Vui lòng thêm sản phẩm vào giỏ hàng trước khi đặt hàng."

---

#### TC_ORDER_003: Tạo đơn hàng - Chưa đăng nhập
**Mô tả:** Test tạo đơn hàng khi chưa đăng nhập

**Điều kiện tiên quyết:**
- Chưa đăng nhập
- Có món ăn trong giỏ hàng (localStorage)

**Các bước thực hiện:**
1. Truy cập `/cart`
2. Click "Đặt hàng"

**Kết quả mong đợi:**
- Redirect về `/login`
- Sau khi đăng nhập, redirect về `/cart`

---

#### TC_ORDER_004: Xem danh sách đơn hàng (Read - List) - Customer
**Mô tả:** Test customer xem danh sách đơn hàng của mình

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "customer"

**Các bước thực hiện:**
1. Truy cập `/order-history`

**Kết quả mong đợi:**
- Hiển thị danh sách đơn hàng của user
- Hiển thị thông tin: ID, tổng tiền, trạng thái, thời gian

---

#### TC_ORDER_005: Xem danh sách đơn hàng - Stall Owner
**Mô tả:** Test stall owner xem danh sách đơn hàng của quầy

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- User có quầy hàng

**Các bước thực hiện:**
1. Truy cập `/stall-orders`

**Kết quả mong đợi:**
- Hiển thị danh sách đơn hàng của quầy
- Có thể lọc theo trạng thái

---

#### TC_ORDER_006: Xem danh sách đơn hàng - Admin
**Mô tả:** Test admin xem tất cả đơn hàng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin?action=orders`

**Kết quả mong đợi:**
- Hiển thị danh sách tất cả đơn hàng
- Có thể xem đơn hàng của mọi quầy và mọi customer

---

#### TC_ORDER_007: Cập nhật trạng thái đơn hàng (Update Status)
**Mô tả:** Test cập nhật trạng thái đơn hàng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall" hoặc "admin"
- Có đơn hàng với trạng thái "new_order"

**Các bước thực hiện:**
1. Truy cập `/stall-orders` hoặc `/admin?action=orders`
2. Chọn đơn hàng
3. Click nút cập nhật trạng thái
4. Chọn trạng thái mới: "confirmed"

**Kết quả mong đợi:**
- Trạng thái đơn hàng được cập nhật thành công
- Trạng thái mới được hiển thị

---

#### TC_ORDER_008: Cập nhật trạng thái - Không có quyền
**Mô tả:** Test cập nhật trạng thái đơn hàng khi không có quyền

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "customer"

**Các bước thực hiện:**
1. Gửi POST request đến `/order?action=updateStatus`

**Kết quả mong đợi:**
- Trả về lỗi 403 Forbidden
- Thông báo: "You don't have permission to update order status"

---

#### TC_ORDER_009: Cập nhật trạng thái - Trạng thái không hợp lệ
**Mô tả:** Test cập nhật trạng thái với giá trị không hợp lệ

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"

**Các bước thực hiện:**
1. Gửi POST request đến `/order?action=updateStatus`
2. Gửi status = "invalid_status"

**Kết quả mong đợi:**
- Trả về lỗi 400 Bad Request
- Thông báo: "Invalid status value"

---

### 1.5. Test CRUD Danh mục (Category)

#### TC_CATEGORY_001: Xem danh sách danh mục (Read - List)
**Mô tả:** Test xem danh sách danh mục món ăn

**Các bước thực hiện:**
1. Truy cập `/category`

**Kết quả mong đợi:**
- Hiển thị danh sách tất cả danh mục
- Hiển thị món ăn trong mỗi danh mục

---

#### TC_CATEGORY_002: Xem món ăn theo danh mục
**Mô tả:** Test xem món ăn theo danh mục cụ thể

**Các bước thực hiện:**
1. Truy cập `/category?id=1`

**Kết quả mong đợi:**
- Hiển thị danh sách món ăn thuộc danh mục ID = 1

---

## 2. Test Chức năng Người dùng

### 2.1. Đăng nhập/Đăng xuất

#### TC_AUTH_001: Đăng nhập thành công - Customer
**Mô tả:** Test đăng nhập thành công với tài khoản customer

**Các bước thực hiện:**
1. Truy cập `/login`
2. Nhập username và password hợp lệ của customer
3. Click "Đăng nhập"

**Kết quả mong đợi:**
- Đăng nhập thành công
- Redirect về `/home`
- Session có các attribute: `is_login=true`, `userId`, `username`, `type_user="customer"`

---

#### TC_AUTH_002: Đăng nhập thành công - Stall Owner
**Mô tả:** Test đăng nhập thành công với tài khoản stall

**Các bước thực hiện:**
1. Truy cập `/login`
2. Nhập username và password hợp lệ của stall owner
3. Click "Đăng nhập"

**Kết quả mong đợi:**
- Đăng nhập thành công
- Redirect về `/home`
- Session có `type_user="stall"`

---

#### TC_AUTH_003: Đăng nhập thành công - Admin
**Mô tả:** Test đăng nhập thành công với tài khoản admin

**Các bước thực hiện:**
1. Truy cập `/login`
2. Nhập username và password hợp lệ của admin
3. Click "Đăng nhập"

**Kết quả mong đợi:**
- Đăng nhập thành công
- Redirect về `/home`
- Session có `type_user="admin"`

---

#### TC_AUTH_004: Đăng nhập thất bại - Sai mật khẩu
**Mô tả:** Test đăng nhập với mật khẩu sai

**Các bước thực hiện:**
1. Truy cập `/login`
2. Nhập username đúng, password sai
3. Click "Đăng nhập"

**Kết quả mong đợi:**
- Hiển thị thông báo lỗi: "Login Failed, check user name and password"
- Vẫn ở trang login
- Không tạo session

---

#### TC_AUTH_005: Đăng nhập thất bại - Tài khoản bị khóa
**Mô tả:** Test đăng nhập với tài khoản bị khóa

**Điều kiện tiên quyết:**
- Có tài khoản với status = false

**Các bước thực hiện:**
1. Truy cập `/login`
2. Nhập username và password của tài khoản bị khóa
3. Click "Đăng nhập"

**Kết quả mong đợi:**
- Hiển thị thông báo lỗi: "Login Failed, user blocked - please contact admin"
- Vẫn ở trang login
- Không tạo session

---

#### TC_AUTH_006: Đăng nhập - Tài khoản không tồn tại
**Mô tả:** Test đăng nhập với username không tồn tại

**Các bước thực hiện:**
1. Truy cập `/login`
2. Nhập username không tồn tại và password bất kỳ
3. Click "Đăng nhập"

**Kết quả mong đợi:**
- Hiển thị thông báo lỗi: "Login Failed, check user name and password"
- Vẫn ở trang login

---

#### TC_AUTH_007: Đăng nhập - Đã đăng nhập
**Mô tả:** Test truy cập trang login khi đã đăng nhập

**Điều kiện tiên quyết:**
- Đã đăng nhập

**Các bước thực hiện:**
1. Truy cập `/login`

**Kết quả mong đợi:**
- Redirect về `/home`
- Không hiển thị trang login

---

#### TC_AUTH_008: Đăng xuất
**Mô tả:** Test đăng xuất

**Điều kiện tiên quyết:**
- Đã đăng nhập

**Các bước thực hiện:**
1. Click nút "Đăng xuất" hoặc truy cập `/logout`

**Kết quả mong đợi:**
- Session bị xóa
- Redirect về `/home` hoặc `/login`
- Không thể truy cập các trang yêu cầu đăng nhập

---

### 2.2. Xem danh sách món ăn

#### TC_FOOD_LIST_001: Xem danh sách món ăn - Tất cả
**Mô tả:** Test xem danh sách tất cả món ăn

**Các bước thực hiện:**
1. Truy cập `/foods?action=list`

**Kết quả mong đợi:**
- Hiển thị danh sách tất cả món ăn
- Có phân trang nếu có nhiều món
- Hiển thị thông tin: tên, giá, tồn kho, hình ảnh

---

#### TC_FOOD_LIST_002: Xem danh sách món ăn - Theo quầy
**Mô tả:** Test xem danh sách món ăn của một quầy cụ thể

**Các bước thực hiện:**
1. Truy cập `/foods?action=list&stallId=1`

**Kết quả mong đợi:**
- Hiển thị chỉ món ăn của quầy ID = 1
- Không hiển thị món ăn của quầy khác

---

#### TC_FOOD_LIST_003: Tìm kiếm món ăn
**Mô tả:** Test tìm kiếm món ăn theo tên hoặc giá

**Các bước thực hiện:**
1. Truy cập `/foods?action=list`
2. Nhập từ khóa tìm kiếm: "phở"
3. Click "Tìm kiếm"

**Kết quả mong đợi:**
- Hiển thị kết quả tìm kiếm
- Chỉ hiển thị món ăn có tên hoặc giá chứa từ khóa "phở"

---

#### TC_FOOD_LIST_004: Sắp xếp món ăn
**Mô tả:** Test sắp xếp danh sách món ăn

**Các bước thực hiện:**
1. Truy cập `/foods?action=list&sortField=price&orderField=ASC`

**Kết quả mong đợi:**
- Danh sách món ăn được sắp xếp theo giá tăng dần

---

#### TC_FOOD_LIST_005: Phân trang
**Mô tả:** Test phân trang danh sách món ăn

**Điều kiện tiên quyết:**
- Có nhiều hơn 25 món ăn (PAGE_SIZE = 25)

**Các bước thực hiện:**
1. Truy cập `/foods?action=list`
2. Click nút "Trang 2" hoặc "Sau"

**Kết quả mong đợi:**
- Hiển thị trang 2 của danh sách
- Hiển thị đúng 25 món ăn (hoặc ít hơn nếu là trang cuối)

---

### 2.3. Quản lý giỏ hàng

#### TC_CART_001: Thêm món ăn vào giỏ hàng
**Mô tả:** Test thêm món ăn vào giỏ hàng

**Các bước thực hiện:**
1. Truy cập trang danh sách món ăn
2. Click nút "Thêm vào giỏ" trên một món ăn

**Kết quả mong đợi:**
- Món ăn được thêm vào giỏ hàng (localStorage)
- Số lượng trong giỏ hàng tăng lên
- Icon giỏ hàng hiển thị số lượng

---

#### TC_CART_002: Xem giỏ hàng
**Mô tả:** Test xem nội dung giỏ hàng

**Điều kiện tiên quyết:**
- Đã có món ăn trong giỏ hàng

**Các bước thực hiện:**
1. Truy cập `/cart`

**Kết quả mong đợi:**
- Hiển thị danh sách món ăn trong giỏ hàng
- Hiển thị số lượng, giá từng món
- Hiển thị tổng tiền

---

#### TC_CART_003: Cập nhật số lượng món ăn trong giỏ hàng
**Mô tả:** Test tăng/giảm số lượng món ăn

**Điều kiện tiên quyết:**
- Đã có món ăn trong giỏ hàng

**Các bước thực hiện:**
1. Truy cập `/cart`
2. Click nút "+" hoặc "-" để thay đổi số lượng

**Kết quả mong đợi:**
- Số lượng được cập nhật
- Tổng tiền được tính lại
- Giỏ hàng được lưu vào localStorage

---

#### TC_CART_004: Xóa món ăn khỏi giỏ hàng
**Mô tả:** Test xóa món ăn khỏi giỏ hàng

**Điều kiện tiên quyết:**
- Đã có món ăn trong giỏ hàng

**Các bước thực hiện:**
1. Truy cập `/cart`
2. Click nút "X" để xóa một món ăn

**Kết quả mong đợi:**
- Món ăn được xóa khỏi giỏ hàng
- Tổng tiền được tính lại
- Giỏ hàng được cập nhật trong localStorage

---

#### TC_CART_005: Giỏ hàng trống
**Mô tả:** Test xem giỏ hàng khi trống

**Các bước thực hiện:**
1. Truy cập `/cart` khi giỏ hàng trống

**Kết quả mong đợi:**
- Hiển thị thông báo "Giỏ hàng trống"
- Không hiển thị nút "Đặt hàng"

---

#### TC_CART_006: Lưu giỏ hàng vào session
**Mô tả:** Test lưu giỏ hàng từ localStorage vào session khi checkout

**Điều kiện tiên quyết:**
- Đã đăng nhập
- Có món ăn trong giỏ hàng (localStorage)

**Các bước thực hiện:**
1. Truy cập `/cart`
2. Click "Đặt hàng"
3. Điền form và submit

**Kết quả mong đợi:**
- Giỏ hàng từ localStorage được chuyển vào session
- Dữ liệu được lưu dưới dạng List<Order_FoodDAO>

---

### 2.4. Đặt hàng

#### TC_ORDER_CREATE_001: Đặt hàng thành công
**Mô tả:** Test đặt hàng thành công với đầy đủ thông tin

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản customer
- Đã có món ăn trong giỏ hàng

**Các bước thực hiện:**
1. Truy cập `/cart`
2. Điền địa chỉ giao hàng: "123 Đường ABC"
3. Chọn phương thức thanh toán: "COD"
4. Click "Đặt hàng"

**Kết quả mong đợi:**
- Đơn hàng được tạo thành công
- Redirect về trang thành công (`order-success.jsp`)
- Hiển thị thông tin đơn hàng
- Giỏ hàng được xóa
- Trạng thái đơn hàng: "new_order"

---

#### TC_ORDER_CREATE_002: Đặt hàng - Thiếu địa chỉ
**Mô tả:** Test đặt hàng khi không nhập địa chỉ

**Điều kiện tiên quyết:**
- Đã đăng nhập
- Đã có món ăn trong giỏ hàng

**Các bước thực hiện:**
1. Truy cập `/cart`
2. Để trống địa chỉ giao hàng
3. Click "Đặt hàng"

**Kết quả mong đợi:**
- Hiển thị trang lỗi (`order-failed.jsp`)
- Thông báo: "Vui lòng nhập địa chỉ giao hàng."
- Đơn hàng không được tạo

---

#### TC_ORDER_CREATE_003: Đặt hàng - Giỏ hàng trống
**Mô tả:** Test đặt hàng khi giỏ hàng trống

**Điều kiện tiên quyết:**
- Đã đăng nhập
- Giỏ hàng trống

**Các bước thực hiện:**
1. Truy cập `/cart`
2. Click "Đặt hàng" (nếu có)

**Kết quả mong đợi:**
- Hiển thị trang lỗi
- Thông báo: "Giỏ hàng trống. Vui lòng thêm sản phẩm vào giỏ hàng trước khi đặt hàng."

---

#### TC_ORDER_CREATE_004: Đặt hàng - Chưa đăng nhập
**Mô tả:** Test đặt hàng khi chưa đăng nhập

**Điều kiện tiên quyết:**
- Chưa đăng nhập
- Có món ăn trong giỏ hàng (localStorage)

**Các bước thực hiện:**
1. Truy cập `/cart`
2. Click "Đặt hàng"

**Kết quả mong đợi:**
- Redirect về `/login`
- Sau khi đăng nhập, redirect về `/cart`

---

### 2.5. Xem lịch sử đơn hàng

#### TC_ORDER_HISTORY_001: Xem lịch sử đơn hàng - Customer
**Mô tả:** Test customer xem lịch sử đơn hàng của mình

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản customer
- Đã có ít nhất một đơn hàng

**Các bước thực hiện:**
1. Truy cập `/order-history`

**Kết quả mong đợi:**
- Hiển thị danh sách đơn hàng của user
- Hiển thị thông tin: ID, tổng tiền, trạng thái, thời gian
- Hiển thị chi tiết món ăn trong mỗi đơn hàng

---

#### TC_ORDER_HISTORY_002: Xem lịch sử đơn hàng - Chưa đăng nhập
**Mô tả:** Test xem lịch sử đơn hàng khi chưa đăng nhập

**Các bước thực hiện:**
1. Truy cập `/order-history`

**Kết quả mong đợi:**
- Redirect về `/login`

---

#### TC_ORDER_HISTORY_003: Xem lịch sử đơn hàng - Không có đơn hàng
**Mô tả:** Test xem lịch sử khi chưa có đơn hàng nào

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản customer mới
- Chưa có đơn hàng nào

**Các bước thực hiện:**
1. Truy cập `/order-history`

**Kết quả mong đợi:**
- Hiển thị thông báo "Chưa có đơn hàng nào" hoặc danh sách trống

---

### 2.6. Quản lý quầy (Stall Owner)

#### TC_STALL_MGMT_001: Xem trang quản lý quầy
**Mô tả:** Test stall owner xem trang quản lý quầy

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- User có quầy hàng được gán

**Các bước thực hiện:**
1. Truy cập `/stall`

**Kết quả mong đợi:**
- Hiển thị thông tin quầy hàng
- Hiển thị thống kê: tổng đơn hàng, doanh thu, đơn mới, đang xử lý, đã hoàn thành
- Hiển thị danh sách đơn hàng cần xử lý
- Hiển thị đơn hàng gần đây

---

#### TC_STALL_MGMT_002: Xem trang quản lý quầy - Không có quầy
**Mô tả:** Test xem trang quản lý khi user không có quầy

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- User chưa được gán quầy hàng

**Các bước thực hiện:**
1. Truy cập `/stall`

**Kết quả mong đợi:**
- Trả về lỗi 403 Forbidden
- Thông báo: "You don't manage any stall"

---

#### TC_STALL_MGMT_003: Xem trang quản lý quầy - Không phải stall owner
**Mô tả:** Test xem trang quản lý quầy khi không phải stall owner

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "customer" hoặc "admin"

**Các bước thực hiện:**
1. Truy cập `/stall`

**Kết quả mong đợi:**
- Redirect về `/home`

---

#### TC_STALL_MGMT_004: Mở/Đóng quầy hàng
**Mô tả:** Test mở/đóng quầy hàng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- User có quầy hàng

**Các bước thực hiện:**
1. Truy cập `/stall`
2. Click nút "Mở cửa" hoặc "Đóng cửa"

**Kết quả mong đợi:**
- Trạng thái quầy được cập nhật
- Trạng thái mới được hiển thị ngay lập tức

---

#### TC_STALL_MGMT_005: Xem đơn hàng của quầy
**Mô tả:** Test stall owner xem danh sách đơn hàng của quầy

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- User có quầy hàng

**Các bước thực hiện:**
1. Truy cập `/stall-orders`

**Kết quả mong đợi:**
- Hiển thị danh sách đơn hàng của quầy
- Hiển thị chi tiết món ăn trong mỗi đơn hàng
- Có thể lọc theo trạng thái

---

#### TC_STALL_MGMT_006: Cập nhật trạng thái đơn hàng
**Mô tả:** Test stall owner cập nhật trạng thái đơn hàng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- Có đơn hàng với trạng thái "new_order"

**Các bước thực hiện:**
1. Truy cập `/stall-orders`
2. Chọn đơn hàng
3. Cập nhật trạng thái từ "new_order" sang "confirmed"

**Kết quả mong đợi:**
- Trạng thái đơn hàng được cập nhật thành công
- Trạng thái mới được hiển thị

---

#### TC_STALL_MGMT_007: Quản lý menu món ăn
**Mô tả:** Test stall owner quản lý menu món ăn của quầy

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "stall"
- User có quầy hàng

**Các bước thực hiện:**
1. Truy cập `/stall`
2. Click nút "Quản lý menu"
3. Hoặc truy cập `/foods?action=list&stallId=X` (X là ID quầy của user)

**Kết quả mong đợi:**
- Hiển thị danh sách món ăn của quầy
- Có thể tạo, sửa, xóa món ăn
- Nút "Thêm món ăn mới" hiển thị

---

### 2.7. Quản lý Admin

#### TC_ADMIN_001: Xem trang dashboard admin
**Mô tả:** Test admin xem trang dashboard

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin` hoặc `/admin?action=dashboard`

**Kết quả mong đợi:**
- Hiển thị thống kê tổng quan:
  - Tổng số người dùng
  - Tổng số quầy hàng
  - Doanh thu hôm nay
  - Tổng đơn hàng hôm nay
- Hiển thị đơn hàng gần đây

---

#### TC_ADMIN_002: Xem trang dashboard - Không phải admin
**Mô tả:** Test xem trang dashboard khi không phải admin

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "customer" hoặc "stall"

**Các bước thực hiện:**
1. Truy cập `/admin`

**Kết quả mong đợi:**
- Redirect về `/home`

---

#### TC_ADMIN_003: Quản lý người dùng
**Mô tả:** Test admin quản lý danh sách người dùng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin?action=users`

**Kết quả mong đợi:**
- Hiển thị danh sách tất cả người dùng
- Có thể tạo, sửa, xóa, khóa/mở khóa người dùng
- Có thể lọc theo role

---

#### TC_ADMIN_004: Quản lý quầy hàng
**Mô tả:** Test admin quản lý danh sách quầy hàng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin?action=stalls`

**Kết quả mong đợi:**
- Hiển thị danh sách tất cả quầy hàng
- Có thể tạo, sửa, xóa quầy hàng
- Hiển thị thông tin quầy và người quản lý

---

#### TC_ADMIN_005: Quản lý đơn hàng
**Mô tả:** Test admin xem và quản lý tất cả đơn hàng

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin?action=orders`

**Kết quả mong đợi:**
- Hiển thị danh sách tất cả đơn hàng
- Có thể xem chi tiết đơn hàng
- Có thể cập nhật trạng thái đơn hàng

---

#### TC_ADMIN_006: Xem thống kê
**Mô tả:** Test admin xem thống kê hệ thống

**Điều kiện tiên quyết:**
- Đã đăng nhập với tài khoản có role = "admin"

**Các bước thực hiện:**
1. Truy cập `/admin?action=statistics`

**Kết quả mong đợi:**
- Hiển thị các thống kê:
  - Doanh thu theo thời gian
  - Đơn hàng theo quầy
  - Món ăn bán chạy
  - Đơn hàng theo ngày

---

## Ghi chú Test

### Môi trường Test
- **URL Base:** `http://localhost:8080/web_canteen_final_00`
- **Database:** MySQL
- **Framework:** Java Servlet, JSP

### Dữ liệu Test
- **Admin:** username: `admin`, password: `admin123` (hoặc theo dữ liệu thực tế)
- **Stall Owner:** username: `stall1`, password: `123456` (hoặc theo dữ liệu thực tế)
- **Customer:** username: `customer1`, password: `123456` (hoặc theo dữ liệu thực tế)

### Các trạng thái đơn hàng hợp lệ
- `new_order`: Đơn hàng mới
- `confirmed`: Đã xác nhận
- `in_delivery`: Đang giao
- `delivered`: Đã giao

### Các role người dùng
- `admin`: Quản trị viên
- `stall`: Chủ quầy hàng
- `customer`: Khách hàng

### Lưu ý khi test
1. Đảm bảo database đã được khởi tạo với dữ liệu mẫu
2. Kiểm tra kết nối database trước khi test
3. Xóa dữ liệu test sau khi hoàn thành để không ảnh hưởng đến test case khác
4. Test các trường hợp edge case (biên) như giá trị null, rỗng, số âm, v.v.
5. Test bảo mật: kiểm tra authorization và authentication cho mọi chức năng

---

**Ngày tạo:** 2024
**Phiên bản:** 1.0
**Người tạo:** Test Team

