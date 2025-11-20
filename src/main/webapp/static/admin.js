// Set current user ID for JavaScript
// var adminContextPath = '<%=contextPath%>';
var adminContextPath = URL_ADMIN;
// var currentUserIdAttr = document.body.getAttribute('data-current-user-id');
var currentUserIdAttr = $('.min-h-screen').attr('data-current-user-id')
var currentUserId = currentUserIdAttr ? parseInt(currentUserIdAttr, 10) : null;
var revenueChartInstance = null;
var allUsersData = [];
var allFoodsData = [];
var allOrdersData = [];
var currentUserType = 'customer';

// Active state cho menu + chuyển view theo hash
function setActiveView(hash) {
    const views = document.querySelectorAll('.admin-view');
    views.forEach(v => v.classList.add('hidden'));
    const target = document.querySelector('[data-view="' + (hash || 'dashboard') + '"]');
    if (target) target.classList.remove('hidden');

    document.querySelectorAll('#admin-nav a').forEach(a => {
        if (a.getAttribute('href') === '#' + (hash || 'dashboard')) {
            a.classList.add('bg-blue-100', 'text-blue-700');
        } else {
            a.classList.remove('bg-blue-100', 'text-blue-700');
        }
    });

    const mobile = document.getElementById('admin-mobile-nav');
    if (mobile && ('#' + (hash || 'dashboard')) !== mobile.value) {
        mobile.value = '#' + (hash || 'dashboard');
    }
    // cập nhật icon
    if (window.lucide) lucide.createIcons();
}

window.addEventListener('hashchange', () => {
    setActiveView(location.hash.replace('#', ''));
});
document.getElementById('admin-mobile-nav')?.addEventListener('change', (e) => {
    location.hash = e.target.value;
});

// Initialize report dates
updateReportDates();

// Lần đầu vào trang
setActiveView(location.hash.replace('#', '') || 'dashboard');

// Load data when switching tabs
window.addEventListener('hashchange', function() {
    const hash = location.hash.replace('#', '');
    if (hash === 'users') {
        loadUsers('customer');
    } else if (hash === 'stalls') {
        loadStalls();
    } else if (hash === 'foods') {
        loadFoods();
    } else if (hash === 'orders') {
        loadOrders();
    } else if (hash === 'reports') {
        loadReports();
    }
});

// Load on initial page load if hash is set
const initialHash = location.hash.replace('#', '');
if (initialHash === 'foods') {
    loadFoods();
} else if (initialHash === 'orders') {
    loadOrders();
} else if (initialHash === 'reports') {
    loadReports();
}


// Load users data - loads customers or stall users with orders
function loadUsers(type) {
    type = type || 'customer';
    currentUserType = type;
    const action = type === 'customer' ? 'customers' : 'stalls-users';

    fetch(adminContextPath + '/admin?action=' + action)
        .then(response => response.json())
        .then(users => {
            allUsersData = users;
            const tbody = document.getElementById('users-table-body');
            if (tbody) {
                if (users.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="9" class="py-4 px-3 text-center text-gray-500">Chưa có người dùng nào</td></tr>';
                } else {
                    renderUsers(users);
                }
            }
        })
        .catch(error => console.error('Error loading users:', error));
}

