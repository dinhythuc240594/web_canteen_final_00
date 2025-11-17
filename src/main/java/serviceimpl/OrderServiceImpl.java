package serviceimpl;

import java.util.List;

import javax.sql.DataSource;

import model.OrderDAO;
import model.Order_FoodDAO;
import model.Page;
import model.PageRequest;
import repository.OrderRepository;
import repositoryimpl.OrderRepositoryImpl;
import service.OrderService;

public class OrderServiceImpl implements OrderService{

	private OrderRepository orderRepository;
	
	public OrderServiceImpl(DataSource ds) {
		this.orderRepository = new OrderRepositoryImpl(ds);
	}
	
	@Override
	public OrderDAO save(OrderDAO order) {
		return this.orderRepository.save(order);
	}

	@Override
	public OrderDAO findById(int id) {
		return this.orderRepository.findById(id);
	}

	@Override
	public Page<OrderDAO> findAll(PageRequest pageRequest) {
		List<OrderDAO> data = this.orderRepository.findAll(pageRequest); 
		return new Page<>(data, pageRequest.getPage(), this.orderRepository.count(pageRequest.getKeyword()), pageRequest.getPageSize());
	}

	@Override
	public void deleteById(int id) {
		this.orderRepository.deleteById(id);
	}

	@Override
	public List<OrderDAO> findByUserId(int userId) {
		return this.orderRepository.findByUserId(userId);
	}

	@Override
	public List<OrderDAO> findByStallId(int stallId) {
		return this.orderRepository.findByStallId(stallId);
	}

	@Override
	public List<OrderDAO> findByStallIdAndStatus(int stallId, String status) {
		return this.orderRepository.findByStallIdAndStatus(stallId, status);
	}

	@Override
	public List<OrderDAO> findByStatus(String status) {
		return this.orderRepository.findByStatus(status);
	}

	@Override
	public double getTotalRevenueFromCompletedOrders() {
		return this.orderRepository.getTotalRevenueFromCompletedOrders();
	}

	@Override
	public boolean updateStatus(int id, String newStatus) {
		return this.orderRepository.updateStatus(id, newStatus);
	}

	@Override
	public int count(String keyword) {
		// TODO Auto-generated method stub
		return 0;
	}

}
