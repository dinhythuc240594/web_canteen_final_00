package service;

import java.util.List;
import model.UserDAO;

public interface UserService {
	Boolean isAuthenticated(String username, String password);
	UserDAO getUser(String username);
	UserDAO getUserById(int id);
	List<UserDAO> findAll();
	List<UserDAO> findByRole(String role);
	UserDAO save(UserDAO user);
	boolean update(UserDAO user);
	boolean updateProfile(UserDAO user);
	boolean updateStatus(int id, boolean status);
	boolean updatePassword(int id, String rawPassword);
	boolean deleteById(int id);
	int count();
	boolean existsByUsername(String username);
}
