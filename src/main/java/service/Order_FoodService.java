package service;

import java.util.List;

import model.Order_FoodDAO;
import model.Page;
import model.PageRequest;

public interface Order_FoodService {
	Order_FoodDAO create(Order_FoodDAO orderFood);
    Order_FoodDAO findById(int id);
    Page<Order_FoodDAO> findAll(PageRequest pageRequest);
    void deleteById(int id);
    List<Order_FoodDAO> findByOrderId(int orderId);
    void deleteByOrderId(int orderId);
    int count(String keyword);
}
