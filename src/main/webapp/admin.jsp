<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản trị - Canteen ĐH</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

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

    // Get data from servlet with null safety
    Object totalUsersObj = request.getAttribute("totalUsers");
    int totalUsers = (totalUsersObj != null) ? (Integer) totalUsersObj : 0;

    Object totalStallsObj = request.getAttribute("totalStalls");
    int totalStalls = (totalStallsObj != null) ? (Integer) totalStallsObj : 0;

    Object totalRevenueObj = request.getAttribute("totalRevenue");
    Double totalRevenue = (totalRevenueObj != null) ? (Double) totalRevenueObj : 0.0;

    Object totalOrdersObj = request.getAttribute("totalOrders");
    int totalOrders = (totalOrdersObj != null) ? (Integer) totalOrdersObj : 0;

    java.util.List<model.OrderDAO> recentOrders = (java.util.List<model.OrderDAO>) request.getAttribute("recentOrders");
    java.util.Map<Integer, String> userNames = (java.util.Map<Integer, String>) request.getAttribute("userNames");
    java.util.Map<Integer, String> stallNames = (java.util.Map<Integer, String>) request.getAttribute("stallNames");
    Integer currentUserId = (Integer) request.getAttribute("currentUserId");

    if (recentOrders == null) recentOrders = new java.util.ArrayList<>();
    if (userNames == null) userNames = new java.util.HashMap<>();
    if (stallNames == null) stallNames = new java.util.HashMap<>();

    String contextPath = request.getContextPath();
%>

<main class="min-h-screen"  data-current-user-id="<%= currentUserId != null ? currentUserId : "" %>">
    <div class="mx-auto px-4 sm:px-6 lg:px-8 py-6">
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
<%--                    <a href="#foods" class="block px-3 py-2 rounded text-gray-700 hover:bg-gray-100">Món ăn</a>--%>
<%--                    <a href="#orders" class="block px-3 py-2 rounded text-gray-700 hover:bg-gray-100">Đơn hàng</a>--%>
<%--                    <a href="#stalls" class="block px-3 py-2 rounded text-gray-700 hover:bg-gray-100">Quầy ăn</a>--%>
                    <!-- <a href="#reports" class="block px-3 py-2 rounded text-gray-700 hover:bg-gray-100">Báo cáo</a> -->
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
                                    <p class="text-2xl font-bold text-green-600"><%= totalRevenue != null ? String.format("%,.0f", totalRevenue) : "0" %>đ</p>
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
                            <div class="flex items-center justify-between mb-3 gap-3">
                                <div>
                                    <h3 class="text-lg font-semibold">Biểu đồ doanh thu theo ngày</h3>
                                    <p class="text-sm text-gray-500">Theo dõi doanh thu gần đây</p>
                                </div>
                                <select id="revenue-chart-range" class="px-3 py-2 border rounded-md text-sm">
                                    <option value="7">7 ngày qua</option>
                                    <option value="30">30 ngày qua</option>
                                </select>
                            </div>
                            <div class="h-64">
                                <canvas id="revenue-chart" class="w-full h-full"></canvas>
                            </div>
                        </div>
                        <div class="bg-white p-4 rounded-lg shadow-sm border">
                            <div class="flex items-center justify-between mb-3">
                                <div>
                                    <h3 class="text-lg font-semibold">Món bán chạy</h3>
                                    <p class="text-sm text-gray-500">Top 5 món có doanh thu cao nhất</p>
                                </div>
                                <button id="refresh-best-seller" class="text-sm text-blue-600 hover:text-blue-800">Làm mới</button>
                            </div>
                            <div id="best-seller-list" class="space-y-2 text-sm text-gray-700">
                                <div class="text-gray-400 text-center py-8 text-sm">Đang tải dữ liệu...</div>
                            </div>
                        </div>
                    </div>

