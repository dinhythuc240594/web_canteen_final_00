package model;

import java.sql.Timestamp;

public class TokenDAO {
	private String username;
	private String series;
	private String token_has;
	private Timestamp expires;
	
	public TokenDAO() {
		super();
		this.username = "";
		this.series = "";
		this.token_has = "";
		this.expires = new Timestamp(System.currentTimeMillis());;
	}
	
	public TokenDAO(String username, String series, String token_has, Timestamp expires) {
		super();
		this.username = username;
		this.series = series;
		this.token_has = token_has;
		this.expires = expires;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public String getSeries() {
		return series;
	}
	public void setSeries(String series) {
		this.series = series;
	}
	public String getToken_has() {
		return token_has;
	}
	public void setToken_has(String token_has) {
		this.token_has = token_has;
	}
	public Timestamp getExpires() {
		return expires;
	}
	public void setExpires(Timestamp expires) {
		this.expires = expires;
	}
	
}
