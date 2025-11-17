package repositoryimpl;

import utils.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import model.UserDAO;
import repository.UserRepository;

public class UserRepositoryImpl implements UserRepository {
	private final DataSource ds;
	
	public UserRepositoryImpl(DataSource ds) {
		this.ds = ds;
	}
	
	@Override
	public Boolean isAuthenticated(String username, String password) {
		String sql = "SELECT 1 FROM users WHERE username=? And password=? AND status=1";
		String hassPwd = MD5Generator.generateMD5(password);
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)){
    		ps.setString(1, username);
    		ps.setString(2, hassPwd);
            ResultSet rs = ps.executeQuery();
            if(rs.next()) {
            	return true;	
            }
       } catch (Exception e) {
           e.printStackTrace();
       }
        return false;
	}

	@Override
	public UserDAO getUser(String username) {
		UserDAO user = null;
		String sql = "SELECT id, email, full_name, phone_number, photo, role, status FROM users WHERE username=?";
		try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)){
    		ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if(rs.next()) {
                int id = rs.getInt("id");
                String full_name  = rs.getString("full_name");
                String email = rs.getString("email");
                String phone_number = rs.getString("phone_number");
                String avatar = rs.getString("photo");
                String role = rs.getString("role");
                boolean status = rs.getBoolean("status");
            	user = new UserDAO(id, username, full_name, email, phone_number, avatar, role, status);
            }
       } catch (Exception e) {
           e.printStackTrace();
       }
    	return user;
	}

	@Override
	public UserDAO getUserById(int id) {
		UserDAO user = null;
		String sql = "SELECT id, username, email, full_name, phone_number, photo, role, status FROM users WHERE id=?";
		try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)){
    		ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if(rs.next()) {
                String username = rs.getString("username");
                String full_name  = rs.getString("full_name");
                String email = rs.getString("email");
                String phone_number = rs.getString("phone_number");
                String avatar = rs.getString("photo");
                String role = rs.getString("role");
                boolean status = rs.getBoolean("status");
            	user = new UserDAO(id, username, full_name, email, phone_number, avatar, role, status);
            }
       } catch (Exception e) {
           e.printStackTrace();
       }
    	return user;
	}

	@Override
	public List<UserDAO> findAll() {
		List<UserDAO> users = new ArrayList<>();
		String sql = "SELECT id, username, email, full_name, phone_number, photo, role, status, created_at FROM users ORDER BY created_at DESC";
		try (Connection conn = ds.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while(rs.next()) {
                UserDAO user = mapResultSetToUser(rs);
                users.add(user);
            }
       } catch (Exception e) {
           e.printStackTrace();
       }
    	return users;
	}

	@Override
	public List<UserDAO> findByRole(String role) {
		List<UserDAO> users = new ArrayList<>();
		String sql = "SELECT id, username, email, full_name, phone_number, photo, role, status, created_at FROM users WHERE role=? ORDER BY created_at DESC";
		try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)){
    		ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                UserDAO user = mapResultSetToUser(rs);
                users.add(user);
            }
       } catch (Exception e) {
           e.printStackTrace();
       }
    	return users;
	}

	@Override
	public UserDAO save(UserDAO user) {
		String sql = "INSERT INTO users (username, password, full_name, email, phone_number, role, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
		try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)){
			String defaultPassword = MD5Generator.generateMD5("123456"); // Default password
    		ps.setString(1, user.getUsername());
    		ps.setString(2, defaultPassword);
    		ps.setString(3, user.getFull_name());
    		ps.setString(4, user.getEmail());
    		ps.setString(5, user.getPhone());
    		ps.setString(6, user.getRole());
    		ps.setBoolean(7, user.isStatus());
            
            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        user.setId(generatedKeys.getInt(1));
                    }
                }
                return user;
            }
       } catch (Exception e) {
           e.printStackTrace();
       }
    	return null;
	}

	@Override
	public boolean update(UserDAO user) {
		String sql = "UPDATE users SET username=?, full_name=?, email=?, phone_number=?, role=?, status=? WHERE id=?";
		try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)){
    		ps.setString(1, user.getUsername());
    		ps.setString(2, user.getFull_name());
    		ps.setString(3, user.getEmail());
    		ps.setString(4, user.getPhone());
    		ps.setString(5, user.getRole());
    		ps.setBoolean(6, user.isStatus());
    		ps.setInt(7, user.getId());
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
       } catch (Exception e) {
           e.printStackTrace();
       }
    	return false;
	}
	
	@Override
	public boolean updateProfile(UserDAO user) {
		String sql = "UPDATE users SET full_name=?, email=?, phone_number=?, photo=? WHERE id=?";
		try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)){
    		ps.setString(1, user.getFull_name());
    		ps.setString(2, user.getEmail());
    		ps.setString(3, user.getPhone());
    		ps.setString(4, user.getAvatar());
    		ps.setInt(5, user.getId());
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
       } catch (Exception e) {
           e.printStackTrace();
       }
    	return false;
	}

	@Override
	public boolean updateStatus(int id, boolean status) {
		String sql = "UPDATE users SET status=? WHERE id=?";
		try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)){
    		ps.setBoolean(1, status);
    		ps.setInt(2, id);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
       } catch (Exception e) {
           e.printStackTrace();
       }
    	return false;
	}

	@Override
	public boolean updatePassword(int id, String hashedPassword) {
		String sql = "UPDATE users SET password=? WHERE id=?";
		try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)){
    		ps.setString(1, hashedPassword);
    		ps.setInt(2, id);

            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
       } catch (Exception e) {
           e.printStackTrace();
       }
    	return false;
	}

	@Override
	public boolean deleteById(int id) {
		String sql = "DELETE FROM users WHERE id=?";
		try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)){
    		ps.setInt(1, id);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
       } catch (Exception e) {
           e.printStackTrace();
       }
    	return false;
	}

	@Override
	public int count() {
		String sql = "SELECT COUNT(*) as total FROM users";
		try (Connection conn = ds.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if(rs.next()) {
            	return rs.getInt("total");
            }
       } catch (Exception e) {
           e.printStackTrace();
       }
    	return 0;
	}

	@Override
	public boolean existsByUsername(String username) {
		String sql = "SELECT 1 FROM users WHERE username=?";
		try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)){
    		ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            return rs.next();
       } catch (Exception e) {
           e.printStackTrace();
       }
    	return false;
	}
	
	private UserDAO mapResultSetToUser(ResultSet rs) throws SQLException {
		UserDAO user = new UserDAO();
		user.setId(rs.getInt("id"));
		user.setUsername(rs.getString("username"));
		user.setFull_name(rs.getString("full_name"));
		user.setEmail(rs.getString("email"));
		user.setPhone(rs.getString("phone_number"));
		user.setAvatar(rs.getString("photo"));
		user.setRole(rs.getString("role"));
		user.setStatus(rs.getBoolean("status"));
		user.setCreateDate(rs.getTimestamp("created_at"));
		return user;
	}
}
