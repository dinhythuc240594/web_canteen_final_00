package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.*;
import serviceimpl.OrderServiceImpl;
import serviceimpl.StallServiceImpl;
import serviceimpl.StatisticServiceImpl;
import serviceimpl.UserServiceImpl;
import utils.DataSourceUtil;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import com.google.gson.Gson;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private UserServiceImpl userServiceImpl;
	private StallServiceImpl stallServiceImpl;
	private OrderServiceImpl orderServiceImpl;
	private StatisticServiceImpl statisticServiceImpl;
	
	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.userServiceImpl = new UserServiceImpl(ds);
		this.stallServiceImpl = new StallServiceImpl(ds);
		this.orderServiceImpl = new OrderServiceImpl(ds);
		this.statisticServiceImpl = new StatisticServiceImpl(ds);
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// Security check: Only admin can access
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
		
		String action = request.getParameter("action");
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
			case "stalls":
				handleStalls(request, response);
				break;
			case "orders":
				handleOrders(request, response);
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
		
		String action = request.getParameter("action");
		
		// Check permissions based on action
		boolean isStallAction = "createStall".equals(action) || "updateStall".equals(action) || "deleteStall".equals(action);
		
		// For non-stall actions, only admin can access
		// For stall actions, admin or stall managers can access
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
		
		// Get statistics
		int totalUsers = this.userServiceImpl.count();
		List<StallDAO> stalls = this.stallServiceImpl.findAll();
		int totalStalls = stalls.size();
		
		// Get today's statistics
		LocalDate today = LocalDate.now();
		Date sqlToday = Date.valueOf(today);
		
		// Calculate total revenue and orders for today
		double totalRevenue = 0.0;
		int totalOrders = 0;
		
		List<StatisticDAO> todayStats = this.statisticServiceImpl.findByDateRange(sqlToday, sqlToday);
		for (StatisticDAO stat : todayStats) {
			totalRevenue += stat.getRevenue();
			totalOrders += stat.getOrdersCount();
		}
		
		// Get recent orders (last 10)
		PageRequest pageReq = new PageRequest(1, 10, "created_at", "DESC", "");
        Page<OrderDAO> pageOrders = this.orderServiceImpl.findAll(pageReq);
		List<OrderDAO> recentOrders = pageOrders.getData();
		
		// Load user and stall names for each order
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
		// For simplicity, we'll return a limited set of recent orders
		// In a real application, you might want to implement pagination
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		// Return empty array for now - orders can be fetched through other means
		response.getWriter().write("[]");
	}
	
	private void handleStatistics(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String startDateStr = request.getParameter("startDate");
		String endDateStr = request.getParameter("endDate");
		
		LocalDate startDate = startDateStr != null ? LocalDate.parse(startDateStr) : LocalDate.now().minusDays(7);
		LocalDate endDate = endDateStr != null ? LocalDate.parse(endDateStr) : LocalDate.now();
		
		Date sqlStartDate = Date.valueOf(startDate);
		Date sqlEndDate = Date.valueOf(endDate);
		
		List<StatisticDAO> statistics = this.statisticServiceImpl.findByDateRange(sqlStartDate, sqlEndDate);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(statistics);
		response.getWriter().write(json);
	}
	
	private void handleGetUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		int id = Integer.parseInt(request.getParameter("id"));
		UserDAO user = this.userServiceImpl.getUserById(id);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(user);
		response.getWriter().write(json);
	}
	
	private void handleGetStall(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		int id = Integer.parseInt(request.getParameter("id"));
		StallDAO stall = this.stallServiceImpl.findById(id);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(stall);
		response.getWriter().write(json);
	}
	
	private void handleCreateUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String username = request.getParameter("username");
		String fullName = request.getParameter("fullName");
		String email = request.getParameter("email");
		String phone = request.getParameter("phone");
		String role = request.getParameter("role");
		
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
		int id = Integer.parseInt(request.getParameter("id"));
		String username = request.getParameter("username");
		String fullName = request.getParameter("fullName");
		String email = request.getParameter("email");
		String phone = request.getParameter("phone");
		String role = request.getParameter("role");
		boolean status = Boolean.parseBoolean(request.getParameter("status"));
		
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
		int id = Integer.parseInt(request.getParameter("id"));
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
		int id = Integer.parseInt(request.getParameter("id"));
		boolean status = Boolean.parseBoolean(request.getParameter("status"));
		
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
		// Check permission: Only admin or stall managers can create stalls
		// Stall managers can only create stalls for themselves
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
		
		String name = request.getParameter("name");
		String description = request.getParameter("description");
		int managerUserId = Integer.parseInt(request.getParameter("managerUserId"));
		boolean isOpen = Boolean.parseBoolean(request.getParameter("isOpen"));
		
		// If user is stall manager, they can only create stalls for themselves
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
		// Check permission: Only admin or stall managers can update stalls
		// Stall managers can only update their own stalls
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
		
		int id = Integer.parseInt(request.getParameter("id"));
		
		// Check if stall exists and user has permission
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
		
		// If user is stall manager, they can only update their own stalls
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
		
		String name = request.getParameter("name");
		String description = request.getParameter("description");
		int managerUserId = Integer.parseInt(request.getParameter("managerUserId"));
		boolean isOpen = Boolean.parseBoolean(request.getParameter("isOpen"));
		
		// If user is stall manager, they cannot change the manager
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
		// Check permission: Only admin or stall managers can delete stalls
		// Stall managers can only delete their own stalls
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
		
		int id = Integer.parseInt(request.getParameter("id"));
		
		// Check if stall exists and user has permission
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
		
		// If user is stall manager, they can only delete their own stalls
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

