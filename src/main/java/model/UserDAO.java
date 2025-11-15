package model;

import java.util.Date;

public class UserDAO {
	private int id;
	private String username;
	private String full_name;
	private String email;
	private String phone;
	private String role;
	private String avatar;
	private boolean status;
	private Date createDate;
	
	public UserDAO() {
		this.id = 0;
		this.username = "";
		this.full_name = "";
		this.email = "";
		this.phone = "";
		this.avatar = "";
		this.role = "";
		this.status = false;
	}
	
	public UserDAO(int id, String username, String full_name, String email, String phone, String avatar, String role, boolean status) {
		this.id = id;
		this.username = username;
		this.full_name = full_name;
		this.email = email;
		this.phone = phone;
		this.avatar = avatar;
		this.role = role;
		this.status = status;
	}
	
	public int getId() {
		return id;
	}
	
	public void setId(int id) {
		this.id = id;
	}
	
	public String getUsername() {
		return username;
	}
	
	public void setUsername(String username) {
		this.username = username;
	}
	
	public String getFull_name() {
		return full_name;
	}
	
	public void setFull_name(String full_name) {
		this.full_name = full_name;
	}
	
	public String getEmail() {
		return email;
	}
	
	public void setEmail(String email) {
		this.email = email;
	}
	
	public String getPhone() {
		return phone;
	}
	
	public void setPhone(String phone) {
		this.phone = phone;
	}
	
	public String getRole() {
		return role;
	}
	
	public void setRole(String role) {
		this.role = role;
	}
	
	public String getAvatar() {
		return avatar;
	}
	
	public void setAvatar(String avatar) {
		this.avatar = avatar;
	}
	
	public boolean isStatus() {
		return status;
	}
	
	public void setStatus(boolean status) {
		this.status = status;
	}
	
	public Date getCreateDate() {
		return createDate;
	}
	
	public void setCreateDate(Date createDate) {
		this.createDate = createDate;
	}
}
