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
	model.Page<dto.FoodDTO> pageFood = (model.Page<dto.FoodDTO>) request.getAttribute("pageFood");
	java.util.List<dto.FoodDTO> foods = null;
	if (pageFood != null) {
		foods = pageFood.getData();
	}
	
	model.PageRequest pageReq = (model.PageRequest) request.getAttribute("pageReq");
	String keyword = pageReq != null ? pageReq.getKeyword() : "";
	int totalPage = pageFood != null ? pageFood.getTotalPage() : 1;
	int currentPage = pageFood != null ? pageFood.getCurrentPage() : 1;
	Integer selectedStallId = pageReq != null ? pageReq.getStallId() : null;
	
	String userRole = (String) request.getAttribute("userRole");
	boolean isStallRole = "stall".equals(userRole);
	
	java.util.List<model.StallDAO> stalls = (java.util.List<model.StallDAO>) request.getAttribute("stalls");
%>

<!-- 🔍 Tìm kiếm -->
<section class="py-6 bg-white/90 backdrop-blur-sm shadow-sm">
  <div class="max-w-5xl mx-auto text-center px-4">
    <form action="foods" method="get" class="flex flex-col sm:flex-row items-center gap-3 justify-center">
      <input type="hidden" name="action" value="list">
      
      <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>"
             placeholder="Tìm món ăn bạn muốn..." 
             class="w-full sm:w-2/3 rounded-full border border-gray-300 px-5 py-2 focus:ring-2 focus:ring-blue-400 outline-none transition-all" />

      <select name="stallId" class="rounded-full border border-gray-300 px-3 py-2 focus:ring-2 focus:ring-blue-400">
        <option value="">Tất cả quầy</option>
        <% if (stalls != null) {
            for (model.StallDAO stall : stalls) {
                boolean selected = selectedStallId != null && selectedStallId == stall.getId();
        %>
        <option value="<%= stall.getId() %>" <%= selected ? "selected" : "" %>>
            <%= stall.getName() %>
        </option>
        <% }
        } %>
      </select>

      <button type="submit"
              class="bg-blue-600 text-white rounded-full px-3 py-2 focus:ring-2 focus:ring-blue-400" style="width:150px;">
        Tìm kiếm
      </button>
    </form>
  </div>
</section>

