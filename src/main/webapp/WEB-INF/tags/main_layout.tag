<%@ tag language="java" pageEncoding="UTF-8"%>
<%@attribute name="pageTitle" required="true" type="java.lang.String" %>
<%@attribute name="header" fragment="true" %>
<%@attribute name="footer" fragment="true" %>

<html>
	<head>
		<title>${pageTitle}</title>
	    <!-- Common CSS and JavaScript links -->
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
		<style>
			.grid { display: grid; gap: 20px; }
		    .book { border: 1px solid #ccc; padding: 10px; text-align: center; }
		</style>
	</head>
	<body>
	    <div id="pageheader">
	      <jsp:invoke fragment="header"/>
	    </div>
	    <div id="body">
	      <jsp:doBody/>
	    </div>
	    <div id="pagefooter">
	      <jsp:invoke fragment="footer"/>
	    </div>
	</body>
</html>