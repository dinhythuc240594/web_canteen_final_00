package service;

import java.util.List;

import dto.FoodDTO;
import model.FoodDAO;
import model.Page;
import model.PageRequest;

public interface FoodService {

	Page<FoodDTO> findAll(PageRequest pageRequest);
	FoodDTO findById(int id);	
	List<FoodDTO> newFoods();
	List<FoodDTO> promotionFoods();
	boolean create(String nameFood, double priceFood, int inventoryFood, int stallId);
	boolean update(int id, String nameFood, double priceFood, int inventoryFood);
	boolean delete(int id);
	int count(String keyword);

}
