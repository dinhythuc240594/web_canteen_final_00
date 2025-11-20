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
<script>
    let cart = JSON.parse(localStorage.getItem('cart')) || [];

    document.addEventListener('DOMContentLoaded', function() {
        lucide.createIcons();
        updateCartCount();
        renderCart();
    });

    function addToCart(stall_id, id, name, price, image) {
        const existing = cart.find(item => item.id === id);
        if (existing) {
            existing.quantity += 1;
        } else {
            cart.push({stall_id, id, name, price, image, quantity: 1 });
        }

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
            if (footer) footer.classList.add('hidden');
            return;
        }

        container.innerHTML = cart.map(item => {
            const price = Number(item.price) || 0;
            const quantity = Number(item.quantity) || 0;
            total += price * quantity;

            var html = "";
            html += '<div class="flex items-center space-x-3 bg-gray-50 p-2 rounded mb-2">';
            html += '<img src="'+ (item.image || "static/img/food-thumbnail.png") +'" class="w-12 h-12 object-cover rounded">';
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
