package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.OrderDAO;
import model.Order_FoodDAO;
import repository.OrderRepository;
import repository.Order_FoodRepository;
import repositoryimpl.OrderRepositoryImpl;
import repositoryimpl.Order_FoodRepositoryImpl;
import utils.DataSourceUtil;
import utils.RequestUtil;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import dto.OrderFoodDTO;

/**
 * Servlet implementation class CartServerlet
 */
@WebServlet("/cart")
public class CartServerlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private OrderRepository orderRepository;
    private Order_FoodRepository orderFoodRepository;

    public CartServerlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        DataSource ds = DataSourceUtil.getDataSource();
        this.orderRepository = new OrderRepositoryImpl(ds);
        this.orderFoodRepository = new Order_FoodRepositoryImpl(ds);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        
        // // Check if user is logged in
        // if (session == null || session.getAttribute("userId") == null) {
        //     response.sendRedirect(request.getContextPath() + "/login");
        //     return;
        // }
        System.out.println("Get cart page");
        
        List<Order_FoodDAO> cart = (List<Order_FoodDAO>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }
        
        request.getRequestDispatcher("cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String action = RequestUtil.getString(request, "action", "");
        if ((session == null || session.getAttribute("username") == null) && action.equals("checkout")) {
            if (session == null) {
                session = request.getSession(true);
            }
            String cartUrl = request.getContextPath() + "/cart";
            session.setAttribute("redirectAfterLogin", cartUrl);
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Handler page base on action
        switch (action) {
            case "add":
                try {
                    String orders_raw = RequestUtil.getString(request, "orders", "[]");
                    System.out.println("Received cart data: " + orders_raw);
                    
                    JSONParser parser = new JSONParser();
                    JSONArray cartItems = (JSONArray) parser.parse(orders_raw);
                    
                    List<Order_FoodDAO> cart = new ArrayList<>();
                    int stallId = 0;
                    
                    for (Object obj : cartItems) {
                        JSONObject item = (JSONObject) obj;
                        Order_FoodDAO orderFood = new Order_FoodDAO();
                        
                        orderFood.setFoodId(((Long) item.get("id")).intValue());
                        orderFood.setQuantity(((Long) item.get("quantity")).intValue());
                        
                        Object priceObj = item.get("price");
                        if (priceObj instanceof Long) {
                            orderFood.setPriceAtOrder(((Long) priceObj).doubleValue());
                        } else if (priceObj instanceof Double) {
                            orderFood.setPriceAtOrder((Double) priceObj);
                        }
                        
                        orderFood.setName((String) item.get("name"));
                        orderFood.setImage((String) item.get("image"));
                        
                        if (stallId == 0 && item.get("stall_id") != null) {
                            stallId = ((Long) item.get("stall_id")).intValue();
                        }
                        
                        cart.add(orderFood);
                    }
                    
                    session.setAttribute("cart", cart);
                    if (stallId > 0) {
                        session.setAttribute("stallId", stallId);
                    }
                    
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("{\"status\":\"success\"}");
                    
                } catch (ParseException e) {
                    e.printStackTrace();
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Invalid JSON format: " + e.getMessage() + "\"}");
                } catch (Exception e) {
                    e.printStackTrace();
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}");
                }
                return;

            case "checkout":
                List<Order_FoodDAO> cart = (List<Order_FoodDAO>) session.getAttribute("cart");
                processCheckout(request, response, session, cart);
                return;

            default:
                response.sendRedirect(request.getContextPath() + "/cart");
                break;
        }
    }

    private void processCheckout(HttpServletRequest request, HttpServletResponse response,
                                 HttpSession session, List<Order_FoodDAO> cart) throws IOException, ServletException {
        try {
        	
            if (cart == null || cart.isEmpty()) {
                request.setAttribute("errorMessage", "Giỏ hàng trống. Vui lòng thêm sản phẩm vào giỏ hàng trước khi đặt hàng.");
                request.getRequestDispatcher("order-failed.jsp").forward(request, response);
                return;
            }

            int userId = (int) session.getAttribute("userId");

            String address = request.getParameter("address");
            String payment = request.getParameter("payment");
            String stallParam = request.getParameter("stallId");

            if (address == null || address.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng nhập địa chỉ giao hàng.");
                request.getRequestDispatcher("order-failed.jsp").forward(request, response);
                return;
            }

            int stallId = 0;
            if (stallParam != null && !stallParam.isEmpty()) {
                try {
                    stallId = Integer.parseInt(stallParam);
                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "Thông tin quầy hàng không hợp lệ.");
                    request.getRequestDispatcher("order-failed.jsp").forward(request, response);
                    return;
                }
            }
            
            if (stallId == 0) {
                Object sessionStallIdObj = session.getAttribute("stallId");
                if (sessionStallIdObj != null) {
                    try {
                        stallId = (int) sessionStallIdObj;
                    } catch (ClassCastException e) {
                        request.setAttribute("errorMessage", "Thông tin quầy hàng không hợp lệ.");
                        request.getRequestDispatcher("order-failed.jsp").forward(request, response);
                        return;
                    }
                }
            }

            double total = cart.stream()
                    .mapToDouble(i -> i.getPriceAtOrder() * i.getQuantity())
                    .sum();

            OrderDAO order = new OrderDAO();
            order.setUserId(userId);
            order.setStallId(stallId);
            order.setTotalPrice(total);
            order.setStatus("new_order");
            order.setPaymentMethod(payment != null ? payment : "COD");
            order.setDeliveryLocation(address);

            OrderDAO createdOrder = orderRepository.save(order);
            if (createdOrder == null || createdOrder.getId() == 0) {
                request.setAttribute("errorMessage", "Không thể tạo đơn hàng. Vui lòng thử lại sau.");
                request.getRequestDispatcher("order-failed.jsp").forward(request, response);
                return;
            }

            for (Order_FoodDAO item : cart) {
                item.setOrderId(createdOrder.getId());
                orderFoodRepository.create(item);
            }

            session.removeAttribute("cart");
            session.removeAttribute("stallId");
            
            request.setAttribute("order", createdOrder);
            request.getRequestDispatcher("order-success.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Thông tin đơn hàng không hợp lệ: " + e.getMessage());
            request.getRequestDispatcher("order-failed.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống khi xử lý đơn hàng. Vui lòng thử lại sau.");
            request.getRequestDispatcher("order-failed.jsp").forward(request, response);
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        List<Order_FoodDAO> cart = (List<Order_FoodDAO>) session.getAttribute("cart");
        if (cart == null) return;

        int foodId = Integer.parseInt(req.getParameter("foodId"));
        cart.removeIf(item -> item.getFoodId() == foodId);

        session.setAttribute("cart", cart);
        resp.setStatus(HttpServletResponse.SC_OK);
    }

}
