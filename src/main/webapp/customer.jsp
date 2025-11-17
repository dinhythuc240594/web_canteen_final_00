<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Security check: Only customer can access this page
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("type_user");
    
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    if (!"customer".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    
    // Get data from servlet
    model.UserDAO user = (model.UserDAO) request.getAttribute("user");
    int totalOrders = (int) request.getAttribute("totalOrders");
    double totalSpent = (double) request.getAttribute("totalSpent");
    int pendingOrders = (int) request.getAttribute("pendingOrders");
    int completedOrders = (int) request.getAttribute("completedOrders");
    java.util.List<model.OrderDAO> recentOrders = (java.util.List<model.OrderDAO>) request.getAttribute("recentOrders");
    java.util.List<model.OrderDAO> allOrders = (java.util.List<model.OrderDAO>) request.getAttribute("allOrders");
    
    if (recentOrders == null) recentOrders = new java.util.ArrayList<>();
    if (allOrders == null) allOrders = new java.util.ArrayList<>();
    
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
    <title>Trang cá nhân - Canteen ĐH</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<main class="min-h-screen">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div class="mb-6 space-y-3">
            <h1 class="text-3xl font-bold text-gray-800">Trang cá nhân</h1>
            <p class="text-gray-600 mt-2">Xin chào, <%= user != null ? user.getFull_name() : username %>!</p>
            <% if (profileSuccess != null) { %>
                <div class="rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-800">
                    <%= profileSuccess %>
                </div>
            <% } %>
        </div>

        <!-- Statistics Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
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
                        <p class="text-sm text-gray-600">Tổng chi tiêu</p>
                        <p class="text-2xl font-bold text-green-600"><%= String.format("%,.0f", totalSpent) %>đ</p>
                    </div>
                    <i data-lucide="dollar-sign" class="text-green-600"></i>
                </div>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-sm border">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-600">Đơn đang xử lý</p>
                        <p class="text-2xl font-bold text-yellow-600"><%= pendingOrders %></p>
                    </div>
                    <i data-lucide="clock" class="text-yellow-600"></i>
                </div>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-sm border">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-600">Đơn hoàn thành</p>
                        <p class="text-2xl font-bold text-purple-600"><%= completedOrders %></p>
                    </div>
                    <i data-lucide="check-circle" class="text-purple-600"></i>
                </div>
            </div>
        </div>

        <!-- User Information -->
        <div class="bg-white p-6 rounded-lg shadow-sm border mb-6">
            <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-4">
                <div>
                    <h2 class="text-xl font-bold text-gray-800">Thông tin tài khoản</h2>
<%--                    <p class="text-gray-500 text-sm mt-1">Thông tin cá nhân và liên hệ của bạn</p>--%>
                </div>
                <div class="flex flex-wrap gap-2">
                    <a href="<%= contextPath %>/customer?view=edit" class="inline-flex items-center justify-center rounded-md border border-blue-600 px-4 py-2 text-sm font-medium text-blue-600 hover:bg-blue-50">
                        <i data-lucide="edit" class="w-4 h-4 mr-2"></i>
                        Chỉnh sửa thông tin
                    </a>
                    <a href="<%= contextPath %>/change-password" class="inline-flex items-center justify-center rounded-md border border-amber-500 px-4 py-2 text-sm font-medium text-amber-600 hover:bg-amber-50">
                        <i data-lucide="key" class="w-4 h-4 mr-2"></i>
                        Đổi mật khẩu
                    </a>
                </div>
            </div>
            <div class="flex items-center gap-4 mb-6">
                <img src="<%= avatarUrl %>" alt="Ảnh đại diện" class="w-20 h-20 rounded-full object-cover border border-gray-200 shadow-sm" />
                <div>
<%--                    <p class="text-sm text-gray-600">Ảnh đại diện hiện tại</p>--%>
                    <p class="text-lg font-semibold text-gray-800"><%= user != null ? user.getFull_name() : username %></p>
<%--                    <p class="text-sm text-gray-500">Nhấn “Chỉnh sửa thông tin” để cập nhật ảnh và thông tin cá nhân</p>--%>
                </div>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <p class="text-sm text-gray-600">Tên đăng nhập</p>
                    <p class="text-lg font-semibold text-gray-800"><%= user != null ? user.getUsername() : username %></p>
                </div>
                <div>
                    <p class="text-sm text-gray-600">Họ và tên</p>
                    <p class="text-lg font-semibold text-gray-800"><%= user != null ? user.getFull_name() : "N/A" %></p>
                </div>
                <div>
                    <p class="text-sm text-gray-600">Email</p>
                    <p class="text-lg font-semibold text-gray-800"><%= user != null && user.getEmail() != null ? user.getEmail() : "N/A" %></p>
                </div>
                <div>
                    <p class="text-sm text-gray-600">Số điện thoại</p>
                    <p class="text-lg font-semibold text-gray-800"><%= user != null && user.getPhone() != null ? user.getPhone() : "N/A" %></p>
                </div>
            </div>
        </div>
        
        <!-- Recent Orders -->
        <div class="bg-white p-6 rounded-lg shadow-sm border">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-xl font-bold text-gray-800">Đơn hàng gần đây</h2>
                <a href="<%=contextPath%>/order-history" class="text-blue-600 hover:text-blue-800 text-sm font-medium">
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
                            <a href="<%=contextPath%>/order-history?orderId=<%= order.getId() %>" 
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

