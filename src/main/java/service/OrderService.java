package service;

import java.util.List;

import model.OrderDAO;
import model.Page;
import model.PageRequest;

public interface OrderService {

	OrderDAO save(OrderDAO order);
    OrderDAO findById(int id);
    Page<OrderDAO> findAll(PageRequest pageRequest);
    void deleteById(int id);
    List<OrderDAO> findByUserId(int userId);
    List<OrderDAO> findByStallId(int stallId);
    List<OrderDAO> findByStallIdAndStatus(int stallId, String status);
    boolean updateStatus(int id, String newStatus);
    int count(String keyword);
    
}
