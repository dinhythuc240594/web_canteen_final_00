<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Security check: Only stall can access this page
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("type_user");
    
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    if (!"stall".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    
    // Get data from servlet
    model.UserDAO user = (model.UserDAO) request.getAttribute("user");
    model.StallDAO stall = (model.StallDAO) request.getAttribute("stall");
    int totalOrders = (int) request.getAttribute("totalOrders");
    double totalRevenue = (double) request.getAttribute("totalRevenue");
    int newOrders = (int) request.getAttribute("newOrders");
    int confirmedOrders = (int) request.getAttribute("confirmedOrders");
    int inDeliveryOrders = (int) request.getAttribute("inDeliveryOrders");
    int deliveredOrders = (int) request.getAttribute("deliveredOrders");
    java.util.List<model.OrderDAO> recentOrders = (java.util.List<model.OrderDAO>) request.getAttribute("recentOrders");
    java.util.List<model.OrderDAO> pendingOrders = (java.util.List<model.OrderDAO>) request.getAttribute("pendingOrders");
    
    if (recentOrders == null) recentOrders = new java.util.ArrayList<>();
    if (pendingOrders == null) pendingOrders = new java.util.ArrayList<>();
    
    String contextPath = request.getContextPath();
    String rawAvatarPath = (user != null && user.getAvatar() != null && !user.getAvatar().isBlank())
            ? user.getAvatar()
            : "static/img/default-avatar.svg";
    String avatarUrl = rawAvatarPath.startsWith("http") ? rawAvatarPath : contextPath + "/" + rawAvatarPath;
    String profileSuccess = (String) request.getAttribute("profileSuccess");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý quầy - Canteen ĐH</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<main class="min-h-screen">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div class="mb-6 space-y-3">
            <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div class="flex items-center gap-4">
                    <img src="<%= avatarUrl %>" alt="Avatar" class="w-16 h-16 rounded-full object-cover border border-gray-200 shadow-sm" />
                    <div>
                        <h1 class="text-3xl font-bold text-gray-800">Quản lý quầy</h1>
                        <p class="text-gray-600 mt-2">Xin chào, <%= user != null ? user.getFull_name() : username %>!</p>
                    </div>
                </div>
                <a href="<%= contextPath %>/stall-profile" class="inline-flex items-center justify-center rounded-md border border-blue-600 px-4 py-2 text-sm font-medium text-blue-600 hover:bg-blue-50">
                    <i data-lucide="edit" class="w-4 h-4 mr-2"></i>
                    Chỉnh sửa thông tin
                </a>
            </div>
            <% if (profileSuccess != null) { %>
                <div class="rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-800">
                    <%= profileSuccess %>
                </div>
            <% } %>
        </div>

        <!-- Stall Information -->
        <div class="bg-white p-6 rounded-lg shadow-sm border mb-6">
            <div class="flex justify-between items-start mb-4">
                <div class="flex-1">
                    <h2 class="text-xl font-bold text-gray-800 mb-2">Thông tin quầy hàng</h2>
                    <div class="space-y-2 mb-4">
                        <div>
                            <span class="text-sm font-medium text-gray-600">Tên quầy:</span>
                            <span class="text-sm text-gray-800 ml-2"><%= stall != null ? stall.getName() : "N/A" %></span>
                        </div>
                        <% if (stall != null && stall.getDescription() != null && !stall.getDescription().isEmpty()) { %>
                        <div>
                            <span class="text-sm font-medium text-gray-600">Mô tả:</span>
                            <span class="text-sm text-gray-800 ml-2"><%= stall.getDescription() %></span>
                        </div>
                        <% } %>
                        <div>
                            <span class="text-sm font-medium text-gray-600">Trạng thái:</span>
                            <span class="px-2 py-1 rounded text-xs ml-2 <%= stall != null && stall.getIsOpen() ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800" %>">
                                <%= stall != null && stall.getIsOpen() ? "Đang mở cửa" : "Đã đóng cửa" %>
                            </span>
                        </div>
                    </div>
                    <div class="mt-4 pt-4 border-t border-gray-200">
                        <h3 class="text-lg font-semibold text-gray-800 mb-2">Người quản lý quầy</h3>
                        <div class="space-y-2">
                            <div>
                                <span class="text-sm font-medium text-gray-600">Họ tên:</span>
                                <span class="text-sm text-gray-800 ml-2"><%= user != null && user.getFull_name() != null ? user.getFull_name() : "N/A" %></span>
                            </div>
                            <div class="flex items-center gap-3">
                                <span class="text-sm font-medium text-gray-600">Tên đăng nhập:</span>
                                <div class="flex items-center gap-2 text-sm text-gray-800">
<%--                                    <img src="<%= avatarUrl %>" alt="Avatar" class="w-8 h-8 rounded-full object-cover border border-gray-200" />--%>
                                    <span><%= user != null && user.getUsername() != null ? user.getUsername() : username %></span>
                                </div>
                            </div>
                            <% if (user != null && user.getEmail() != null && !user.getEmail().isEmpty()) { %>
                            <div>
                                <span class="text-sm font-medium text-gray-600">Email:</span>
                                <span class="text-sm text-gray-800 ml-2"><%= user.getEmail() %></span>
                            </div>
                            <% } %>
                            <% if (user != null && user.getPhone() != null && !user.getPhone().isEmpty()) { %>
                            <div>
                                <span class="text-sm font-medium text-gray-600">Số điện thoại:</span>
                                <span class="text-sm text-gray-800 ml-2"><%= user.getPhone() %></span>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
                <div class="ml-6 pl-6 border-l border-gray-200 flex flex-col items-end gap-3">
                    <a href="<%=contextPath%>/foods?action=list&stallId=<%= stall != null ? stall.getId() : "" %>" 
                       class="px-4 py-2 rounded-md text-sm font-medium bg-blue-600 hover:bg-blue-700 text-white flex items-center gap-2">
                        <i data-lucide="utensils-crossed" class="w-4 h-4"></i>
                        Quản lý menu
                    </a>
                    <form method="POST" action="<%=contextPath%>/stall" class="mb-0">
                        <input type="hidden" name="action" value="toggleStatus">
                        <button type="submit" 
                                class="px-4 py-2 rounded-md text-sm font-medium <%= stall != null && stall.getIsOpen() ? "bg-red-600 hover:bg-red-700" : "bg-green-600 hover:bg-green-700" %> text-white">
                            <%= stall != null && stall.getIsOpen() ? "Đóng cửa" : "Mở cửa" %>
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4 mb-6">
            <div class="bg-white p-4 rounded-lg shadow-sm border">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-600">Tổng đơn hàng</p>
                        <p class="text-2xl font-bold text-blue-600"><%= totalOrders %></p>
                    </div>
                    <i data-lucide="package" class="text-blue-600"></i>
                </div>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-sm border">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-600">Tổng doanh thu</p>
                        <p class="text-2xl font-bold text-green-600"><%= String.format("%,.0f", totalRevenue) %>đ</p>
                    </div>
                    <i data-lucide="dollar-sign" class="text-green-600"></i>
                </div>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-sm border">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-600">Đơn mới</p>
                        <p class="text-2xl font-bold text-yellow-600"><%= newOrders %></p>
                    </div>
                    <i data-lucide="clock" class="text-yellow-600"></i>
                </div>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-sm border">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-600">Đang xử lý</p>
                        <p class="text-2xl font-bold text-purple-600"><%= confirmedOrders + inDeliveryOrders %></p>
                    </div>
                    <i data-lucide="loader" class="text-purple-600"></i>
                </div>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-sm border">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-600">Đã hoàn thành</p>
                        <p class="text-2xl font-bold text-indigo-600"><%= deliveredOrders %></p>
                    </div>
                    <i data-lucide="check-circle" class="text-indigo-600"></i>
                </div>
            </div>
        </div>

        <!-- Pending Orders -->
        <div class="bg-white p-6 rounded-lg shadow-sm border mb-6">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-xl font-bold text-gray-800">Đơn hàng cần xử lý</h2>
                <a href="<%=contextPath%>/stall-orders" class="text-blue-600 hover:text-blue-800 text-sm font-medium">
                    Xem tất cả <i data-lucide="arrow-right" class="w-4 h-4 inline"></i>
                </a>
            </div>
            <div class="overflow-x-auto">
                <% if (pendingOrders.isEmpty()) { %>
                <p class="text-gray-500 text-center py-8">Không có đơn hàng nào cần xử lý</p>
                <% } else { %>
                <table class="w-full text-sm">
                    <thead class="bg-gray-50">
                    <tr class="border-b">
                        <th class="text-left py-2 px-3">ID</th>
                        <th class="text-left py-2 px-3">Tổng tiền</th>
                        <th class="text-left py-2 px-3">Trạng thái</th>
                        <th class="text-left py-2 px-3">Thời gian</th>
                        <th class="text-left py-2 px-3">Hành động</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (model.OrderDAO order : pendingOrders) { %>
                    <tr class="border-b hover:bg-gray-50">
                        <td class="py-2 px-3">#<%= order.getId() %></td>
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
                        <td class="py-2 px-3">
                            <a href="<%=contextPath%>/stall-orders?orderId=<%= order.getId() %>" 
                               class="text-blue-600 hover:text-blue-800">
                                <i data-lucide="eye" class="w-4 h-4"></i>
                            </a>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>

        <!-- Recent Orders -->
        <div class="bg-white p-6 rounded-lg shadow-sm border">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-xl font-bold text-gray-800">Đơn hàng gần đây</h2>
                <a href="<%=contextPath%>/stall-orders" class="text-blue-600 hover:text-blue-800 text-sm font-medium">
                    Xem tất cả <i data-lucide="arrow-right" class="w-4 h-4 inline"></i>
                </a>
            </div>
            <div class="overflow-x-auto">
                <% if (recentOrders.isEmpty()) { %>
                <p class="text-gray-500 text-center py-8">Chưa có đơn hàng nào</p>
                <% } else { %>
                <table class="w-full text-sm">
                    <thead class="bg-gray-50">
                    <tr class="border-b">
                        <th class="text-left py-2 px-3">ID</th>
                        <th class="text-left py-2 px-3">Tổng tiền</th>
                        <th class="text-left py-2 px-3">Trạng thái</th>
                        <th class="text-left py-2 px-3">Thời gian</th>
                        <th class="text-left py-2 px-3">Hành động</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (model.OrderDAO order : recentOrders) { %>
                    <tr class="border-b hover:bg-gray-50">
                        <td class="py-2 px-3">#<%= order.getId() %></td>
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
                        <td class="py-2 px-3">
                            <a href="<%=contextPath%>/stall-orders?orderId=<%= order.getId() %>" 
                               class="text-blue-600 hover:text-blue-800">
                                <i data-lucide="eye" class="w-4 h-4"></i>
                            </a>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
<script>
    lucide.createIcons();
</script>
</body>
</html>

