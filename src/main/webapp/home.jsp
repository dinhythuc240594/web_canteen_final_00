<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dto.FoodDTO" %>
<%@ page import="model.StallDAO" %>

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
    String keyword = pageReq != null ? pageReq.getKeyword() : "";
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

<%--<!-- 📅 Menu theo ngày -->--%>
<%--<section class="py-6 bg-gradient-to-r from-blue-50 to-indigo-50">--%>
<%--  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">--%>
<%--    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3 mb-4">--%>
<%--      <div>--%>
<%--        <h2 class="text-xl font-bold text-gray-800">Thực đơn hôm nay</h2>--%>
<%--        <p class="text-sm text-gray-600">Ngày: <span class="font-semibold text-gray-900"><%= dailyMenuDateLabel != null ? dailyMenuDateLabel : "Chưa xác định" %></span></p>--%>
<%--      </div>--%>
<%--      <p class="text-sm text-gray-500">Các món đã được công bố cho thực đơn của từng quầy.</p>--%>
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

<!-- 🥗 Danh sách món ăn -->
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
          <button class="add-to-cart-btn mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transition"
                  data-stall-id="<%= food.getStallId() %>"
                  data-food-id="<%= food.getId() %>"
                  data-food-name="<%= food.getNameFood().replace("\"", "&quot;").replace("'", "&#39;") %>"
                  data-food-price="<%= food.getPriceFood() %>"
                  data-food-image="<%= imageUrl.replace("\"", "&quot;").replace("'", "&#39;") %>">
            Thêm vào giỏ
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
<jsp:include page="/WEB-INF/jsp/common/cart-sidebar.jsp" />

<script>
  let cart = JSON.parse(localStorage.getItem('cart')) || [];

  const defaultFoodImage = '<%= contextPath %>/image/food-thumbnail.png';

  document.addEventListener('DOMContentLoaded', () => {
    lucide.createIcons();
    updateCartCount();
    renderCart();
    
    // Add event listeners to all add-to-cart buttons
    document.querySelectorAll('.add-to-cart-btn').forEach(btn => {
      btn.addEventListener('click', function() {
        const stallId = parseInt(this.getAttribute('data-stall-id'));
        const id = parseInt(this.getAttribute('data-food-id'));
        const name = this.getAttribute('data-food-name');
        const price = parseFloat(this.getAttribute('data-food-price'));
        const image = this.getAttribute('data-food-image');
        addToCart(stallId, id, name, price, image);
      });
    });
  });

  function addToCart(stall_id, id, name, price, image) {
    const existing = cart.find(item => item.id === id);
    if (existing) existing.quantity += 1;
    else cart.push({stall_id, id, name, price, image, quantity: 1 });

    localStorage.setItem('cart', JSON.stringify(cart));
    updateCartCount();
    renderCart();
    alert('Đã thêm ' + name + ' vào giỏ hàng!');
  }

  function updateCartCount() {
    const count = cart.reduce((sum, i) => sum + i.quantity, 0);
    const el = document.getElementById('cart-count');
    if (el) {
      el.textContent = count;
      el.classList.toggle('hidden', count === 0);
    }
  }

  function renderCart() {
	  const container = document.getElementById('cart-items');
	  const footer = document.getElementById('cart-footer');
	  let cart = JSON.parse(localStorage.getItem('cart')) || [];
	  let total = 0;

	  if (!container) return;

	  if (cart.length === 0) {
	    container.innerHTML = '<div class="text-center py-6 text-gray-500">Giỏ hàng trống</div>';
	    footer.classList.add('hidden');
	    return;
	  }

	  container.innerHTML = cart.map(item => {
	    const price = Number(item.price) || 0;
	    const quantity = Number(item.quantity) || 0;
	    total += price * quantity;

	    var html = "";
	    	html += '<div class="flex items-center space-x-3 bg-gray-50 p-2 rounded mb-2">';
	    	html += '<img src="'+ (item.image || defaultFoodImage) +'" class="w-12 h-12 object-cover rounded">';
	    	html += '<div class="flex-1">';
	    	html += '<h3 class="text-sm font-medium text-gray-800 truncate">' + (item.name || "Không rõ món") + '</h3>';
	    	html += '<p class="text-blue-600 text-sm font-semibold">' + price.toLocaleString('vi-VN') + 'đ</p>';
	    	html += '</div>';
	    	html += '<div class="flex items-center space-x-1">';
	    	html += '<button onclick="updateQuantity(' + item.id + ',' + (item.quantity - 1) + ')" class="p-1 bg-gray-200 rounded-full">-</button>';
	    	html += '<span class="w-6 text-center">' + item.quantity + '</span>';
	    	html += '<button onclick="updateQuantity(' + item.id + ',' + (item.quantity + 1) + ')" class="p-1 bg-gray-200 rounded-full">+</button>';
	    	html += '</div>';
	    	html += '<button onclick="removeFromCart(' + item.id + ')" class="text-red-600">✕</button>';
	    	html += '</div>';

	      return html;
	  }).join('');

	  document.getElementById('cart-total').textContent = total.toLocaleString('vi-VN') + 'đ';
	  footer.classList.remove('hidden');
	}


  function updateQuantity(id, newQty) {
    if (newQty <= 0) return removeFromCart(id);
    const item = cart.find(i => i.id === id);
    if (item) item.quantity = newQty;
    localStorage.setItem('cart', JSON.stringify(cart));
    updateCartCount();
    renderCart();
  }

  function removeFromCart(id) {
    cart = cart.filter(i => i.id !== id);
    localStorage.setItem('cart', JSON.stringify(cart));
    updateCartCount();
    renderCart();
  }

  function checkout() {
    if (cart.length === 0) {
      alert('Giỏ hàng trống!');
      return;
    }
    
    // Send cart data to server via POST
    $.ajax({
      type: "POST",
      url: "cart",
      data: {
        'orders': JSON.stringify(cart),
        'action': 'add'
      },
      success: function(response) {
        console.log("Cart saved successfully");
        // Redirect to cart page
        window.location.href = 'cart';
      },
      error: function(xhr, status, error) {
        console.error("Error saving cart:", status, error);
        alert("Có lỗi xảy ra khi lưu giỏ hàng. Vui lòng thử lại!");
      }
    });
  }
</script>
</body>
</html>