package serviceimpl;

import java.util.List;

import javax.sql.DataSource;

import dto.FoodDTO;
import model.Food_CategoryDAO;
import model.Page;
import model.PageRequest;
import repository.Food_CategoryRepository;
import repositoryimpl.Food_CategoryRepositoryImpl;
import service.Food_CategoryService;

public class Food_CategoryServiceImpl implements Food_CategoryService {

	private Food_CategoryRepository foodCategoryRepository;
	
	public Food_CategoryServiceImpl(DataSource ds) {
		this.foodCategoryRepository = new Food_CategoryRepositoryImpl(ds);
	}
	
	@Override
	public List<Food_CategoryDAO> findAll() {
		return this.foodCategoryRepository.findAll();
	}

	@Override
	public Food_CategoryDAO findById(int id) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public boolean create(String nameCategory, String descriptionCategory) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean update(int id, String nameCategory, String descriptionCategory) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean delete(int id) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public int count(String keyword) {
		// TODO Auto-generated method stub
		return 0;
	}

}