function renderUsers(users) {
    const tbody = document.getElementById('users-table-body');
    if (!tbody) return;

    if (users.length === 0) {
        tbody.innerHTML = '<tr><td colspan="9" class="py-4 px-3 text-center text-gray-500">Không tìm thấy kết quả</td></tr>';
        return;
    }

    if (currentUserType === 'customer') {
        tbody.innerHTML = users.map(customer => {
            const statusClass = customer.status ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800';
            const statusText = customer.status ? 'Hoạt động' : 'Khóa';
            const formattedDate = customer.createDate ? new Date(customer.createDate).toLocaleDateString('vi-VN') : 'N/A';
            const totalSpent = customer.totalSpent ? customer.totalSpent.toLocaleString('vi-VN') : '0';

            return '<tr class="border-b hover:bg-gray-50">'
                + '<td class="py-3 px-4">#' + customer.id + '</td>'
                + '<td class="py-3 px-4">' + (customer.username || 'N/A') + '</td>'
                + '<td class="py-3 px-4">' + (customer.email || 'N/A') + '</td>'
                + '<td class="py-3 px-4">' + (customer.phone || 'N/A') + '</td>'
                + '<td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs bg-blue-100 text-blue-800">Khách hàng</span></td>'
                + '<td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs' + statusClass + '">'+ statusText +'</span></td>'
                + '<td class="py-3 px-4">' + totalSpent + 'đ</td>'
                + '<td class="py-3 px-4">' + formattedDate + '</td>'
                + '<td class="py-3 px-4">'
                + '<div class="flex space-x-2">'
                +            '<button onclick="toggleUserStatus(\''+ customer.id +'\',\'' + (customer.status ? 'false' : 'true') + '\')" class="p-1 text-blue-600 hover:text-blue-800" title="' + (customer.status ? 'Khóa' : 'Mở khóa') + '">'
                +                '<i data-lucide="'+ (customer.status ? 'user-x' : 'user-check') +'" class="w-4 h-4"></i>'
                +            '</button>'
                +        '</div>'
                +    '</td>'
                + '</tr>';
        }).join('');
    } else {
        tbody.innerHTML = users.map(stallUser => {
            const statusClass = stallUser.status ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800';
            const statusText = stallUser.status ? 'Hoạt động' : 'Khóa';
            const formattedDate = stallUser.createDate ? new Date(stallUser.createDate).toLocaleDateString('vi-VN') : 'N/A';
            const totalRevenue = stallUser.totalRevenue ? stallUser.totalRevenue.toLocaleString('vi-VN') : '0';

            return '<tr class="border-b hover:bg-gray-50">'
                + '<td class="py-3 px-4">#'+ stallUser.id +'</td>'
                + '<td class="py-3 px-4">' + (stallUser.username || 'N/A') + '</td>'
                + '<td class="py-3 px-4">' + (stallUser.email || 'N/A') + '</td>'
                + '<td class="py-3 px-4">' + (stallUser.phone || 'N/A') + '</td>'
                + '<td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs bg-purple-100 text-purple-800">Quầy:' + (stallUser.stallName || 'Chưa có quầy') + '</span></td>'
                + '<td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs '+ statusClass + '">' + statusText + '</span></td>'
                + '<td class="py-3 px-4">'+ totalRevenue + 'đ</td>'
                + '<td class="py-3 px-4">' + formattedDate + '</td>'
                + '<td class="py-3 px-4">'
                + '<div class="flex space-x-2">'
                + '<button onclick="toggleUserStatus(\'' + stallUser.id +',\'' + (stallUser.status ? 'false' : 'true') + '\')" class="p-1 text-blue-600 hover:text-blue-800" title="' + (stallUser.status ? 'Khóa' : 'Mở khóa') +'">'
                + '<i data-lucide="'+ (stallUser.status ? 'user-x' : 'user-check') + '" class="w-4 h-4"></i>'
                + '</button>'
                + '</div>'
                +    '</td>'
                + '</tr>';
        }).join('');
    }
    lucide.createIcons();
}

// Filter users
function filterUsers() {
    const searchTerm = document.getElementById('users-search').value.toLowerCase();
    const statusFilter = document.getElementById('users-status-filter').value;
    const typeFilter = document.getElementById('users-type-filter').value;

    let filtered = allUsersData.filter(user => {
        // Search filter
        const matchesSearch = !searchTerm ||
            (user.username && user.username.toLowerCase().includes(searchTerm)) ||
            (user.email && user.email.toLowerCase().includes(searchTerm)) ||
            (user.phone && user.phone.toLowerCase().includes(searchTerm)) ||
            (user.fullName && user.fullName.toLowerCase().includes(searchTerm));

        // Status filter
        const matchesStatus = statusFilter === 'all' ||
            (statusFilter === 'true' && user.status === true) ||
            (statusFilter === 'false' && user.status === false);

        // Type filter
        const matchesType = typeFilter === 'all' ||
            (typeFilter === 'customer' && currentUserType === 'customer') ||
            (typeFilter === 'stall' && currentUserType === 'stall');

        return matchesSearch && matchesStatus && matchesType;
    });

    renderUsers(filtered);
}

