<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://unpkg.com/lucide@latest"></script>
<script src="https://cdn.ckeditor.com/4.22.1/full-all/ckeditor.js"></script>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
<script src="${pageContext.request.contextPath}/static/jquery-3.7.1.min.js"></script>
<script>
	document.addEventListener('DOMContentLoaded', function() {
		lucide.createIcons();
	});
</script>
<jsp:include page="/WEB-INF/jsp/common/cart-sidebar.jsp" />