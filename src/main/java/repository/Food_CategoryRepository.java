package repository;

import java.util.List;

import model.Food_CategoryDAO;
import model.PageRequest;

public interface Food_CategoryRepository extends Repository<Food_CategoryDAO>{

	List<Food_CategoryDAO> findAll();
	Food_CategoryDAO findById(int id);
	boolean delete(int id);
	int count(String keyword);
	
}
