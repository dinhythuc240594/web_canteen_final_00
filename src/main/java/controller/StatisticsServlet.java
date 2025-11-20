package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.StatisticDAO;
import model.StallDAO;
import serviceimpl.StatisticServiceImpl;
import serviceimpl.StallServiceImpl;
import utils.DataSourceUtil;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import com.google.gson.Gson;

@WebServlet("/statistics")
public class StatisticsServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private StatisticServiceImpl statisticService;
	private StallServiceImpl stallService;
	
	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.statisticService = new StatisticServiceImpl(ds);
		this.stallService = new StallServiceImpl(ds);
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// Security check: Only admin and stall can access
		HttpSession session = request.getSession(false);
		String userRole = (String) (session != null ? session.getAttribute("type_user") : null);
		String username = (String) (session != null ? session.getAttribute("username") : null);
		
		if (username == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		
		if (!"admin".equals(userRole) && !"stall".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		String action = request.getParameter("action");
		if (action == null) {
			action = "overview";
		}
		
		switch (action) {
			case "overview":
				handleOverview(request, response);
				break;
			case "byStall":
				handleByStall(request, response);
				break;
			case "bestSelling":
				handleBestSelling(request, response);
				break;
			case "dailyOrders":
				handleDailyOrders(request, response);
				break;
			case "revenue":
				handleRevenue(request, response);
				break;
			default:
				handleOverview(request, response);
				break;
		}
	}
	
	private void handleOverview(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		String userRole = (String) session.getAttribute("type_user");
		
		// Get date range from parameters or default to last 7 days
		String startDateStr = request.getParameter("startDate");
		String endDateStr = request.getParameter("endDate");
		
		LocalDate startDate = startDateStr != null ? LocalDate.parse(startDateStr) : LocalDate.now().minusDays(7);
		LocalDate endDate = endDateStr != null ? LocalDate.parse(endDateStr) : LocalDate.now();
		
		Date _startDate = Date.valueOf(startDate);
		Date _endDate = Date.valueOf(endDate);
		
		List<StatisticDAO> statistics = statisticService.findByDateRange(_startDate, _endDate);
		
		// Calculate totals
		double totalRevenue = 0.0;
		int totalOrders = 0;
		int totalQuantitySold = 0;
		
		for (StatisticDAO stat : statistics) {
			totalRevenue += stat.getRevenue();
			totalOrders += stat.getOrdersCount();
			totalQuantitySold += stat.getQuantitySold();
		}
		
		request.setAttribute("statistics", statistics);
		request.setAttribute("totalRevenue", totalRevenue);
		request.setAttribute("totalOrders", totalOrders);
		request.setAttribute("totalQuantitySold", totalQuantitySold);
		request.setAttribute("startDate", startDate.toString());
		request.setAttribute("endDate", endDate.toString());
		
		request.getRequestDispatcher("/statistics.jsp").forward(request, response);
	}
	
	private void handleByStall(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		int stallId = Integer.parseInt(request.getParameter("stallId"));
		
		String startDateStr = request.getParameter("startDate");
		String endDateStr = request.getParameter("endDate");
		
		LocalDate startDate = startDateStr != null ? LocalDate.parse(startDateStr) : LocalDate.now().minusDays(30);
		LocalDate endDate = endDateStr != null ? LocalDate.parse(endDateStr) : LocalDate.now();

		Date _startDate = Date.valueOf(startDate);
		Date _endDate = Date.valueOf(endDate);

		List<StatisticDAO> statistics = statisticService.findByStallIdAndDateRange(stallId, _startDate, _endDate);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(statistics);
		response.getWriter().write(json);
	}
	
	private void handleBestSelling(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String startDateStr = request.getParameter("startDate");
		String endDateStr = request.getParameter("endDate");
		
		LocalDate startDate = startDateStr != null ? LocalDate.parse(startDateStr) : LocalDate.now().minusDays(30);
		LocalDate endDate = endDateStr != null ? LocalDate.parse(endDateStr) : LocalDate.now();
		
		Date _startDate = Date.valueOf(startDate);
		Date _endDate = Date.valueOf(endDate);
		
		List<StatisticDAO> statistics = statisticService.findByDateRange(_startDate, _endDate);
		
		// Group by food and sum quantities
		Map<Integer, Map<String, Object>> foodStats = new HashMap<>();
		
		for (StatisticDAO stat : statistics) {
			int foodId = stat.getFoodId();
			if (!foodStats.containsKey(foodId)) {
				Map<String, Object> foodData = new HashMap<>();
				foodData.put("foodId", foodId);
				foodData.put("quantitySold", 0);
				foodData.put("revenue", 0.0);
				foodStats.put(foodId, foodData);
			}
			
			Map<String, Object> foodData = foodStats.get(foodId);
			int currentQty = (int) foodData.get("quantitySold");
			double currentRevenue = (Double) foodData.get("revenue");
			
			foodData.put("quantitySold", currentQty + stat.getQuantitySold());
			foodData.put("revenue", currentRevenue + stat.getRevenue());
		}
		
		// Convert to list and sort by quantity sold
		List<Map<String, Object>> bestSelling = new ArrayList<>(foodStats.values());
		bestSelling.sort((a, b) -> Integer.compare((int) b.get("quantitySold"), (int) a.get("quantitySold")));
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(bestSelling);
		response.getWriter().write(json);
	}
	
	private void handleDailyOrders(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String startDateStr = request.getParameter("startDate");
		String endDateStr = request.getParameter("endDate");
		
		LocalDate startDate = startDateStr != null ? LocalDate.parse(startDateStr) : LocalDate.now().minusDays(30);
		LocalDate endDate = endDateStr != null ? LocalDate.parse(endDateStr) : LocalDate.now();
		
		Date _startDate = Date.valueOf(startDate);
		Date _endDate = Date.valueOf(endDate);
		
		List<StatisticDAO> statistics = statisticService.findByDateRange(_startDate, _endDate);
		
		// Group by date
		Map<String, Map<String, Object>> dailyStats = new HashMap<>();
		
		for (StatisticDAO stat : statistics) {
			String date = stat.getStatDate().toString();
			if (!dailyStats.containsKey(date)) {
				Map<String, Object> dayData = new HashMap<>();
				dayData.put("date", date);
				dayData.put("ordersCount", 0);
				dayData.put("revenue", 0.0);
				dailyStats.put(date, dayData);
			}
			
			Map<String, Object> dayData = dailyStats.get(date);
			int currentOrders = (int) dayData.get("ordersCount");
			double currentRevenue = (Double) dayData.get("revenue");
			
			dayData.put("ordersCount", currentOrders + stat.getOrdersCount());
			dayData.put("revenue", currentRevenue + stat.getRevenue());
		}
		
		List<Map<String, Object>> dailyList = new ArrayList<>(dailyStats.values());
		dailyList.sort((a, b) -> ((String) a.get("date")).compareTo((String) b.get("date")));
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(dailyList);
		response.getWriter().write(json);
	}
	
	private void handleRevenue(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String startDateStr = request.getParameter("startDate");
		String endDateStr = request.getParameter("endDate");
		
		LocalDate startDate = startDateStr != null ? LocalDate.parse(startDateStr) : LocalDate.now().minusDays(30);
		LocalDate endDate = endDateStr != null ? LocalDate.parse(endDateStr) : LocalDate.now();
		
		Date _startDate = Date.valueOf(startDate);
		Date _endDate = Date.valueOf(endDate);
		
		List<StatisticDAO> statistics = statisticService.findByDateRange(_startDate, _endDate);
		List<StallDAO> stalls = stallService.findAll();
		
		// Group by stall
		Map<Integer, Map<String, Object>> stallRevenue = new HashMap<>();
		
		// Initialize all stalls
		for (StallDAO stall : stalls) {
			Map<String, Object> stallData = new HashMap<>();
			stallData.put("stallId", stall.getId());
			stallData.put("stallName", stall.getName());
			stallData.put("revenue", 0.0);
			stallData.put("ordersCount", 0);
			stallRevenue.put(stall.getId(), stallData);
		}
		
		// Aggregate statistics
		for (StatisticDAO stat : statistics) {
			int stallId = stat.getStallId();
			if (stallRevenue.containsKey(stallId)) {
				Map<String, Object> stallData = stallRevenue.get(stallId);
				double currentRevenue = (Double) stallData.get("revenue");
				int currentOrders = (int) stallData.get("ordersCount");
				
				stallData.put("revenue", currentRevenue + stat.getRevenue());
				stallData.put("ordersCount", currentOrders + stat.getOrdersCount());
			}
		}
		
		List<Map<String, Object>> revenueList = new ArrayList<>(stallRevenue.values());
		revenueList.sort((a, b) -> Double.compare((Double) b.get("revenue"), (Double) a.get("revenue")));
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Gson gson = new Gson();
		String json = gson.toJson(revenueList);
		response.getWriter().write(json);
	}
}

