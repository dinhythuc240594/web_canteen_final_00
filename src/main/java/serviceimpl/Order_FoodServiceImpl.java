package serviceimpl;

import java.util.List;

import javax.sql.DataSource;

import dto.FoodDTO;
import model.Order_FoodDAO;
import model.Page;
import model.PageRequest;
import repository.FoodRepository;
import repository.Order_FoodRepository;
import repositoryimpl.FoodRepositoryImpl;
import repositoryimpl.Order_FoodRepositoryImpl;
import service.Order_FoodService;

public class Order_FoodServiceImpl implements Order_FoodService{

	private Order_FoodRepository order_FoodRepository;
	
	public Order_FoodServiceImpl(DataSource ds) {
		this.order_FoodRepository = new Order_FoodRepositoryImpl(ds);
	}
	
	@Override
	public Order_FoodDAO create(Order_FoodDAO orderFood) {
		return this.order_FoodRepository.create(orderFood);
	}

	@Override
	public Order_FoodDAO findById(int id) {
		return this.order_FoodRepository.findById(id);
	}

	@Override
	public Page<Order_FoodDAO> findAll(PageRequest pageRequest) {
		List<Order_FoodDAO> data = this.order_FoodRepository.findAll(pageRequest); 
		return new Page<>(data, pageRequest.getPage(), this.order_FoodRepository.count(pageRequest.getKeyword()), pageRequest.getPageSize());
	}

	@Override
	public void deleteById(int id) {
		this.order_FoodRepository.deleteById(id);
	}

	@Override
	public List<Order_FoodDAO> findByOrderId(int orderId) {
		return this.order_FoodRepository.findByOrderId(orderId);
	}

	@Override
	public void deleteByOrderId(int orderId) {
		this.order_FoodRepository.deleteByOrderId(orderId);
	}

	@Override
	public int count(String keyword) {
		return this.order_FoodRepository.count(keyword);
	}

}
