package repository;

import java.util.List;

import dto.FoodDTO;
import model.PageRequest;

public interface FoodRepository extends Repository<FoodDTO>{
	
	List<FoodDTO> findAll(PageRequest pageRequest);
	List<FoodDTO> newFoods();
	List<FoodDTO> promotionFoods();
	boolean create(String nameFood, double priceFood, int inventoryFood);
	boolean update(int id, String nameFood, double priceFood, int inventoryFood);
}
