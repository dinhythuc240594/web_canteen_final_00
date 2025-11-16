package serviceimpl;

import java.util.List;

import javax.sql.DataSource;

import dto.FoodDTO;
import model.FoodDAO;
import model.Page;
import model.PageRequest;
import repository.FoodRepository;
import repositoryimpl.FoodRepositoryImpl;
import service.FoodService;

public class FoodServiceImpl implements FoodService {

	private FoodRepository foodRepository;
	
	public FoodServiceImpl(DataSource ds) {
		this.foodRepository = new FoodRepositoryImpl(ds);
	}
	
	@Override
	public Page<FoodDTO> findAll(PageRequest pageRequest) {
		List<FoodDTO> data = this.foodRepository.findAll(pageRequest); 
		FoodRepositoryImpl repoImpl = (FoodRepositoryImpl) this.foodRepository;
		int totalCount = repoImpl.count(pageRequest.getKeyword(), pageRequest.getStallId(), pageRequest.getCategoryId());
		return new Page<>(data, pageRequest.getPage(), totalCount, pageRequest.getPageSize());
	}

	@Override
	public FoodDTO findById(int id) {
		return this.foodRepository.findById(id);
	}

	@Override
	public boolean create(String nameFood, double priceFood, int inventoryFood, int stallId, Integer categoryId, String image, String description, Double promotion, Boolean isAvailable) {
		return this.foodRepository.create(nameFood, priceFood, inventoryFood, stallId, categoryId, image, description, promotion, isAvailable);
	}

	@Override
	public boolean update(int id, String nameFood, double priceFood, int inventoryFood, Integer categoryId, String image, String description, Double promotion, Boolean isAvailable) {
		return this.foodRepository.update(id, nameFood, priceFood, inventoryFood, categoryId, image, description, promotion, isAvailable);
	}

	@Override
	public boolean delete(int id) {
		return this.foodRepository.delete(id);
	}

	@Override
	public int count(String keyword) {
		return this.foodRepository.count(keyword);
	}

	@Override
	public List<FoodDTO> newFoods() {
		return this.foodRepository.newFoods();
	}

	@Override
	public List<FoodDTO> promotionFoods() {
		return this.foodRepository.promotionFoods();
	}

}
