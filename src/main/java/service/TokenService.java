package service;

import java.sql.Timestamp;

import model.TokenDAO;

public interface TokenService {
	TokenDAO findTokenByHash(String tokenHash);
	void saveToken(String username, String series, String tokenHash, Timestamp expries);
	void updateTokenHash(String series, String newToken);
	boolean isTokenOwnedByUser(String username, String seriesToDelete);
	void deleteTokenBySeries(String seriesToDelete);
}
