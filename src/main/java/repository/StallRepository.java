package repository;

import java.util.List;

import model.StallDAO;

public interface StallRepository {

	StallDAO save(StallDAO stall);
    StallDAO findById(int id);
    List<StallDAO> findAll();
    void deleteById(int id);

    List<StallDAO> findByManagerUserId(int managerUserId);
    List<StallDAO> findOpenStalls();
    void updateOpenStatus(int id, Boolean isOpen);
	
}
