<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html lang="vi">
<head>
	<meta charset="UTF-8">
	<title>Danh sách món ăn</title>
	<jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<%
	model.PageRequest pageReq = (model.PageRequest) request.getAttribute("pageReq");
	String keyword = pageReq != null ? pageReq.getKeyword() : "";
	Integer selectedStallId = pageReq != null ? pageReq.getStallId() : null;
	
	String userRole = (String) request.getAttribute("userRole");
	boolean isStallRole = "stall".equals(userRole);
	Integer userStallId = (Integer) request.getAttribute("userStallId");
	
	// Chỉ hiển thị các button quản lý món khi người dùng là chủ quầy và có quầy
	boolean isStallOwner = isStallRole && userStallId != null;
	
	// Chỉ hiển thị nút tạo món khi đang xem quầy của chính user hoặc không có quầy nào được chọn
	boolean canCreateFood = isStallOwner && (selectedStallId == null || selectedStallId.equals(userStallId));
	
	java.util.List<model.StallDAO> stalls = (java.util.List<model.StallDAO>) request.getAttribute("stalls");
	String contextPath = request.getContextPath();
	String defaultFoodImage = contextPath + "/image/food-thumbnail.png";
	java.time.LocalDate dailyMenuDate = (java.time.LocalDate) request.getAttribute("dailyMenuDate");
	java.time.format.DateTimeFormatter dailyMenuFormatter = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
	String dailyMenuDateLabel = dailyMenuDate != null ? dailyMenuDate.format(dailyMenuFormatter) : null;
	java.util.Map<Integer, java.util.List<dto.FoodDTO>> dailyMenuByStall = (java.util.Map<Integer, java.util.List<dto.FoodDTO>>) request.getAttribute("dailyMenuByStall");
	java.util.List<model.StallDAO> dailyMenuStalls = (java.util.List<model.StallDAO>) request.getAttribute("dailyMenuStalls");
	java.util.List<dto.FoodDTO> dailyMenuFoods = (java.util.List<dto.FoodDTO>) request.getAttribute("dailyMenuFoods");
%>

<!-- 🔍 Tìm kiếm -->
<section class="py-6 bg-white/90 backdrop-blur-sm shadow-sm">
  <div class="max-w-5xl mx-auto text-center px-4">
    <form action="foods" method="get" class="flex flex-col sm:flex-row items-center gap-3 justify-center">
      <input type="hidden" name="action" value="list">
      
      <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>"
             placeholder="Tìm theo tên hoặc giá món ăn..." 
             class="w-full sm:w-2/3 rounded-full border border-gray-300 px-5 py-2 focus:ring-2 focus:ring-blue-400 outline-none transition-all" />

      <button type="submit"
              class="bg-blue-600 text-white rounded-full px-3 py-2 focus:ring-2 focus:ring-blue-400" style="width:150px;">
        Tìm kiếm
      </button>
    </form>
  </div>
</section>

<%--<!-- 📅 Menu theo ngày -->--%>
<%--<section class="py-6 bg-gradient-to-r from-blue-50 to-indigo-50">--%>
<%--  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">--%>
<%--    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3 mb-4">--%>
<%--      <div>--%>
<%--        <h2 class="text-xl font-bold text-gray-800">Thực đơn theo ngày</h2>--%>
<%--        <p class="text-sm text-gray-600">Ngày: <span class="font-semibold text-gray-900"><%= dailyMenuDateLabel != null ? dailyMenuDateLabel : "Chưa xác định" %></span></p>--%>
<%--      </div>--%>
<%--      <p class="text-sm text-gray-500">Danh sách món đã được quầy công bố cho ngày hiện tại.</p>--%>
<%--    </div>--%>
<%--    --%>
<%--    <% if (dailyMenuStalls != null && !dailyMenuStalls.isEmpty()) { %>--%>
<%--    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">--%>
<%--      <% for (model.StallDAO stallItem : dailyMenuStalls) {--%>
<%--           java.util.List<dto.FoodDTO> stallMenu = dailyMenuByStall != null ? dailyMenuByStall.get(stallItem.getId()) : null;--%>
<%--      %>--%>
<%--      <div class="bg-white border border-gray-200 rounded-xl p-4 shadow-sm">--%>
<%--        <div class="flex items-start justify-between">--%>
<%--          <div>--%>
<%--            <h3 class="text-lg font-semibold text-gray-800"><%= stallItem.getName() %></h3>--%>
<%--            <p class="text-sm text-gray-500"><%= stallItem.getDescription() != null ? stallItem.getDescription() : "Quầy ăn trong căng tin" %></p>--%>
<%--          </div>--%>
<%--          <span class="text-xs px-2 py-1 rounded-full <%= stallItem.getIsOpen() != null && stallItem.getIsOpen() ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700" %>">--%>
<%--            <%= stallItem.getIsOpen() != null && stallItem.getIsOpen() ? "Đang mở" : "Tạm đóng" %>--%>
<%--          </span>--%>
<%--        </div>--%>
<%--        <% if (stallMenu != null && !stallMenu.isEmpty()) { %>--%>
<%--        <div class="mt-3 space-y-2 text-sm">--%>
<%--          <% for (dto.FoodDTO menuFood : stallMenu) { --%>
<%--               Double menuPrice = menuFood.getPriceFood() != null ? menuFood.getPriceFood() : 0.0;--%>
<%--          %>--%>
<%--          <div class="flex items-center justify-between border-b border-gray-100 pb-2 last:border-b-0 last:pb-0">--%>
<%--            <span class="text-gray-700 truncate pr-3"><%= menuFood.getNameFood() %></span>--%>
<%--            <span class="text-blue-600 font-semibold whitespace-nowrap"><%= String.format("%,.0f", menuPrice) %>đ</span>--%>
<%--          </div>--%>
<%--          <% } %>--%>
<%--        </div>--%>
<%--        <% } else { %>--%>
<%--        <p class="text-sm text-gray-500 mt-3 italic">Chưa có món nào được đăng cho ngày này.</p>--%>
<%--        <% } %>--%>
<%--      </div>--%>
<%--      <% } %>--%>
<%--    </div>--%>
<%--    <% } else { %>--%>
<%--    <div class="text-center py-8 text-gray-600 bg-white rounded-xl border border-dashed border-gray-300">--%>
<%--      Chưa có thực đơn nào được đăng cho ngày này.--%>
<%--    </div>--%>
<%--    <% } %>--%>
<%--  </div>--%>
<%--</section>--%>

