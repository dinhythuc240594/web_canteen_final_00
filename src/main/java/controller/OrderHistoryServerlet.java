package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.OrderDAO;
import model.Order_FoodDAO;
import model.Page;
import model.PageRequest;
import model.StallDAO;
import repository.OrderRepository;
import repository.Order_FoodRepository;
import repository.StallRepository;
import repositoryimpl.OrderRepositoryImpl;
import repositoryimpl.Order_FoodRepositoryImpl;
import repositoryimpl.StallRepositoryImpl;
import serviceimpl.OrderServiceImpl;
import serviceimpl.StallServiceImpl;
import utils.DataSourceUtil;
import utils.RequestUtil;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import dto.FoodDTO;

/**
 * Servlet implementation class OrderHistoryServerlet
 */
@WebServlet("/order-history")
public class OrderHistoryServerlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public OrderHistoryServerlet() {
        super();
    }

    private OrderServiceImpl orderService;
    private StallServiceImpl stallService;
    private Order_FoodRepository orderFoodRepository;

    @Override
    public void init() throws ServletException {
    	DataSource ds = DataSourceUtil.getDataSource();
        orderService = new OrderServiceImpl(ds);
        stallService = new StallServiceImpl(ds);
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
        String userRole = (String) session.getAttribute("type_user");
        
        if (userRole == null) {
            userRole = "customer"; // default role
        }

        List<OrderDAO> orders = new ArrayList<>();
        Map<Integer, List<Order_FoodDAO>> orderFoodMap = new HashMap<>();
        
        // Role-based order retrieval
        if ("admin".equals(userRole)) {
            // Admin sees all orders
            String keyword = RequestUtil.getString(request, "keyword", "");
            String sortField = RequestUtil.getString(request, "sortField", "created_at");
            String orderField = RequestUtil.getString(request, "orderField", "DESC");
            int page = RequestUtil.getInt(request, "page", 1);
            
            PageRequest pageReq = new PageRequest(page, 25, sortField, orderField, keyword);
            Page<OrderDAO> pageOrder = this.orderService.findAll(pageReq);
            orders = pageOrder.getData();
            
            request.setAttribute("pageReq", pageReq);
            request.setAttribute("pageOrder", pageOrder);
        } else if ("stall".equals(userRole)) {
            // Stall user sees only orders for their stall
            List<StallDAO> stalls = stallService.findByManagerUserId(userId);
            if (!stalls.isEmpty()) {
                int stallId = stalls.get(0).getId(); // Get first stall (assuming one stall per user)
                orders = orderService.findByStallId(stallId);
                request.setAttribute("stallId", stallId);
            }
        } else {
            // Customer sees only their own orders
            orders = orderService.findByUserId(userId);
        }
        
        // Get order details (food items) for each order
        for (OrderDAO order : orders) {
            List<Order_FoodDAO> items = orderFoodRepository.findByOrderId(order.getId());
            orderFoodMap.put(order.getId(), items);
        }
        
        request.setAttribute("orders", orders);
        request.setAttribute("orderFoodMap", orderFoodMap);
        request.setAttribute("userRole", userRole);

        request.getRequestDispatcher("order_history.jsp").forward(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}
