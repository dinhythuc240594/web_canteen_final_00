<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
	<title>Update Food</title>
	<jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body>
	<h1>Edit</h1>
  <div id="container">
	<% dto.FoodDTO food = (dto.FoodDTO) request.getAttribute("food"); %>
	<% if (food != null) { %>
    <div id="" class="form-text">

        <label class="form-label">Tên món ăn</label>
        <span id="nameFood" class="form-control"><%= food.getNameFood() %></span><br />
        <label class="form-label">Giá</label>
        <span id="priceFood" class="form-control"><%= food.getPriceFood() %></span><br />
        <label class="form-label">Tồn kho</label>
        <span id="inventoryFood" class="form-control" ><%= food.getInventoryFood() %></span>
        
    </div>
	<% } %>
	<a href="foods?action=list">Go back to Home</a>
  </div>

</body>
</html>
