package service;

import java.sql.Date;
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
	List<FoodDTO> findByUpdatedDate(Date targetDate, Integer stallId, String keyword);
	boolean create(String nameFood, double priceFood, int inventoryFood, int stallId, Integer categoryId, String image, String description, Double promotion, Boolean isAvailable);
	boolean update(int id, String nameFood, double priceFood, int inventoryFood, Integer categoryId, String image, String description, Double promotion, Boolean isAvailable);
	boolean delete(int id);
	int count(String keyword);

}
