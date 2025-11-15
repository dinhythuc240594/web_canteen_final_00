package repository;

import java.util.List;

import model.OrderDAO;
import model.PageRequest;

public interface OrderRepository {

	OrderDAO save(OrderDAO order);
    OrderDAO findById(int id);
    List<OrderDAO> findAll(PageRequest pageReq);
    void deleteById(int id);
    int count(String keyword);
    List<OrderDAO> findByUserId(int userId);
    List<OrderDAO> findByStallId(int stallId);
    List<OrderDAO> findByStallIdAndStatus(int stallId, String status);
    boolean updateStatus(int id, String newStatus);
	
}
