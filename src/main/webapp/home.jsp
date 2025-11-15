<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dto.FoodDTO" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Thực đơn - Canteen Đại Học</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<%
    model.Page<dto.FoodDTO> pageFood = (model.Page<dto.FoodDTO>) request.getAttribute("pageFood");
    java.util.List<dto.FoodDTO> foods = (java.util.List<dto.FoodDTO>) pageFood.getData();

    model.PageRequest pageReq = (model.PageRequest) request.getAttribute("pageReq");
    String keyword = pageReq.getKeyword();
    int totalPage = pageFood.getTotalPage();
%>

<!-- 🔍 Tìm kiếm -->
<section class="py-6 bg-white/90 backdrop-blur-sm shadow-sm">
  <div class="max-w-5xl mx-auto text-center px-4">
    <form action="home" method="get" class="flex flex-col sm:flex-row items-center gap-3 justify-center">
      <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>"
             placeholder="Tìm món ăn bạn muốn..." 
             class="w-full sm:w-2/3 rounded-full border border-gray-300 px-5 py-2 focus:ring-2 focus:ring-blue-400 outline-none transition-all" />

      <select name="sortfield" class="rounded-full border border-gray-300 px-3 py-2 focus:ring-2 focus:ring-blue-400">
        <option value="nameFood">Tên món</option>
        <option value="priceFood">Giá</option>
      </select>
      <select name="orderfield" class="rounded-full border border-gray-300 px-3 py-2 focus:ring-2 focus:ring-blue-400">
        <option value="ASC">Tăng dần</option>
        <option value="DESC">Giảm dần</option>
      </select>

      <button type="submit"
              class="bg-blue-600 text-white rounded-full px-3 py-2 focus:ring-2 focus:ring-blue-400" style="width:150px;">
        Tìm kiếm
      </button>
    </form>
  </div>
</section>

<!-- 🥗 Danh sách món ăn -->
<section class="py-8 bg-gradient-to-b from-gray-50 to-blue-50">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- <h2 class="text-xl font-bold text-gray-800 mb-4 text-center">Tất cả món ăn</h2> -->

    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
      <%
        if (foods != null) {
          for (FoodDTO food : foods) {
      %>
      <div class="bg-white rounded-xl shadow hover:shadow-md border border-gray-200 overflow-hidden transition">
        <img src="<%= food.getImage() %>" alt="<%= food.getNameFood() %>"
             class="w-full h-32 object-cover">
        <div class="p-3">
          <h3 class="font-medium text-gray-800 text-sm truncate"><%= food.getNameFood() %></h3>
          <p class="text-blue-600 font-bold text-sm"><%= food.getPriceFood() %>đ</p>
          <button onclick="addToCart(<%= food.getStallId() %>, <%= food.getId() %>, '<%= food.getNameFood() %>', <%= food.getPriceFood() %>, '<%= food.getImage() %>')"
                  class="mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transition">
            Thêm vào giỏ
          </button>
        </div>
      </div>
      <% } } %>
    </div>

    <div class="flex justify-center mt-6 space-x-2">
      <% for (int i = 1; i <= totalPage; i++) { %>
        <a href="home?action=list&page=<%= i %>&keyword=<%= keyword %>"
           class="px-3 py-1 rounded-full border text-sm <%= (i == pageReq.getPage()) ? "bg-blue-600 text-white" : "bg-white hover:bg-blue-100" %>">
          <%= i %>
        </a>
      <% } %>
    </div>
  </div>
</section>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
<jsp:include page="/WEB-INF/jsp/common/cart-sidebar.jsp" />

<script>
  let cart = JSON.parse(localStorage.getItem('cart')) || [];

  document.addEventListener('DOMContentLoaded', () => {
    lucide.createIcons();
    updateCartCount();
    renderCart();
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
	    container.innerHTML = `<div class="text-center py-6 text-gray-500">Giỏ hàng trống</div>`;
	    footer.classList.add('hidden');
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
	    	html += '<button onclick="removeFromCart("\'' + item.id + '\')" class="text-red-600">✕</button>';
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