package repositoryimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import model.Order_FoodDAO;
import model.PageRequest;
import repository.Order_FoodRepository;

public class Order_FoodRepositoryImpl implements Order_FoodRepository{

	private final DataSource ds;
	
	public Order_FoodRepositoryImpl(DataSource ds) {
		this.ds = ds;
	}
	
	@Override
	public Order_FoodDAO create(Order_FoodDAO orderFood) {
		String sql = "INSERT INTO order_foods (order_id, food_id, quantity, price_at_order) VALUES (?, ?, ?, ?)";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) { 

            pstmt.setInt(1, orderFood.getOrderId());
            pstmt.setInt(2, orderFood.getFoodId());
            pstmt.setInt(3, orderFood.getQuantity());
            pstmt.setDouble(4, orderFood.getPriceAtOrder());

            pstmt.executeUpdate();

            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                	orderFood.setId(rs.getInt(1));
                }
            }
            
            return orderFood;

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi thêm chi tiết đơn hàng.", e);
        }
	}

	@Override
	public Order_FoodDAO findById(int id) {
		String sql = "SELECT id, order_id, food_id, quantity, price_at_order FROM order_foods WHERE id = ?";
		Order_FoodDAO order_food = null;
        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setLong(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToOrderFoodDAO(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi tìm chi tiết đơn hàng theo ID: " + id, e);
        }
        return order_food;
	}

	@Override
	public List<Order_FoodDAO> findAll(PageRequest pageRequest) {
		List<Order_FoodDAO> items = new ArrayList<>();
        String sql = "SELECT id, order_id, food_id, quantity, price_at_order FROM order_foods";

        try (Connection conn = ds.getConnection();
        	PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery(sql)) {

            while (rs.next()) {
                items.add(mapResultSetToOrderFoodDAO(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi lấy tất cả chi tiết đơn hàng.", e);
        }
        return items;
	}

	@Override
	public void deleteById(int id) {
		String sql = "DELETE FROM order_foods WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setLong(1, id);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi xóa chi tiết đơn hàng ID: " + id, e);
        }
	}

	@Override
	public List<Order_FoodDAO> findByOrderId(int orderId) {
		List<Order_FoodDAO> items = new ArrayList<>();
        String sql = "SELECT id, order_id, food_id, quantity, price_at_order FROM order_foods WHERE order_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, orderId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    items.add(mapResultSetToOrderFoodDAO(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi tìm chi tiết đơn hàng theo Order ID: " + orderId, e);
        }
        return items;
	}

	@Override
	public void deleteByOrderId(int orderId) {
		String sql = "DELETE FROM order_foods WHERE order_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setLong(1, orderId);
            int affectedRows = pstmt.executeUpdate();
            System.out.println("Đã xóa " + affectedRows + " chi tiết đơn hàng cho Order ID: " + orderId);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi xóa chi tiết đơn hàng theo Order ID: " + orderId, e);
        }
		
	}

	@Override
	public void deleteByFoodId(int foodId) {
		String sql = "DELETE FROM order_foods WHERE food_id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, foodId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi xóa chi tiết đơn hàng theo Food ID: " + foodId, e);
        }
	}
	
	private Order_FoodDAO mapResultSetToOrderFoodDAO(ResultSet rs) throws SQLException {
        Order_FoodDAO item = new Order_FoodDAO();
        
        item.setId(rs.getInt("id"));
        item.setOrderId(rs.getInt("order_id"));
        item.setFoodId(rs.getInt("food_id"));
        item.setQuantity(rs.getInt("quantity"));
        item.setPriceAtOrder(rs.getDouble("price_at_order"));
        
        return item;
    }

	@Override
	public int count(String keyword) {
        String sql = "SELECT COUNT(1) FROM order_foods";
        int total = 0;
        
        boolean hasKeywords = keyword != null && !keyword.trim().isEmpty();
        
        if (hasKeywords) {
            sql += " WHERE title LIKE ? OR author LIKE ?";
        }
        
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (hasKeywords) {
                String searchPattern = "%" + keyword + "%";
                ps.setString(1, searchPattern);
                ps.setString(2, searchPattern);
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt(1);
            }

        } catch (Exception e) {
        	System.err.println("Lỗi count: " + e.getMessage());
            return -1;
        }
        
        return total;
	}

}
