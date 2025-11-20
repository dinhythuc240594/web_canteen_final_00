package serviceimpl;

import repository.AdminRepository;
import repositoryimpl.AdminRepositoryImpl;
import service.AdminService;

import javax.sql.DataSource;
import java.util.List;
import java.util.Map;

public class AdminServiceImpl implements AdminService {

	private AdminRepository adminRepository;
	
	public AdminServiceImpl(DataSource ds) {
		this.adminRepository = new AdminRepositoryImpl(ds);
	}

    @Override
    public List<Map<String, Object>> getBestSellingFoods() {
        return this.adminRepository.getBestSellingFoods();
    }
}
