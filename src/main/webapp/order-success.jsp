<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.OrderDAO" %>

<%

    // String username = (String) session.getAttribute("username");
    // if (username == null) {
    //     response.sendRedirect(request.getContextPath() + "/login");
    //     return;
    // }

    OrderDAO order = (OrderDAO) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt hàng thành công - Canteen Đại Học</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>

<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<section class="py-12 bg-gradient-to-b from-gray-50 to-blue-50 min-h-screen flex items-center">
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    
    <!-- Success Animation -->
    <div class="text-center mb-8">
      <div class="inline-flex items-center justify-center w-24 h-24 bg-green-100 rounded-full mb-4">
        <svg class="w-12 h-12 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
        </svg>
      </div>
      <h1 class="text-3xl font-bold text-gray-800 mb-2">Đặt hàng thành công! 🎉</h1>
      <p class="text-gray-600">Cảm ơn bạn đã đặt hàng. Đơn hàng của bạn đang được xử lý.</p>
    </div>

    <!-- Order Details Card -->
    <div class="bg-white rounded-xl shadow-lg overflow-hidden">
      <div class="bg-gradient-to-r from-blue-600 to-blue-700 text-white px-6 py-4">
        <h2 class="text-xl font-semibold">Thông tin đơn hàng</h2>
      </div>
      
      <div class="p-6 space-y-4">
        <div class="flex justify-between items-center py-3 border-b border-gray-200">
          <span class="text-gray-600 font-medium">Mã đơn hàng:</span>
          <span class="text-gray-800 font-bold">#<%= order.getId() %></span>
        </div>
        
        <div class="flex justify-between items-center py-3 border-b border-gray-200">
          <span class="text-gray-600 font-medium">Tổng tiền:</span>
          <span class="text-blue-600 font-bold text-xl"><%= String.format("%,.0f", order.getTotalPrice()) %>đ</span>
        </div>
        
        <div class="flex justify-between items-center py-3 border-b border-gray-200">
          <span class="text-gray-600 font-medium">Địa chỉ giao hàng:</span>
          <span class="text-gray-800 text-right"><%= order.getDeliveryLocation() %></span>
        </div>
        
        <div class="flex justify-between items-center py-3 border-b border-gray-200">
          <span class="text-gray-600 font-medium">Phương thức thanh toán:</span>
          <span class="text-gray-800"><%= order.getPaymentMethod() %></span>
        </div>
        
        <div class="flex justify-between items-center py-3">
          <span class="text-gray-600 font-medium">Trạng thái:</span>
          <span class="inline-block bg-yellow-100 text-yellow-800 px-3 py-1 rounded-full text-sm font-medium">
            <%= order.getStatus() %>
          </span>
        </div>
      </div>
    </div>

    <!-- Information Box -->
    <div class="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-6">
      <h3 class="font-semibold text-blue-900 mb-2">📋 Lưu ý:</h3>
      <ul class="space-y-2 text-blue-800 text-sm">
        <li>• Đơn hàng của bạn sẽ được xử lý trong vòng 15-30 phút</li>
        <li>• Bạn có thể theo dõi trạng thái đơn hàng trong mục "Lịch sử đơn hàng"</li>
        <li>• Nếu có bất kỳ thắc mắc nào, vui lòng liên hệ với chúng tôi</li>
      </ul>
    </div>

    <!-- Action Buttons -->
    <div class="mt-8 flex flex-col sm:flex-row gap-4">
      <a href="order-history" 
         class="flex-1 bg-blue-600 text-white text-center py-3 px-6 rounded-lg hover:bg-blue-700 transition font-medium">
        Xem lịch sử đơn hàng
      </a>
      <a href="home" 
         class="flex-1 bg-gray-200 text-gray-700 text-center py-3 px-6 rounded-lg hover:bg-gray-300 transition font-medium">
        Tiếp tục mua sắm
      </a>
    </div>

  </div>
</section>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />

<script>
  console.log('Order #<%= order.getId() %> placed successfully!');
</script>

</body>
</html>

