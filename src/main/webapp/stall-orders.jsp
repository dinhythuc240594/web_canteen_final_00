<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.OrderDAO, model.Order_FoodDAO, model.StallDAO" %>
<%
    // Security check: Only stall and admin can access this page
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("type_user");
    
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    if (!"stall".equals(userRole) && !"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    
    List<OrderDAO> orders = (List<OrderDAO>) request.getAttribute("orders");
    Map<Integer, List<Order_FoodDAO>> orderFoodMap = (Map<Integer, List<Order_FoodDAO>>) request.getAttribute("orderFoodMap");
    String contextPath = request.getContextPath();
    String selectedStatus = request.getParameter("status") != null ? request.getParameter("status") : "all";
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý đơn hàng - Quầy</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<main class="min-h-screen">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div class="mb-6">
            <h1 class="text-2xl font-bold text-gray-800">Quản lý đơn hàng</h1>
            <p class="text-gray-600">Cập nhật trạng thái đơn hàng của quầy</p>
        </div>

        <!-- Filter -->
        <div class="mb-6 bg-white p-4 rounded-lg shadow-sm border">
            <label class="block text-sm font-medium text-gray-700 mb-2">Lọc theo trạng thái:</label>
            <div class="flex flex-wrap gap-2">
                <button onclick="filterOrders('all')" class="filter-btn <%= "all".equals(selectedStatus) ? "active" : "" %>" data-status="all">
                    Tất cả
                </button>
                <button onclick="filterOrders('new_order')" class="filter-btn <%= "new_order".equals(selectedStatus) ? "active" : "" %>" data-status="new_order">
                    Đơn mới
                </button>
                <button onclick="filterOrders('confirmed')" class="filter-btn <%= "confirmed".equals(selectedStatus) ? "active" : "" %>" data-status="confirmed">
                    Đã xác nhận
                </button>
                <button onclick="filterOrders('in_delivery')" class="filter-btn <%= "in_delivery".equals(selectedStatus) ? "active" : "" %>" data-status="in_delivery">
                    Đang giao
                </button>
                <button onclick="filterOrders('delivered')" class="filter-btn <%= "delivered".equals(selectedStatus) ? "active" : "" %>" data-status="delivered">
                    Đã giao
                </button>
            </div>
        </div>

        <!-- Orders List -->
        <div class="space-y-4">
            <% 
            if (orders == null || orders.isEmpty()) {
            %>
                <div class="bg-white rounded-lg shadow-sm border p-8 text-center">
                    <p class="text-gray-500">Không có đơn hàng nào.</p>
                </div>
            <%
            } else {
                for (OrderDAO order : orders) {
                    List<Order_FoodDAO> foods = orderFoodMap.get(order.getId());
                    String statusClass = "";
                    String statusText = "";
                    
                    switch(order.getStatus()) {
                        case "new_order":
                            statusClass = "bg-yellow-100 text-yellow-800";
                            statusText = "Đơn mới";
                            break;
                        case "confirmed":
                            statusClass = "bg-blue-100 text-blue-800";
                            statusText = "Đã xác nhận";
                            break;
                        case "in_delivery":
                            statusClass = "bg-purple-100 text-purple-800";
                            statusText = "Đang giao";
                            break;
                        case "delivered":
                            statusClass = "bg-green-100 text-green-800";
                            statusText = "Đã giao";
                            break;
                        default:
                            statusClass = "bg-gray-100 text-gray-800";
                            statusText = order.getStatus();
                    }
            %>
            <div class="bg-white rounded-lg shadow-sm border p-6">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <h3 class="text-lg font-semibold text-gray-800">Đơn hàng #<%= order.getId() %></h3>
                        <p class="text-sm text-gray-600">Ngày đặt: <%= order.getCreatedAt() %></p>
                        <p class="text-sm text-gray-600">Khách hàng ID: <%= order.getUserId() %></p>
                        <p class="text-sm text-gray-600">Địa chỉ: <%= order.getDeliveryLocation() %></p>
                    </div>
                    <span class="px-3 py-1 rounded-full text-sm font-medium <%= statusClass %>">
                        <%= statusText %>
                    </span>
                </div>

                <!-- Order Items -->
                <div class="mb-4">
                    <h4 class="font-medium text-gray-700 mb-2">Món ăn:</h4>
                    <div class="bg-gray-50 rounded p-3">
                        <% 
                        if (foods != null) {
                            for (Order_FoodDAO food : foods) {
                        %>
                        <div class="flex justify-between py-1">
                            <span class="text-gray-700"><%= food.getName() %> x <%= food.getQuantity() %></span>
                            <span class="text-gray-900 font-medium"><%= String.format("%,.0f", food.getPriceAtOrder() * food.getQuantity()) %>₫</span>
                        </div>
                        <% 
                            }
                        }
                        %>
                    </div>
                </div>

                <div class="flex justify-between items-center pt-4 border-t">
                    <div class="text-lg font-bold text-gray-900">
                        Tổng: <%= String.format("%,.0f", order.getTotalPrice()) %>₫
                    </div>
                    
                    <!-- Status Update Buttons -->
                    <div class="flex space-x-2">
                        <% if ("new_order".equals(order.getStatus())) { %>
                        <button onclick="updateOrderStatus(<%= order.getId() %>, 'confirmed')" 
                                class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors">
                            Xác nhận
                        </button>
                        <% } else if ("confirmed".equals(order.getStatus())) { %>
                        <button onclick="updateOrderStatus(<%= order.getId() %>, 'in_delivery')" 
                                class="px-4 py-2 bg-purple-600 text-white rounded hover:bg-purple-700 transition-colors">
                            Bắt đầu giao
                        </button>
                        <% } else if ("in_delivery".equals(order.getStatus())) { %>
                        <button onclick="updateOrderStatus(<%= order.getId() %>, 'delivered')" 
                                class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 transition-colors">
                            Hoàn thành
                        </button>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
                }
            }
            %>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />

<style>
    .filter-btn {
        padding: 0.5rem 1rem;
        border: 1px solid #e5e7eb;
        border-radius: 0.375rem;
        background-color: white;
        color: #6b7280;
        font-size: 0.875rem;
        cursor: pointer;
        transition: all 0.2s;
    }
    
    .filter-btn:hover {
        background-color: #f3f4f6;
    }
    
    .filter-btn.active {
        background-color: #3b82f6;
        color: white;
        border-color: #3b82f6;
    }
</style>

<script>
    function filterOrders(status) {
        const url = new URL(window.location.href);
        if (status === 'all') {
            url.searchParams.delete('status');
        } else {
            url.searchParams.set('status', status);
        }
        window.location.href = url.toString();
    }
    
    function updateOrderStatus(orderId, newStatus) {
        if (!confirm('Bạn có chắc chắn muốn cập nhật trạng thái đơn hàng?')) {
            return;
        }
        
        fetch('<%=contextPath%>/order', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                'action': 'updateStatus',
                'orderId': orderId,
                'status': newStatus
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Cập nhật trạng thái thành công!');
                window.location.reload();
            } else {
                alert('Lỗi: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Có lỗi xảy ra khi cập nhật trạng thái');
        });
    }
    
    document.addEventListener('DOMContentLoaded', function() {
        lucide.createIcons();
    });
</script>
</body>
</html>

