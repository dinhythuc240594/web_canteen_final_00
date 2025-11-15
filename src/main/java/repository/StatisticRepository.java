package repository;

import java.sql.Date;
import java.util.List;

import model.StatisticDAO;

public interface StatisticRepository {

	StatisticDAO save(StatisticDAO statistics);
    StatisticDAO findById(int id);
    List<StatisticDAO> findAll();
    void deleteById(int id);

    List<StatisticDAO> findByStallIdAndDateRange(int stallId, Date startDate, Date endDate);
    
    StatisticDAO findByStallIdAndFoodIdAndDate(int stallId, int foodId, Date statDate);
	
}
