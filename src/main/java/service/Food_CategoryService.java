package service;

import java.util.List;

import model.Food_CategoryDAO;
import model.Page;
import model.PageRequest;

public interface Food_CategoryService {

	List<Food_CategoryDAO> findAll();
	Food_CategoryDAO findById(int id);
	boolean create(String nameCategory, String descriptionCategory);
	boolean update(int id, String nameCategory, String descriptionCategory);
	boolean delete(int id);
	int count(String keyword);
	
}
