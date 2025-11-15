package model;

import java.sql.Date;

public class Order_FoodDAO {

	private int id;              
    private int orderId;         
    private int foodId;       
    private int quantity;     
    private Double priceAtOrder;
    private Date date;
    private String name;
    private String image;

    public Order_FoodDAO() {
    	
    }

    public Order_FoodDAO(int orderId, int foodId, int quantity, Double priceAtOrder) {
        this.orderId = orderId;
        this.foodId = foodId;
        this.quantity = quantity;
        this.priceAtOrder = priceAtOrder;
    }
    
    public Order_FoodDAO(int foodId, int quantity, Double priceAtOrder) {
        this.foodId = foodId;
        this.quantity = quantity;
        this.priceAtOrder = priceAtOrder;
    }

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getOrderId() {
		return orderId;
	}

	public void setOrderId(int orderId) {
		this.orderId = orderId;
	}

	public int getFoodId() {
		return foodId;
	}

	public void setFoodId(int foodId) {
		this.foodId = foodId;
	}

	public int getQuantity() {
		return quantity;
	}

	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}

	public Double getPriceAtOrder() {
		return priceAtOrder;
	}

	public void setPriceAtOrder(Double priceAtOrder) {
		this.priceAtOrder = priceAtOrder;
	}

	public Date getDate() {
		return date;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getImage() {
		return image;
	}

	public void setImage(String image) {
		this.image = image;
	}
	
}