function clearUsersFilter() {
    document.getElementById('users-search').value = '';
    document.getElementById('users-status-filter').value = 'all';
    document.getElementById('users-type-filter').value = 'all';
    renderUsers(allUsersData);
}

// Load foods data
function loadFoods() {
    fetch(adminContextPath + '/admin?action=foods')
        .then(response => response.json())
        .then(foods => {
            allFoodsData = foods;
            const tbody = document.getElementById('foods-table-body');
            if (tbody) {
                if (foods.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="7" class="py-4 px-3 text-center text-gray-500">Chưa có món ăn nào</td></tr>';
                } else {
                    // Populate stall filter
                    const stallFilter = document.getElementById('foods-stall-filter');
                    // Clear existing options except "Tất cả quầy"
                    while (stallFilter.children.length > 1) {
                        stallFilter.removeChild(stallFilter.lastChild);
                    }
                    const uniqueStalls = [...new Set(foods.map(f => f.stallName).filter(Boolean))];
                    uniqueStalls.forEach(stallName => {
                        const option = document.createElement('option');
                        option.value = stallName;
                        option.textContent = stallName;
                        stallFilter.appendChild(option);
                    });

                    renderFoods(foods);
                }
            }
        })
        .catch(error => console.error('Error loading foods:', error));
}

function renderFoods(foods) {
    const tbody = document.getElementById('foods-table-body');
    if (!tbody) return;

    if (foods.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="py-4 px-3 text-center text-gray-500">Không tìm thấy kết quả</td></tr>';
        return;
    }

    tbody.innerHTML = foods.map(food => {
        const imageUrl = food.image ? adminContextPath + '/uploads/' + food.image : 'https://placehold.co/40x40/3498db/white?text=' + encodeURIComponent((food.name || 'NA').substring(0, 2));
        // const promotionText = food.promotion && food.promotion > 0 ? food.promotion + '%' : 'Không';
        var html = '';
        html += '<tr class="border-b hover:bg-gray-50">';
        html += '<td class="py-3 px-4">'
        html += '<div class="flex items-center space-x-3">'
        // html += '<img src="' + imageUrl + '"';
        // html += 'class="w-10 h-10 rounded object-cover" alt="' + (food.name || 'N/A') +'"/>';
        html += '<span>' + (food.name || "N/A") + '</span>';
        html += '</div>';
        html += '</td>';
        html += '<td class="py-3 px-4">' + (food.price ? food.price.toLocaleString('vi-VN') : '0') +'đ</td>';
        // html += '<td class="py-3 px-4">-</td>'
        // html += '<td class="py-3 px-4">' + (food.stallName || 'N/A') +'</td>';
        // html += '<td class="py-3 px-4">' + promotionText + '</td>';
        html += '<td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs bg-green-100 text-green-800">Hoạt động</span></td>';
        html += '<td class="py-3 px-4">'
        html +=     '<div class="flex space-x-2">'
        html +=     '<button class="p-1 text-blue-600 hover:text-blue-800"><i data-lucide="edit" class="w-4 h-4"></i></button>';
        html +=     '<button class="p-1 text-red-600 hover:text-red-800"><i data-lucide="trash-2" class="w-4 h-4"></i></button>';
        html += '</div>';
        html += '</td>';
        html += '</tr>';
        return html;
    }).join('');
    lucide.createIcons();
}

