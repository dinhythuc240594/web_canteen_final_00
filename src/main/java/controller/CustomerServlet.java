package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.OrderDAO;
import model.UserDAO;
import serviceimpl.OrderServiceImpl;
import serviceimpl.UserServiceImpl;
import utils.DataSourceUtil;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

@WebServlet("/customer")
public class CustomerServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private UserServiceImpl userService;
	private OrderServiceImpl orderService;
	
	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.userService = new UserServiceImpl(ds);
		this.orderService = new OrderServiceImpl(ds);
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// Security check: Only customer can access
		HttpSession session = request.getSession(false);
		String userRole = (String) (session != null ? session.getAttribute("type_user") : null);
		String username = (String) (session != null ? session.getAttribute("username") : null);
		Integer userId = (Integer) (session != null ? session.getAttribute("userId") : null);
		
		if (username == null || userId == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		
		if (!"customer".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		// Get user information
		UserDAO user = userService.getUserById(userId);
		
		// Get user's orders
		List<OrderDAO> orders = orderService.findByUserId(userId);
		
		// Calculate statistics
		int totalOrders = orders.size();
		double totalSpent = 0.0;
		int pendingOrders = 0;
		int completedOrders = 0;
		
		for (OrderDAO order : orders) {
			totalSpent += order.getTotalPrice();
			if ("delivered".equals(order.getStatus())) {
				completedOrders++;
			} else {
				pendingOrders++;
			}
		}
		
		// Get recent orders (last 5)
		List<OrderDAO> recentOrders = orders.size() > 5 ? orders.subList(0, 5) : orders;
		
		request.setAttribute("user", user);
		request.setAttribute("totalOrders", totalOrders);
		request.setAttribute("totalSpent", totalSpent);
		request.setAttribute("pendingOrders", pendingOrders);
		request.setAttribute("completedOrders", completedOrders);
		request.setAttribute("recentOrders", recentOrders);
		request.setAttribute("allOrders", orders);
		
		request.getRequestDispatcher("/customer.jsp").forward(request, response);
	}
}

