<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("type_user");
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    if (userRole == null || (!"customer".equals(userRole) && !"stall".equals(userRole))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    java.util.List<String> passwordErrors = (java.util.List<String>) request.getAttribute("passwordErrors");
    String contextPath = request.getContextPath();
    String backUrl = "stall".equals(userRole) ? (contextPath + "/stall") : (contextPath + "/customer");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đổi mật khẩu</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
    <style>
        .password-input::-ms-reveal {
            display: none;
        }
    </style>
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<main class="min-h-screen">
    <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <div class="mb-8">
            <a href="<%= backUrl %>" class="inline-flex items-center text-sm text-blue-600 hover:text-blue-800">
                <i data-lucide="arrow-left" class="w-4 h-4 mr-1"></i>
                Quay lại trang trước
            </a>
        </div>
        <div class="bg-white border rounded-2xl shadow-sm p-6 md:p-8 space-y-8">
            <div class="space-y-2">
                <p class="text-sm uppercase tracking-wide text-blue-600 font-semibold">Tài khoản của bạn</p>
                <h1 class="text-2xl md:text-3xl font-bold text-gray-900">Đổi mật khẩu</h1>
                <p class="text-gray-600">Thiết lập mật khẩu mới để bảo vệ tài khoản tốt hơn. Mật khẩu nên có tối thiểu 6 ký tự và kết hợp chữ cái, số hoặc ký tự đặc biệt.</p>
            </div>

            <% if (passwordErrors != null && !passwordErrors.isEmpty()) { %>
                <div class="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
                    <ul class="list-disc pl-5 space-y-1">
                        <% for (String err : passwordErrors) { %>
                            <li><%= err %></li>
                        <% } %>
                    </ul>
                </div>
            <% } %>

            <form method="post" class="space-y-6">
                <div>
                    <label for="currentPassword" class="block text-sm font-medium text-gray-700 mb-1">Mật khẩu hiện tại</label>
                    <input id="currentPassword" name="currentPassword" type="password" required
                           class="password-input w-full rounded-lg border border-gray-300 px-3 py-2 focus:border-blue-500 focus:ring-blue-500" />
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label for="newPassword" class="block text-sm font-medium text-gray-700 mb-1">Mật khẩu mới</label>
                        <input id="newPassword" name="newPassword" type="password" required minlength="6"
                               class="password-input w-full rounded-lg border border-gray-300 px-3 py-2 focus:border-blue-500 focus:ring-blue-500" />
                    </div>
                    <div>
                        <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-1">Xác nhận mật khẩu mới</label>
                        <input id="confirmPassword" name="confirmPassword" type="password" required minlength="6"
                               class="password-input w-full rounded-lg border border-gray-300 px-3 py-2 focus:border-blue-500 focus:ring-blue-500" />
                    </div>
                </div>
                <div class="rounded-lg bg-gray-50 border border-gray-200 px-4 py-3 text-sm text-gray-600 flex items-start gap-3">
                    <i data-lucide="shield" class="w-5 h-5 text-blue-600"></i>
                    <div>
                        <p>Gợi ý bảo mật:</p>
                        <ul class="list-disc pl-5 space-y-1 mt-1">
                            <li>Không chia sẻ mật khẩu cho người khác.</li>
                            <li>Tránh sử dụng mật khẩu giống với các trang khác.</li>
                            <li>Nên thay đổi mật khẩu định kỳ.</li>
                        </ul>
                    </div>
                </div>
                <div class="flex flex-wrap items-center gap-3">
                    <button type="submit"
                            class="inline-flex items-center justify-center px-5 py-2 rounded-lg bg-blue-600 text-white font-semibold hover:bg-blue-700 transition">
                        <i data-lucide="lock" class="w-4 h-4 mr-2"></i>
                        Cập nhật mật khẩu
                    </button>
                    <a href="<%= backUrl %>" class="px-4 py-2 rounded-lg border border-gray-300 text-gray-700 hover:bg-gray-50">
                        Hủy
                    </a>
                </div>
            </form>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
<script>
    if (window.lucide) {
        lucide.createIcons();
    }
</script>
</body>
</html>

