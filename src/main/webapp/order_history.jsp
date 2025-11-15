<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.OrderDAO" %>
<%@ page import="model.Order_FoodDAO" %>
<%@ page import="model.Page" %>
<%@ page import="model.PageRequest" %>

<%
    List<OrderDAO> orders = (List<OrderDAO>) request.getAttribute("orders");
    Map<Integer, List<Order_FoodDAO>> orderFoodMap = (Map<Integer, List<Order_FoodDAO>>) request.getAttribute("orderFoodMap");
    String userRole = (String) request.getAttribute("userRole");
    
    // For admin pagination
    Page<OrderDAO> pageOrder = (Page<OrderDAO>) request.getAttribute("pageOrder");
    PageRequest pageReq = (PageRequest) request.getAttribute("pageReq");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Lịch sử đặt hàng - Canteen Đại Học</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<!-- Main Content -->
<section class="py-8 bg-gradient-to-b from-gray-50 to-blue-50 min-h-screen">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  
      <h2 class="text-3xl font-bold text-center mb-6 text-gray-800">
          📋 
          <% if ("admin".equals(userRole)) { %>
              Tất cả đơn hàng (Admin)
          <% } else if ("stall".equals(userRole)) { %>
              Đơn hàng của quầy
          <% } else { %>
              Lịch sử đặt hàng của bạn
          <% } %>
      </h2>

      <% if (orders == null || orders.isEmpty()) { %>
          <div class="bg-white rounded-lg shadow-md p-8 text-center">
              <i data-lucide="shopping-bag" class="w-16 h-16 mx-auto text-gray-400 mb-4"></i>
              <p class="text-gray-600 text-lg">Chưa có đơn hàng nào.</p>
              <a href="home" class="inline-block mt-4 bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition">
                  Đặt hàng ngay
              </a>
          </div>
      <% } else { %>
          <div class="space-y-4">
              <% for (OrderDAO order : orders) { 
                  List<Order_FoodDAO> items = orderFoodMap.get(order.getId());
                  
                  // Status badge colors
                  String statusClass = "";
                  String statusText = "";
                  switch(order.getStatus() != null ? order.getStatus() : "new_order") {
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
              <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition">
                  <!-- Order Header -->
                  <div class="bg-gradient-to-r from-blue-600 to-indigo-600 text-white p-4">
                      <div class="flex justify-between items-center flex-wrap gap-2">
                          <div>
                              <h3 class="text-lg font-semibold">Đơn hàng #<%= order.getId() %></h3>
                              <p class="text-sm text-blue-100"><%= order.getCreatedAt() != null ? order.getCreatedAt().toString() : "N/A" %></p>
                          </div>
                          <div class="text-right">
                              <div class="<%= statusClass %> px-3 py-1 rounded-full text-sm font-semibold inline-block">
                                  <%= statusText %>
                              </div>
                          </div>
                      </div>
                  </div>
                  
                  <!-- Order Details -->
                  <div class="p-4">
                      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                          <div>
                              <p class="text-sm text-gray-600">
                                  <span class="font-semibold">Tổng tiền:</span> 
                                  <span class="text-blue-600 font-bold text-lg">
                                      <%= String.format("%,.0f", order.getTotalPrice() != null ? order.getTotalPrice() : 0.0) %>đ
                                  </span>
                              </p>
                              <p class="text-sm text-gray-600">
                                  <span class="font-semibold">Thanh toán:</span> 
                                  <%= order.getPaymentMethod() != null ? order.getPaymentMethod() : "Chưa có thông tin" %>
                              </p>
                          </div>
                          <div>
                              <% if ("admin".equals(userRole) || "stall".equals(userRole)) { %>
                              <p class="text-sm text-gray-600">
                                  <span class="font-semibold">Khách hàng ID:</span> <%= order.getUserId() %>
                              </p>
                              <% } %>
                              <p class="text-sm text-gray-600">
                                  <span class="font-semibold">Địa chỉ giao:</span> 
                                  <%= order.getDeliveryLocation() != null ? order.getDeliveryLocation() : "Chưa có thông tin" %>
                              </p>
                          </div>
                      </div>
                      
                      <!-- Order Items -->
                      <% if (items != null && !items.isEmpty()) { %>
                      <div class="border-t pt-4">
                          <h4 class="font-semibold text-gray-800 mb-3">Chi tiết món ăn:</h4>
                          <div class="space-y-2">
                              <% for (Order_FoodDAO item : items) { %>
                              <div class="flex items-center gap-4 bg-gray-50 p-3 rounded-lg">
                                  <% if (item.getImage() != null && !item.getImage().isEmpty()) { %>
                                  <img src="<%= item.getImage() %>" 
                                       alt="<%= item.getName() != null ? item.getName() : "Món ăn" %>"
                                       class="w-16 h-16 object-cover rounded-lg">
                                  <% } %>
                                  <div class="flex-1">
                                      <p class="font-medium text-gray-800">
                                          <%= item.getName() != null && !item.getName().isEmpty() ? item.getName() : "Món ăn ID: " + item.getFoodId() %>
                                      </p>
                                      <p class="text-sm text-gray-600">Số lượng: <%= item.getQuantity() %></p>
                                  </div>
                                  <div class="text-right">
                                      <p class="text-blue-600 font-semibold">
                                          <%= String.format("%,.0f", item.getPriceAtOrder() != null ? item.getPriceAtOrder() : 0.0) %>đ
                                      </p>
                                      <p class="text-xs text-gray-500">
                                          Tổng: <%= String.format("%,.0f", (item.getPriceAtOrder() != null ? item.getPriceAtOrder() : 0.0) * item.getQuantity()) %>đ
                                      </p>
                                  </div>
                              </div>
                              <% } %>
                          </div>
                      </div>
                      <% } %>
                  </div>
              </div>
              <% } %>
          </div>
          
          <!-- Pagination for Admin -->
          <% if ("admin".equals(userRole) && pageOrder != null && pageReq != null) { 
              int totalPage = pageOrder.getTotalPage();
              String keyword = pageReq.getKeyword();
              if (totalPage > 1) {
          %>
          <div class="flex justify-center mt-6 space-x-2">
              <% for (int i = 1; i <= totalPage; i++) { %>
                <a href="order-history?page=<%= i %>&keyword=<%= keyword != null ? keyword : "" %>"
                   class="px-3 py-1 rounded-full border text-sm <%= (i == pageReq.getPage()) ? "bg-blue-600 text-white" : "bg-white hover:bg-blue-100" %>">
                  <%= i %>
                </a>
              <% } %>
          </div>
          <% } } %>
      <% } %>
  </div>
</section>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />

<script>
  document.addEventListener('DOMContentLoaded', () => {
    lucide.createIcons();
  });
</script>
</body>
</html>
