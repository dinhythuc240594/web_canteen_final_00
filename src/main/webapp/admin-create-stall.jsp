<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("type_user");

    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    if (!"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Tạo quầy mới - Quản trị</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<main class="min-h-screen py-8">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="mb-6">
            <a href="<%=contextPath%>/admin.jsp#stalls" class="inline-flex items-center text-sm text-blue-600 hover:text-blue-800">
                <i data-lucide="arrow-left" class="w-4 h-4 mr-1"></i>
                Quay lại trang quản trị
            </a>
        </div>

        <div class="bg-white border shadow-sm rounded-xl p-6 space-y-6">
            <div>
                <p class="text-sm uppercase tracking-wide text-orange-500 font-semibold">Quản lý quầy ăn</p>
                <h1 class="text-2xl md:text-3xl font-bold text-gray-900 mt-1">Đăng ký quầy mới</h1>
                <p class="text-gray-600 mt-2">Nhập thông tin quầy và gán cho chủ quầy đã có tài khoản.</p>
            </div>

            <div class="bg-orange-50 border border-orange-100 rounded-lg p-4 flex items-start space-x-3 text-sm text-orange-900">
                <i data-lucide="alert-triangle" class="w-5 h-5 mt-0.5 flex-shrink-0"></i>
                <p>
                    Hãy đảm bảo chủ quầy đã có tài khoản loại <span class="font-semibold">Chủ quầy</span> trước khi tạo quầy.
                    Bạn có thể tạo nhanh trong trang <a href="<%=contextPath%>/admin-create-user.jsp" class="underline">tạo tài khoản</a>.
                </p>
            </div>

            <form id="create-stall-form" class="space-y-5">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <div class="md:col-span-2">
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Tên quầy<span class="text-red-500">*</span></label>
                        <input name="name" type="text" required placeholder="Quầy bánh mì Đức Huy"
                               class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500" />
                    </div>
                    <div class="md:col-span-2">
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Mô tả chi tiết</label>
                        <textarea name="description" rows="4" placeholder="Món chính, thời gian phục vụ, ưu đãi ..."
                                  class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"></textarea>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Chủ quầy<span class="text-red-500">*</span></label>
                        <select name="managerUserId" id="stall-manager-select" required
                                class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                            <option value="">Đang tải danh sách...</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Trạng thái ban đầu</label>
                        <div class="flex items-center space-x-3 mt-2">
                            <input type="checkbox" id="stall-is-open" name="isOpen"
                                   class="rounded border-gray-300 text-blue-600 focus:ring-blue-500">
                            <label for="stall-is-open" class="text-sm text-gray-700">Mở cửa ngay sau khi tạo</label>
                        </div>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Giờ mở cửa</label>
                        <input type="time" name="openTime"
                               class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Giờ đóng cửa</label>
                        <input type="time" name="closeTime"
                               class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    </div>
                </div>

                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Ghi chú nội bộ</label>
                    <textarea name="note" rows="3" placeholder="(Không bắt buộc) ví dụ: Ưu tiên hiển thị trong trang chủ"
                              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"></textarea>
                </div>

                <div class="flex flex-wrap items-center justify-end gap-3 pt-2">
                    <button type="button" onclick="document.getElementById('create-stall-form').reset()"
                            class="px-4 py-2 rounded-lg border text-gray-700 hover:bg-gray-50 transition">
                        Làm mới
                    </button>
                    <button type="submit"
                            class="px-5 py-2 rounded-lg bg-blue-600 text-white font-semibold hover:bg-blue-700 transition flex items-center space-x-2">
                        <i data-lucide="store" class="w-4 h-4"></i>
                        <span>Tạo quầy</span>
                    </button>
                </div>
            </form>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />

<script>
    const adminContextPath = '<%=contextPath%>';
    const stallForm = document.getElementById('create-stall-form');
    const managerSelect = document.getElementById('stall-manager-select');

    function showAlert(message, success) {
        alert(message || (success ? 'Thao tác thành công' : 'Đã có lỗi xảy ra'));
    }

    function populateManagers() {
        if (!managerSelect) return;
        fetch(adminContextPath + '/admin?action=stalls-users')
            .then(res => res.json())
            .then(users => {
                if (!Array.isArray(users) || users.length === 0) {
                    managerSelect.innerHTML = '<option value="">Chưa có chủ quầy nào</option>';
                    return;
                }
                managerSelect.innerHTML = '<option value="">-- Chọn chủ quầy --</option>' +
                    users.map(function(user) {
                        const display = (user.fullName || user.username || 'User') + ' (' + (user.username || 'N/A') + ')';
                        return '<option value="' + user.id + '">' + display + '</option>';
                    }).join('');
            })
            .catch(() => {
                managerSelect.innerHTML = '<option value="">Không thể tải danh sách</option>';
            });
    }

    if (stallForm) {
        stallForm.addEventListener('submit', function (e) {
            e.preventDefault();
            const formData = new FormData(stallForm);
            formData.append('action', 'createStall');
            formData.set('isOpen', formData.get('isOpen') ? 'true' : 'false');

            if (!formData.get('managerUserId')) {
                showAlert('Vui lòng chọn chủ quầy');
                return;
            }

            fetch(adminContextPath + '/admin', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams(formData)
            })
                .then(res => res.json())
                .then(data => {
                    showAlert(data.message, data.success);
                    if (data.success) {
                        stallForm.reset();
                    }
                })
                .catch(() => showAlert('Có lỗi xảy ra khi tạo quầy'));
        });
    }

    populateManagers();
    if (window.lucide) {
        lucide.createIcons();
    }
</script>
</body>
</html>

