package repository;

import java.sql.Date;
import java.util.List;

import dto.FoodDTO;
import model.PageRequest;

public interface FoodRepository extends Repository<FoodDTO>{
	
	List<FoodDTO> findAll(PageRequest pageRequest);
	List<FoodDTO> newFoods();
	List<FoodDTO> promotionFoods();
	List<FoodDTO> findByUpdatedDate(Date targetDate, Integer stallId, String keyword);
	boolean create(String nameFood, double priceFood, int inventoryFood, int stallId, Integer categoryId, String image, String description, Double promotion, Boolean isAvailable);
	boolean update(int id, String nameFood, double priceFood, int inventoryFood, Integer categoryId, String image, String description, Double promotion, Boolean isAvailable);
}
