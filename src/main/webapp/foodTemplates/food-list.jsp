<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Food List</title>
	<jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body>
<div class = "container">
    <div class = "rowtable-reponsive">
        <h2>List</h2>
        <%
            
        	model.Page<dto.FoodDTO> pageFood = (model.Page<dto.FoodDTO>) request.getAttribute("pageFood");
        	java.util.List<dto.FoodDTO> foods = (java.util.List<dto.FoodDTO>) pageFood.getData();
        	
        	model.PageRequest pageReq = (model.PageRequest) request.getAttribute("pageReq");
        	String keyword = pageReq.getKeyword();
        	String orderField = pageReq.getOrderField();
        	String sortField = pageReq.getSortField();
        	int totalPage = pageFood.getTotalPage();
        	
            if (foods != null) {
        %>
        <a type="button" class="btn btn-danger" style="background-color: green" href="foods?&action=create">New</a>
        <div class="grid">

            <table class="table">
                <thead>
                <tr>
                    <th scope="col">Name</th>
                    <th scope="col">Price</th>
                    <th scope="col">Inventory</th>
                    <th scope="col">Detail</th>
                    <th scope="col">Update</th>
                    <th scope="col">Delete</th>
                </tr>
                </thead>
                <tbody>
            <% for (dto.FoodDTO f : foods) { %>

                <tr>
                    <td><%= f.getNameFood() %></td>
                    <td><%= f.getPriceFood() %></td>
                    <td><%= f.getInventoryFood() %></td>
                    <td><a class="btn btn-info" href="foods?id=<%= f.getId() %>&action=detail">Detail</a></td>
                    <td><a class="btn btn-success" href="foods?id=<%= f.getId() %>&action=update">Update</a></td>
                    <td><a class="btn btn-danger" href="foods?id=<%= f.getId() %>&action=delete">Delete</a></td>
                </tr>
            <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
        <a href="home">Go back to Home</a>
    </div>
</div>
</body>
</html>