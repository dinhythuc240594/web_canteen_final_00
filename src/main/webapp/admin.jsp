<%--
  Created by IntelliJ IDEA.
  User: bangt
  Date: 10/11/2025
  Time: 8:04 CH
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Security check: Only admin can access this page
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("type_user");
    
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    if (!"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    
    // Get data from servlet
    int totalUsers = (int) request.getAttribute("totalUsers");
    int totalStalls = (int) request.getAttribute("totalStalls");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    int totalOrders = (int) request.getAttribute("totalOrders");
    
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản trị - Canteen ĐH</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<main class="min-h-screen">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div class="flex">
            <!-- Sidebar -->
            <aside class="w-64 bg-white shadow-sm border rounded-lg admin-sidebar hidden md:block">
                <div class="p-4 border-b">
                    <div class="flex items-center space-x-2">
                        <i data-lucide="shield" class="text-blue-600"></i>
                        <h2 class="text-lg font-bold text-gray-800">Quản trị căn tin</h2>
                    </div>
                </div>
                <nav class="p-3 space-y-1" id="admin-nav">
                    <a href="#dashboard" class="block px-3 py-2 rounded text-gray-700 hover:bg-gray-100">Tổng quan</a>
                    <a href="#users" class="block px-3 py-2 rounded text-gray-700 hover:bg-gray-100">Người dùng</a>
                    <a href="#foods" class="block px-3 py-2 rounded text-gray-700 hover:bg-gray-100">Món ăn</a>
                    <a href="#orders" class="block px-3 py-2 rounded text-gray-700 hover:bg-gray-100">Đơn hàng</a>
                    <a href="#stalls" class="block px-3 py-2 rounded text-gray-700 hover:bg-gray-100">Quầy ăn</a>
                    <a href="#reports" class="block px-3 py-2 rounded text-gray-700 hover:bg-gray-100">Báo cáo</a>
                </nav>
            </aside>

            <!-- Main -->
            <section class="flex-1 md:ml-6">
                <!-- Mobile nav -->
                <div class="md:hidden mb-4">
                    <select id="admin-mobile-nav" class="w-full px-3 py-2 border rounded-md">
                        <option value="#dashboard">Tổng quan</option>
                        <option value="#users">Người dùng</option>
                        <option value="#foods">Món ăn</option>
                        <option value="#orders">Đơn hàng</option>
                        <option value="#stalls">Quầy ăn</option>
                        <option value="#reports">Báo cáo</option>
                    </select>
                </div>

                <!-- Dashboard -->
                <div data-view="dashboard" class="space-y-6 admin-view">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">Tổng quan hệ thống</h1>
                        <p class="text-gray-600">Thống kê hoạt động căn tin hôm nay</p>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                        <div class="bg-white p-4 rounded-lg shadow-sm border">
                            <div class="flex items-center justify-between">
                                <div>
                                    <p class="text-sm text-gray-600">Doanh thu hôm nay</p>
                                    <p class="text-2xl font-bold text-green-600"><%= String.format("%,.0f", totalRevenue) %>đ</p>
                                </div>
                                <i data-lucide="dollar-sign" class="text-green-600"></i>
                            </div>
                        </div>
                        <div class="bg-white p-4 rounded-lg shadow-sm border">
                            <div class="flex items-center justify-between">
                                <div>
                                    <p class="text-sm text-gray-600">Đơn hôm nay</p>
                                    <p class="text-2xl font-bold text-blue-600"><%= totalOrders %></p>
                                </div>
                                <i data-lucide="package" class="text-blue-600"></i>
                            </div>
                        </div>
                        <div class="bg-white p-4 rounded-lg shadow-sm border">
                            <div class="flex items-center justify-between">
                                <div>
                                    <p class="text-sm text-gray-600">Người dùng</p>
                                    <p class="text-2xl font-bold text-purple-600"><%= totalUsers %></p>
                                </div>
                                <i data-lucide="users" class="text-purple-600"></i>
                            </div>
                        </div>
                        <div class="bg-white p-4 rounded-lg shadow-sm border">
                            <div class="flex items-center justify-between">
                                <div>
                                    <p class="text-sm text-gray-600">Quầy ăn</p>
                                    <p class="text-2xl font-bold text-orange-600"><%= totalStalls %></p>
                                </div>
                                <i data-lucide="store" class="text-orange-600"></i>
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                        <div class="bg-white p-4 rounded-lg shadow-sm border">
                            <h3 class="text-lg font-semibold mb-3">Liên kết nhanh</h3>
                            <div class="space-y-2">
                                <a href="<%=contextPath%>/statistics" class="block p-3 border rounded hover:bg-gray-50 transition-colors">
                                    <div class="flex items-center justify-between">
                                        <span class="font-medium">Xem báo cáo thống kê</span>
                                        <i data-lucide="arrow-right" class="w-4 h-4"></i>
                                    </div>
                                </a>
                                <a href="<%=contextPath%>/stall-orders" class="block p-3 border rounded hover:bg-gray-50 transition-colors">
                                    <div class="flex items-center justify-between">
                                        <span class="font-medium">Quản lý đơn hàng</span>
                                        <i data-lucide="arrow-right" class="w-4 h-4"></i>
                                    </div>
                                </a>
                                <a href="<%=contextPath%>/foods?action=list" class="block p-3 border rounded hover:bg-gray-50 transition-colors">
                                    <div class="flex items-center justify-between">
                                        <span class="font-medium">Quản lý món ăn</span>
                                        <i data-lucide="arrow-right" class="w-4 h-4"></i>
                                    </div>
                                </a>
                                <a href="<%=contextPath%>/store" class="block p-3 border rounded hover:bg-gray-50 transition-colors">
                                    <div class="flex items-center justify-between">
                                        <span class="font-medium">Quản lý quầy ăn</span>
                                        <i data-lucide="arrow-right" class="w-4 h-4"></i>
                                    </div>
                                </a>
                            </div>
                        </div>
                        <div class="bg-white p-4 rounded-lg shadow-sm border">
                            <h3 class="text-lg font-semibold mb-3">Trạng thái hệ thống</h3>
                            <div class="space-y-2">
                                <div class="flex justify-between">
                                    <span>Tổng quầy ăn</span>
                                    <span class="font-semibold text-green-600"><%= totalStalls %></span>
                                </div>
                                <div class="flex justify-between">
                                    <span>Tổng người dùng</span>
                                    <span class="font-semibold text-green-600"><%= totalUsers %></span>
                                </div>
                                <div class="flex justify-between">
                                    <span>Đơn hàng hôm nay</span>
                                    <span class="font-semibold text-blue-600"><%= totalOrders %></span>
                                </div>
                                <div class="flex justify-between">
                                    <span>Doanh thu hôm nay</span>
                                    <span class="font-semibold text-green-600"><%= String.format("%,.0f", totalRevenue) %>đ</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white p-4 rounded-lg shadow-sm border">
                        <h3 class="text-lg font-semibold mb-3">Đơn hàng gần đây</h3>
                        <div class="overflow-x-auto">
                            <table class="w-full text-sm">
                                <thead class="bg-gray-50">
                                <tr class="border-b">
                                    <th class="text-left py-2 px-3">ID</th>
                                    <th class="text-left py-2 px-3">Khách hàng</th>
                                    <th class="text-left py-2 px-3">Tổng tiền</th>
                                    <th class="text-left py-2 px-3">Trạng thái</th>
                                    <th class="text-left py-2 px-3">Thời gian</th>
                                    <th class="text-left py-2 px-3">Quầy</th>
                                </tr>
                                </thead>
                                <tbody>
                                <tr class="border-b">
                                    <td class="py-2 px-3">#1</td>
                                    <td class="py-2 px-3">Nguyễn Văn A</td>
                                    <td class="py-2 px-3">47,000đ</td>
                                    <td class="py-2 px-3"><span class="px-2 py-1 bg-green-100 text-green-800 rounded text-xs">Hoàn thành</span></td>
                                    <td class="py-2 px-3">2025-11-10 08:30</td>
                                    <td class="py-2 px-3">Quầy cơm & món khô</td>
                                </tr>
                                <tr>
                                    <td class="py-2 px-3">#2</td>
                                    <td class="py-2 px-3">Trần Thị B</td>
                                    <td class="py-2 px-3">45,000đ</td>
                                    <td class="py-2 px-3"><span class="px-2 py-1 bg-yellow-100 text-yellow-800 rounded text-xs">Chờ xử lý</span></td>
                                    <td class="py-2 px-3">2025-11-10 09:15</td>
                                    <td class="py-2 px-3">Quầy món nước</td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Users -->
                <div data-view="users" class="space-y-6 admin-view hidden">
                    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                        <div>
                            <h1 class="text-2xl font-bold text-gray-800">Quản lý người dùng</h1>
                            <p class="text-gray-600">Tất cả tài khoản người dùng (mock)</p>
                        </div>
                        <button class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 flex items-center space-x-2">
                            <i data-lucide="plus-circle"></i><span>Thêm người dùng</span>
                        </button>
                    </div>

                    <div class="bg-white p-4 rounded-lg shadow-sm border">
                        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                            <input type="text" class="px-3 py-2 border rounded text-sm" placeholder="Tìm kiếm (tên/email)"/>
                            <select class="px-3 py-2 border rounded text-sm"><option>Tất cả vai trò</option><option>Người dùng</option><option>Nhân viên</option><option>Quản trị viên</option></select>
                            <select class="px-3 py-2 border rounded text-sm"><option>Tất cả trạng thái</option><option>Hoạt động</option><option>Khóa</option></select>
                            <button class="bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400 text-sm">Xóa bộ lọc</button>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-sm border overflow-hidden">
                        <div class="overflow-x-auto">
                            <table class="w-full text-sm">
                                <thead class="bg-gray-50">
                                <tr>
                                    <th class="text-left py-3 px-4">ID</th>
                                    <th class="text-left py-3 px-4">Tên người dùng</th>
                                    <th class="text-left py-3 px-4">Email</th>
                                    <th class="text-left py-3 px-4">SĐT</th>
                                    <th class="text-left py-3 px-4">Vai trò</th>
                                    <th class="text-left py-3 px-4">Trạng thái</th>
                                    <th class="text-left py-3 px-4">Số dư</th>
                                    <th class="text-left py-3 px-4">Ngày tham gia</th>
                                    <th class="text-left py-3 px-4">Hành động</th>
                                </tr>
                                </thead>
                                <tbody>
                                <tr class="border-b hover:bg-gray-50">
                                    <td class="py-3 px-4">#1</td>
                                    <td class="py-3 px-4">nguyenvana</td>
                                    <td class="py-3 px-4">a@example.com</td>
                                    <td class="py-3 px-4">0123456789</td>
                                    <td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs bg-blue-100 text-blue-800">Người dùng</span></td>
                                    <td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs bg-green-100 text-green-800">Hoạt động</span></td>
                                    <td class="py-3 px-4">500,000đ</td>
                                    <td class="py-3 px-4">2024-01-15</td>
                                    <td class="py-3 px-4">
                                        <div class="flex space-x-2">
                                            <button class="p-1 text-blue-600 hover:text-blue-800"><i data-lucide="edit" class="w-4 h-4"></i></button>
                                            <button class="p-1 text-red-600 hover:text-red-800"><i data-lucide="user-x" class="w-4 h-4"></i></button>
                                            <button class="p-1 text-red-600 hover:text-red-800"><i data-lucide="trash-2" class="w-4 h-4"></i></button>
                                        </div>
                                    </td>
                                </tr>
                                <!-- thêm vài dòng mock khác nếu muốn -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Foods -->
                <div data-view="foods" class="space-y-6 admin-view hidden">
                    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                        <div>
                            <h1 class="text-2xl font-bold text-gray-800">Quản lý món ăn</h1>
                            <p class="text-gray-600">Tất cả món ăn (mock)</p>
                        </div>
                        <button class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 flex items-center space-x-2">
                            <i data-lucide="plus-circle"></i><span>Thêm món ăn</span>
                        </button>
                    </div>

                    <div class="bg-white p-4 rounded-lg shadow-sm border">
                        <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
                            <input type="text" class="px-3 py-2 border rounded text-sm" placeholder="Tìm món..."/>
                            <select class="px-3 py-2 border rounded text-sm"><option>Tất cả danh mục</option></select>
                            <select class="px-3 py-2 border rounded text-sm"><option>Tất cả quầy</option></select>
                            <select class="px-3 py-2 border rounded text-sm"><option>Tất cả trạng thái</option><option>Hoạt động</option><option>Ngừng</option></select>
                            <button class="bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400 text-sm">Xóa bộ lọc</button>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-sm border overflow-hidden">
                        <div class="overflow-x-auto">
                            <table class="w-full text-sm">
                                <thead class="bg-gray-50">
                                <tr>
                                    <th class="text-left py-3 px-4">Món</th>
                                    <th class="text-left py-3 px-4">Giá</th>
                                    <th class="text-left py-3 px-4">Danh mục</th>
                                    <th class="text-left py-3 px-4">Quầy</th>
                                    <th class="text-left py-3 px-4">Giảm giá</th>
                                    <th class="text-left py-3 px-4">Trạng thái</th>
                                    <th class="text-left py-3 px-4">Hành động</th>
                                </tr>
                                </thead>
                                <tbody>
                                <tr class="border-b hover:bg-gray-50">
                                    <td class="py-3 px-4">
                                        <div class="flex items-center space-x-3">
                                            <img src="https://placehold.co/40x40/3498db/white?text=PB" class="w-10 h-10 rounded object-cover" alt="Phở bò"/>
                                            <span>Phở bò</span>
                                        </div>
                                    </td>
                                    <td class="py-3 px-4">30,000đ</td>
                                    <td class="py-3 px-4">Món nước</td>
                                    <td class="py-3 px-4">Quầy món nước</td>
                                    <td class="py-3 px-4">Không</td>
                                    <td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs bg-green-100 text-green-800">Hoạt động</span></td>
                                    <td class="py-3 px-4">
                                        <div class="flex space-x-2">
                                            <button class="p-1 text-blue-600 hover:text-blue-800"><i data-lucide="edit" class="w-4 h-4"></i></button>
                                            <button class="p-1 text-red-600 hover:text-red-800"><i data-lucide="x-circle" class="w-4 h-4"></i></button>
                                            <button class="p-1 text-red-600 hover:text-red-800"><i data-lucide="trash-2" class="w-4 h-4"></i></button>
                                        </div>
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Orders -->
                <div data-view="orders" class="space-y-6 admin-view hidden">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">Quản lý đơn hàng</h1>
                        <p class="text-gray-600">Tất cả đơn hàng (mock)</p>
                    </div>

                    <div class="bg-white p-4 rounded-lg shadow-sm border">
                        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                            <input type="text" class="px-3 py-2 border rounded text-sm" placeholder="Khách hàng, món..."/>
                            <select class="px-3 py-2 border rounded text-sm"><option>Tất cả trạng thái</option><option>Chờ xử lý</option><option>Đang chuẩn bị</option><option>Hoàn thành</option><option>Đã hủy</option></select>
                            <select class="px-3 py-2 border rounded text-sm"><option>Tất cả quầy</option></select>
                            <input type="date" class="px-3 py-2 border rounded text-sm"/>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-sm border overflow-hidden">
                        <div class="overflow-x-auto">
                            <table class="w-full text-sm">
                                <thead class="bg-gray-50">
                                <tr>
                                    <th class="text-left py-3 px-4">ID</th>
                                    <th class="text-left py-3 px-4">Khách hàng</th>
                                    <th class="text-left py-3 px-4">Món ăn</th>
                                    <th class="text-left py-3 px-4">Tổng tiền</th>
                                    <th class="text-left py-3 px-4">Quầy</th>
                                    <th class="text-left py-3 px-4">Trạng thái</th>
                                    <th class="text-left py-3 px-4">Phương thức</th>
                                    <th class="text-left py-3 px-4">Thời gian</th>
                                    <th class="text-left py-3 px-4">Hành động</th>
                                </tr>
                                </thead>
                                <tbody>
                                <tr class="border-b hover:bg-gray-50">
                                    <td class="py-3 px-4">#1001</td>
                                    <td class="py-3 px-4">Phạm Thị D</td>
                                    <td class="py-3 px-4">
                                        <div class="space-y-1">
                                            <div class="text-sm">Cơm chay thập cẩm</div>
                                            <div class="text-sm">Salad rau củ</div>
                                        </div>
                                    </td>
                                    <td class="py-3 px-4">48,000đ</td>
                                    <td class="py-3 px-4">Quầy món chay</td>
                                    <td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs bg-green-100 text-green-800">Hoàn thành</span></td>
                                    <td class="py-3 px-4"><span class="px-2 py-1 bg-blue-100 text-blue-800 rounded text-xs">Ví điện tử</span></td>
                                    <td class="py-3 px-4">2025-11-10 11:30</td>
                                    <td class="py-3 px-4">
                                        <div class="flex space-x-2">
                                            <button class="p-1 text-blue-600 hover:text-blue-800"><i data-lucide="eye" class="w-4 h-4"></i></button>
                                            <button class="p-1 text-green-600 hover:text-green-800"><i data-lucide="check" class="w-4 h-4"></i></button>
                                            <button class="p-1 text-red-600 hover:text-red-800"><i data-lucide="x-circle" class="w-4 h-4"></i></button>
                                        </div>
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Stalls -->
                <div data-view="stalls" class="space-y-6 admin-view hidden">
                    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                        <div>
                            <h1 class="text-2xl font-bold text-gray-800">Quản lý quầy ăn</h1>
                            <p class="text-gray-600">Tất cả quầy (mock)</p>
                        </div>
                        <button class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 flex items-center space-x-2">
                            <i data-lucide="plus-circle"></i><span>Thêm quầy</span>
                        </button>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                        <div class="bg-white rounded-lg shadow-sm border p-4">
                            <div class="flex justify-between items-start mb-2">
                                <h3 class="font-semibold text-gray-800">Quầy cơm & món khô</h3>
                                <span class="px-2 py-1 rounded text-xs bg-green-100 text-green-800">Hoạt động</span>
                            </div>
                            <p class="text-sm text-gray-600 mb-2">Cơm, mì xào, hủ tiếu xào...</p>
                            <p class="text-xs text-gray-500 mb-3">Quản lý: Nguyễn Văn A</p>
                            <div class="flex justify-between items-center">
                                <span class="text-xs text-gray-500">26 món</span>
                                <div class="flex space-x-2">
                                    <button class="p-1 text-blue-600 hover:text-blue-800"><i data-lucide="edit" class="w-4 h-4"></i></button>
                                    <button class="p-1 text-red-600 hover:text-red-800"><i data-lucide="x-circle" class="w-4 h-4"></i></button>
                                    <button class="p-1 text-red-600 hover:text-red-800"><i data-lucide="trash-2" class="w-4 h-4"></i></button>
                                </div>
                            </div>
                        </div>
                        <!-- thêm thẻ quầy khác tương tự -->
                    </div>
                </div>

                <!-- Reports -->
                <div data-view="reports" class="space-y-6 admin-view hidden">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">Báo cáo & Thống kê</h1>
                        <p class="text-gray-600">Thống kê hoạt động căn tin (mock)</p>
                    </div>

                    <div class="bg-white p-4 rounded-lg shadow-sm border">
                        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
                            <select class="px-3 py-2 border rounded text-sm">
                                <option>Theo ngày</option><option>Theo tuần</option><option>Theo tháng</option><option>Tùy chọn</option>
                            </select>
                            <input type="date" class="px-3 py-2 border rounded text-sm"/>
                            <input type="date" class="px-3 py-2 border rounded text-sm"/>
                            <button class="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 text-sm">Tạo báo cáo</button>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                        <div class="bg-white p-6 rounded-lg shadow-sm border h-64 flex items-center justify-center text-gray-500">
                            Biểu đồ doanh thu (mock)
                        </div>
                        <div class="bg-white p-6 rounded-lg shadow-sm border">
                            <h3 class="text-lg font-semibold mb-3">Món bán chạy</h3>
                            <div class="space-y-2">
                                <div class="flex justify-between border-b py-2">
                                    <div class="flex items-center space-x-3">
                                        <span class="text-sm font-medium text-gray-500">#1</span><span>Phở bò</span>
                                    </div>
                                    <span class="font-semibold text-green-600">156 đơn</span>
                                </div>
                                <div class="flex justify-between border-b py-2">
                                    <div class="flex items-center space-x-3">
                                        <span class="text-sm font-medium text-gray-500">#2</span><span>Cơm chiên dương châu</span>
                                    </div>
                                    <span class="font-semibold text-green-600">132 đơn</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
                        <div class="bg-white p-4 rounded-lg shadow-sm border">
                            <h4 class="font-semibold mb-2">Doanh thu hôm nay</h4>
                            <p class="text-2xl font-bold text-green-600">2,450,000đ</p>
                            <p class="text-sm text-gray-500 mt-1">124 đơn</p>
                        </div>
                        <div class="bg-white p-4 rounded-lg shadow-sm border">
                            <h4 class="font-semibold mb-2">Doanh thu tuần này</h4>
                            <p class="text-2xl font-bold text-blue-600">18,750,000đ</p>
                            <p class="text-sm text-gray-500 mt-1">892 đơn</p>
                        </div>
                        <div class="bg-white p-4 rounded-lg shadow-sm border">
                            <h4 class="font-semibold mb-2">Doanh thu tháng này</h4>
                            <p class="text-2xl font-bold text-purple-600">78,250,000đ</p>
                            <p class="text-sm text-gray-500 mt-1">3,654 đơn</p>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />

<script>
    // Active state cho menu + chuyển view theo hash
    function setActiveView(hash) {
        const views = document.querySelectorAll('.admin-view');
        views.forEach(v => v.classList.add('hidden'));
        const target = document.querySelector('[data-view="' + (hash || 'dashboard') + '"]');
        if (target) target.classList.remove('hidden');

        document.querySelectorAll('#admin-nav a').forEach(a => {
            if (a.getAttribute('href') === '#' + (hash || 'dashboard')) {
                a.classList.add('bg-blue-100', 'text-blue-700');
            } else {
                a.classList.remove('bg-blue-100', 'text-blue-700');
            }
        });

        const mobile = document.getElementById('admin-mobile-nav');
        if (mobile && ('#' + (hash || 'dashboard')) !== mobile.value) {
            mobile.value = '#' + (hash || 'dashboard');
        }
        // cập nhật icon
        if (window.lucide) lucide.createIcons();
    }

    window.addEventListener('hashchange', () => {
        setActiveView(location.hash.replace('#', ''));
    });
    document.getElementById('admin-mobile-nav')?.addEventListener('change', (e) => {
        location.hash = e.target.value;
    });

    // Lần đầu vào trang
    setActiveView(location.hash.replace('#', '') || 'dashboard');
    
    // Load data when switching tabs
    window.addEventListener('hashchange', function() {
        const hash = location.hash.replace('#', '');
        if (hash === 'users') {
            loadUsers();
        } else if (hash === 'stalls') {
            loadStalls();
        }
    });
    
    // Load users data
    function loadUsers() {
        fetch('<%=contextPath%>/admin?action=users')
            .then(response => response.json())
            .then(users => {
                const tbody = document.querySelector('[data-view="users"] tbody');
                if (tbody && users.length > 0) {
                    tbody.innerHTML = users.map(user => {
                        const roleClass = user.role === 'admin' ? 'bg-red-100 text-red-800' : 
                                         user.role === 'stall' ? 'bg-purple-100 text-purple-800' : 
                                         'bg-blue-100 text-blue-800';
                        const statusClass = user.status ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800';
                        const statusText = user.status ? 'Hoạt động' : 'Khóa';
                        // Format date to avoid JSP EL parsing issue
                        const formattedDate = user.createDate ? new Date(user.createDate).toLocaleDateString('vi-VN') : 'N/A';
                        
                        return `
                            <tr class="border-b hover:bg-gray-50">
                                <td class="py-3 px-4">#${user.id}</td>
                                <td class="py-3 px-4">${user.username}</td>
                                <td class="py-3 px-4">${user.email || 'N/A'}</td>
                                <td class="py-3 px-4">${user.phone || 'N/A'}</td>
                                <td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs ${roleClass}">${user.role}</span></td>
                                <td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs ${statusClass}">${statusText}</span></td>
                                <td class="py-3 px-4">${formattedDate}</td>
                                <td class="py-3 px-4">
                                    <div class="flex space-x-2">
                                        <button onclick="toggleUserStatus(${user.id}, ${!user.status})" class="p-1 text-blue-600 hover:text-blue-800" title="${user.status ? 'Khóa' : 'Mở khóa'}">
                                            <i data-lucide="${user.status ? 'user-x' : 'user-check'}" class="w-4 h-4"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        `;
                    }).join('');
                    lucide.createIcons();
                }
            })
            .catch(error => console.error('Error loading users:', error));
    }
    
    // Load stalls data
    function loadStalls() {
        fetch('<%=contextPath%>/admin?action=stalls')
            .then(response => response.json())
            .then(stalls => {
                const tbody = document.querySelector('[data-view="stalls"] tbody');
                if (tbody && stalls.length > 0) {
                    tbody.innerHTML = stalls.map(stall => {
                        const statusClass = stall.isOpen ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800';
                        const statusText = stall.isOpen ? 'Mở cửa' : 'Đóng cửa';
                        
                        return `
                            <tr class="border-b hover:bg-gray-50">
                                <td class="py-3 px-4">#${stall.id}</td>
                                <td class="py-3 px-4">${stall.name}</td>
                                <td class="py-3 px-4">${stall.description || 'N/A'}</td>
                                <td class="py-3 px-4">User #${stall.managerUserId}</td>
                                <td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs ${statusClass}">${statusText}</span></td>
                                <td class="py-3 px-4">
                                    <div class="flex space-x-2">
                                        <button class="p-1 text-blue-600 hover:text-blue-800" title="Sửa">
                                            <i data-lucide="edit" class="w-4 h-4"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        `;
                    }).join('');
                    lucide.createIcons();
                }
            })
            .catch(error => console.error('Error loading stalls:', error));
    }
    
    // Toggle user status
    function toggleUserStatus(userId, newStatus) {
        if (!confirm('Bạn có chắc chắn muốn ' + (newStatus ? 'mở khóa' : 'khóa') + ' tài khoản này?')) {
            return;
        }
        
        fetch('<%=contextPath%>/admin', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({
                action: 'toggleUserStatus',
                id: userId,
                status: newStatus
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert(data.message);
                loadUsers();
            } else {
                alert('Lỗi: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Có lỗi xảy ra');
        });
    }
</script>
</body>
</html>