// Filter foods
function filterFoods() {
    const searchTerm = document.getElementById('foods-search').value.toLowerCase();
    const categoryFilter = document.getElementById('foods-category-filter').value;
    const stallFilter = document.getElementById('foods-stall-filter').value;
    const statusFilter = document.getElementById('foods-status-filter').value;

    let filtered = allFoodsData.filter(food => {
        const matchesSearch = !searchTerm ||
            (food.name && food.name.toLowerCase().includes(searchTerm));
        const matchesCategory = categoryFilter === 'all' || food.categoryId == categoryFilter;
        const matchesStall = stallFilter === 'all' || food.stallName === stallFilter;
        const matchesStatus = statusFilter === 'all' ||
            (statusFilter === 'active') ||
            (statusFilter === 'inactive');

        return matchesSearch && matchesCategory && matchesStall && matchesStatus;
    });

    renderFoods(filtered);
}

function clearFoodsFilter() {
    document.getElementById('foods-search').value = '';
    document.getElementById('foods-category-filter').value = 'all';
    document.getElementById('foods-stall-filter').value = 'all';
    document.getElementById('foods-status-filter').value = 'all';
    renderFoods(allFoodsData);
}

// Load orders data
function loadOrders() {
    fetch(adminContextPath + '/admin?action=orders')
        .then(response => response.json())
        .then(orders => {
            allOrdersData = orders;
            const tbody = document.getElementById('orders-table-body');
            if (tbody) {
                if (orders.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="8" class="py-4 px-3 text-center text-gray-500">Chưa có đơn hàng nào</td></tr>';
                } else {
                    // Populate stall filter
                    const stallFilter = document.getElementById('orders-stall-filter');
                    // Clear existing options except "Tất cả quầy"
                    while (stallFilter.children.length > 1) {
                        stallFilter.removeChild(stallFilter.lastChild);
                    }
                    const uniqueStalls = [...new Set(orders.map(o => o.stallName).filter(Boolean))];
                    uniqueStalls.forEach(stallName => {
                        const option = document.createElement('option');
                        option.value = stallName;
                        option.textContent = stallName;
                        stallFilter.appendChild(option);
                    });

                    renderOrders(orders);
                }
            }
        })
        .catch(error => console.error('Error loading orders:', error));
}

function renderOrders(orders) {
    const tbody = document.getElementById('orders-table-body');
    if (!tbody) return;

    if (orders.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="py-4 px-3 text-center text-gray-500">Không tìm thấy kết quả</td></tr>';
        return;
    }

    tbody.innerHTML = orders.map(order => {
        let statusText = 'N/A';
        let statusClass = 'bg-gray-100 text-gray-800';
        if (order.status) {
            switch(order.status) {
                case 'new_order':
                    statusText = 'Chờ xử lý';
                    statusClass = 'bg-yellow-100 text-yellow-800';
                    break;
                case 'confirmed':
                    statusText = 'Đã xác nhận';
                    statusClass = 'bg-blue-100 text-blue-800';
                    break;
                case 'in_delivery':
                    statusText = 'Đang giao';
                    statusClass = 'bg-purple-100 text-purple-800';
                    break;
                case 'delivered':
                    statusText = 'Hoàn thành';
                    statusClass = 'bg-green-100 text-green-800';
                    break;
            }
        }
        const formattedDate = order.createdAt ? new Date(order.createdAt).toLocaleString('vi-VN') : 'N/A';

        var html = '';
        html += '<tr class="border-b hover:bg-gray-50">';
        html += '<td class="py-3 px-4">#'+ order.id +'</td>';
        html += '<td class="py-3 px-4">' + (order.userName || 'N/A') +'</td>';
        html += '<td class="py-3 px-4">-</td>'
        html += '<td class="py-3 px-4">' + (order.totalPrice ? order.totalPrice.toLocaleString('vi-VN') : '0') + 'đ</td>';
        html += '<td class="py-3 px-4">' + (order.stallName || 'N/A') + '</td>';
        html += '<td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs' + statusClass + '">' + statusText + '</span></td>';
        html += '<td class="py-3 px-4">' + (order.paymentMethod || 'N/A') + '</td>';
        html += '<td class="py-3 px-4">' + formattedDate + '</td>';
        html += '<td class="py-3 px-4">';
        html += '<div class="flex space-x-2">';
        html += '<button class="p-1 text-blue-600 hover:text-blue-800"><i data-lucide="eye" class="w-4 h-4"></i></button>';
        html += '</div>';
        html += '</td>';
        html += '</tr>';

        return html;
    }).join('');
    lucide.createIcons();
}

