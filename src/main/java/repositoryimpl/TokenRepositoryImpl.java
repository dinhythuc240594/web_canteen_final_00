package repositoryimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import javax.sql.DataSource;

import model.TokenDAO;
import repository.TokenRepository;

public class TokenRepositoryImpl implements TokenRepository {

	private final DataSource ds;
	
	public TokenRepositoryImpl(DataSource ds) {
		this.ds = ds;
	}

	@Override
	public void updateTokenHash(String series, String newToken) {
		String sql = "UPDATE persistent_logins SET token_hash = ? WHERE series = ?";
		
		try (Connection conn = ds.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			
	            pstmt.setString(1, newToken);
	            pstmt.setString(2, series);
	            
	            pstmt.executeUpdate();
	        } catch (SQLException e) {
	            System.err.println("Lỗi khi cập nhật token hash: " + e.getMessage());
	        }
		
	}

	@Override
	public TokenDAO findTokenByHash(String tokenHash) {
		TokenDAO token = null;
		String sql = "SELECT username, series, expires FROM persistent_logins WHERE token_hash = ?";
		try (Connection conn = ds.getConnection();
	             PreparedStatement pstmt = conn.prepareStatement(sql)) {
	            
				pstmt.setString(1, tokenHash);

	            try (ResultSet rs = pstmt.executeQuery()) {
	                if (rs.next()) {
	                	String username = rs.getString("username");
	                	String series = rs.getString("series");
	                	Timestamp expires = rs.getTimestamp("expires");
	                	System.out.println("token get");
	                    token = new TokenDAO(username, series, tokenHash, expires);
	                    return token;
	                }
	            }
	        } catch (SQLException e) {
	            System.err.println("Lỗi khi findTokenByHash: " + e.getMessage());
	        }
	        return token;
	}

	@Override
	public void saveToken(String username, String series, String tokenHash, Timestamp expries) {
		String sql =  "INSERT INTO persistent_logins (username, series, token_hash, expires) " +
	            "VALUES (?, ?, ?, ?)";
		
		try (Connection conn = ds.getConnection();
	             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
			pstmt.setString(1, username);        
            pstmt.setString(2, series);
            pstmt.setString(3, tokenHash);
            pstmt.setTimestamp(4, expries);
            
           pstmt.executeUpdate();
		} catch (SQLException e) {
            System.err.println("Lỗi khi saveToken: " + e.getMessage());
        }
	}

	@Override
	public boolean isTokenOwnedByUser(String username, String seriesToDelete) {
		return false;
	}

	@Override
	public void deleteTokenBySeries(String seriesToDelete) {
	}

}
