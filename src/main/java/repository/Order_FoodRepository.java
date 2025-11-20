package repository;

import java.util.List;

import model.Order_FoodDAO;
import model.Page;
import model.PageRequest;

public interface Order_FoodRepository {

	Order_FoodDAO create(Order_FoodDAO orderFood);
    Order_FoodDAO findById(int id);
    List<Order_FoodDAO> findAll(PageRequest pageRequest);
    void deleteById(int id);
    List<Order_FoodDAO> findByOrderId(int orderId);
    void deleteByOrderId(int orderId);
    void deleteByFoodId(int foodId);
    int count(String keyword);
	
}
