package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.*;
import repository.AdminRepository;
import serviceimpl.*;
import utils.DataSourceUtil;
import dto.FoodDTO;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import com.google.gson.Gson;
import utils.RequestUtil;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private UserServiceImpl userServiceImpl;
	private StallServiceImpl stallServiceImpl;
	private OrderServiceImpl orderServiceImpl;
	private StatisticServiceImpl statisticServiceImpl;
	private FoodServiceImpl foodServiceImpl;
    private AdminServiceImpl adminServiceImpl;
	private DataSource ds;
	
	@Override
	public void init() throws ServletException {
		ds = DataSourceUtil.getDataSource();
		this.userServiceImpl = new UserServiceImpl(ds);
		this.stallServiceImpl = new StallServiceImpl(ds);
		this.orderServiceImpl = new OrderServiceImpl(ds);
		this.statisticServiceImpl = new StatisticServiceImpl(ds);
		this.foodServiceImpl = new FoodServiceImpl(ds);
        this.adminServiceImpl = new AdminServiceImpl(ds);
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// check session
		HttpSession session = request.getSession(false);
		String userRole = (String) (session != null ? session.getAttribute("type_user") : null);
		String username = (String) (session != null ? session.getAttribute("username") : null);
		
		if (username == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		
		if (!"admin".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		String action = RequestUtil.getString(request, "action", null);
		if (action == null) {
			action = "dashboard";
		}
		
		switch (action) {
			case "dashboard":
				handleDashboard(request, response);
				break;
			case "users":
				handleUsers(request, response);
				break;
			case "customers":
				handleCustomers(request, response);
				break;
			case "stalls-users":
				handleStallsUsers(request, response);
				break;
			case "stalls":
				handleStalls(request, response);
				break;
			case "foods":
				handleFoods(request, response);
				break;
			case "orders":
				handleOrders(request, response);
				break;
			case "revenue-report":
				handleRevenueReport(request, response);
				break;
			case "statistics":
				handleStatistics(request, response);
				break;
			case "getUser":
				handleGetUser(request, response);
				break;
			case "getStall":
				handleGetStall(request, response);
				break;
			default:
				response.sendRedirect(request.getContextPath() + "/admin");
				break;
		}
	}
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		String userRole = (String) (session != null ? session.getAttribute("type_user") : null);
		String username = (String) (session != null ? session.getAttribute("username") : null);
		Integer userId = (Integer) (session != null ? session.getAttribute("userId") : null);
		
		if (username == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		
		String action = RequestUtil.getString(request, "action", null);
		
		// Check action
		boolean isStallAction = "createStall".equals(action) || "updateStall".equals(action) || "deleteStall".equals(action);
		if (!isStallAction && !"admin".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		if (isStallAction && !"admin".equals(userRole) && !"stall".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		switch (action) {
			case "createUser":
				handleCreateUser(request, response);
				break;
			case "updateUser":
				handleUpdateUser(request, response);
				break;
			case "deleteUser":
				handleDeleteUser(request, response);
				break;
			case "toggleUserStatus":
				handleToggleUserStatus(request, response);
				break;
			case "createStall":
				handleCreateStall(request, response, userId, userRole);
				break;
			case "updateStall":
				handleUpdateStall(request, response, userId, userRole);
				break;
			case "deleteStall":
				handleDeleteStall(request, response, userId, userRole);
				break;
			default:
				response.sendRedirect(request.getContextPath() + "/admin");
				break;
		}
	}
	
	private void handleDashboard(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		
		int totalUsers = this.userServiceImpl.count();
		List<StallDAO> stalls = this.stallServiceImpl.findAll();
		int totalStalls = stalls.size();
		
		LocalDate today = LocalDate.now();
		Date _today = Date.valueOf(today);
		
		double totalRevenue = this.orderServiceImpl.getTotalRevenueFromCompletedOrders();
		
		int totalOrders = 0;
		List<StatisticDAO> todayStats = this.statisticServiceImpl.findByDateRange(_today, _today);
		for (StatisticDAO stat : todayStats) {
			totalOrders += stat.getOrdersCount();
		}
		
		PageRequest pageReq = new PageRequest(1, 10, "created_at", "DESC", "");
		Page<OrderDAO> pageOrders = this.orderServiceImpl.findAll(pageReq);
		List<OrderDAO> recentOrders = pageOrders.getData();
		
		Map<Integer, String> userNames = new HashMap<>();
		Map<Integer, String> stallNames = new HashMap<>();
		for (OrderDAO order : recentOrders) {
			if (!userNames.containsKey(order.getUserId())) {
				UserDAO user = this.userServiceImpl.getUserById(order.getUserId());
				if (user != null) {
					userNames.put(order.getUserId(), user.getFull_name());
				}
			}
			if (!stallNames.containsKey(order.getStallId())) {
				StallDAO stall = this.stallServiceImpl.findById(order.getStallId());
				if (stall != null) {
					stallNames.put(order.getStallId(), stall.getName());
				}
			}
		}
		
		Integer userId = (Integer) (session != null ? session.getAttribute("userId") : null);
		
		request.setAttribute("totalUsers", totalUsers);
		request.setAttribute("totalStalls", totalStalls);
		request.setAttribute("totalRevenue", totalRevenue);
		request.setAttribute("totalOrders", totalOrders);
		request.setAttribute("recentOrders", recentOrders);
		request.setAttribute("userNames", userNames);
		request.setAttribute("stallNames", stallNames);
		request.setAttribute("currentUserId", userId);
		
		request.getRequestDispatcher("/admin.jsp").forward(request, response);
	}
	
	private void handleUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		List<UserDAO> users = this.userServiceImpl.findAll();
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(users);
		response.getWriter().write(json);
	}
	
	private void handleStalls(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		List<StallDAO> stalls = this.stallServiceImpl.findAll();
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(stalls);
		response.getWriter().write(json);
	}
	
	private void handleOrders(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PageRequest pageReq = new PageRequest(1, 1000, "created_at", "DESC", "");
		Page<OrderDAO> pageOrders = this.orderServiceImpl.findAll(pageReq);
		List<OrderDAO> orders = pageOrders.getData();
		
		// load order
		List<Map<String, Object>> ordersWithDetails = new ArrayList<>();
		for (OrderDAO order : orders) {
			Map<String, Object> orderData = new HashMap<>();
			orderData.put("id", order.getId());
			orderData.put("userId", order.getUserId());
			orderData.put("stallId", order.getStallId());
			orderData.put("totalPrice", order.getTotalPrice());
			orderData.put("status", order.getStatus());
			orderData.put("createdAt", order.getCreatedAt());
			orderData.put("deliveryLocation", order.getDeliveryLocation());
			orderData.put("paymentMethod", order.getPaymentMethod());
			
			UserDAO user = this.userServiceImpl.getUserById(order.getUserId());
			if (user != null) {
				orderData.put("userName", user.getFull_name());
				orderData.put("userEmail", user.getEmail());
			}
			
			StallDAO stall = this.stallServiceImpl.findById(order.getStallId());
			if (stall != null) {
				orderData.put("stallName", stall.getName());
			}
			
			ordersWithDetails.add(orderData);
		}
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(ordersWithDetails);
		response.getWriter().write(json);
	}
	
	private void handleCustomers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		List<UserDAO> customers = this.userServiceImpl.findByRole("customer");
		
		// Load orders for customer
		List<Map<String, Object>> customersWithOrders = new ArrayList<>();
		for (UserDAO customer : customers) {
			Map<String, Object> customerData = new HashMap<>();
			customerData.put("id", customer.getId());
			customerData.put("username", customer.getUsername());
			customerData.put("fullName", customer.getFull_name());
			customerData.put("email", customer.getEmail());
			customerData.put("phone", customer.getPhone());
			customerData.put("status", customer.isStatus());
			customerData.put("createDate", customer.getCreateDate());
			
			List<OrderDAO> orders = this.orderServiceImpl.findByUserId(customer.getId());
			customerData.put("totalOrders", orders.size());
			
			double totalSpent = 0.0;
			for (OrderDAO order : orders) {
				totalSpent += order.getTotalPrice();
			}
			customerData.put("totalSpent", totalSpent);
			customerData.put("orders", orders);
			
			customersWithOrders.add(customerData);
		}
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(customersWithOrders);
		response.getWriter().write(json);
	}
	
	private void handleStallsUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		List<UserDAO> stallUsers = this.userServiceImpl.findByRole("stall");
		
		// Load orders for stall
		List<Map<String, Object>> stallUsersWithOrders = new ArrayList<>();
		for (UserDAO stallUser : stallUsers) {
			Map<String, Object> userData = new HashMap<>();
			userData.put("id", stallUser.getId());
			userData.put("username", stallUser.getUsername());
			userData.put("fullName", stallUser.getFull_name());
			userData.put("email", stallUser.getEmail());
			userData.put("phone", stallUser.getPhone());
			userData.put("status", stallUser.isStatus());
			userData.put("createDate", stallUser.getCreateDate());
			
			List<StallDAO> stalls = this.stallServiceImpl.findByManagerUserId(stallUser.getId());
			if (!stalls.isEmpty()) {
				StallDAO stall = stalls.get(0);
				userData.put("stallId", stall.getId());
				userData.put("stallName", stall.getName());
				
				List<OrderDAO> orders = this.orderServiceImpl.findByStallId(stall.getId());
				userData.put("totalOrders", orders.size());
				
				double totalRevenue = 0.0;
				for (OrderDAO order : orders) {
					totalRevenue += order.getTotalPrice();
				}
				userData.put("totalRevenue", totalRevenue);
				userData.put("orders", orders);
			} else {
				userData.put("stallId", null);
				userData.put("stallName", null);
				userData.put("totalOrders", 0);
				userData.put("totalRevenue", 0.0);
				userData.put("orders", new ArrayList<>());
			}
			
			stallUsersWithOrders.add(userData);
		}
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(stallUsersWithOrders);
		response.getWriter().write(json);
	}
	
	private void handleFoods(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PageRequest pageReq = new PageRequest(1, 1000, "id", "ASC", "");
		Page<FoodDTO> pageFoods = this.foodServiceImpl.findAll(pageReq);
		List<FoodDTO> foods = pageFoods.getData();
		
		List<Map<String, Object>> foodsWithDetails = new ArrayList<>();
		for (FoodDTO food : foods) {
			Map<String, Object> foodData = new HashMap<>();
			foodData.put("id", food.getId());
			foodData.put("name", food.getNameFood());
			foodData.put("price", food.getPriceFood());
			foodData.put("inventory", food.getInventoryFood());
			foodData.put("image", food.getImage());
			foodData.put("description", food.getDescription());
			foodData.put("promotion", food.getPromotion());
			foodData.put("stallId", food.getStallId());
			
			StallDAO stall = this.stallServiceImpl.findById(food.getStallId());
			if (stall != null) {
				foodData.put("stallName", stall.getName());
			}
			
			foodsWithDetails.add(foodData);
		}
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(foodsWithDetails);
		response.getWriter().write(json);
	}
	
	private void handleRevenueReport(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		double totalRevenue = this.orderServiceImpl.getTotalRevenueFromCompletedOrders();
		
		List<Map<String, Object>> bestSellingFoods = this.adminServiceImpl.getBestSellingFoods();
		
		Map<String, Object> report = new HashMap<>();
		report.put("totalRevenue", totalRevenue);
		report.put("bestSellingFoods", bestSellingFoods);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(report);
		response.getWriter().write(json);
	}

	private void handleStatistics(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String startDateStr = RequestUtil.getString(request, "startDate", "");
		String endDateStr = RequestUtil.getString(request, "endDate", "");
		
		LocalDate startDate = startDateStr != null ? LocalDate.parse(startDateStr) : LocalDate.now().minusDays(7);
		LocalDate endDate = endDateStr != null ? LocalDate.parse(endDateStr) : LocalDate.now();
		
		Date _startDate = Date.valueOf(startDate);
		Date _endDate = Date.valueOf(endDate);
		
		List<StatisticDAO> statistics = this.statisticServiceImpl.findByDateRange(_startDate, _endDate);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(statistics);
		response.getWriter().write(json);
	}
	
	private void handleGetUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		int id = RequestUtil.getInt(request, "id", 0);
		UserDAO user = this.userServiceImpl.getUserById(id);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(user);
		response.getWriter().write(json);
	}
	
	private void handleGetStall(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		int id = RequestUtil.getInt(request, "id", 0);
		StallDAO stall = this.stallServiceImpl.findById(id);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(stall);
		response.getWriter().write(json);
	}
	
	private void handleCreateUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String username = RequestUtil.getString(request, "username", "");
		String fullName = RequestUtil.getString(request, "fullName", "");
		String email = RequestUtil.getString(request, "email", "");
		String phone = RequestUtil.getString(request, "phone", "");
		String role= RequestUtil.getString(request, "role", "");
		
		UserDAO user = new UserDAO();
		user.setUsername(username);
		user.setFull_name(fullName);
		user.setEmail(email);
		user.setPhone(phone);
		user.setRole(role);
		user.setStatus(true);
		
		UserDAO savedUser = this.userServiceImpl.save(user);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Map<String, Object> result = new HashMap<>();
		if (savedUser != null) {
			result.put("success", true);
			result.put("message", "User created successfully");
			result.put("user", savedUser);
		} else {
			result.put("success", false);
			result.put("message", "Failed to create user");
		}
		
		Gson gson = new Gson();
		String json = gson.toJson(result);
		response.getWriter().write(json);
	}
	
	private void handleUpdateUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		int id = RequestUtil.getInt(request, "id", 0);
		String username = RequestUtil.getString(request, "username", "");
		String fullName = RequestUtil.getString(request, "fullName", "");
		String email = RequestUtil.getString(request, "email", "");
		String phone = RequestUtil.getString(request, "phone", "");
		String role= RequestUtil.getString(request, "role", "");
		
		String statusParam = RequestUtil.getString(request, "status", null);
		boolean status = false;
		if (statusParam != null) {
			String statusStr = statusParam.trim().toLowerCase();
			status = "true".equals(statusStr) || "1".equals(statusStr) || "yes".equals(statusStr);
		}
		
		UserDAO user = new UserDAO();
		user.setId(id);
		user.setUsername(username);
		user.setFull_name(fullName);
		user.setEmail(email);
		user.setPhone(phone);
		user.setRole(role);
		user.setStatus(status);
		
		boolean updated = this.userServiceImpl.update(user);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Map<String, Object> result = new HashMap<>();
		result.put("success", updated);
		result.put("message", updated ? "User updated successfully" : "Failed to update user");
		
		Gson gson = new Gson();
		String json = gson.toJson(result);
		response.getWriter().write(json);
	}
	
	private void handleDeleteUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		int id = RequestUtil.getInt(request, "id", 0);
		boolean deleted = this.userServiceImpl.deleteById(id);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Map<String, Object> result = new HashMap<>();
		result.put("success", deleted);
		result.put("message", deleted ? "User deleted successfully" : "Failed to delete user");
		
		Gson gson = new Gson();
		String json = gson.toJson(result);
		response.getWriter().write(json);
	}
	
	private void handleToggleUserStatus(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		int id = RequestUtil.getInt(request, "id", 0);
		String statusParam = RequestUtil.getString(request, "status", null);
		boolean status = false;
		
		if (statusParam != null) {
			String statusStr = statusParam.trim().toLowerCase();
			status = "true".equals(statusStr) || "1".equals(statusStr) || "yes".equals(statusStr);
		}
		
		boolean updated = this.userServiceImpl.updateStatus(id, status);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Map<String, Object> result = new HashMap<>();
		result.put("success", updated);
		result.put("message", updated ? "User status updated successfully" : "Failed to update user status");
		
		Gson gson = new Gson();
		String json = gson.toJson(result);
		response.getWriter().write(json);
	}
	
	private void handleCreateStall(HttpServletRequest request, HttpServletResponse response, Integer userId, String userRole) throws ServletException, IOException {
		// check role
		if (!"admin".equals(userRole) && !"stall".equals(userRole)) {
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			Map<String, Object> result = new HashMap<>();
			result.put("success", false);
			result.put("message", "Bạn không có quyền tạo quầy");
			Gson gson = new Gson();
			response.getWriter().write(gson.toJson(result));
			return;
		}
		
		String name = RequestUtil.getString(request, "name", "");
		String description = RequestUtil.getString(request, "description", "");
		int managerUserId = RequestUtil.getInt(request, "managerUserId", 0);
		
		String isOpenParam = RequestUtil.getString(request, "isOpen", null);
		boolean isOpen = false;
		if (isOpenParam != null) {
			String isOpenStr = isOpenParam.trim().toLowerCase();
			isOpen = "true".equals(isOpenStr) || "1".equals(isOpenStr) || "yes".equals(isOpenStr);
		}
		
		if ("stall".equals(userRole) && userId != null && !userId.equals(managerUserId)) {
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			Map<String, Object> result = new HashMap<>();
			result.put("success", false);
			result.put("message", "Bạn chỉ có thể tạo quầy cho chính mình");
			Gson gson = new Gson();
			response.getWriter().write(gson.toJson(result));
			return;
		}
		
		StallDAO stall = new StallDAO();
		stall.setName(name);
		stall.setDescription(description);
		stall.setManagerUserId(managerUserId);
		stall.setIsOpen(isOpen);
		
		StallDAO savedStall = this.stallServiceImpl.save(stall);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Map<String, Object> result = new HashMap<>();
		if (savedStall != null) {
			result.put("success", true);
			result.put("message", "Stall created successfully");
			result.put("stall", savedStall);
		} else {
			result.put("success", false);
			result.put("message", "Failed to create stall");
		}
		
		Gson gson = new Gson();
		String json = gson.toJson(result);
		response.getWriter().write(json);
	}
	
	private void handleUpdateStall(HttpServletRequest request, HttpServletResponse response, Integer userId, String userRole) throws ServletException, IOException {
		// Check role
		if (!"admin".equals(userRole) && !"stall".equals(userRole)) {
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			Map<String, Object> result = new HashMap<>();
			result.put("success", false);
			result.put("message", "Bạn không có quyền sửa quầy");
			Gson gson = new Gson();
			response.getWriter().write(gson.toJson(result));
			return;
		}
		
		int id = RequestUtil.getInt(request, "id", 0);
		
		StallDAO existingStall = this.stallServiceImpl.findById(id);
		if (existingStall == null) {
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			Map<String, Object> result = new HashMap<>();
			result.put("success", false);
			result.put("message", "Quầy không tồn tại");
			Gson gson = new Gson();
			response.getWriter().write(gson.toJson(result));
			return;
		}
		
		if ("stall".equals(userRole) && userId != null && !userId.equals(existingStall.getManagerUserId())) {
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			Map<String, Object> result = new HashMap<>();
			result.put("success", false);
			result.put("message", "Bạn chỉ có thể sửa quầy do mình quản lý");
			Gson gson = new Gson();
			response.getWriter().write(gson.toJson(result));
			return;
		}
		
		String name = RequestUtil.getString(request, "name", "");
		String description = RequestUtil.getString(request, "description", "");
		int managerUserId = RequestUtil.getInt(request, "managerUserId", 0);
		
		String isOpenParam = RequestUtil.getString(request, "isOpen", null);
		boolean isOpen = false;
		if (isOpenParam != null) {
			String isOpenStr = isOpenParam.trim().toLowerCase();
			isOpen = "true".equals(isOpenStr) || "1".equals(isOpenStr) || "yes".equals(isOpenStr);
		}
		
		if ("stall".equals(userRole) && userId != null && !userId.equals(managerUserId)) {
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			Map<String, Object> result = new HashMap<>();
			result.put("success", false);
			result.put("message", "Bạn không thể thay đổi người quản lý quầy");
			Gson gson = new Gson();
			response.getWriter().write(gson.toJson(result));
			return;
		}
		
		StallDAO stall = new StallDAO();
		stall.setId(id);
		stall.setName(name);
		stall.setDescription(description);
		stall.setManagerUserId(managerUserId);
		stall.setIsOpen(isOpen);
		
		StallDAO updatedStall = this.stallServiceImpl.save(stall);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Map<String, Object> result = new HashMap<>();
		if (updatedStall != null) {
			result.put("success", true);
			result.put("message", "Stall updated successfully");
		} else {
			result.put("success", false);
			result.put("message", "Failed to update stall");
		}
		
		Gson gson = new Gson();
		String json = gson.toJson(result);
		response.getWriter().write(json);
	}
	
	private void handleDeleteStall(HttpServletRequest request, HttpServletResponse response, Integer userId, String userRole) throws ServletException, IOException {
		// Check role
		if (!"admin".equals(userRole) && !"stall".equals(userRole)) {
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			Map<String, Object> result = new HashMap<>();
			result.put("success", false);
			result.put("message", "Bạn không có quyền xóa quầy");
			Gson gson = new Gson();
			response.getWriter().write(gson.toJson(result));
			return;
		}
		
		int id = RequestUtil.getInt(request, "id", 0);

		StallDAO existingStall = this.stallServiceImpl.findById(id);
		if (existingStall == null) {
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			Map<String, Object> result = new HashMap<>();
			result.put("success", false);
			result.put("message", "Quầy không tồn tại");
			Gson gson = new Gson();
			response.getWriter().write(gson.toJson(result));
			return;
		}
		
		if ("stall".equals(userRole) && userId != null && !userId.equals(existingStall.getManagerUserId())) {
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			Map<String, Object> result = new HashMap<>();
			result.put("success", false);
			result.put("message", "Bạn chỉ có thể xóa quầy do mình quản lý");
			Gson gson = new Gson();
			response.getWriter().write(gson.toJson(result));
			return;
		}
		
		this.stallServiceImpl.deleteById(id);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Map<String, Object> result = new HashMap<>();
		result.put("success", true);
		result.put("message", "Stall deleted successfully");
		
		Gson gson = new Gson();
		String json = gson.toJson(result);
		response.getWriter().write(json);
	}
}

