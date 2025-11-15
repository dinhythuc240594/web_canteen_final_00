package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.OrderDAO;
import model.Order_FoodDAO;
import model.PageRequest;
import repository.OrderRepository;
import repository.Order_FoodRepository;
import repositoryimpl.OrderRepositoryImpl;
import repositoryimpl.Order_FoodRepositoryImpl;
import utils.DataSourceUtil;
import utils.RequestUtil;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

/**
 * Servlet implementation class OrderServerlet
 */
@WebServlet("/order")
public class OrderServerlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public OrderServerlet() {
        super();
        // TODO Auto-generated constructor stub
    }

    private OrderRepository orderRepository;
    private Order_FoodRepository orderFoodRepository;
    private int PAGE_SIZE = 25;

    @Override
    public void init() throws ServletException {
    	DataSource ds = DataSourceUtil.getDataSource();
        orderRepository = new OrderRepositoryImpl(ds);
        orderFoodRepository = new Order_FoodRepositoryImpl(ds);
    }
    
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		 HttpSession session = request.getSession(false);
	        if (session == null || session.getAttribute("userId") == null) {
	        	response.sendRedirect(request.getContextPath() + "/login");
	            return;
	        }

	        int userId = (int) session.getAttribute("userId");
	        String username = (String) session.getAttribute("username");

//			String keyword = RequestUtil.getString(request, "keyword", "");
//			String sortField = RequestUtil.getString(request, "sortField", "name");
//			String orderField = RequestUtil.getString(request, "orderField", "ASC");
//			int page = RequestUtil.getInt(request, "page", 1);
//	        
//	        PageRequest pageReq = new PageRequest(page, PAGE_SIZE, sortField, orderField, keyword);
//	        List<OrderDAO> orders = this.orderRepository.findAll(pageReq);

	        List<OrderDAO> orders = this.orderRepository.findByUserId(userId);	        
	        Map<Integer, List<Order_FoodDAO>> orderFoodMap = new HashMap<>();
	        for (OrderDAO order : orders) {
	            List<Order_FoodDAO> items = orderFoodRepository.findByOrderId(order.getId());
	            orderFoodMap.put(order.getId(), items);
	        }
	        
	        request.setAttribute("orders", orders);
	        request.setAttribute("orderFoodMap", orderFoodMap);

	        request.getRequestDispatcher("order.jsp").forward(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
        	response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("updateStatus".equals(action)) {
        	handleUpdateStatus(request, response);
        } else {
        	doGet(request, response);
        }
	}
	
	private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		String userRole = (String) session.getAttribute("type_user");
		
		// Only admin and stall can update order status
		if (!"admin".equals(userRole) && !"stall".equals(userRole)) {
			response.sendError(HttpServletResponse.SC_FORBIDDEN, "You don't have permission to update order status");
			return;
		}
		
		int orderId = Integer.parseInt(request.getParameter("orderId"));
		String newStatus = request.getParameter("status");
		
		// Validate status
		if (!isValidStatus(newStatus)) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid status value");
			return;
		}
		
		boolean updated = orderRepository.updateStatus(orderId, newStatus);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Map<String, Object> result = new HashMap<>();
		result.put("success", updated);
		result.put("message", updated ? "Order status updated successfully" : "Failed to update order status");
		
		response.getWriter().write(new com.google.gson.Gson().toJson(result));
	}
	
	private boolean isValidStatus(String status) {
		return "new_order".equals(status) || 
		       "confirmed".equals(status) || 
		       "in_delivery".equals(status) || 
		       "delivered".equals(status);
	}

}
