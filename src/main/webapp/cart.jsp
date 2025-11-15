<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.Order_FoodDAO" %>

<%
//    // Security check: Redirect to login if not authenticated
    String username = (String) session.getAttribute("username");
//    if (username == null) {
//        response.sendRedirect(request.getContextPath() + "/login");
//        return;
//    }
    
    // Lấy thông tin người dùng và giỏ hàng từ session
    List<Order_FoodDAO> cart = (List<Order_FoodDAO>) session.getAttribute("cart");
    if (cart == null) {
        cart = new ArrayList<>();
        session.setAttribute("cart", cart);
    }
    
    int stallId = (int) session.getAttribute("stallId");

    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Giỏ hàng của bạn - Canteen Đại Học</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>

<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />
<section class="py-8 bg-gradient-to-b from-gray-50 to-blue-50 min-h-screen">
  <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
  
      <h2 class="text-3xl font-bold text-center mb-6 text-gray-800">🛒 Giỏ hàng của bạn</h2>

      <% if (error != null) { %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4 text-center">
          <%= error.equals("empty_cart") ? "Giỏ hàng đang trống!" :
              error.equals("not_logged_in") ? "Bạn cần đăng nhập trước khi thanh toán!" :
              error.equals("empty_address") ? "Vui lòng nhập địa chỉ giao hàng!" :
              error.equals("server_error") ? "Có lỗi xảy ra trên máy chủ, vui lòng thử lại!" :
              "Có lỗi xảy ra, vui lòng thử lại!" %>
        </div>
      <% } else if (success != null) { %>
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4 text-center">
          Thanh toán thành công! Đơn hàng của bạn đã được ghi nhận.
        </div>
      <% } %>
      
      <% if (cart.isEmpty()) { %>
        <div class="bg-white rounded-xl shadow p-8 text-center">
          <p class="text-gray-500 text-lg mb-4">Giỏ hàng của bạn đang trống</p>
          <a href="home" class="inline-block bg-blue-600 text-white px-6 py-2 rounded-full hover:bg-blue-700 transition">
            Tiếp tục mua sắm
          </a>
        </div>
      <% } else { %>
        <div class="bg-white rounded-xl shadow overflow-hidden">
          <div class="overflow-x-auto">
            <table class="w-full">
              <thead class="bg-gray-100">
                <tr>
                  <th class="px-4 py-3 text-left text-sm font-semibold text-gray-700">Món ăn</th>
                  <th class="px-4 py-3 text-right text-sm font-semibold text-gray-700">Giá</th>
                  <th class="px-4 py-3 text-center text-sm font-semibold text-gray-700">Số lượng</th>
                  <th class="px-4 py-3 text-right text-sm font-semibold text-gray-700">Tổng</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <% 
                  double total = 0;
                  for (Order_FoodDAO item : cart) {
                    double itemTotal = item.getPriceAtOrder() * item.getQuantity();
                    total += itemTotal;
                %>
                <tr class="hover:bg-gray-50">
                  <td class="px-4 py-3">
                    <div class="flex items-center space-x-3">
                      <img src="<%= item.getImage() != null ? item.getImage() : "/images/default-food.jpg" %>" 
                           alt="<%= item.getName() %>" 
                           class="w-16 h-16 object-cover rounded">
                      <span class="font-medium text-gray-800"><%= item.getName() %></span>
                    </div>
                  </td>
                  <td class="px-4 py-3 text-right text-gray-700">
                    <%= String.format("%,.0f", item.getPriceAtOrder()) %>đ
                  </td>
                  <td class="px-4 py-3 text-center">
                    <span class="inline-block bg-gray-100 px-4 py-1 rounded font-medium">
                      <%= item.getQuantity() %>
                    </span>
                  </td>
                  <td class="px-4 py-3 text-right font-semibold text-blue-600">
                    <%= String.format("%,.0f", itemTotal) %>đ
                  </td>
                </tr>
                <% } %>
              </tbody>
              <tfoot class="bg-gray-50">
                <tr>
                  <td colspan="3" class="px-4 py-4 text-right font-bold text-gray-800">Tổng cộng:</td>
                  <td class="px-4 py-4 text-right font-bold text-blue-600 text-xl">
                    <%= String.format("%,.0f", total) %>đ
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>

        <div class="mt-6 bg-white rounded-xl shadow p-6">
          <h3 class="text-lg font-semibold text-gray-800 mb-4">Thông tin giao hàng</h3>
          <form action="${pageContext.request.contextPath}/cart" method="post" id="checkoutForm">
            <input type="hidden" name="action" value="checkout">
            <input type="hidden" name="stallId" value="<%= stallId > 0 ? stallId : "" %>">
            
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Địa chỉ giao hàng *</label>
                <input type="text" name="address" 
                       placeholder="Nhập địa chỉ giao hàng của bạn" 
                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-400 outline-none" 
                       required>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Phương thức thanh toán</label>
                <select name="payment" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-400 outline-none">
                  <option value="COD">Thanh toán khi nhận hàng (COD)</option>
                  <option value="Banking">Chuyển khoản ngân hàng</option>
                </select>
              </div>
              
              <div class="flex space-x-3 pt-4">
                <a href="home" class="flex-1 bg-gray-200 text-gray-700 text-center py-3 rounded-lg hover:bg-gray-300 transition font-medium">
                  ← Tiếp tục mua sắm
                </a>
                <button type="submit" class="flex-1 bg-blue-600 text-white py-3 rounded-lg hover:bg-blue-700 transition font-medium">
                  Đặt hàng ngay
                </button>
              </div>
            </div>
          </form>
        </div>
      <% } %>
  </div>
</section>
<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />

<script>
  // Check if user is logged in before checkout
  document.getElementById('checkoutForm')?.addEventListener('submit', function(e) {
    <% if (username == null) { %>
      e.preventDefault();
      alert('Vui lòng đăng nhập để thanh toán.');
      window.location.href = 'login';
    <% } else { %>
      // Clear localStorage cart when submitting checkout
      localStorage.removeItem('cart');
      localStorage.removeItem('cartStallId');
    <% } %>
  });
  
  // Always ensure cart is cleared from localStorage if session cart is empty
  <% if (cart.isEmpty()) { %>
    localStorage.removeItem('cart');
    localStorage.removeItem('cartStallId');
    
    // Update cart count in header
    const cartCountEl = document.getElementById('cart-count');
    if (cartCountEl) {
      cartCountEl.textContent = '0';
      cartCountEl.classList.add('hidden');
    }
  <% } %>
  
  // Initialize cart display when page loads
  window.addEventListener('DOMContentLoaded', function() {
    // If cart was just cleared after checkout, ensure localStorage is also cleared
    <% if (cart.isEmpty()) { %>
      localStorage.removeItem('cart');
      localStorage.removeItem('cartStallId');
    <% } %>
  });
</script>
</body>
</html>