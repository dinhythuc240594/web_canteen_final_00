package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.OrderDAO;
import model.Order_FoodDAO;
import model.StallDAO;
import serviceimpl.OrderServiceImpl;
import serviceimpl.StallServiceImpl;
import serviceimpl.Order_FoodServiceImpl;
import utils.DataSourceUtil;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

@WebServlet("/stall-orders")
public class StallOrderServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private OrderServiceImpl orderService;
	private StallServiceImpl stallService;
	private Order_FoodServiceImpl orderFoodService;
	
	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.orderService = new OrderServiceImpl(ds);
		this.stallService = new StallServiceImpl(ds);
		this.orderFoodService = new Order_FoodServiceImpl(ds);
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// Security check: Only stall and admin can access
		HttpSession session = request.getSession(false);
		String userRole = (String) (session != null ? session.getAttribute("type_user") : null);
		String username = (String) (session != null ? session.getAttribute("username") : null);
		int userId = (int) session.getAttribute("userId");
		
		if (username == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		
		if (!"stall".equals(userRole) && !"admin".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		// Get stall for this user
		List<StallDAO> userStalls = stallService.findByManagerUserId(userId);
		
		if (userStalls.isEmpty() && !"admin".equals(userRole)) {
			response.sendError(HttpServletResponse.SC_FORBIDDEN, "You don't manage any stall");
			return;
		}
		
		// Get orders
		String statusFilter = request.getParameter("status");
		List<OrderDAO> orders;
		
		if ("admin".equals(userRole)) {
			// Admin sees all orders
			if (statusFilter != null && !statusFilter.equals("all")) {
				orders = orderService.findByStallIdAndStatus(0, statusFilter); // This won't work properly, need to adjust
			} else {
				// For admin, we'd need a findAll method that returns List<OrderDAO>
				orders = orderService.findByUserId(userId); // Placeholder - needs proper implementation
			}
		} else {
			// Stall user sees only their orders
			int stallId = userStalls.get(0).getId();
			if (statusFilter != null && !statusFilter.equals("all")) {
				orders = orderService.findByStallIdAndStatus(stallId, statusFilter);
			} else {
				orders = orderService.findByStallId(stallId);
			}
		}
		
		// Get order items for each order
		Map<Integer, List<Order_FoodDAO>> orderFoodMap = new HashMap<>();
		for (OrderDAO order : orders) {
			List<Order_FoodDAO> items = orderFoodService.findByOrderId(order.getId());
			orderFoodMap.put(order.getId(), items);
		}
		
		request.setAttribute("orders", orders);
		request.setAttribute("orderFoodMap", orderFoodMap);
		
		request.getRequestDispatcher("/stall-orders.jsp").forward(request, response);
	}
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
}

