package repositoryimpl;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import model.StatisticDAO;
import repository.StatisticRepository;

public class StatisticRepositoryImpl implements StatisticRepository{

	private final DataSource ds;
	
	public StatisticRepositoryImpl(DataSource ds) {
		this.ds = ds;
	}
	
	public StatisticDAO save(StatisticDAO stat) {
        if (stat.getId() == 0) {
            String SQL_INSERT = "INSERT INTO statistics (stat_date, stall_id, food_id, orders_count, revenue, quantity_sold) VALUES (?, ?, ?, ?, ?, ?)";
            try (Connection conn = ds.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(SQL_INSERT)) { 

                pstmt.setDate(1, stat.getStatDate());
                pstmt.setLong(2, stat.getStallId());
                
                pstmt.setInt(3, stat.getFoodId());
                
                pstmt.setInt(4, stat.getOrdersCount());
                pstmt.setDouble(5, stat.getRevenue());
                pstmt.setInt(6, stat.getQuantitySold());
                
                pstmt.executeUpdate();

                return stat;

            } catch (SQLException e) {
                e.printStackTrace();
                throw new RuntimeException("Lỗi khi thêm mới số liệu thống kê.", e);
            }
        } else {

            String sql = "UPDATE statistics SET stat_date = ?, stall_id = ?, food_id = ?, orders_count = ?, revenue = ?, quantity_sold = ? WHERE id = ?";
            try (Connection conn = ds.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setDate(1, stat.getStatDate());
                pstmt.setLong(2, stat.getStallId());
                
                pstmt.setInt(3, stat.getFoodId());
                
                pstmt.setInt(4, stat.getOrdersCount());
                pstmt.setDouble(5, stat.getRevenue());
                pstmt.setInt(6, stat.getQuantitySold());
                pstmt.setLong(7, stat.getId());
                
                pstmt.executeUpdate();
                return stat;

            } catch (SQLException e) {
                e.printStackTrace();
                throw new RuntimeException("Lỗi khi cập nhật số liệu thống kê ID: " + stat.getId(), e);
            }
        }
    }
    
    @Override
    public List<StatisticDAO> findByStallIdAndDateRange(int stallId, Date startDate, Date endDate) {
        List<StatisticDAO> stats = new ArrayList<>();
        String sql = "SELECT * FROM statistics WHERE stall_id = ? AND stat_date BETWEEN ? AND ? ORDER BY stat_date ASC, food_id ASC";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setLong(1, stallId);
            pstmt.setDate(2, startDate);
            pstmt.setDate(3, endDate);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    stats.add(mapResultSetToStatisticsDAO(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi tìm thống kê theo Stall ID và khoảng thời gian.", e);
        }
        return stats;
    }

    @Override
    public StatisticDAO findByStallIdAndFoodIdAndDate(int stallId, int foodId, Date statDate) {
        String sql = "SELECT * FROM statistics WHERE stall_id = ? AND food_id = ? AND stat_date = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setLong(1, stallId);
            pstmt.setLong(2, foodId);
            pstmt.setDate(3, statDate);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToStatisticsDAO(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi tìm thống kê món ăn cụ thể.", e);
        }
        return null;
    }
    
    @Override
    public List<StatisticDAO> findByDateRange(Date startDate, Date endDate) {
        List<StatisticDAO> stats = new ArrayList<>();
        String sql = "SELECT " +
//                "    stall_id, " +
                "    DATE(created_at) as stat_date, " +
                "    COUNT(id) as total_orders, " +
                "    SUM(total_price) as total_revenue " +
                "FROM orders " +
                "WHERE DATE(created_at) BETWEEN ? AND ? " +
                 "AND status = 'delivered' "
                + "GROUP BY DATE(created_at) "
                + "ORDER BY stat_date ASC";
//                "GROUP BY stall_id, DATE(created_at) " +
//                "ORDER BY stat_date ASC, stall_id ASC";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setDate(1, startDate);
            pstmt.setDate(2, endDate);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    StatisticDAO stat = new StatisticDAO();
//                    stat.setStallId(rs.getInt("stall_id"));
                    stat.setStatDate(rs.getDate("stat_date"));
                    stat.setTotalOrders(rs.getInt("total_orders"));
                    stat.setTotalRevenue(rs.getDouble("total_revenue")); // Hoặc getBigDecimal nếu dùng tiền lớn

                    stats.add(stat);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi thống kê dữ liệu orders.", e);
        }
        return stats;

//        String sql = "SELECT * FROM statistics WHERE stat_date BETWEEN ? AND ? ORDER BY stat_date ASC, stall_id ASC, food_id ASC";
//
//        try (Connection conn = ds.getConnection();
//             PreparedStatement pstmt = conn.prepareStatement(sql)) {
//
//            pstmt.setDate(1, startDate);
//            pstmt.setDate(2, endDate);
//
//            try (ResultSet rs = pstmt.executeQuery()) {
//                while (rs.next()) {
//                    stats.add(mapResultSetToStatisticsDAO(rs));
//                }
//            }
//        } catch (SQLException e) {
//            e.printStackTrace();
//            throw new RuntimeException("Lỗi khi tìm thống kê theo khoảng thời gian.", e);
//        }
//        return stats;
    }

	public StatisticDAO findById(int id) {
        String sql = "SELECT id, stat_date, stall_id, food_id, orders_count, revenue, quantity_sold FROM statistics WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setLong(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToStatisticsDAO(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi tìm số liệu thống kê theo ID: " + id, e);
        }
        return null;
    }
    
    @Override
    public List<StatisticDAO> findAll() {
        List<StatisticDAO> stats = new ArrayList<>();
        String sql = "SELECT id, stat_date, stall_id, food_id, orders_count, revenue, quantity_sold FROM statistics ORDER BY stat_date DESC";

        try (Connection conn = ds.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                stats.add(mapResultSetToStatisticsDAO(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi lấy tất cả số liệu thống kê.", e);
        }
        return stats;
    }


    @Override
    public void deleteById(int id) {
        String sql = "DELETE FROM statistics WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setLong(1, id);
            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                System.out.println("Cảnh báo: Không tìm thấy số liệu thống kê với ID " + id + " để xóa.");
            } else {
                System.out.println("Đã xóa thành công số liệu thống kê với ID: " + id);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi xóa số liệu thống kê theo ID: " + id, e);
        }
    }
    
	private StatisticDAO mapResultSetToStatisticsDAO(ResultSet rs) throws SQLException {
        StatisticDAO stat = new StatisticDAO();
        
        Date sqlDate = rs.getDate("stat_date");
        if (sqlDate != null) {
            stat.setStatDate(sqlDate);
        }
        
        stat.setStallId(rs.getInt("stall_id"));
        stat.setFoodId(rs.getInt("food_id") == 0 && rs.wasNull() ? null : rs.getInt("food_id"));
        
        stat.setOrdersCount(rs.getInt("orders_count"));
        stat.setRevenue(rs.getDouble("revenue"));
        stat.setQuantitySold(rs.getInt("quantity_sold"));
        
        return stat;
    }
	
}
