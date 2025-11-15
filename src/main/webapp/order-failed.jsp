<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Security check: Redirect to login if not authenticated
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    String errorMessage = (String) request.getAttribute("errorMessage");
    if (errorMessage == null) {
        errorMessage = request.getParameter("error");
        if (errorMessage == null) {
            errorMessage = "Đã xảy ra lỗi khi đặt hàng. Vui lòng thử lại sau.";
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt hàng thất bại - Canteen Đại Học</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>

<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<section class="py-12 bg-gradient-to-b from-gray-50 to-red-50 min-h-screen flex items-center">
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    
    <!-- Error Animation -->
    <div class="text-center mb-8">
      <div class="inline-flex items-center justify-center w-24 h-24 bg-red-100 rounded-full mb-4">
        <svg class="w-12 h-12 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
      </div>
      <h1 class="text-3xl font-bold text-gray-800 mb-2">Đặt hàng thất bại! 😔</h1>
      <p class="text-gray-600">Rất tiếc, đã xảy ra lỗi khi xử lý đơn hàng của bạn.</p>
    </div>

    <!-- Error Details Card -->
    <div class="bg-white rounded-xl shadow-lg overflow-hidden">
      <div class="bg-gradient-to-r from-red-600 to-red-700 text-white px-6 py-4">
        <h2 class="text-xl font-semibold">Thông tin lỗi</h2>
      </div>
      
      <div class="p-6 space-y-4">
        <div class="bg-red-50 border-l-4 border-red-500 p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm text-red-700">
                <%= errorMessage %>
              </p>
            </div>
          </div>
        </div>
        
        <div class="pt-4 border-t border-gray-200">
          <h3 class="font-semibold text-gray-800 mb-2">Có thể do:</h3>
          <ul class="space-y-2 text-gray-600 text-sm list-disc list-inside">
            <li>Lỗi kết nối mạng hoặc máy chủ</li>
            <li>Giỏ hàng trống hoặc đã hết hàng</li>
            <li>Thông tin đơn hàng không hợp lệ</li>
            <li>Lỗi hệ thống tạm thời</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Information Box -->
    <div class="mt-6 bg-yellow-50 border border-yellow-200 rounded-lg p-6">
      <h3 class="font-semibold text-yellow-900 mb-2">💡 Gợi ý:</h3>
      <ul class="space-y-2 text-yellow-800 text-sm">
        <li>• Vui lòng kiểm tra lại giỏ hàng của bạn</li>
        <li>• Đảm bảo bạn đã nhập đầy đủ thông tin giao hàng</li>
        <li>• Thử lại sau vài phút</li>
        <li>• Nếu vấn đề vẫn tiếp tục, vui lòng liên hệ với chúng tôi</li>
      </ul>
    </div>

    <!-- Action Buttons -->
    <div class="mt-8 flex flex-col sm:flex-row gap-4">
      <a href="cart" 
         class="flex-1 bg-blue-600 text-white text-center py-3 px-6 rounded-lg hover:bg-blue-700 transition font-medium">
        Quay lại giỏ hàng
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
  console.log('Order placement failed: <%= errorMessage %>');
</script>

</body>
</html>

