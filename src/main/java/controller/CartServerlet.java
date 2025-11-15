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
        
        // Get cart from session - will be null/empty after successful checkout
        List<Order_FoodDAO> cart = (List<Order_FoodDAO>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }
        
        // Forward to cart page
        request.getRequestDispatcher("cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String action = RequestUtil.getString(request, "action", "");
        // Check if user is logged in for checkout operation
        if ((session == null || session.getAttribute("username") == null) && action.equals("checkout")) {
            // Lưu URL trang cart vào session để redirect về sau khi đăng nhập
            if (session == null) {
                session = request.getSession(true);
            }
            String cartUrl = request.getContextPath() + "/cart";
            session.setAttribute("redirectAfterLogin", cartUrl);
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        switch (action) {
            case "add":
                try {
                    String orders_raw = RequestUtil.getString(request, "orders", "[]");
                    System.out.println("Received cart data: " + orders_raw);
                    
                    // Parse JSON cart data from localStorage using json-simple
                    JSONParser parser = new JSONParser();
                    JSONArray cartItems = (JSONArray) parser.parse(orders_raw);
                    
                    // Convert to Order_FoodDAO objects
                    List<Order_FoodDAO> cart = new ArrayList<>();
                    int stallId = 0;
                    
                    for (Object obj : cartItems) {
                        JSONObject item = (JSONObject) obj;
                        Order_FoodDAO orderFood = new Order_FoodDAO();
                        
                        // Parse each field from JSON object
                        orderFood.setFoodId(((Long) item.get("id")).intValue());
                        orderFood.setQuantity(((Long) item.get("quantity")).intValue());
                        
                        // Handle price as either Long or Double
                        Object priceObj = item.get("price");
                        if (priceObj instanceof Long) {
                            orderFood.setPriceAtOrder(((Long) priceObj).doubleValue());
                        } else if (priceObj instanceof Double) {
                            orderFood.setPriceAtOrder((Double) priceObj);
                        }
                        
                        orderFood.setName((String) item.get("name"));
                        orderFood.setImage((String) item.get("image"));
                        
                        // Store stallId for the order (all items should be from same stall)
                        if (stallId == 0 && item.get("stall_id") != null) {
                            stallId = ((Long) item.get("stall_id")).intValue();
                        }
                        
                        cart.add(orderFood);
                    }
                    
                    // Save cart and stallId to session
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
                                 HttpSession session, List<Order_FoodDAO> cart) throws IOException {
        try {
        	
            if (cart == null || cart.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/cart?error=empty_cart");
                return;
            }

            int userId = (int) session.getAttribute("userId");
            String username = (String) session.getAttribute("username");
            if (username == null) {
                session.setAttribute("redirectAfterLogin", request.getRequestURI());
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            String address = request.getParameter("address");
            String payment = request.getParameter("payment");
            String stallParam = request.getParameter("stallId");

            if (address == null || address.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/cart?error=empty_address");
                return;
            }

            // Get stallId from parameter or session
            int stallId = 0;
            if (stallParam != null && !stallParam.isEmpty()) {
                try {
                    stallId = Integer.parseInt(stallParam);
                } catch (NumberFormatException ignored) {
                }
            }
            
            // If not in parameter, try to get from session
            if (stallId == 0) {
                int sessionStallId = (int) session.getAttribute("stallId");
                if (sessionStallId > 0) {
                    stallId = sessionStallId;
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

            for (Order_FoodDAO item : cart) {
                item.setOrderId(createdOrder.getId());
                orderFoodRepository.create(item);
            }

            // Clear cart and stallId from session immediately after successful order
            session.removeAttribute("cart");
            session.removeAttribute("stallId");
            
            // Use redirect instead of forward to ensure cart is cleared
            // Store order ID in session temporarily to display on success page
            session.setAttribute("lastOrderId", createdOrder.getId());
            response.sendRedirect(request.getContextPath() + "/order-success.jsp?orderId=" + createdOrder.getId());

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/cart?error=invalid_stallId");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cart?error=server_error");
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
