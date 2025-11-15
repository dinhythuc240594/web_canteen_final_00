package serviceimpl;

import java.util.List;

import javax.sql.DataSource;

import model.StallDAO;
import repository.OrderRepository;
import repository.StallRepository;
import repositoryimpl.OrderRepositoryImpl;
import repositoryimpl.StallRepositoryImpl;
import service.StallService;

public class StallServiceImpl implements StallService {

	private StallRepository stallRepository;
	
	public StallServiceImpl(DataSource ds) {
		this.stallRepository = new StallRepositoryImpl(ds);
	}
	
	@Override
	public StallDAO save(StallDAO stall) {
		return this.stallRepository.save(stall);
	}

	@Override
	public StallDAO findById(int id) {
		return this.stallRepository.findById(id);
	}

	@Override
	public List<StallDAO> findAll() {
		return this.stallRepository.findAll();
	}

	@Override
	public void deleteById(int id) {
		this.stallRepository.deleteById(id);
	}

	@Override
	public List<StallDAO> findByManagerUserId(int managerUserId) {
		return this.stallRepository.findByManagerUserId(managerUserId);
	}

	@Override
	public List<StallDAO> findOpenStalls() {
		return this.stallRepository.findOpenStalls();
	}

	@Override
	public void updateOpenStatus(int id, Boolean isOpen) {
		this.stallRepository.updateOpenStatus(id, isOpen);
	}

}
