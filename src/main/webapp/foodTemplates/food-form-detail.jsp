<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dto.FoodDTO" %>
<!DOCTYPE html>
<html lang="vi">
<head>
	<title>Chi tiết món ăn</title>
	<jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<% 
	FoodDTO food = (FoodDTO) request.getAttribute("food");
	String userRole = (String) request.getAttribute("userRole");
	boolean isStallRole = "stall".equals(userRole);
%>

<% if (food != null) { %>
<section class="py-8 bg-gradient-to-b from-gray-50 to-blue-50">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="bg-white rounded-xl shadow-lg overflow-hidden">
      <div class="md:flex">
        <!-- Image Section -->
        <div class="md:w-1/2">
            <% if (food.getImage() != null && !food.getImage().isEmpty()) { %>
                <img src="<%= food.getImage() %>" alt="<%= food.getNameFood() %>" class="w-full h-64 md:h-full object-cover" />
            <% } else { %>
                <img src="${pageContext.request.contextPath}/static/img/food-thumbnail.png" alt="<%= food.getNameFood() %>" class="w-full h-64 md:h-full object-cover" />
            <% } %>
        </div>
        
        <!-- Details Section -->
        <div class="md:w-1/2 p-6 md:p-8">
          <h1 class="text-3xl font-bold text-gray-800 mb-4"><%= food.getNameFood() %></h1>
          
          <div class="space-y-4 mb-6">
            <div>
              <label class="text-sm font-semibold text-gray-600">Giá:</label>
              <p class="text-2xl font-bold text-blue-600">
                <%= String.format("%,.0f", food.getPriceFood()) %>đ
                <!-- <% if (food.getPromotion() != null && food.getPromotion() > 0) { %>
                  <span class="text-lg text-gray-500 line-through ml-2">
                    <%= String.format("%,.0f", food.getPriceAfterPromotion()) %>đ
                  </span>
                  <span class="text-sm text-red-600 ml-2">(-<%= food.getPromotion() %>% khuyến mãi)</span>
                <% } %> -->
              </p>
            </div>
            
            <!-- <div>
              <label class="text-sm font-semibold text-gray-600">Tồn kho:</label>
              <p class="text-lg <%= food.getInventoryFood() > 0 ? "text-green-600 font-semibold" : "text-red-600 font-semibold" %>">
                <%= food.getInventoryFood() %> món
              </p>
            </div> -->
            
<%--            <% if (food.getDescription() != null && !food.getDescription().isEmpty()) { %>--%>
<%--            <div>--%>
<%--              <label class="text-sm font-semibold text-gray-600">Mô tả:</label>--%>
<%--              <p class="text-gray-700 mt-1"><%= food.getDescription() %></p>--%>
<%--            </div>--%>
<%--            <% } %>--%>
          </div>
          
          <!-- Action Buttons -->
          <div class="flex flex-col sm:flex-row gap-3 mt-6">
            <% if (food.getInventoryFood() > 0) { %>
            <button onclick="addToCart(<%= food.getStallId() %>, <%= food.getId() %>, '<%= food.getNameFood().replace("'", "\\'") %>', <%= food.getPriceFood() %>, '<%= food.getImage() != null ? food.getImage().replace("'", "\\'") : "static/img/food-thumbnail.png" %>')"
                    class="flex-1 bg-blue-600 text-white py-3 px-6 rounded-lg hover:bg-blue-700 transition font-semibold text-center">
              <i data-lucide="shopping-cart" class="w-5 h-5 inline mr-2"></i>
              Thêm vào giỏ hàng
            </button>
            <% } else { %>
            <button disabled
                    class="flex-1 bg-gray-400 text-white py-3 px-6 rounded-lg cursor-not-allowed font-semibold text-center">
              Hết hàng
            </button>
            <% } %>
            
            <% if (isStallRole) { %>
            <a href="foods?id=<%= food.getId() %>&action=update" 
               class="flex-1 bg-yellow-600 text-white py-3 px-6 rounded-lg hover:bg-yellow-700 transition font-semibold text-center">
              <i data-lucide="edit" class="w-5 h-5 inline mr-2"></i>
              Sửa món ăn
            </a>
            <% } %>
          </div>
          
          <div class="mt-4">
            <a href="foods?action=list" class="text-blue-600 hover:text-blue-700 inline-flex items-center">
              <i data-lucide="arrow-left" class="w-4 h-4 mr-2"></i>
              Quay lại danh sách
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
    <% if (food.getDescription() != null && !food.getDescription().isEmpty()) { %>
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <div>
        <label class="text-sm font-semibold text-gray-600">Mô tả:</label>
        <p class="text-gray-700 mt-1"><%= food.getDescription() %></p>
    </div>
    </div>
    <% } %>
</section>
<% } else { %>
<section class="py-8">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="bg-white rounded-xl shadow-lg p-8 text-center">
      <i data-lucide="alert-circle" class="w-16 h-16 text-gray-400 mx-auto mb-4"></i>
      <h2 class="text-2xl font-bold text-gray-800 mb-4">Không tìm thấy món ăn</h2>
      <p class="text-gray-600 mb-6">Món ăn bạn đang tìm kiếm không tồn tại hoặc đã bị xóa.</p>
      <a href="foods?action=list" class="inline-flex items-center text-blue-600 hover:text-blue-700">
        <i data-lucide="arrow-left" class="w-4 h-4 mr-2"></i>
        Quay lại danh sách
      </a>
    </div>
  </div>
</section>
<% } %>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
</body>
</html>
