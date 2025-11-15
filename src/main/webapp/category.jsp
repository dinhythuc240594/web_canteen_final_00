<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Danh mục - Canteen ĐH</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body>
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<div class="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div class="flex flex-col lg:flex-row gap-6">
            <!-- Categories sidebar -->
            <div class="lg:w-1/4">
                <h2 class="text-xl font-bold text-gray-800 mb-4">Danh mục</h2>
                <div class="bg-white rounded-lg shadow-sm p-3 border border-gray-200">
                    <ul class="space-y-1">
                        <li>
                            <a href="#" onclick="filterCategory(1); return false;"
                               class="w-full text-left px-3 py-2.5 rounded-md hover:bg-blue-50 transition-colors flex items-center space-x-2 text-sm bg-blue-50 font-medium">
                                <span class="text-lg">🍚</span>
                                <span class="font-medium text-gray-700">Món khô</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" onclick="filterCategory(2); return false;"
                               class="w-full text-left px-3 py-2.5 rounded-md hover:bg-blue-50 transition-colors flex items-center space-x-2 text-sm">
                                <span class="text-lg">🍜</span>
                                <span class="font-medium text-gray-700">Món nước</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" onclick="filterCategory(3); return false;"
                               class="w-full text-left px-3 py-2.5 rounded-md hover:bg-blue-50 transition-colors flex items-center space-x-2 text-sm">
                                <span class="text-lg">🍔</span>
                                <span class="font-medium text-gray-700">Đồ ăn nhanh</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" onclick="filterCategory(4); return false;"
                               class="w-full text-left px-3 py-2.5 rounded-md hover:bg-blue-50 transition-colors flex items-center space-x-2 text-sm">
                                <span class="text-lg">🥤</span>
                                <span class="font-medium text-gray-700">Đồ uống</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" onclick="filterCategory(5); return false;"
                               class="w-full text-left px-3 py-2.5 rounded-md hover:bg-blue-50 transition-colors flex items-center space-x-2 text-sm">
                                <span class="text-lg">🍰</span>
                                <span class="font-medium text-gray-700">Ăn vặt / tráng miệng</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" onclick="filterCategory(6); return false;"
                               class="w-full text-left px-3 py-2.5 rounded-md hover:bg-blue-50 transition-colors flex items-center space-x-2 text-sm">
                                <span class="text-lg">🥬</span>
                                <span class="font-medium text-gray-700">Món chay</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" onclick="filterCategory(7); return false;"
                               class="w-full text-left px-3 py-2.5 rounded-md hover:bg-blue-50 transition-colors flex items-center space-x-2 text-sm">
                                <span class="text-lg">🥗</span>
                                <span class="font-medium text-gray-700">Món eatclean</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" onclick="filterCategory(8); return false;"
                               class="w-full text-left px-3 py-2.5 rounded-md hover:bg-blue-50 transition-colors flex items-center space-x-2 text-sm">
                                <span class="text-lg">➕</span>
                                <span class="font-medium text-gray-700">Topping/Món Thêm</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- Foods by category -->
            <div class="lg:w-3/4">
                <h2 class="text-xl font-bold text-gray-800 mb-4">Tất cả món ăn</h2>
                <div id="foods-grid" class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
                    <!-- Mock foods - will be filtered by JavaScript -->
                    <div class="bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200 hover:shadow-md transition-shadow" data-category="1">
                        <img src="https://placehold.co/200x150/e74c3c/white?text=Cơm+Chiên"
                             alt="Cơm chiên dương châu"
                             class="w-full h-28 object-cover">
                        <div class="p-3">
                            <h3 class="font-medium text-gray-800 text-sm line-clamp-1">Cơm chiên dương châu</h3>
                            <div class="flex items-center mt-1">
                                <span class="text-sm font-bold text-blue-600">22,500đ</span>
                                <span class="ml-1 text-xs text-red-500 line-through">25,000đ</span>
                            </div>
                            <div class="flex items-center mt-1">
                                <i data-lucide="star" class="w-3 h-3 text-yellow-400 fill-current"></i>
                                <span class="ml-1 text-xs text-gray-600">4.5</span>
                                <span class="ml-auto bg-red-500 text-white text-xs px-1 py-0.5 rounded">-10%</span>
                            </div>
                            <button onclick="addToCart(1)"
                                    class="mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transition-colors">
                                Thêm vào giỏ
                            </button>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200 hover:shadow-md transition-shadow" data-category="2">
                        <img src="https://placehold.co/200x150/3498db/white?text=Phở+Bò"
                             alt="Phở bò"
                             class="w-full h-28 object-cover">
                        <div class="p-3">
                            <h3 class="font-medium text-gray-800 text-sm line-clamp-1">Phở bò</h3>
                            <div class="flex items-center mt-1">
                                <span class="text-sm font-bold text-blue-600">30,000đ</span>
                            </div>
                            <div class="flex items-center mt-1">
                                <i data-lucide="star" class="w-3 h-3 text-yellow-400 fill-current"></i>
                                <span class="ml-1 text-xs text-gray-600">4.8</span>
                            </div>
                            <button onclick="addToCart(6)"
                                    class="mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transition-colors">
                                Thêm vào giỏ
                            </button>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200 hover:shadow-md transition-shadow" data-category="3">
                        <img src="https://placehold.co/200x150/9b59b6/white?text=Bánh+Mì"
                             alt="Bánh mì thịt nướng"
                             class="w-full h-28 object-cover">
                        <div class="p-3">
                            <h3 class="font-medium text-gray-800 text-sm line-clamp-1">Bánh mì thịt nướng</h3>
                            <div class="flex items-center mt-1">
                                <span class="text-sm font-bold text-blue-600">17,100đ</span>
                                <span class="ml-1 text-xs text-red-500 line-through">18,000đ</span>
                            </div>
                            <div class="flex items-center mt-1">
                                <i data-lucide="star" class="w-3 h-3 text-yellow-400 fill-current"></i>
                                <span class="ml-1 text-xs text-gray-600">4.3</span>
                                <span class="ml-auto bg-red-500 text-white text-xs px-1 py-0.5 rounded">-5%</span>
                            </div>
                            <button onclick="addToCart(5)"
                                    class="mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transition-colors">
                                Thêm vào giỏ
                            </button>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200 hover:shadow-md transition-shadow" data-category="4">
                        <img src="https://placehold.co/200x150/27ae60/white?text=Sinh+Tố"
                             alt="Sinh tố bơ"
                             class="w-full h-28 object-cover">
                        <div class="p-3">
                            <h3 class="font-medium text-gray-800 text-sm line-clamp-1">Sinh tố bơ</h3>
                            <div class="flex items-center mt-1">
                                <span class="text-sm font-bold text-blue-600">18,700đ</span>
                                <span class="ml-1 text-xs text-red-500 line-through">22,000đ</span>
                            </div>
                            <div class="flex items-center mt-1">
                                <i data-lucide="star" class="w-3 h-3 text-yellow-400 fill-current"></i>
                                <span class="ml-1 text-xs text-gray-600">4.6</span>
                                <span class="ml-auto bg-red-500 text-white text-xs px-1 py-0.5 rounded">-15%</span>
                            </div>
                            <button onclick="addToCart(2)"
                                    class="mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transition-colors">
                                Thêm vào giỏ
                            </button>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200 hover:shadow-md transition-shadow" data-category="5">
                        <img src="https://placehold.co/200x150/f39c12/white?text=Sữa+Chua"
                             alt="Sữa chua nếp cẩm"
                             class="w-full h-28 object-cover">
                        <div class="p-3">
                            <h3 class="font-medium text-gray-800 text-sm line-clamp-1">Sữa chua nếp cẩm</h3>
                            <div class="flex items-center mt-1">
                                <span class="text-sm font-bold text-blue-600">15,000đ</span>
                            </div>
                            <div class="flex items-center mt-1">
                                <i data-lucide="star" class="w-3 h-3 text-yellow-400 fill-current"></i>
                                <span class="ml-1 text-xs text-gray-600">4.4</span>
                            </div>
                            <button onclick="addToCart(7)"
                                    class="mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transition-colors">
                                Thêm vào giỏ
                            </button>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200 hover:shadow-md transition-shadow" data-category="6">
                        <img src="https://placehold.co/200x150/2ecc71/white?text=Cơm+Chay"
                             alt="Cơm chay thập cẩm"
                             class="w-full h-28 object-cover">
                        <div class="p-3">
                            <h3 class="font-medium text-gray-800 text-sm line-clamp-1">Cơm chay thập cẩm</h3>
                            <div class="flex items-center mt-1">
                                <span class="text-sm font-bold text-blue-600">24,640đ</span>
                                <span class="ml-1 text-xs text-red-500 line-through">28,000đ</span>
                            </div>
                            <div class="flex items-center mt-1">
                                <i data-lucide="star" class="w-3 h-3 text-yellow-400 fill-current"></i>
                                <span class="ml-1 text-xs text-gray-600">4.7</span>
                                <span class="ml-auto bg-red-500 text-white text-xs px-1 py-0.5 rounded">-12%</span>
                            </div>
                            <button onclick="addToCart(3)"
                                    class="mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transition-colors">
                                Thêm vào giỏ
                            </button>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200 hover:shadow-md transition-shadow" data-category="7">
                        <img src="https://placehold.co/200x150/1abc9c/white?text=Salad"
                             alt="Salad rau củ"
                             class="w-full h-28 object-cover">
                        <div class="p-3">
                            <h3 class="font-medium text-gray-800 text-sm line-clamp-1">Salad rau củ</h3>
                            <div class="flex items-center mt-1">
                                <span class="text-sm font-bold text-blue-600">18,400đ</span>
                                <span class="ml-1 text-xs text-red-500 line-through">20,000đ</span>
                            </div>
                            <div class="flex items-center mt-1">
                                <i data-lucide="star" class="w-3 h-3 text-yellow-400 fill-current"></i>
                                <span class="ml-1 text-xs text-gray-600">4.2</span>
                                <span class="ml-auto bg-red-500 text-white text-xs px-1 py-0.5 rounded">-8%</span>
                            </div>
                            <button onclick="addToCart(4)"
                                    class="mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transition-colors">
                                Thêm vào giỏ
                            </button>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200 hover:shadow-md transition-shadow" data-category="8">
                        <img src="https://placehold.co/200x150/e67e22/white?text=Trứng"
                             alt="Trứng ốp la"
                             class="w-full h-28 object-cover">
                        <div class="p-3">
                            <h3 class="font-medium text-gray-800 text-sm line-clamp-1">Trứng ốp la</h3>
                            <div class="flex items-center mt-1">
                                <span class="text-sm font-bold text-blue-600">8,000đ</span>
                            </div>
                            <div class="flex items-center mt-1">
                                <i data-lucide="star" class="w-3 h-3 text-yellow-400 fill-current"></i>
                                <span class="ml-1 text-xs text-gray-600">4.1</span>
                            </div>
                            <button onclick="addToCart(10)"
                                    class="mt-2 w-full bg-blue-600 text-white py-1.5 rounded text-sm hover:bg-blue-700 transition-colors">
                                Thêm vào giỏ
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
<jsp:include page="/WEB-INF/jsp/common/cart-sidebar.jsp" />
<script>
    document.addEventListener('DOMContentLoaded', function() {
        lucide.createIcons();
    });

    function filterCategory(categoryId) {
        // Update active state
        document.querySelectorAll('.lg\\:w-1\\/4 ul li a').forEach(link => {
            link.classList.remove('bg-blue-50', 'font-medium');
        });
        event.target.closest('a').classList.add('bg-blue-50', 'font-medium');

        // Filter foods
        const foods = document.querySelectorAll('#foods-grid > div');
        foods.forEach(food => {
            if (categoryId === 0 || food.dataset.category == categoryId) {
                food.style.display = 'block';
            } else {
                food.style.display = 'none';
            }
        });
    }

    function addToCart(foodId) {
        alert('Tính năng thêm vào giỏ hàng sẽ được triển khai khi kết nối backend!');
    }
</script>
</body>
</html>