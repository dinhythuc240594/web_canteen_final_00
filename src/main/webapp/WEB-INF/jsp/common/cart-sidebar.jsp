<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div id="cart-sidebar" class="fixed inset-0 z-50 overflow-hidden hidden">
  <div class="absolute inset-0 bg-black bg-opacity-50" onclick="toggleCart()"></div>
  <div class="absolute right-0 top-0 h-full w-full max-w-md bg-white shadow-xl">
    <div class="flex flex-col h-full">
      <div class="flex items-center justify-between p-3 border-b">
        <h2 class="text-md font-semibold">Giỏ hàng</h2>
        <button onclick="toggleCart()" class="p-1">
          <i data-lucide="x" class="w-5 h-5"></i>
        </button>
      </div>

      <div class="flex-1 overflow-y-auto p-3">
        <div id="cart-items">
          <!-- Cart items will be rendered here by JavaScript -->
        </div>
      </div>

      	<div id="cart-footer" class="p-3 border-t bg-white hidden">
		  <div class="flex justify-between font-semibold text-gray-700 mb-2">
		    <span>Tổng tiền:</span>
		    <span id="cart-total">0đ</span>
		  </div>
		  <button onclick="checkout()" class="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 transition">
		    🛒 Đặt món
		  </button>
		</div>

    </div>
  </div>
</div>

<script>
  function toggleCart() {
    const cartSidebar = document.getElementById('cart-sidebar');
    if (cartSidebar) {
      cartSidebar.classList.toggle('hidden');
      lucide.createIcons();
    }
  }

  function checkout() {
    alert('Tính năng đặt hàng sẽ được triển khai sau khi kết nối backend!');
  }

  // Make functions available globally
  if (typeof window.updateQuantity === 'undefined') {
    window.updateQuantity = function(foodId, newQuantity) {
      // This will be overridden by home.jsp
    };
  }

  if (typeof window.removeFromCart === 'undefined') {
    window.removeFromCart = function(foodId) {
      // This will be overridden by home.jsp
    };
  }
</script>
