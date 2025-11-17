<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dto.FoodDTO" %>
<%@ page import="model.Food_CategoryDAO" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Danh mục - Canteen ĐH</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body>
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
    
    List<Food_CategoryDAO> categories = (List<Food_CategoryDAO>) request.getAttribute("categories");
    Integer selectedCategoryId = (Integer) request.getAttribute("selectedCategoryId");
    if (selectedCategoryId == null) selectedCategoryId = 0;
%>

<div class="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <!-- Search bar -->
        <div class="mb-6">
            <form action="category" method="get" class="flex flex-col sm:flex-row items-center gap-3">
                <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>"
                       placeholder="Tìm theo tên hoặc giá món ăn..." 
                       class="w-full sm:w-2/3 rounded-full border border-gray-300 px-5 py-2 focus:ring-2 focus:ring-blue-400 outline-none transition-all" />
                <% if (selectedCategoryId > 0) { %>
                <input type="hidden" name="categoryId" value="<%= selectedCategoryId %>" />
                <% } %>
                <button type="submit"
                        class="bg-blue-600 text-white rounded-full px-6 py-2 focus:ring-2 focus:ring-blue-400 hover:bg-blue-700 transition-colors">
                    Tìm kiếm
                </button>
            </form>
        </div>

        <div class="flex flex-col lg:flex-row gap-6">
            <!-- Categories sidebar -->
            <div class="lg:w-1/4">
                <h2 class="text-xl font-bold text-gray-800 mb-4">Danh mục</h2>
                <div class="bg-white rounded-lg shadow-sm p-3 border border-gray-200">
                    <ul class="space-y-1">
                        <li>
                            <a href="category?keyword=<%= keyword != null ? keyword : "" %>"
                               class="w-full text-left px-3 py-2.5 rounded-md hover:bg-blue-50 transition-colors flex items-center space-x-2 text-sm <%= selectedCategoryId == 0 ? "bg-blue-50 font-medium" : "" %>">
                                <span class="text-lg">📋</span>
                                <span class="font-medium text-gray-700">Tất cả</span>
                            </a>
                        </li>
                        <% if (categories != null) {
                            for (Food_CategoryDAO category : categories) {
                                boolean isActive = selectedCategoryId != null && selectedCategoryId == category.getId();
                        %>
                        <li>
                            <a href="category?categoryId=<%= category.getId() %>&keyword=<%= keyword != null ? keyword : "" %>"
                               class="w-full text-left px-3 py-2.5 rounded-md hover:bg-blue-50 transition-colors flex items-center space-x-2 text-sm <%= isActive ? "bg-blue-50 font-medium" : "" %>">
                                <span class="text-lg">🍽️</span>
                                <span class="font-medium text-gray-700"><%= category.getName() %></span>
                            </a>
                        </li>
                        <% }
                        } %>
                    </ul>
                </div>
            </div>

            <!-- Foods by category -->
            <div class="lg:w-3/4">
                <h2 class="text-xl font-bold text-gray-800 mb-4">
                    <% if (selectedCategoryId > 0 && categories != null) {
                        for (Food_CategoryDAO cat : categories) {
                            if (cat.getId() == selectedCategoryId) {
                    %>
                    <%= cat.getName() %>
                    <%      break;
                            }
                        }
                    } else { %>
                    Tất cả món ăn
                    <% } %>
                </h2>
                
                <% if (foods != null && !foods.isEmpty()) { %>
                <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
                    <%
                        for (FoodDTO food : foods) {
                            double finalPrice = food.getPriceAfterPromotion() != null ? food.getPriceAfterPromotion() : food.getPriceFood();
                            boolean hasPromotion = food.getPromotion() != null && food.getPromotion() > 0;
                    %>
                    <div class="bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200 hover:shadow-md transition-shadow">
                        <img src="<%= food.getImage() != null && !food.getImage().isEmpty() ? food.getImage() : "https://placehold.co/200x150/e74c3c/white?text=" + food.getNameFood().replace(" ", "+") %>"
                             alt="<%= food.getNameFood() %>"
                             class="w-full h-28 object-cover">
                        <div class="p-3">
                            <h3 class="font-medium text-gray-800 text-sm line-clamp-1"><%= food.getNameFood() %></h3>
                            <div class="flex items-center mt-1">
                                <span class="text-sm font-bold text-blue-600"><%= String.format("%,.0f", finalPrice) %>đ</span>
                                <% if (hasPromotion) { %>
                                <span class="ml-1 text-xs text-red-500 line-through"><%= String.format("%,.0f", food.getPriceFood()) %>đ</span>
                                <% } %>
                            </div>
                            <% if (hasPromotion) { %>
                            <div class="flex items-center mt-1">
                                <span class="ml-auto bg-red-500 text-white text-xs px-1 py-0.5 rounded">-<%= String.format("%.0f", food.getPromotion()) %>%</span>
                            </div>
                            <% } %>
                            <button class="add-to-cart-btn mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transition-colors"
                                    data-stall-id="<%= food.getStallId() %>"
                                    data-food-id="<%= food.getId() %>"
                                    data-food-name="<%= food.getNameFood().replace("\"", "&quot;").replace("'", "&#39;") %>"
                                    data-food-price="<%= finalPrice %>"
                                    data-food-image="<%= (food.getImage() != null && !food.getImage().isEmpty() ? food.getImage() : "https://placehold.co/200x150/e74c3c/white?text=" + food.getNameFood().replace(" ", "+")).replace("\"", "&quot;").replace("'", "&#39;") %>">
                                Thêm vào giỏ
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
                        String categoryParam = selectedCategoryId > 0 ? "&categoryId=" + selectedCategoryId : "";
                        
                        // Previous button
                        if (currentPage > 1) {
                    %>
                    <a href="category?page=<%= currentPage - 1 %>&keyword=<%= keywordParam %><%= categoryParam %>"
                       class="px-3 py-1 rounded-full border text-sm bg-white hover:bg-blue-100">
                        <i data-lucide="chevron-left" class="w-4 h-4 inline"></i> Trước
                    </a>
                    <% } %>
                    
                    <% 
                        int startPage = Math.max(1, currentPage - 2);
                        int endPage = Math.min(totalPage, currentPage + 2);
                        
                        if (startPage > 1) {
                    %>
                    <a href="category?page=1&keyword=<%= keywordParam %><%= categoryParam %>"
                       class="px-3 py-1 rounded-full border text-sm bg-white hover:bg-blue-100">
                        1
                    </a>
                    <% if (startPage > 2) { %>
                    <span class="px-3 py-1 text-sm">...</span>
                    <% } %>
                    <% } %>
                    
                    <% for (int i = startPage; i <= endPage; i++) { %>
                    <a href="category?page=<%= i %>&keyword=<%= keywordParam %><%= categoryParam %>"
                       class="px-3 py-1 rounded-full border text-sm <%= (i == currentPage) ? "bg-blue-600 text-white" : "bg-white hover:bg-blue-100" %>">
                        <%= i %>
                    </a>
                    <% } %>
                    
                    <% if (endPage < totalPage) { %>
                    <% if (endPage < totalPage - 1) { %>
                    <span class="px-3 py-1 text-sm">...</span>
                    <% } %>
                    <a href="category?page=<%= totalPage %>&keyword=<%= keywordParam %><%= categoryParam %>"
                       class="px-3 py-1 rounded-full border text-sm bg-white hover:bg-blue-100">
                        <%= totalPage %>
                    </a>
                    <% } %>
                    
                    <% if (currentPage < totalPage) { %>
                    <a href="category?page=<%= currentPage + 1 %>&keyword=<%= keywordParam %><%= categoryParam %>"
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
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
<jsp:include page="/WEB-INF/jsp/common/cart-sidebar.jsp" />

<script>
  let cart = JSON.parse(localStorage.getItem('cart')) || [];

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
