<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dto.FoodDTO" %>
<%@ page import="model.StallDAO" %>
<%@ page import="model.Page" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Thực đơn - Canteen Đại Học</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<%
    model.PageRequest pageReq = (model.PageRequest) request.getAttribute("pageReq");
    Page<dto.FoodDTO> dailyMenuPage = (Page<dto.FoodDTO>) request.getAttribute("dailyMenuPage");
    int dailyMenuCurrentPage = dailyMenuPage != null ? dailyMenuPage.getCurrentPage() : 1;
    int dailyMenuTotalPages = dailyMenuPage != null ? dailyMenuPage.getTotalPage() : 1;
    String keyword = pageReq != null ? pageReq.getKeyword() : "";
    String contextPath = request.getContextPath();
    String defaultFoodImage = contextPath + "/image/food-thumbnail.png";
    java.time.LocalDate dailyMenuDate = (java.time.LocalDate) request.getAttribute("dailyMenuDate");
    java.time.format.DateTimeFormatter dailyMenuFormatter = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
    String dailyMenuDateLabel = dailyMenuDate != null ? dailyMenuDate.format(dailyMenuFormatter) : null;
//    java.util.Map<Integer, java.util.List<dto.FoodDTO>> dailyMenuByStall = (java.util.Map<Integer, java.util.List<dto.FoodDTO>>) request.getAttribute("dailyMenuByStall");
//    java.util.List<model.StallDAO> dailyMenuStalls = (java.util.List<model.StallDAO>) request.getAttribute("dailyMenuStalls");
    java.util.List<dto.FoodDTO> dailyMenuFoods = (java.util.List<dto.FoodDTO>) request.getAttribute("dailyMenuFoods");
    StringBuilder homePageUrlBuilder = new StringBuilder("home");
    boolean homeHasQuery = false;
    if (keyword != null && !keyword.trim().isEmpty()) {
        homePageUrlBuilder.append(homeHasQuery ? "&" : "?")
                          .append("keyword=").append(URLEncoder.encode(keyword, StandardCharsets.UTF_8));
        homeHasQuery = true;
    }
    if (pageReq != null) {
        if (pageReq.getSortField() != null && !pageReq.getSortField().isEmpty()) {
            homePageUrlBuilder.append(homeHasQuery ? "&" : "?")
                              .append("sortField=").append(pageReq.getSortField());
            homeHasQuery = true;
        }
        if (pageReq.getOrderField() != null && !pageReq.getOrderField().isEmpty()) {
            homePageUrlBuilder.append(homeHasQuery ? "&" : "?")
                              .append("orderField=").append(pageReq.getOrderField());
            homeHasQuery = true;
        }
    }
    String homePageBaseUrl = homePageUrlBuilder.toString();
    String homePageUrlPrefix = homePageBaseUrl + (homeHasQuery ? "&" : "?") + "page=";
%>

<!-- Search -->
<section class="py-6 bg-white/90 backdrop-blur-sm shadow-sm">
  <div class="max-w-5xl mx-auto text-center px-4">
    <form action="home" method="get" class="flex flex-col sm:flex-row items-center gap-3 justify-center">
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

<!-- Food list -->
<section class="py-8 bg-gradient-to-b from-gray-50 to-blue-50">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div>
              <h2 class="text-xl font-bold text-gray-800">Thực đơn hôm nay</h2>
              <p class="text-sm text-gray-600">Ngày: <span class="font-semibold text-gray-900"><%= dailyMenuDateLabel != null ? dailyMenuDateLabel : "Chưa xác định" %></span></p>
            </div>
      <br />
      <% if (dailyMenuFoods != null && !dailyMenuFoods.isEmpty()) { %>
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
      <%
        for (FoodDTO food : dailyMenuFoods) {
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
          <h3 class="font-medium text-gray-800 text-sm truncate"><%= food.getNameFood() %></h3>
          <p class="text-blue-600 font-bold text-sm"><%= String.format("%,.0f", food.getPriceFood()) %>đ</p>
          <!-- <span class="text-xs <%= food.getInventoryFood() > 0 ? "text-green-600" : "text-red-600" %>">
            Tồn kho: <%= food.getInventoryFood() %>
          </span> -->
            <button onclick="addToCart(<%= food.getStallId() %>, <%= food.getId() %>, '<%= food.getNameFood().replace("'", "\\'") %>', <%= food.getPriceFood() %>, '<%= food.getImage() != null ? food.getImage().replace("'", "\\'") : "static/img/food-thumbnail.png" %>')"
                    class="add-to-cart-btn mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transitio">
                <i data-lucide="shopping-cart" class="w-5 h-5 inline mr-2"></i>
                Thêm vào giỏ hàng
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
    <% if (dailyMenuPage != null && dailyMenuTotalPages > 1) { %>
    <div class="mt-8 flex justify-center">
      <nav class="inline-flex items-center gap-2 text-sm" aria-label="Phân trang thực đơn">
        <% if (dailyMenuCurrentPage > 1) { %>
        <a href="<%= homePageUrlPrefix + (dailyMenuCurrentPage - 1) %>" class="px-3 py-1.5 border border-gray-300 rounded-full text-gray-700 bg-white hover:border-blue-400">Trước</a>
        <% } else { %>
        <span class="px-3 py-1.5 border border-gray-200 rounded-full text-gray-400 bg-gray-100 cursor-not-allowed">Trước</span>
        <% } %>
        <% for (int i = 1; i <= dailyMenuTotalPages; i++) { boolean isActive = (i == dailyMenuCurrentPage); %>
        <a href="<%= homePageUrlPrefix + i %>" class="px-3 py-1.5 border rounded-full <%= isActive ? "bg-blue-600 border-blue-600 text-white" : "border-gray-300 text-gray-700 bg-white hover:border-blue-400" %>"><%= i %></a>
        <% } %>
        <% if (dailyMenuCurrentPage < dailyMenuTotalPages) { %>
        <a href="<%= homePageUrlPrefix + (dailyMenuCurrentPage + 1) %>" class="px-3 py-1.5 border border-gray-300 rounded-full text-gray-700 bg-white hover:border-blue-400">Sau</a>
        <% } else { %>
        <span class="px-3 py-1.5 border border-gray-200 rounded-full text-gray-400 bg-gray-100 cursor-not-allowed">Sau</span>
        <% } %>
      </nav>
    </div>
    <% } %>
  </div>
</section>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
</body>
</html>