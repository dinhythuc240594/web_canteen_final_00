package service;

import java.util.List;

import model.StallDAO;

public interface StallService {

	StallDAO save(StallDAO stall);
    StallDAO findById(int id);
    List<StallDAO> findAll();
    void deleteById(int id);

    List<StallDAO> findByManagerUserId(int managerUserId);
    List<StallDAO> findOpenStalls();
    void updateOpenStatus(int id, Boolean isOpen);
	
}
