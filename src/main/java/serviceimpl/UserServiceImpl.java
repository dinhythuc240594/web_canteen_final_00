package serviceimpl;

import java.util.List;

import javax.sql.DataSource;

import model.UserDAO;
import repository.UserRepository;
import repositoryimpl.UserRepositoryImpl;
import service.UserService;
import utils.MD5Generator;

public class UserServiceImpl implements UserService{
	private UserRepository userRepository;
	
	public UserServiceImpl(DataSource ds) {
		this.userRepository = new UserRepositoryImpl(ds);
	}

	@Override
	public Boolean isAuthenticated(String username, String password) {
		return this.userRepository.isAuthenticated(username, password);
	}

	@Override
	public UserDAO getUser(String username) {
		return this.userRepository.getUser(username);
	}

	@Override
	public UserDAO getUserById(int id) {
		return this.userRepository.getUserById(id);
	}

	@Override
	public List<UserDAO> findAll() {
		return this.userRepository.findAll();
	}

	@Override
	public List<UserDAO> findByRole(String role) {
		return this.userRepository.findByRole(role);
	}

	@Override
	public UserDAO save(UserDAO user) {
		return this.userRepository.save(user);
	}

	@Override
	public boolean update(UserDAO user) {
		return this.userRepository.update(user);
	}
	
	@Override
	public boolean updateProfile(UserDAO user) {
		return this.userRepository.updateProfile(user);
	}

	@Override
	public boolean updateStatus(int id, boolean status) {
		return this.userRepository.updateStatus(id, status);
	}
	
	@Override
	public boolean updatePassword(int id, String rawPassword) {
		String hashedPassword = MD5Generator.generateMD5(rawPassword);
		return this.userRepository.updatePassword(id, hashedPassword);
	}

	@Override
	public boolean deleteById(int id) {
		return this.userRepository.deleteById(id);
	}

	@Override
	public int count() {
		return this.userRepository.count();
	}

	@Override
	public boolean existsByUsername(String username) {
		return this.userRepository.existsByUsername(username);
	}
}