// Filter orders
function filterOrders() {
    const searchTerm = document.getElementById('orders-search').value.toLowerCase();
    const statusFilter = document.getElementById('orders-status-filter').value;
    const stallFilter = document.getElementById('orders-stall-filter').value;
    const dateFilter = document.getElementById('orders-date-filter').value;

    let filtered = allOrdersData.filter(order => {
        const matchesSearch = !searchTerm ||
            (order.id && order.id.toString().includes(searchTerm)) ||
            (order.userName && order.userName.toLowerCase().includes(searchTerm)) ||
            (order.stallName && order.stallName.toLowerCase().includes(searchTerm));

        const matchesStatus = statusFilter === 'all' || order.status === statusFilter;
        const matchesStall = stallFilter === 'all' || order.stallName === stallFilter;

        let matchesDate = true;
        if (dateFilter) {
            const orderDate = order.createdAt ? new Date(order.createdAt).toISOString().split('T')[0] : '';
            matchesDate = orderDate === dateFilter;
        }

        return matchesSearch && matchesStatus && matchesStall && matchesDate;
    });

    renderOrders(filtered);
}

function clearOrdersFilter() {
    document.getElementById('orders-search').value = '';
    document.getElementById('orders-status-filter').value = 'all';
    document.getElementById('orders-stall-filter').value = 'all';
    document.getElementById('orders-date-filter').value = '';
    renderOrders(allOrdersData);
}

// Load reports data
function loadReports() {
    fetch(adminContextPath + '/admin?action=revenue-report')
        .then(response => response.json())
        .then(report => {
            // Update total revenue
            const totalRevenueEl = document.getElementById('total-revenue');
            if (totalRevenueEl && report.totalRevenue !== undefined) {
                totalRevenueEl.textContent = report.totalRevenue.toLocaleString('vi-VN') + 'đ';
            }

            // Update best selling foods
            const bestSellingContainer = document.querySelector('[data-view="reports"] .space-y-2');
            if (bestSellingContainer && report.bestSellingFoods) {
                if (report.bestSellingFoods.length === 0) {
                    bestSellingContainer.innerHTML = '<div class="text-gray-500 text-center py-4">Chưa có dữ liệu món bán chạy</div>';
                } else {
                    bestSellingContainer.innerHTML = report.bestSellingFoods.map((food, index) =>
                        '<div class="flex justify-between border-b py-2">' +
                        '<div class="flex items-center space-x-3">' +
                        '<span class="text-sm font-medium text-gray-500">#'+ (index + 1) + '</span>' +
                        '<span>'+ (food.foodName || 'N/A') + '</span>' +
                        '</div>' +
                        '<span class="font-semibold text-green-600">'+ (food.totalQuantity || 0) +' đơn</span>'+
                        '</div>'
                    ).join('');

                    // Update top food
                    const topFoodEl = document.getElementById('top-food');
                    if (topFoodEl && report.bestSellingFoods.length > 0) {
                        topFoodEl.textContent = report.bestSellingFoods[0].foodName || '-';
                    }
                }
            }
            renderDashboardBestSellers(report.bestSellingFoods || []);
        })
        .catch(error => console.error('Error loading reports:', error));
}

