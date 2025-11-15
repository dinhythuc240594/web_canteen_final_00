package repository;

import java.sql.Timestamp;

import model.TokenDAO;

public interface TokenRepository {
	void updateTokenHash(String series, String newToken);
	TokenDAO findTokenByHash(String tokenHash);
	void saveToken(String username, String series, String tokenHash, Timestamp expries);
	boolean isTokenOwnedByUser(String username, String seriesToDelete);
	void deleteTokenBySeries(String seriesToDelete);
}
