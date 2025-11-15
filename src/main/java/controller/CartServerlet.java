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
                // Giỏ hàng trống - redirect đến trang thất bại
                response.sendRedirect(request.getContextPath() + "/order-failed.jsp?error=Giỏ hàng trống. Vui lòng thêm sản phẩm vào giỏ hàng trước khi đặt hàng.");
                return;
            }

            // Lấy userId từ session (đã được kiểm tra ở trên khi checkout)
            int userId = (int) session.getAttribute("userId");
            // Kiểm tra username đã được xử lý ở trên (dòng 83-92), không cần kiểm tra lại
            // String username = (String) session.getAttribute("username");
            // if (username == null) {
            //     session.setAttribute("redirectAfterLogin", request.getRequestURI());
            //     response.sendRedirect(request.getContextPath() + "/login");
            //     return;
            // }

            String address = request.getParameter("address");
            String payment = request.getParameter("payment");
            String stallParam = request.getParameter("stallId");

            if (address == null || address.trim().isEmpty()) {
                // Địa chỉ trống - redirect đến trang thất bại
                response.sendRedirect(request.getContextPath() + "/order-failed.jsp?error=Vui lòng nhập địa chỉ giao hàng.");
                return;
            }

            // Get stallId from parameter or session
            int stallId = 0;
            if (stallParam != null && !stallParam.isEmpty()) {
                try {
                    stallId = Integer.parseInt(stallParam);
                } catch (NumberFormatException e) {
                    // stallId không hợp lệ - redirect đến trang thất bại
                    response.sendRedirect(request.getContextPath() + "/order-failed.jsp?error=Thông tin quầy hàng không hợp lệ.");
                    return;
                }
            }
            
            // If not in parameter, try to get from session
            if (stallId == 0) {
                Object sessionStallIdObj = session.getAttribute("stallId");
                if (sessionStallIdObj != null) {
                    try {
                        stallId = (int) sessionStallIdObj;
                    } catch (ClassCastException e) {
                        // stallId trong session không hợp lệ
                        response.sendRedirect(request.getContextPath() + "/order-failed.jsp?error=Thông tin quầy hàng không hợp lệ.");
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

            // Lưu đơn hàng - nếu thất bại sẽ throw exception
            OrderDAO createdOrder = orderRepository.save(order);
            if (createdOrder == null || createdOrder.getId() == 0) {
                // Không thể tạo đơn hàng
                response.sendRedirect(request.getContextPath() + "/order-failed.jsp?error=Không thể tạo đơn hàng. Vui lòng thử lại sau.");
                return;
            }

            // Lưu các món ăn trong đơn hàng
            for (Order_FoodDAO item : cart) {
                item.setOrderId(createdOrder.getId());
                orderFoodRepository.create(item);
            }

            // Clear cart and stallId from session immediately after successful order
            session.removeAttribute("cart");
            session.removeAttribute("stallId");
            
            // Đặt hàng thành công - redirect đến trang thành công
            response.sendRedirect(request.getContextPath() + "/order-success.jsp?orderId=" + createdOrder.getId());

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/order-failed.jsp?error=Thông tin đơn hàng không hợp lệ: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            // Lỗi hệ thống - redirect đến trang thất bại
            response.sendRedirect(request.getContextPath() + "/order-failed.jsp?error=Đã xảy ra lỗi hệ thống khi xử lý đơn hàng. Vui lòng thử lại sau.");
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
