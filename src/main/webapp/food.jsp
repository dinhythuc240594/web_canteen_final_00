<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.FoodDAO" %>
<!DOCTYPE html>
<html>
<head>
    <title>Đồ ăn - FoodApp</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body>
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<div class="container mt-4">
        <%
            
        	model.Page<model.FoodDAO> pageFood = (model.Page<model.FoodDAO>) request.getAttribute("pageFood");
        	java.util.List<model.FoodDAO> foods = (java.util.List<model.FoodDAO>) pageFood.getData();
        	
        	model.PageRequest pageReq = (model.PageRequest) request.getAttribute("pageReq");
        	String keyword = pageReq.getKeyword();
        	String orderField = pageReq.getOrderField();
        	String sortField = pageReq.getSortField();
        	int totalPage = pageFood.getTotalPage();
        	
        	List<FoodDAO> newFoods = (List<FoodDAO>) request.getAttribute("newFoods");
        	List<FoodDAO> promotionFoods = (List<FoodDAO>) request.getAttribute("promotionFoods");
        	List<FoodDAO> allFoods = foods;
        	
        %>
    <div class="slider-container">
        <h2 class="slider-title">Đồ ăn mới</h2>
        <div class="slider">
            <%
                if (newFoods != null) {
                    for (FoodDAO food : newFoods) {
            %>
            <div class="slider-item" onclick="location.href='food?action=detail&id=<%= food.getId() %>'">
                <div class="slider-img">
                    <% if (food.getImage() != null && !food.getImage().isEmpty()) { %>
                    <img src="<%= food.getImage() %>" alt="<%= food.getNameFood() %>" style="width:100%; height:100%; object-fit:cover;">
                    <% } else { %>
                    <%= food.getNameFood() %>
                    <% } %>
                </div>
                <div class="slider-content">
                    <h3><%= food.getNameFood() %></h3>
                    <p><%= food.getDescription() != null ? food.getDescription() : "Món ngon" %></p>
                </div>
            </div>
            <%
                    }
                }
            %>
        </div>
    </div>

    <!-- Ưu đãi -->
    <div class="slider-container">
        <h2 class="slider-title">Ưu đãi</h2>
        <div class="slider">
            <%
                
                if (promotionFoods != null) {
                    for (FoodDAO food : promotionFoods) {
            %>
            <div class="slider-item" onclick="location.href='food?action=detail&id=<%= food.getId() %>'">
                <div class="slider-img">
                    <% if (food.getImage() != null && !food.getImage().isEmpty()) { %>
                    <img src="<%= food.getImage() %>" alt="<%= food.getNameFood() %>" style="width:100%; height:100%; object-fit:cover;">
                    <% } else { %>
                    Ưu đãi
                    <% } %>
                </div>
                <div class="slider-content">
                    <h3><%= food.getNameFood() %></h3>
                    <p>Giảm giá đặc biệt</p>
                </div>
            </div>
            <%
                    }
                }
            %>
        </div>
    </div>

    <!-- Danh sách món (A -> Z) -->
    <h2 class="slider-title">Danh sách món (A -> Z)</h2>
    <div class="food-list">
        <%
            
            if (allFoods != null) {
                for (FoodDAO food : allFoods) {
        %>
        <div class="food-item" onclick="location.href='food?action=detail&id=<%= food.getId() %>'">
            <div class="food-img">
                <% if (food.getImage() != null && !food.getImage().isEmpty()) { %>
                <img src="<%= food.getImage() %>" alt="<%= food.getNameFood() %>" style="width:100%; height:100%; object-fit:cover;">
                <% } else { %>
                <%= food.getNameFood() %>
                <% } %>
            </div>
            <div class="food-name"><%= food.getNameFood() %></div>
            <div class="food-price"><%= String.format("%,d", food.getPriceFood()) %>đ</div>
        </div>
        <%
                }
            }
        %>
        
       <nav aria-label="Page navigation">
			<ul class="pagination">
			  <% for (int i=1; i < totalPage; i++) { %>
			  	<li class="page-item"><a class="page-link" href="books?page=<%= i %>&keyword=<%= keyword %>"><%= i %></a></li>
			  <% } %>
			</ul>
		</nav>
        
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
</body>
</html>