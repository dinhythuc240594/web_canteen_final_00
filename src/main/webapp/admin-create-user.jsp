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
    <title>Tạo tài khoản - Quản trị</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<main class="min-h-screen py-8">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="mb-6">
            <a href="<%=contextPath%>/admin.jsp#users" class="inline-flex items-center text-sm text-blue-600 hover:text-blue-800">
                <i data-lucide="arrow-left" class="w-4 h-4 mr-1"></i>
                Quay lại trang quản trị
            </a>
        </div>
        <div class="bg-white border shadow-sm rounded-xl p-6 space-y-6">
            <div>
                <p class="text-sm uppercase tracking-wide text-blue-600 font-semibold">Quản trị hệ thống</p>
                <h1 class="text-2xl md:text-3xl font-bold text-gray-900 mt-1">Tạo tài khoản mới</h1>
                <p class="text-gray-600 mt-2">Biểu mẫu riêng giúp bạn tạo nhanh khách hàng, chủ quầy hoặc quản trị viên.</p>
            </div>

            <div class="bg-blue-50 border border-blue-100 rounded-lg p-4 flex items-start space-x-3 text-sm text-blue-800">
                <i data-lucide="info" class="w-5 h-5 mt-0.5 flex-shrink-0"></i>
                <p>
                    Mật khẩu mặc định cho tài khoản mới là <span class="font-semibold">123456</span>.
                    Người dùng nên đổi mật khẩu trong lần đăng nhập đầu tiên.
                </p>
            </div>

            <form id="create-user-form" class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Tên đăng nhập<span class="text-red-500">*</span></label>
                    <input name="username" type="text" required placeholder="ví dụ: admin01"
                           class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500" />
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Họ và tên<span class="text-red-500">*</span></label>
                    <input name="fullName" type="text" required placeholder="Nguyễn Văn A"
                           class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500" />
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Email<span class="text-red-500">*</span></label>
                    <input name="email" type="email" required placeholder="user@example.com"
                           class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500" />
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Số điện thoại</label>
                    <input name="phone" type="tel" placeholder="0912 345 678"
                           class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500" />
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Loại tài khoản<span class="text-red-500">*</span></label>
                    <select name="role" required class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        <option value="customer">Khách hàng</option>
                        <option value="stall">Chủ quầy</option>
                        <option value="admin">Quản trị viên</option>
                    </select>
                </div>
                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Ghi chú nội bộ</label>
                    <textarea name="note" rows="3" placeholder="(Không bắt buộc) ví dụ: tạo giúp chủ quầy mới"
                              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"></textarea>
                </div>
                <div class="md:col-span-2 flex flex-wrap items-center justify-end gap-3">
                    <button type="button"
                            onclick="document.getElementById('create-user-form').reset()"
                            class="px-4 py-2 rounded-lg border text-gray-700 hover:bg-gray-50 transition">
                        Làm mới
                    </button>
                    <button type="submit"
                            class="px-5 py-2 rounded-lg bg-blue-600 text-white font-semibold hover:bg-blue-700 transition flex items-center space-x-2">
                        <i data-lucide="check-circle" class="w-4 h-4"></i>
                        <span>Tạo tài khoản</span>
                    </button>
                </div>
            </form>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />

<script>
    const adminContextPath = '<%=contextPath%>';
    const userForm = document.getElementById('create-user-form');

    function showAlert(message, success) {
        alert(message || (success ? 'Thao tác thành công' : 'Đã có lỗi xảy ra'));
    }

    if (userForm) {
        userForm.addEventListener('submit', function (e) {
            e.preventDefault();
            const formData = new FormData(userForm);
            formData.append('action', 'createUser');

            fetch(adminContextPath + '/admin', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams(formData)
            })
                .then(res => res.json())
                .then(data => {
                    showAlert(data.message, data.success);
                    if (data.success) {
                        userForm.reset();
                    }
                })
                .catch(() => showAlert('Có lỗi xảy ra khi tạo tài khoản'));
        });
    }

    if (window.lucide) {
        lucide.createIcons();
    }
</script>
</body>
</html>