// Update report dates based on period selection
function updateReportDates() {
    const period = document.getElementById('reports-period').value;
    const startDate = document.getElementById('reports-start-date');
    const endDate = document.getElementById('reports-end-date');
    const today = new Date();

    if (period === 'today') {
        startDate.value = today.toISOString().split('T')[0];
        endDate.value = today.toISOString().split('T')[0];
    } else if (period === 'week') {
        const weekAgo = new Date(today);
        weekAgo.setDate(today.getDate() - 7);
        startDate.value = weekAgo.toISOString().split('T')[0];
        endDate.value = today.toISOString().split('T')[0];
    } else if (period === 'month') {
        const monthAgo = new Date(today);
        monthAgo.setDate(today.getDate() - 30);
        startDate.value = monthAgo.toISOString().split('T')[0];
        endDate.value = today.toISOString().split('T')[0];
    }
    // For 'custom', user can manually select dates
}

function updateReportPeriod() {
    // When user manually changes dates, set period to 'custom'
    document.getElementById('reports-period').value = 'custom';
}

// ---------- Dashboard revenue chart & best sellers ----------
function getDateString(date) {
    return date.toISOString().split('T')[0];
}

function fetchRevenueStatistics(days) {
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(endDate.getDate() - (parseInt(days, 10) - 1));
    const params = new URLSearchParams({
        action: 'statistics',
        startDate: getDateString(startDate),
        endDate: getDateString(endDate)
    });
    return fetch(adminContextPath + '/admin?' + params.toString())
        .then(res => res.json())
        .catch(() => []);
}

function prepareRevenueData(stats, days) {
    const map = new Map();
    (stats || []).forEach(stat => {
        const date = stat.statDate ? stat.statDate.split('T')[0] : '';
        if (!date) return;
        const revenue = stat.revenue || 0;
        map.set(date, (map.get(date) || 0) + revenue);
    });
    const dataPoints = [];
    const end = new Date();
    const start = new Date();
    start.setDate(end.getDate() - (parseInt(days, 10) - 1));
    for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
        const key = getDateString(d);
        dataPoints.push({
            date: new Date(key).toLocaleDateString('vi-VN'),
            revenue: map.get(key) || 0
        });
    }
    return dataPoints;
}

