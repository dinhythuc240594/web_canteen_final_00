package serviceimpl;

import java.sql.Date;
import java.util.List;

import javax.sql.DataSource;

import model.StatisticDAO;
import repository.StatisticRepository;
import repositoryimpl.StatisticRepositoryImpl;
import service.StatisticService;

public class StatisticServiceImpl implements StatisticService{

	private StatisticRepository statisticRepository;
	
	public StatisticServiceImpl(DataSource ds) {
		this.statisticRepository = new StatisticRepositoryImpl(ds);
	}
	
	@Override
	public StatisticDAO save(StatisticDAO statistics) {
		return this.statisticRepository.save(statistics);
	}

	@Override
	public StatisticDAO findById(int id) {
		return this.statisticRepository.findById(id);
	}

	@Override
	public List<StatisticDAO> findAll() {
		return this.statisticRepository.findAll();
	}

	@Override
	public void deleteById(int id) {
		this.statisticRepository.deleteById(id);
	}

	@Override
	public List<StatisticDAO> findByStallIdAndDateRange(int stallId, Date startDate, Date endDate) {
		return this.statisticRepository.findByStallIdAndDateRange(stallId, startDate, endDate);
	}

	@Override
	public StatisticDAO findByStallIdAndFoodIdAndDate(int stallId, int foodId, Date statDate) {
		return this.statisticRepository.findByStallIdAndFoodIdAndDate(stallId, foodId, statDate);
	}

	@Override
	public List<StatisticDAO> findByDateRange(Date sqlStartDate, Date sqlEndDate) {
		return this.statisticRepository.findByDateRange(sqlStartDate, sqlEndDate);
	}

	
}