<%--                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">--%>
<%--                        <div class="bg-white p-4 rounded-lg shadow-sm border">--%>
<%--                            <h3 class="text-lg font-semibold mb-3">Liên kết nhanh</h3>--%>
<%--                            <div class="space-y-2">--%>
<%--                                <a href="#reports" onclick="setActiveView('reports'); loadReports(); return false;" class="block p-3 border rounded hover:bg-gray-50 transition-colors cursor-pointer">--%>
<%--                                    <div class="flex items-center justify-between">--%>
<%--                                        <span class="font-medium">Xem báo cáo thống kê</span>--%>
<%--                                        <i data-lucide="arrow-right" class="w-4 h-4"></i>--%>
<%--                                    </div>--%>
<%--                                </a>--%>
<%--                                <a href="#orders" onclick="setActiveView('orders'); loadOrders(); return false;" class="block p-3 border rounded hover:bg-gray-50 transition-colors cursor-pointer">--%>
<%--                                    <div class="flex items-center justify-between">--%>
<%--                                        <span class="font-medium">Quản lý đơn hàng</span>--%>
<%--                                        <i data-lucide="arrow-right" class="w-4 h-4"></i>--%>
<%--                                    </div>--%>
<%--                                </a>--%>
<%--                                <a href="#foods" onclick="setActiveView('foods'); loadFoods(); return false;" class="block p-3 border rounded hover:bg-gray-50 transition-colors cursor-pointer">--%>
<%--                                    <div class="flex items-center justify-between">--%>
<%--                                        <span class="font-medium">Quản lý món ăn</span>--%>
<%--                                        <i data-lucide="arrow-right" class="w-4 h-4"></i>--%>
<%--                                    </div>--%>
<%--                                </a>--%>
<%--                                <a href="#stalls" onclick="setActiveView('stalls'); loadStalls(); return false;" class="block p-3 border rounded hover:bg-gray-50 transition-colors cursor-pointer">--%>
<%--                                    <div class="flex items-center justify-between">--%>
<%--                                        <span class="font-medium">Quản lý quầy ăn</span>--%>
<%--                                        <i data-lucide="arrow-right" class="w-4 h-4"></i>--%>
<%--                                    </div>--%>
<%--                                </a>--%>
<%--                            </div>--%>
<%--                        </div>--%>
<%--                        <div class="bg-white p-4 rounded-lg shadow-sm border">--%>
<%--                            <h3 class="text-lg font-semibold mb-3">Trạng thái hệ thống</h3>--%>
<%--                            <div class="space-y-2">--%>
<%--                                <div class="flex justify-between">--%>
<%--                                    <span>Tổng quầy ăn</span>--%>
<%--                                    <span class="font-semibold text-green-600"><%= totalStalls %></span>--%>
<%--                                </div>--%>
<%--                                <div class="flex justify-between">--%>
<%--                                    <span>Tổng người dùng</span>--%>
<%--                                    <span class="font-semibold text-green-600"><%= totalUsers %></span>--%>
<%--                                </div>--%>
<%--                                <div class="flex justify-between">--%>
<%--                                    <span>Đơn hàng hôm nay</span>--%>
<%--                                    <span class="font-semibold text-blue-600"><%= totalOrders %></span>--%>
<%--                                </div>--%>
<%--                                <div class="flex justify-between">--%>
<%--                                    <span>Doanh thu hôm nay</span>--%>
<%--                                    <span class="font-semibold text-green-600"><%= totalRevenue != null ? String.format("%,.0f", totalRevenue) : "0" %>đ</span>--%>
<%--                                </div>--%>
<%--                            </div>--%>
<%--                        </div>--%>
<%--                    </div>--%>

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
                                <% if (recentOrders.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="py-4 px-3 text-center text-gray-500">Chưa có đơn hàng nào</td>
                                </tr>
                                <% } else { %>
                                    <% for (model.OrderDAO order : recentOrders) { %>
                                    <tr class="border-b hover:bg-gray-50">
                                        <td class="py-2 px-3">#<%= order.getId() %></td>
                                        <td class="py-2 px-3"><%= userNames.getOrDefault(order.getUserId(), "N/A") %></td>
                                        <td class="py-2 px-3"><%= String.format("%,.0f", order.getTotalPrice()) %>đ</td>
                                        <td class="py-2 px-3">
                                            <%
                                                String status = order.getStatus();
                                                String statusText = "N/A";
                                                String statusClass = "bg-gray-100 text-gray-800";
                                                if (status != null) {
                                                    switch(status) {
                                                        case "new_order":
                                                            statusText = "Chờ xử lý";
                                                            statusClass = "bg-yellow-100 text-yellow-800";
                                                            break;
                                                        case "confirmed":
                                                            statusText = "Đã xác nhận";
                                                            statusClass = "bg-blue-100 text-blue-800";
                                                            break;
                                                        case "in_delivery":
                                                            statusText = "Đang giao";
                                                            statusClass = "bg-purple-100 text-purple-800";
                                                            break;
                                                        case "delivered":
                                                            statusText = "Hoàn thành";
                                                            statusClass = "bg-green-100 text-green-800";
                                                            break;
                                                        default:
                                                            statusText = status;
                                                    }
                                                }
                                            %>
                                            <span class="px-2 py-1 rounded text-xs <%= statusClass %>">
                                                <%= statusText %>
                                            </span>
                                        </td>
                                        <td class="py-2 px-3">
                                            <% if (order.getCreatedAt() != null) { %>
                                                <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(order.getCreatedAt()) %>
                                            <% } else { %>
                                                N/A
                                            <% } %>
                                        </td>
                                        <td class="py-2 px-3"><%= stallNames.getOrDefault(order.getStallId(), "N/A") %></td>
                                    </tr>
                                    <% } %>
                                <% } %>
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
                            <p class="text-gray-600">Danh sách khách hàng và đơn hàng đã đặt</p>
                        </div>
                        <div class="flex flex-wrap gap-2 justify-end w-full md:w-auto">
                            <button onclick="loadUsers('customer')" class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 flex items-center space-x-2">
                                <i data-lucide="users"></i><span>Khách hàng</span>
                            </button>
                            <button onclick="loadUsers('stall')" class="bg-purple-600 text-white px-4 py-2 rounded-md hover:bg-purple-700 flex items-center space-x-2">
                                <i data-lucide="store"></i><span>Quầy ăn</span>
                            </button>
                            <a href="<%=contextPath%>/admin-create-user.jsp" class="bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 flex items-center space-x-2">
                                <i data-lucide="plus-circle"></i><span>Tạo tài khoản</span>
                            </a>
                        </div>
                    </div>

                    <div class="bg-white p-4 rounded-lg shadow-sm border">
                        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                            <input type="text" id="users-search" class="px-3 py-2 border rounded text-sm" placeholder="Tìm kiếm (tên/email/SĐT)" onkeyup="filterUsers()"/>
                            <select id="users-status-filter" class="px-3 py-2 border rounded text-sm" onchange="filterUsers()">
                                <option value="all">Tất cả trạng thái</option>
                                <option value="true">Hoạt động</option>
                                <option value="false">Khóa</option>
                            </select>
                            <select id="users-type-filter" class="px-3 py-2 border rounded text-sm" onchange="filterUsers()">
                                <option value="all">Tất cả loại</option>
                                <option value="customer">Khách hàng</option>
                                <option value="stall">Quầy ăn</option>
                            </select>
                            <button onclick="clearUsersFilter()" class="bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400 text-sm">Xóa bộ lọc</button>
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
                                    <th class="text-left py-3 px-4">Số dư/Doanh thu</th>
                                    <th class="text-left py-3 px-4">Ngày tham gia</th>
                                    <th class="text-left py-3 px-4">Hành động</th>
                                </tr>
                                </thead>
                                <tbody id="users-table-body">
                                <!-- Data will be loaded here -->
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
                            <p class="text-gray-600">Danh sách các món ăn của các quầy</p>
                        </div>
                        <button class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 flex items-center space-x-2">
                            <i data-lucide="plus-circle"></i><span>Thêm món ăn</span>
                        </button>
                    </div>

                    <div class="bg-white p-4 rounded-lg shadow-sm border">
                        <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
                            <input type="text" id="foods-search" class="px-3 py-2 border rounded text-sm" placeholder="Tìm món..." onkeyup="filterFoods()"/>
                            <select id="foods-category-filter" class="px-3 py-2 border rounded text-sm" onchange="filterFoods()">
                                <option value="all">Tất cả danh mục</option>
                            </select>
                            <select id="foods-stall-filter" class="px-3 py-2 border rounded text-sm" onchange="filterFoods()">
                                <option value="all">Tất cả quầy</option>
                            </select>
                            <select id="foods-status-filter" class="px-3 py-2 border rounded text-sm" onchange="filterFoods()">
                                <option value="all">Tất cả trạng thái</option>
                                <option value="active">Hoạt động</option>
                                <option value="inactive">Ngừng</option>
                            </select>
                            <button onclick="clearFoodsFilter()" class="bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400 text-sm">Xóa bộ lọc</button>
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
                                <tbody id="foods-table-body">
                                <!-- Data will be loaded here -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Orders -->
                <div data-view="orders" class="space-y-6 admin-view hidden">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">Quản lý đơn hàng</h1>
                        <p class="text-gray-600">Danh sách các hóa đơn</p>
                    </div>

                    <div class="bg-white p-4 rounded-lg shadow-sm border">
                        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                            <input type="text" id="orders-search" class="px-3 py-2 border rounded text-sm" placeholder="Tìm kiếm (ID, khách hàng, quầy)" onkeyup="filterOrders()"/>
                            <select id="orders-status-filter" class="px-3 py-2 border rounded text-sm" onchange="filterOrders()">
                                <option value="all">Tất cả trạng thái</option>
                                <option value="new_order">Chờ xử lý</option>
                                <option value="confirmed">Đã xác nhận</option>
                                <option value="in_delivery">Đang giao</option>
                                <option value="delivered">Hoàn thành</option>
                            </select>
                            <select id="orders-stall-filter" class="px-3 py-2 border rounded text-sm" onchange="filterOrders()">
                                <option value="all">Tất cả quầy</option>
                            </select>
                            <input type="date" id="orders-date-filter" class="px-3 py-2 border rounded text-sm" onchange="filterOrders()"/>
                        </div>
                        <div class="mt-2">
                            <button onclick="clearOrdersFilter()" class="bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400 text-sm">Xóa bộ lọc</button>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-sm border overflow-hidden">
                        <div class="overflow-x-auto">
                            <table class="w-full text-sm">
                                <thead class="bg-gray-50">
                                <tr>
                                    <th class="text-left py-3 px-4">ID</th>
                                    <th class="text-left py-3 px-4">Khách hàng</th>
                                    <th class="text-left py-3 px-4">Tổng tiền</th>
                                    <th class="text-left py-3 px-4">Quầy</th>
                                    <th class="text-left py-3 px-4">Trạng thái</th>
                                    <th class="text-left py-3 px-4">Phương thức</th>
                                    <th class="text-left py-3 px-4">Thời gian</th>
                                    <th class="text-left py-3 px-4">Hành động</th>
                                </tr>
                                </thead>
                                <tbody id="orders-table-body">
                                <!-- Data will be loaded here -->
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
                            <p class="text-gray-600">Tất cả quầy</p>
                        </div>
                        <a href="<%=contextPath%>/admin-create-stall.jsp" class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 flex items-center space-x-2">
                            <i data-lucide="plus-circle"></i><span>Thêm quầy</span>
                        </a>
                    </div>

                    <div class="bg-white rounded-lg shadow-sm border overflow-hidden">
                        <div class="overflow-x-auto">
                            <table class="w-full text-sm">
                                <thead class="bg-gray-50">
                                <tr>
                                    <th class="text-left py-3 px-4">ID</th>
                                    <th class="text-left py-3 px-4">Tên quầy</th>
                                    <th class="text-left py-3 px-4">Mô tả</th>
                                    <th class="text-left py-3 px-4">Người quản lý</th>
                                    <th class="text-left py-3 px-4">Trạng thái</th>
                                    <th class="text-left py-3 px-4">Hành động</th>
                                </tr>
                                </thead>
                                <tbody>
                                <!-- Stalls will be loaded here via JavaScript -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Reports -->
                <div data-view="reports" class="space-y-6 admin-view hidden">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">Báo cáo & Thống kê</h1>
                        <p class="text-gray-600">Báo cáo doanh thu và món bán chạy</p>
                    </div>

                    <div class="bg-white p-4 rounded-lg shadow-sm border">
                        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
                            <select id="reports-period" class="px-3 py-2 border rounded text-sm" onchange="updateReportDates()">
                                <option value="today">Hôm nay</option>
                                <option value="week">7 ngày qua</option>
                                <option value="month">30 ngày qua</option>
                                <option value="custom">Tùy chọn</option>
                            </select>
                            <input type="date" id="reports-start-date" class="px-3 py-2 border rounded text-sm" onchange="updateReportPeriod()"/>
                            <input type="date" id="reports-end-date" class="px-3 py-2 border rounded text-sm" onchange="updateReportPeriod()"/>
                            <button onclick="loadReports()" class="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 text-sm">Tải báo cáo</button>
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
                            <h4 class="font-semibold mb-2">Tổng doanh thu (đơn đã hoàn thành)</h4>
                            <p class="text-2xl font-bold text-green-600" id="total-revenue">0đ</p>
                            <p class="text-sm text-gray-500 mt-1">Từ tất cả các quầy</p>
                        </div>
                        <div class="bg-white p-4 rounded-lg shadow-sm border">
                            <h4 class="font-semibold mb-2">Tổng đơn hàng</h4>
                            <p class="text-2xl font-bold text-blue-600" id="total-orders">0</p>
                            <p class="text-sm text-gray-500 mt-1">Tất cả đơn hàng</p>
                        </div>
                        <div class="bg-white p-4 rounded-lg shadow-sm border">
                            <h4 class="font-semibold mb-2">Món bán chạy nhất</h4>
                            <p class="text-2xl font-bold text-purple-600" id="top-food">-</p>
                            <p class="text-sm text-gray-500 mt-1">Top 1 món ăn</p>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.6/dist/chart.umd.min.js"></script>
<script>
    var URL_ADMIN = '<%=contextPath%>';
</script>
<script src="${pageContext.request.contextPath}/static/admin.js"></script>
</body>
</html>