<!-- Action Buttons (Only for stall role) -->
<% if (isStallRole) { %>
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

    <% if (foods != null && !foods.isEmpty()) { %>
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
      <%
        for (dto.FoodDTO food : foods) {
      %>
      <div class="bg-white rounded-xl shadow hover:shadow-md border border-gray-200 overflow-hidden transition">
        <img src="<%= food.getImage() != null && !food.getImage().isEmpty() ? food.getImage() : "/images/default-food.jpg" %>" 
             alt="<%= food.getNameFood() %>"
             class="w-full h-32 object-cover">
        <div class="p-3">
          <h3 class="font-medium text-gray-800 text-sm truncate cursor-pointer hover:text-blue-600"
              onclick="window.location.href='foods?id=<%= food.getId() %>&action=detail'">
            <%= food.getNameFood() %>
          </h3>
          <p class="text-blue-600 font-bold text-sm"><%= String.format("%,.0f", food.getPriceFood()) %>đ</p>
          <div class="flex items-center justify-between mt-2">
            <span class="text-xs <%= food.getInventoryFood() > 0 ? "text-green-600" : "text-red-600" %>">
              Tồn kho: <%= food.getInventoryFood() %>
            </span>
            <% if (isStallRole) { %>
            <div class="flex gap-1">
              <a href="foods?id=<%= food.getId() %>&action=update" 
                 class="p-1 text-yellow-600 hover:text-yellow-700" title="Sửa">
                <i data-lucide="edit" class="w-4 h-4"></i>
              </a>
              <a href="foods?id=<%= food.getId() %>&action=delete"
                 onclick="return confirm('Bạn có chắc chắn muốn xóa món ăn này?');"
                 class="p-1 text-red-600 hover:text-red-700" title="Xóa">
                <i data-lucide="trash-2" class="w-4 h-4"></i>
              </a>
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

    <!-- Pagination -->
    <% if (totalPage > 1) { %>
    <div class="flex justify-center mt-6 space-x-2">
      <% 
        String keywordParam = keyword != null ? keyword : "";
        String stallIdParam = selectedStallId != null ? String.valueOf(selectedStallId) : "";
        
        // Previous button
        if (currentPage > 1) {
      %>
      <a href="foods?action=list&page=<%= currentPage - 1 %>&keyword=<%= keywordParam %>&stallId=<%= stallIdParam %>"
         class="px-3 py-1 rounded-full border text-sm bg-white hover:bg-blue-100">
        <i data-lucide="chevron-left" class="w-4 h-4 inline"></i> Trước
      </a>
      <% } %>
      
      <% 
        int startPage = Math.max(1, currentPage - 2);
        int endPage = Math.min(totalPage, currentPage + 2);
        
        if (startPage > 1) {
      %>
      <a href="foods?action=list&page=1&keyword=<%= keywordParam %>&stallId=<%= stallIdParam %>"
         class="px-3 py-1 rounded-full border text-sm bg-white hover:bg-blue-100">
        1
      </a>
      <% if (startPage > 2) { %>
      <span class="px-3 py-1 text-sm">...</span>
      <% } %>
      <% } %>
      
      <% for (int i = startPage; i <= endPage; i++) { %>
      <a href="foods?action=list&page=<%= i %>&keyword=<%= keywordParam %>&stallId=<%= stallIdParam %>"
         class="px-3 py-1 rounded-full border text-sm <%= (i == currentPage) ? "bg-blue-600 text-white" : "bg-white hover:bg-blue-100" %>">
        <%= i %>
      </a>
      <% } %>
      
      <% if (endPage < totalPage) { %>
      <% if (endPage < totalPage - 1) { %>
      <span class="px-3 py-1 text-sm">...</span>
      <% } %>
      <a href="foods?action=list&page=<%= totalPage %>&keyword=<%= keywordParam %>&stallId=<%= stallIdParam %>"
         class="px-3 py-1 rounded-full border text-sm bg-white hover:bg-blue-100">
        <%= totalPage %>
      </a>
      <% } %>
      
      <% if (currentPage < totalPage) { %>
      <a href="foods?action=list&page=<%= currentPage + 1 %>&keyword=<%= keywordParam %>&stallId=<%= stallIdParam %>"
         class="px-3 py-1 rounded-full border text-sm bg-white hover:bg-blue-100">
        Sau <i data-lucide="chevron-right" class="w-4 h-4 inline"></i>
      </a>
      <% } %>
    </div>
    <% } %>
    
    <% } else { %>
    <div class="text-center py-12">
      <i data-lucide="info" class="w-12 h-12 text-gray-400 mx-auto mb-4"></i>
      <p class="text-gray-600">Không tìm thấy món ăn nào.</p>
    </div>
    <% } %>
  </div>
</section>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
<jsp:include page="/WEB-INF/jsp/common/cart-sidebar.jsp" />

<script>
  let cart = JSON.parse(localStorage.getItem('cart')) || [];

  document.addEventListener('DOMContentLoaded', function() {
    lucide.createIcons();
    updateCartCount();
    renderCart();
  });

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
      container.innerHTML = `<div class="text-center py-6 text-gray-500">Giỏ hàng trống</div>`;
      if (footer) footer.classList.add('hidden');
      return;
    }

    container.innerHTML = cart.map(item => {
      const price = Number(item.price) || 0;
      const quantity = Number(item.quantity) || 0;
      total += price * quantity;

      var html = "";
      html += '<div class="flex items-center space-x-3 bg-gray-50 p-2 rounded mb-2">';
      html += '<img src="'+ (item.image || "/images/default-food.jpg") +'" class="w-12 h-12 object-cover rounded">';
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

    if (footer) {
      document.getElementById('cart-total').textContent = total.toLocaleString('vi-VN') + 'đ';
      footer.classList.remove('hidden');
    }
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
