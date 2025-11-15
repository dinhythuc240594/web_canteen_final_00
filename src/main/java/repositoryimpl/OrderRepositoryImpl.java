package repositoryimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import model.OrderDAO;
import model.PageRequest;
import repository.OrderRepository;

public class OrderRepositoryImpl implements OrderRepository{

	private final DataSource ds;
	
	public OrderRepositoryImpl(DataSource ds) {
		this.ds = ds;
	}
	
	@Override
	public OrderDAO save(OrderDAO order) {
		if (order.getId() == 0) {
           return insertNewOrder(order);
        } else {
           return updateExistingOrder(order);
        }
	}

	@Override
	public OrderDAO findById(int id) {
		String sql = "SELECT id, user_id, stall_id, total_price, status, created_at, delivery_location, payment_method FROM orders WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToOrderDAO(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi tìm đơn hàng theo ID: " + id, e);
        }
        return null;
	}

	@Override
	public List<OrderDAO> findAll(PageRequest pageRequest) {
		List<OrderDAO> orders = new ArrayList<>();
		
        int pageSize = pageRequest.getPageSize();
        int offset = pageRequest.getOffset();
        String keyword = pageRequest.getKeyword();
        String sortField = pageRequest.getSortField();
        String orderField = pageRequest.getOrderField();
        
        String sql = "SELECT id, user_id, stall_id, total_price, status, created_at, delivery_location, payment_method FROM orders";
        boolean hasKeyword = keyword != null && !keyword.isEmpty();
        
        if (hasKeyword) {
        	sql += " WHERE id LIKE ? OR status LIKE ?";
        }
        sql += " ORDER BY " + sortField + " " + orderField + " LIMIT ? OFFSET ?";
		
        try (Connection conn = ds.getConnection();
        	PreparedStatement pstmt = conn.prepareStatement(sql)) {

            int paramIndex = 1;
            if (hasKeyword) {
            	String searchPattern = "%" + keyword + "%";
            	pstmt.setString(paramIndex++, searchPattern);
            	pstmt.setString(paramIndex++, searchPattern);
            }
            pstmt.setInt(paramIndex++, pageSize);
            pstmt.setInt(paramIndex++, offset);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapResultSetToOrderDAO(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi lấy tất cả đơn hàng.", e);
        }
        return orders;
	}

	@Override
	public void deleteById(int id) {
		String sql = "DELETE FROM orders WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                System.out.println("Cảnh báo: Không tìm thấy đơn hàng với ID " + id + " để xóa.");
            } else {
                System.out.println("Đã xóa thành công đơn hàng với ID: " + id);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi xóa đơn hàng theo ID: " + id, e);
        }
	}

	@Override
	public List<OrderDAO> findByUserId(int userId) {
		List<OrderDAO> orders = new ArrayList<>();
        String sql = 
            "SELECT id, user_id, stall_id, total_price, status, created_at, delivery_location, payment_method " +
            "FROM orders WHERE user_id = ? ORDER BY created_at DESC";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapResultSetToOrderDAO(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi tìm đơn hàng theo User ID: " + userId, e);
        }
        return orders;
	}

	@Override
	public List<OrderDAO> findByStallId(int stallId) {
		List<OrderDAO> orders = new ArrayList<>();
        String sql = 
            "SELECT id, user_id, stall_id, total_price, status, created_at, delivery_location, payment_method " +
            "FROM orders WHERE stall_id = ? ORDER BY created_at DESC";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, stallId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapResultSetToOrderDAO(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi tìm đơn hàng theo Stall ID: " + stallId, e);
        }
        return orders;
	}

	@Override
	public List<OrderDAO> findByStallIdAndStatus(int stallId, String status) {
		List<OrderDAO> orders = new ArrayList<>();
        String sql = 
            "SELECT id, user_id, stall_id, total_price, status, created_at, delivery_location, payment_method " +
            "FROM orders WHERE stall_id = ? AND status = ? ORDER BY created_at ASC";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setLong(1, stallId);
            pstmt.setString(2, status);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapResultSetToOrderDAO(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi tìm đơn hàng theo Stall ID và Status: " + stallId + ", " + status, e);
        }
        return orders;
	}

	@Override
	public boolean updateStatus(int id, String newStatus) {
		String sql = "UPDATE orders SET status = ?, created_at = CURRENT_TIMESTAMP WHERE id = ?"; 

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, newStatus);
            pstmt.setInt(2, id);

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                System.out.println("Cảnh báo: Không tìm thấy đơn hàng với ID " + id + " để cập nhật trạng thái.");
                return false;
            } else {
                System.out.println("Đã cập nhật trạng thái đơn hàng ID " + id + " thành: " + newStatus);
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi cập nhật trạng thái đơn hàng ID: " + id, e);
        }	
	}
	
	private  OrderDAO insertNewOrder(OrderDAO order) {
        String sql = "INSERT INTO orders (user_id, stall_id, total_price, status, delivery_location, payment_method) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) { 

            pstmt.setInt(1, order.getUserId());
            pstmt.setInt(2, order.getStallId());
            pstmt.setDouble(3, order.getTotalPrice());
            pstmt.setString(4, order.getStatus());
            pstmt.setString(5, order.getDeliveryLocation());
            pstmt.setString(6, order.getPaymentMethod());

            pstmt.executeUpdate();
            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    order.setId(rs.getInt(1));
                }
            }
            return order;

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi thêm mới đơn hàng.", e);
        }
    }
	
	private OrderDAO updateExistingOrder(OrderDAO order) {
        String sql = "UPDATE orders SET user_id = ?, stall_id = ?, total_price = ?, status = ?, delivery_location = ?, payment_method = ? WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setLong(1, order.getUserId());
            pstmt.setLong(2, order.getStallId());
            pstmt.setDouble(3, order.getTotalPrice());
            pstmt.setString(4, order.getStatus());
            pstmt.setString(5, order.getDeliveryLocation());
            pstmt.setString(6, order.getPaymentMethod());
            pstmt.setLong(7, order.getId());

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                System.out.println("Cảnh báo: Không tìm thấy đơn hàng với ID " + order.getId() + " để cập nhật.");
            }
            return order;

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi cập nhật đơn hàng.", e);
        }
    }
	
	private OrderDAO mapResultSetToOrderDAO(ResultSet rs) throws SQLException {
        OrderDAO order = new OrderDAO();
        
        order.setId(rs.getInt("id"));
        order.setUserId(rs.getInt("user_id"));
        order.setStallId(rs.getInt("stall_id"));
        order.setTotalPrice(rs.getDouble("total_price"));
        order.setStatus(rs.getString("status"));

        Timestamp timestamp = rs.getTimestamp("created_at");
        if (timestamp != null) {
            order.setCreatedAt(timestamp);
        }
        
        order.setDeliveryLocation(rs.getString("delivery_location"));
        order.setPaymentMethod(rs.getString("payment_method"));
        
        return order;
    }

	@Override
	public int count(String keyword) {
		String sql = "SELECT COUNT(*) as total FROM orders";
		if (keyword != null && !keyword.isEmpty()) {
			sql += " WHERE id LIKE ? OR status LIKE ?";
		}
		
		try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
			
			if (keyword != null && !keyword.isEmpty()) {
				String searchPattern = "%" + keyword + "%";
				pstmt.setString(1, searchPattern);
				pstmt.setString(2, searchPattern);
			}
			
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					return rs.getInt("total");
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new RuntimeException("Error counting orders", e);
		}
		
		return 0;
	}

}
