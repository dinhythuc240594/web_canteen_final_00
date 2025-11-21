package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.OrderDAO;
import model.StallDAO;
import model.UserDAO;
import serviceimpl.OrderServiceImpl;
import serviceimpl.StallServiceImpl;
import serviceimpl.UserServiceImpl;
import utils.DataSourceUtil;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

@WebServlet("/stall")
public class StallServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private UserServiceImpl userService;
	private StallServiceImpl stallService;
	private OrderServiceImpl orderService;
	
	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.userService = new UserServiceImpl(ds);
		this.stallService = new StallServiceImpl(ds);
		this.orderService = new OrderServiceImpl(ds);
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		String userRole = (String) (session != null ? session.getAttribute("type_user") : null);
		String username = (String) (session != null ? session.getAttribute("username") : null);
		Integer userId = (Integer) (session != null ? session.getAttribute("userId") : null);
		
		if (username == null || userId == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		
		if (!"stall".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		UserDAO user = userService.getUserById(userId);
		
		List<StallDAO> userStalls = stallService.findByManagerUserId(userId);
		
		if (userStalls.isEmpty()) {
			response.sendError(HttpServletResponse.SC_FORBIDDEN, "You don't manage any stall");
			return;
		}
		
		StallDAO stall = userStalls.get(0);

		List<OrderDAO> orders = orderService.findByStallId(stall.getId());

		int totalOrders = orders.size();
		double totalRevenue = 0.0;
		int newOrders = 0;
		int confirmedOrders = 0;
		int inDeliveryOrders = 0;
		int deliveredOrders = 0;
		
		for (OrderDAO order : orders) {
			totalRevenue += order.getTotalPrice();
			String status = order.getStatus();
			if ("new_order".equals(status)) {
				newOrders++;
			} else if ("confirmed".equals(status)) {
				confirmedOrders++;
			} else if ("in_delivery".equals(status)) {
				inDeliveryOrders++;
			} else if ("delivered".equals(status)) {
				deliveredOrders++;
			}
		}
		
		// Get recent orders (last 10)
		List<OrderDAO> recentOrders = orders.size() > 10 ? orders.subList(0, 10) : orders;
		
		// Get pending orders (new_order, confirmed, in_delivery)
		List<OrderDAO> pendingOrders = new java.util.ArrayList<>();
		for (OrderDAO order : orders) {
			String status = order.getStatus();
			if ("new_order".equals(status) || "confirmed".equals(status) || "in_delivery".equals(status)) {
				pendingOrders.add(order);
				if (pendingOrders.size() >= 10) {
					break;
				}
			}
		}
		
		request.setAttribute("user", user);
		request.setAttribute("stall", stall);
		request.setAttribute("totalOrders", totalOrders);
		request.setAttribute("totalRevenue", totalRevenue);
		request.setAttribute("newOrders", newOrders);
		request.setAttribute("confirmedOrders", confirmedOrders);
		request.setAttribute("inDeliveryOrders", inDeliveryOrders);
		request.setAttribute("deliveredOrders", deliveredOrders);
		request.setAttribute("recentOrders", recentOrders);
		request.setAttribute("pendingOrders", pendingOrders);
		
		if (session != null) {
			String flashSuccess = (String) session.getAttribute("stallFlashSuccess");
			if (flashSuccess != null) {
				request.setAttribute("profileSuccess", flashSuccess);
				session.removeAttribute("stallFlashSuccess");
			}
		}
		
		request.getRequestDispatcher("/stall.jsp").forward(request, response);
	}
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		String userRole = (String) (session != null ? session.getAttribute("type_user") : null);
		Integer userId = (Integer) (session != null ? session.getAttribute("userId") : null);
		
		if (userId == null || !"stall".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		
		String action = request.getParameter("action");
		if ("toggleStatus".equals(action)) {
			List<StallDAO> userStalls = stallService.findByManagerUserId(userId);
			if (!userStalls.isEmpty()) {
				StallDAO stall = userStalls.get(0);
				boolean newStatus = !stall.getIsOpen();
				stallService.updateOpenStatus(stall.getId(), newStatus);
			}
		}
		
		response.sendRedirect(request.getContextPath() + "/stall");
	}
}

