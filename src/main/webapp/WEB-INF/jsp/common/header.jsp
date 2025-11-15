<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>
<%
	String username = (String) request.getAttribute("username");
	String type_user = (String) request.getAttribute("type_user");
	Boolean is_login = (Boolean) request.getAttribute("is_login");
	if (is_login == null) is_login = false;
%>
<header class="bg-gradient-to-r from-blue-600 to-indigo-600 shadow-lg sticky top-0 z-50">
	<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
		<div class="flex justify-between items-center h-16">
			<div class="flex items-center space-x-8">
				<div class="flex items-center space-x-4">
					<h1 class="text-2xl font-bold text-white">Canteen ĐH</h1>
				</div>

				<nav class="hidden md:flex space-x-6">
					<a href="home"
					   class="px-3 py-2 rounded-md text-sm font-medium transition-colors
                              ${requestScope.currentPage == 'home' ? 'text-white bg-white/20' : 'text-white/80 hover:text-white'}">
						Đồ ăn
					</a>
					<a href="category"
					   class="px-3 py-2 rounded-md text-sm font-medium transition-colors
                              ${requestScope.currentPage == 'categories' ? 'text-white bg-white/20' : 'text-white/80 hover:text-white'}">
						Danh mục
					</a>
					<a href="store"
					   class="px-3 py-2 rounded-md text-sm font-medium transition-colors
                              ${requestScope.currentPage == 'stalls' ? 'text-white bg-white/20' : 'text-white/80 hover:text-white'}">
						Quầy
					</a>
					<% if (is_login) { %>
					<a href="order-history"
					   class="px-3 py-2 rounded-md text-sm font-medium transition-colors
                              ${requestScope.currentPage == 'order-history' ? 'text-white bg-white/20' : 'text-white/80 hover:text-white'}">
						Đơn hàng
					</a>
					<% } %>
				</nav>
			</div>
			<div class="flex items-center space-x-4">
				<% if (is_login) { %>
				<div class="flex items-center space-x-4">
					<button onclick="toggleCart()"
							class="relative p-2 text-white hover:text-white/80 transition-colors">
						<i data-lucide="shopping-cart" class="w-6 h-6"></i>
						<span id="cart-count" class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center hidden">0</span>
					</button>
					<div class="flex items-center space-x-2">
						<%
							String dashboardUrl = "admin";
							if ("customer".equals(type_user)) {
								dashboardUrl = "customer";
							} else if ("stall".equals(type_user)) {
								dashboardUrl = "stall";
							} else if ("admin".equals(type_user)) {
								dashboardUrl = "admin";
							}
						%>
						<a href="<%= dashboardUrl %>" class="flex items-center space-x-2 text-sm font-medium text-white hover:text-white/80 transition-colors cursor-pointer">
							<i data-lucide="user" class="w-6 h-6 text-white"></i>
							<span class="text-sm font-medium text-white">
								<%= username != null ? username : "User" %>
							</span>
						</a>
						<a href="logout" class="text-sm text-white/80 hover:text-white">Đăng xuất</a>
					</div>
				</div>
				<% } else { %>
				<div class="flex items-center space-x-4">
					<!-- Cart button hiển thị cả khi chưa đăng nhập -->
					<button onclick="toggleCart()"
							class="relative p-2 text-white hover:text-white/80 transition-colors">
						<i data-lucide="shopping-cart" class="w-6 h-6"></i>
						<span id="cart-count" class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center hidden">0</span>
					</button>
					<a href="login"
					   class="px-4 py-2 text-sm font-medium text-white/80 hover:text-white transition-colors">
						Đăng nhập
					</a>
<%--					<a href="register"--%>
<%--					   class="px-4 py-2 bg-white text-blue-600 text-sm font-medium rounded-md hover:bg-gray-100 transition-colors">--%>
<%--						Đăng ký--%>
<%--					</a>--%>
				</div>
				<% } %>

				<button onclick="toggleMobileMenu()"
						class="md:hidden p-2 text-white">
					<i data-lucide="menu" id="menu-icon" class="w-6 h-6"></i>
				</button>
			</div>
		</div>

		<!-- Mobile menu -->
		<div id="mobile-menu" class="md:hidden hidden py-4 border-t border-white/20">
			<div class="flex flex-col space-y-2">
				<a href="home"
				   class="px-3 py-2 rounded-md text-sm font-medium text-left text-white/80 hover:text-white hover:bg-white/20">
					Đồ ăn
				</a>
				<a href="category"
				   class="px-3 py-2 rounded-md text-sm font-medium text-left text-white/80 hover:text-white hover:bg-white/20">
					Danh mục
				</a>
				<a href="store"
				   class="px-3 py-2 rounded-md text-sm font-medium text-left text-white/80 hover:text-white hover:bg-white/20">
					Quầy
				</a>
				<% if (is_login) { %>
				<a href="order-history"
				   class="px-3 py-2 rounded-md text-sm font-medium text-left text-white/80 hover:text-white hover:bg-white/20">
					Đơn hàng
				</a>
				<% } %>
			</div>
		</div>
	</div>
</header>

<script>
	function toggleMobileMenu() {
		const menu = document.getElementById('mobile-menu');
		const icon = document.getElementById('menu-icon');
		if (menu.classList.contains('hidden')) {
			menu.classList.remove('hidden');
			icon.setAttribute('data-lucide', 'x');
		} else {
			menu.classList.add('hidden');
			icon.setAttribute('data-lucide', 'menu');
		}
		lucide.createIcons();
	}

	function toggleCart() {
		const cartSidebar = document.getElementById('cart-sidebar');
		if (cartSidebar) {
			cartSidebar.classList.toggle('hidden');
			lucide.createIcons(); // Re-initialize icons after showing sidebar
		} else {
			// Nếu cart-sidebar chưa được include, hiển thị thông báo
			alert('Vui lòng đăng nhập để sử dụng giỏ hàng!');
		}
	}

	// Update cart count từ localStorage (nếu có)
	function updateCartCount() {
		try {
			const cart = JSON.parse(localStorage.getItem('cart')) || [];
			const count = cart.reduce((sum, item) => sum + item.quantity, 0);
			const cartCountElement = document.getElementById('cart-count');
			if (cartCountElement) {
				if (count > 0) {
					cartCountElement.textContent = count;
					cartCountElement.classList.remove('hidden');
				} else {
					cartCountElement.classList.add('hidden');
				}
			}
		} catch (e) {
			// Ignore errors if localStorage is not available
		}
	}

	// Cập nhật cart count khi trang load
	document.addEventListener('DOMContentLoaded', function() {
		updateCartCount();
		// Listen for storage changes (nếu mở nhiều tab)
		window.addEventListener('storage', function(e) {
			if (e.key === 'cart') {
				updateCartCount();
			}
		});
	});
</script>