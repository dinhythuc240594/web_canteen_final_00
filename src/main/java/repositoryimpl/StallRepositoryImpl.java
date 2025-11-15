package repositoryimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import model.StallDAO;
import repository.StallRepository;

public class StallRepositoryImpl implements StallRepository{

	private final DataSource ds;
	
	public StallRepositoryImpl(DataSource ds) {
		this.ds = ds;
	}
	
    @Override
    public StallDAO save(StallDAO stall) {
        if (stall.getId() == 0) {
            // INSERT
            String sql = "INSERT INTO stalls (name, description, manager_user_id, is_open) VALUES (?, ?, ?, ?)";
            try (Connection conn = ds.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) { 

                pstmt.setString(1, stall.getName());
                pstmt.setString(2, stall.getDescription());
                pstmt.setInt(3, stall.getManagerUserId());
                pstmt.setBoolean(4, stall.getIsOpen());
                
                pstmt.executeUpdate();
                return stall;

            } catch (SQLException e) {
                e.printStackTrace();
                throw new RuntimeException("Lỗi khi thêm mới gian hàng.", e);
            }
        } else {
            // UPDATE
            String SQL_UPDATE = "UPDATE stalls SET name = ?, description = ?, manager_user_id = ?, is_open = ? WHERE id = ?";
            try (Connection conn = ds.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(SQL_UPDATE)) {

                pstmt.setString(1, stall.getName());
                pstmt.setString(2, stall.getDescription());
                pstmt.setInt(3, stall.getManagerUserId());
                pstmt.setBoolean(4, stall.getIsOpen());
                pstmt.setInt(5, stall.getId());
                
                pstmt.executeUpdate();
                return stall;

            } catch (SQLException e) {
                e.printStackTrace();
                throw new RuntimeException("Lỗi khi cập nhật gian hàng ID: " + stall.getId(), e);
            }
        }
    }
    
    // --- FIND BY ID ---
    @Override
    public StallDAO findById(int id) {
        String sql = "SELECT id, name, description, manager_user_id, is_open FROM stalls WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setLong(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToStallDAO(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi tìm gian hàng theo ID: " + id, e);
        }
        return null;
    }

    // --- FIND ALL ---
    @Override
    public List<StallDAO> findAll() {
        List<StallDAO> stalls = new ArrayList<>();
        String SQL = "SELECT id, name, description, manager_user_id, is_open FROM stalls";

        try (Connection conn = ds.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(SQL)) {

            while (rs.next()) {
                stalls.add(mapResultSetToStallDAO(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi lấy tất cả gian hàng.", e);
        }
        return stalls;
    }

    // --- DELETE BY ID ---
    @Override
    public void deleteById(int id) {
        String sql = "DELETE FROM stalls WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setLong(1, id);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi xóa gian hàng ID: " + id, e);
        }
    }
    
    // --- FIND BY MANAGER USER ID ---
    @Override
    public List<StallDAO> findByManagerUserId(int managerUserId) {
        List<StallDAO> stalls = new ArrayList<>();
        String SQL = "SELECT id, name, description, manager_user_id, is_open FROM stalls WHERE manager_user_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            
            pstmt.setLong(1, managerUserId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    stalls.add(mapResultSetToStallDAO(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi tìm gian hàng theo Manager User ID: " + managerUserId, e);
        }
        return stalls;
    }

    // --- FIND OPEN STALLS ---
    @Override
    public List<StallDAO> findOpenStalls() {
        List<StallDAO> stalls = new ArrayList<>();
        String sql = "SELECT id, name, description, manager_user_id, is_open FROM stalls WHERE is_open = TRUE";

        try (Connection conn = ds.getConnection();
             Statement stmt = conn.createStatement(); // Hoặc PreparedStatement nếu DB cần giá trị boolean đặc biệt
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                stalls.add(mapResultSetToStallDAO(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi tìm các gian hàng đang mở.", e);
        }
        return stalls;
    }
    
    // --- UPDATE OPEN STATUS ---
    @Override
    public void updateOpenStatus(int id, Boolean isOpen) {
        String sql = "UPDATE stalls SET is_open = ? WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setBoolean(1, isOpen);
            pstmt.setLong(2, id);
            
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khi cập nhật trạng thái mở/đóng cho gian hàng ID: " + id, e);
        }
    }
	
	private StallDAO mapResultSetToStallDAO(ResultSet rs) throws SQLException {
        StallDAO stall = new StallDAO();
        
        stall.setId(rs.getInt("id"));
        stall.setName(rs.getString("name"));
        stall.setDescription(rs.getString("description"));
        stall.setManagerUserId(rs.getInt("manager_user_id"));
        stall.setIsOpen(rs.getBoolean("is_open"));
        
        return stall;
    }

}
