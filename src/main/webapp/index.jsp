<!DOCTYPE html>
<html>
<head>
    <title>Home</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body>

	<%-- Start the scriptlet and define the content area --%>
	<%
		String type_user = (String) request.getAttribute("type_user");
	%>

    <div id="header">
        <jsp:include page="/WEB-INF/jsp/common/header.jsp" />
    </div>

	<div id="content">
	</div>

    <div id="footer">
        <jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
    </div>
</body>

</html>