<!-- Action Buttons (Chỉ hiển thị cho chủ quầy khi xem quầy của chính họ) -->
<% if (canCreateFood) { %>
<section class="py-4 bg-white">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <a href="foods?action=create" class="inline-flex items-center gap-2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition">
      <i data-lucide="plus"></i> Thêm món ăn mới
    </a>
  </div>
</section>
<% } %>

<!-- 🥗 Danh sách món ăn -->
<section class="py-8 bg-gradient-to-b from-gray-50 to-blue-50">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <h2 class="text-xl font-bold text-gray-800 mb-4 text-center">Danh sách món ăn</h2>

    <% if (dailyMenuFoods != null && !dailyMenuFoods.isEmpty()) { %>
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
      <%
        for (dto.FoodDTO food : dailyMenuFoods) {
      %>
      <%
        String rawImage = food.getImage();
        String imageUrl = defaultFoodImage;
        if (rawImage != null && !rawImage.trim().isEmpty()) {
          String trimmedImage = rawImage.trim();
          if (trimmedImage.startsWith("http://") || trimmedImage.startsWith("https://")) {
            imageUrl = trimmedImage;
          } else if (trimmedImage.startsWith(contextPath)) {
            imageUrl = trimmedImage;
          } else if (trimmedImage.startsWith("/")) {
            imageUrl = contextPath + trimmedImage;
          } else {
            imageUrl = contextPath + "/" + trimmedImage;
          }
        }
      %>
      <div class="bg-white rounded-xl shadow hover:shadow-md border border-gray-200 overflow-hidden transition">
        <img src="<%= imageUrl %>" 
             alt="<%= food.getNameFood() %>"
             class="w-full h-32 object-cover">
        <div class="p-3">
          <h3 class="font-medium text-gray-800 text-sm truncate cursor-pointer hover:text-blue-600"
              onclick="window.location.href='foods?id=<%= food.getId() %>&action=detail'">
            <%= food.getNameFood() %>
          </h3>
          <p class="text-blue-600 font-bold text-sm"><%= String.format("%,.0f", food.getPriceFood()) %>đ</p>
          <div class="flex items-center justify-between mt-2">
              <!-- <span class="text-xs <%= food.getInventoryFood() > 0 ? "text-green-600" : "text-red-600" %>">
              Tồn kho: <%= food.getInventoryFood() %>
            </span> -->
            <% 
              // Chỉ hiển thị button sửa/xóa nếu người dùng là chủ quầy và món ăn thuộc về quầy của họ
              boolean canEdit = isStallOwner && food.getStallId() == userStallId;
            %>
            <% if (canEdit) { %>
            <div class="flex gap-1">
              <a href="foods?id=<%= food.getId() %>&action=update" 
                 class="p-1 text-yellow-600 hover:text-yellow-700" title="Sửa">
                <i data-lucide="edit" class="w-4 h-4"></i>
              </a>
              <button type="button"
                      class="p-1 text-red-600 hover:text-red-700"
                      title="Xóa"
                      data-food-id="<%= food.getId() %>"
                      onclick="handleDeleteFood(this.dataset.foodId)">
                <i data-lucide="trash-2" class="w-4 h-4"></i>
              </button>
            </div>
            <% } %>
          </div>
          <button onclick="window.location.href='foods?id=<%= food.getId() %>&action=detail'"
                  class="mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transition">
            Xem chi tiết
          </button>
        </div>
      </div>
      <% } %>
    </div>

    <% } else { %>
    <div class="text-center py-12">
      <i data-lucide="info" class="w-12 h-12 text-gray-400 mx-auto mb-4"></i>
      <p class="text-gray-600">Chưa có món ăn nào được lên thực đơn cho ngày này.</p>
    </div>
    <% } %>
  </div>
</section>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
<script>
  async function handleDeleteFood(foodId) {
    const numericId = Number(foodId);
    if (Number.isNaN(numericId)) {
      alert('ID món ăn không hợp lệ.');
      return;
    }

    if (!confirm('Bạn có chắc chắn muốn xóa món ăn này?')) {
      return;
    }

    const params = new URLSearchParams();
    params.append('action', 'delete');
    params.append('id', numericId);

    try {
      const response = await fetch('foods', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params.toString()
      });
      const result = await response.json();

      if (result.success) {
        window.location.reload();
      } else {
        alert(result.message || 'Xóa món ăn thất bại');
      }
    } catch (error) {
      alert('Không thể xóa món ăn. Vui lòng thử lại sau.');
    }
  }
</script>
</body>
</html>
