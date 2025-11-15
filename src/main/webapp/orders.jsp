<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.OrderDAO, model.Order_FoodDAO" %>
<%
    // Security check: Redirect to login if not authenticated
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    List<OrderDAO> orders = (List<OrderDAO>) request.getAttribute("orders");
    String contextPath = request.getContextPath();
    Map<Integer, List<Order_FoodDAO>> orderFoodMap = (Map<Integer, List<Order_FoodDAO>>)request.getAttribute("orderFoodMap");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch sử đơn hàng</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="order-history-body">
    <h2 class="order-history-h2">Lịch sử đơn hàng của bạn</h2>

    <a class="back-link" href="<%=contextPath%>/home">← Quay lại trang chủ</a>

    <%
        if (orders == null || orders.isEmpty()) {
    %>
        <div class="empty-message">
            <p>Bạn chưa có đơn hàng nào.</p>
            <a href="<%=contextPath%>/menu">Đặt món ngay →</a>
        </div>
    <%
        } else {
            for (OrderDAO order : orders) {
    %>
        <div class="order-block">
            <h3>Đơn hàng #<%= order.getId() %></h3>
            <p><strong>Ngày đặt:</strong> <%= order.getCreatedAt() %></p>
            <p><strong>Địa chỉ giao hàng:</strong> <%= order.getDeliveryLocation() %></p>
            <p><strong>Phương thức thanh toán:</strong> <%= order.getPaymentMethod() %></p>
            <p><strong>Tổng tiền:</strong> <%= String.format("%,.0f", order.getTotalPrice()) %>₫</p>
            <p><strong>Trạng thái:</strong> <span class="order-status <%=order.getStatus()%>"><%= order.getStatus() %></span></p>

            <table class="order-history-table food-list">
                <thead>
                    <tr>
                        <th>Tên món</th>
                        <th>Số lượng</th>
                        <th>Đơn giá</th>
                        <th>Thành tiền</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    List<Order_FoodDAO> foods = orderFoodMap.get(order.getId());
                        if (foods != null) {
                            for (Order_FoodDAO f : foods) {
                    %>
                    <tr>
                        <td><%= f.getName() %></td>
                        <td><%= f.getQuantity() %></td>
                        <td><%= String.format("%,.0f", f.getPriceAtOrder()) %>₫</td>
                        <td><%= String.format("%,.0f", f.getPriceAtOrder() * f.getQuantity()) %>₫</td>
                    </tr>
                    <%
                            }
                        }
                    %>
                </tbody>
            </table>
        </div>
    <%
            }
        }
    %>
</body>
</html>
