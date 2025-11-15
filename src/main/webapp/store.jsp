<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.StallDAO" %>
<%
    List<StallDAO> stalls = (List<StallDAO>) request.getAttribute("stalls");
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quầy - Canteen ĐH</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body>
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<div class="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50 py-6">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 class="text-xl font-bold text-gray-800 mb-6">Danh sách quầy</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <% 
            if (stalls != null && !stalls.isEmpty()) {
                for (StallDAO stall : stalls) {
            %>
            <div class="bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200 hover:shadow-md transition-shadow">
                <div class="p-4">
                    <h3 class="text-lg font-semibold text-gray-800 mb-2"><%= stall.getName() %></h3>
                    <p class="text-gray-600 text-sm mb-3"><%= stall.getDescription() != null ? stall.getDescription() : "Món ăn ngon và đa dạng" %></p>
                    <div class="flex items-center justify-between">
                        <span class="text-xs text-gray-500">Có sẵn</span>
                        <div class="flex space-x-2">
                            <% if (stall.getIsOpen() != null && stall.getIsOpen()) { %>
                            <span class="px-2 py-0.5 bg-blue-100 text-blue-800 text-xs rounded-full">
                                Mở cửa
                            </span>
                            <% } else { %>
                            <span class="px-2 py-0.5 bg-red-100 text-red-800 text-xs rounded-full">
                                Đóng cửa
                            </span>
                            <% } %>
                        </div>
                    </div>
                    <div class="mt-3">
                        <a href="<%=contextPath%>/foods?action=list&stallId=<%= stall.getId() %>" 
                           class="text-blue-600 hover:text-blue-800 text-sm font-medium">
                            Xem thực đơn →
                        </a>
                    </div>
                </div>
            </div>
            <% 
                }
            } else {
            %>
            <div class="col-span-2 text-center py-12">
                <p class="text-gray-500">Chưa có quầy nào được đăng ký.</p>
            </div>
            <% } %>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
<script>
    document.addEventListener('DOMContentLoaded', function() {
        lucide.createIcons();
    });
</script>
</body>
</html>