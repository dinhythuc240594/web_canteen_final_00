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
    <link rel="stylesheet" href="<%=contextPath%>/assets/css/style.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background: #fafafa;
        }
        h2 {
            text-align: center;
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 30px 0;
            background: white;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        th, td {
            padding: 12px;
            border-bottom: 1px solid #ddd;
            text-align: left;
        }
        th {
            background: #f0f0f0;
        }
        tr:hover {
            background: #f9f9f9;
        }
        .order-block {
            border: 1px solid #ccc;
            margin-bottom: 30px;
            border-radius: 6px;
            background: #fff;
            padding: 16px;
        }
        .food-list {
            margin-top: 10px;
            border-top: 1px solid #eee;
        }
        .food-list td {
            padding: 6px 12px;
        }
        .status {
            font-weight: bold;
        }
        .status.PENDING { color: orange; }
        .status.CONFIRMED { color: blue; }
        .status.DELIVERED { color: green; }
        .status.CANCELLED { color: red; }
        a.back {
            display: inline-block;
            margin-bottom: 20px;
            text-decoration: none;
            color: #007bff;
        }
        .empty {
            text-align: center;
            color: #777;
            margin-top: 100px;
        }
    </style>
</head>
<body>
    <h2>Lịch sử đơn hàng của bạn</h2>

    <a class="back" href="<%=contextPath%>/home">← Quay lại trang chủ</a>

    <%
        if (orders == null || orders.isEmpty()) {
    %>
        <div class="empty">
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
            <p><strong>Trạng thái:</strong> <span class="status <%=order.getStatus()%>"><%= order.getStatus() %></span></p>

            <table class="food-list">
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
