package model;

import java.sql.Date;

public class StatisticDAO {

	private int id;
    private Date statDate;    
    private int stallId;      
    private int foodId;       
    private int ordersCount;  
    private Double revenue;   
    private int quantitySold;
    private int totalOrders;
    private double totalRevenue;

    public StatisticDAO() {
    	
    }

    public StatisticDAO(Date statDate, int stallId, int foodId, int ordersCount, Double revenue, int quantitySold) {
        this.statDate = statDate;
        this.stallId = stallId;
        this.foodId = foodId;
        this.ordersCount = ordersCount;
        this.revenue = revenue;
        this.quantitySold = quantitySold;
    }

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public Date getStatDate() {
		return statDate;
	}

	public void setStatDate(Date statDate) {
		this.statDate = statDate;
	}

	public int getStallId() {
		return stallId;
	}

	public void setStallId(int stallId) {
		this.stallId = stallId;
	}

	public int getFoodId() {
		return foodId;
	}

	public void setFoodId(int foodId) {
		this.foodId = foodId;
	}

	public int getOrdersCount() {
		return ordersCount;
	}

	public void setOrdersCount(int ordersCount) {
		this.ordersCount = ordersCount;
	}

	public Double getRevenue() {
		return revenue;
	}

	public void setRevenue(Double revenue) {
		this.revenue = revenue;
	}

	public int getQuantitySold() {
		return quantitySold;
	}

	public void setQuantitySold(int quantitySold) {
		this.quantitySold = quantitySold;
	}

    public int getTotalOrders() { return totalOrders; }
    public void setTotalOrders(int totalOrders) { this.totalOrders = totalOrders; }

    public double getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(double totalRevenue) { this.totalRevenue = totalRevenue; }

}
