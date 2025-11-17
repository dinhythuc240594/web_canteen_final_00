<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("type_user");
    
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    if (!"stall".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    
    model.UserDAO user = (model.UserDAO) request.getAttribute("user");
    String contextPath = request.getContextPath();
    
    String formFullName = (String) request.getAttribute("profileFormFullName");
    if (formFullName == null && user != null) formFullName = user.getFull_name();
    
    String formEmail = (String) request.getAttribute("profileFormEmail");
    if (formEmail == null && user != null && user.getEmail() != null) formEmail = user.getEmail();
    
    String formPhone = (String) request.getAttribute("profileFormPhone");
    if (formPhone == null && user != null && user.getPhone() != null) formPhone = user.getPhone();
    
    String rawAvatarPath = (user != null && user.getAvatar() != null && !user.getAvatar().isBlank())
            ? user.getAvatar()
            : "static/img/default-avatar.svg";
    String avatarUrl = rawAvatarPath.startsWith("http") ? rawAvatarPath : contextPath + "/" + rawAvatarPath;
    
    String profileError = (String) request.getAttribute("profileError");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chỉnh sửa thông tin chủ quầy - Canteen ĐH</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<main class="min-h-screen">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-8">
            <div>
                <h1 class="text-3xl font-bold text-gray-800">Chỉnh sửa thông tin chủ quầy</h1>
                <p class="text-gray-600 mt-2">Cập nhật họ tên, email, số điện thoại và ảnh đại diện của bạn.</p>
            </div>
            <a href="<%= contextPath %>/stall" class="inline-flex items-center justify-center rounded-md border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">
                <i data-lucide="arrow-left" class="w-4 h-4 mr-2"></i>
                Quay lại trang quầy
            </a>
        </div>
        
        <% if (profileError != null) { %>
            <div class="mb-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
                <%= profileError %>
            </div>
        <% } %>
        
        <div class="bg-white p-6 rounded-lg shadow-sm border">
            <div class="flex flex-col lg:flex-row gap-8">
                <div class="lg:w-1/3 text-center lg:text-left">
                    <div class="w-32 h-32 mx-auto lg:mx-0 rounded-full border-4 border-gray-100 shadow-md overflow-hidden">
                        <img id="avatar-preview" src="<%= avatarUrl %>" alt="Xem trước ảnh đại diện" class="w-full h-full object-cover" />
                    </div>
                    <p class="text-sm text-gray-500 mt-3">Ảnh rõ nét, dung lượng tối đa 5MB. Hỗ trợ JPG, PNG, GIF, WebP.</p>
                </div>
                <div class="lg:flex-1">
                    <form method="post" enctype="multipart/form-data" class="space-y-4">
                        <div>
                            <label for="fullName" class="block text-sm font-medium text-gray-700 mb-1">Họ và tên *</label>
                            <input id="fullName" name="fullName" type="text" value="<%= formFullName != null ? formFullName : "" %>" required
                                   class="w-full rounded-md border border-gray-300 px-3 py-2 focus:border-blue-500 focus:ring-blue-500" />
                        </div>
                        <div>
                            <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email *</label>
                            <input id="email" name="email" type="email" value="<%= formEmail != null ? formEmail : "" %>" required
                                   class="w-full rounded-md border border-gray-300 px-3 py-2 focus:border-blue-500 focus:ring-blue-500" />
                        </div>
                        <div>
                            <label for="phone" class="block text-sm font-medium text-gray-700 mb-1">Số điện thoại</label>
                            <input id="phone" name="phone" type="tel" value="<%= formPhone != null ? formPhone : "" %>"
                                   class="w-full rounded-md border border-gray-300 px-3 py-2 focus:border-blue-500 focus:ring-blue-500" />
                        </div>
                        <div>
                            <label for="avatar-input" class="block text-sm font-medium text-gray-700 mb-1">Ảnh đại diện</label>
                            <input id="avatar-input" name="avatar" type="file" accept="image/*"
                                   class="w-full text-sm text-gray-600 file:mr-4 file:rounded-md file:border-0 file:bg-blue-50 file:px-4 file:py-2 file:text-blue-700 hover:file:bg-blue-100" />
                            <p class="text-xs text-gray-500 mt-1">Bỏ trống nếu muốn giữ nguyên ảnh hiện tại.</p>
                        </div>
                        <div class="flex justify-end gap-3">
                            <a href="<%= contextPath %>/stall" class="px-4 py-2 rounded-md border border-gray-300 text-gray-700 hover:bg-gray-50">
                                Hủy
                            </a>
                            <button type="submit" class="px-4 py-2 rounded-md bg-blue-600 text-white hover:bg-blue-700">
                                Lưu thay đổi
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
<script>
    lucide.createIcons();
    
    const avatarInput = document.getElementById('avatar-input');
    const avatarPreview = document.getElementById('avatar-preview');
    if (avatarInput && avatarPreview) {
        avatarInput.addEventListener('change', function (event) {
            const [file] = event.target.files;
            if (file) {
                avatarPreview.src = URL.createObjectURL(file);
            }
        });
    }
</script>
</body>
</html>