function renderRevenueChart(dataPoints) {
    const canvas = document.getElementById('revenue-chart');
    if (!canvas) return;
    if (revenueChartInstance) {
        revenueChartInstance.destroy();
    }
    revenueChartInstance = new Chart(canvas, {
        type: 'line',
        data: {
            labels: dataPoints.map(d => d.date),
            datasets: [{
                label: 'Doanh thu (đ)',
                data: dataPoints.map(d => d.revenue),
                borderColor: '#2563eb',
                backgroundColor: 'rgba(37, 99, 235, 0.15)',
                fill: true,
                tension: 0.3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: {
                    ticks: {
                        callback: value => value.toLocaleString('vi-VN') + 'đ'
                    }
                }
            }
        }
    });
}

function loadRevenueChart(days) {
    fetchRevenueStatistics(days).then(stats => {
        const dataPoints = prepareRevenueData(stats, days);
        renderRevenueChart(dataPoints);
    });
}

function renderDashboardBestSellers(foods) {
    const container = document.getElementById('best-seller-list');
    if (!container) return;
    if (!foods || foods.length === 0) {
        container.innerHTML = '<div class="text-gray-500 text-center py-4">Chưa có dữ liệu</div>';
        return;
    }
    container.innerHTML = foods.slice(0, 5).map(function(food, index) {
        return '' +
            '<div class="flex items-center justify-between border-b pb-2">' +
            '<div class="flex items-center gap-3">' +
            '<span class="text-sm font-semibold text-gray-500">#' + (index + 1) + '</span>' +
            '<div>' +
            '<p class="font-medium">' + (food.foodName || 'N/A') + '</p>' +
            '<p class="text-xs text-gray-500">' + ((food.totalQuantity || 0).toLocaleString('vi-VN')) + ' món</p>' +
            '</div>' +
            '</div>' +
            '<span class="text-sm font-semibold text-green-600">' + ((food.totalRevenue || 0).toLocaleString('vi-VN')) + 'đ</span>' +
            '</div>';
    }).join('');
}

const bestSellerRefreshBtn = document.getElementById('refresh-best-seller');
if (bestSellerRefreshBtn) {
    bestSellerRefreshBtn.addEventListener('click', () => {
        renderDashboardBestSellers([]);
        fetch(adminContextPath + '/admin?action=revenue-report')
            .then(res => res.json())
            .then(report => renderDashboardBestSellers(report.bestSellingFoods || []))
            .catch(() => alert('Không thể tải dữ liệu món bán chạy'));
    });
}

const chartRangeSelect = document.getElementById('revenue-chart-range');
if (chartRangeSelect) {
    chartRangeSelect.addEventListener('change', () => loadRevenueChart(chartRangeSelect.value));
}

// Load stalls data
function loadStalls() {
    fetch(adminContextPath + '/admin?action=stalls')
        .then(response => response.json())
        .then(stalls => {
            const tbody = document.querySelector('[data-view="stalls"] tbody');
            if (tbody) {
                if (stalls.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="py-4 px-3 text-center text-gray-500">Chưa có quầy nào</td></tr>';
                } else {
                    tbody.innerHTML = stalls.map(stall => {
                        const statusClass = stall.isOpen ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800';
                        const statusText = stall.isOpen ? 'Mở cửa' : 'Đóng cửa';
                        const isMyStall = currentUserId !== null && currentUserId === stall.managerUserId;
                        const myStallLabel = isMyStall ? '<span class="px-2 py-0.5 bg-green-100 text-green-800 text-xs rounded-full font-medium ml-2">Quầy của tôi</span>' : '';

                        var html = '';
                        html += '<tr class="border-b hover:bg-gray-50">';
                        html += '<td class="py-3 px-4">#'+ stall.id +'</td>';
                        html += '<td class="py-3 px-4">'
                        html += '<div class="flex items-center">'+ stall.name + myStallLabel
                        html += '</div>';
                        html += '</td>'
                        html += '<td class="py-3 px-4">'+ (stall.description || 'N/A') +'</td>'
                        html += '<td class="py-3 px-4">User #'+ stall.managerUserId +'</td>'
                        html += '<td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs'+ statusClass + '">'+ statusText +'</span></td>'
                        html += '<td class="py-3 px-4">'
                        html +=     '<div class="flex space-x-2">'
                        html +=     '<button class="p-1 text-blue-600 hover:text-blue-800" title="Sửa">'
                        html +=         '<i data-lucide="edit" class="w-4 h-4"></i>'
                        html +=     '</button>'
                        html += '</div>'
                        html += '</td>'
                        html +='</tr>';
                        return html;
                    }).join('');
                    lucide.createIcons();
                }
            }
        })
        .catch(error => console.error('Error loading stalls:', error));
}

// Toggle user status
function toggleUserStatus(userId, newStatus) {
    if (!confirm('Bạn có chắc chắn muốn ' + (newStatus ? 'mở khóa' : 'khóa') + ' tài khoản này?')) {
        return;
    }

    // Ensure boolean is converted to string "true" or "false"
    const statusValue = newStatus === true || newStatus === 'true' || newStatus === 1 ? 'true' : 'false';

    fetch(adminContextPath + '/admin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
            action: 'toggleUserStatus',
            id: userId.toString(),
            status: statusValue
        })
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert(data.message);
                loadUsers(currentUserType);
            } else {
                alert('Lỗi: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Có lỗi xảy ra');
        });
}

// Initial loads for dashboard widgets
loadUsers('customer');
loadStalls();
const defaultRange = chartRangeSelect ? chartRangeSelect.value : 7;
loadRevenueChart(defaultRange);
fetch(adminContextPath + '/admin?action=revenue-report')
    .then(res => res.json())
    .then(report => renderDashboardBestSellers(report.bestSellingFoods || []));