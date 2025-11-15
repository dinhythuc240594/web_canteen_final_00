package repository;

import java.util.List;

import model.PageRequest;

public interface Repository<T> {

	List<T> findAll(PageRequest pageRequest);
	T findById(int id);
	boolean delete(int id);
	int count(String keyword);
	
}
