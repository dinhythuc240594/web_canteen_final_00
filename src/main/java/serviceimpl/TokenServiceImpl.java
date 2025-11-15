package serviceimpl;

import java.sql.Timestamp;

import javax.sql.DataSource;

import model.TokenDAO;
import repository.TokenRepository;
import repositoryimpl.TokenRepositoryImpl;
import service.TokenService;

public class TokenServiceImpl implements TokenService{

	private TokenRepository tokenRepository;
	
	public TokenServiceImpl(DataSource ds) {
		this.tokenRepository = new TokenRepositoryImpl(ds);
	}
	
	@Override
	public void updateTokenHash(String series, String newToken) {
		this.tokenRepository.updateTokenHash(series, newToken);
	}

	@Override
	public TokenDAO findTokenByHash(String tokenHash) {
		return this.tokenRepository.findTokenByHash(tokenHash);
	}

	@Override
	public void saveToken(String username, String series, String tokenHash, Timestamp expries) {
		this.tokenRepository.saveToken(username, series, tokenHash, expries);
	}

	@Override
	public boolean isTokenOwnedByUser(String username, String seriesToDelete) {
		return this.tokenRepository.isTokenOwnedByUser(username, seriesToDelete);
	}

	@Override
	public void deleteTokenBySeries(String seriesToDelete) {
		this.tokenRepository.deleteTokenBySeries(seriesToDelete);
	}

}
