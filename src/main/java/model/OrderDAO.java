package model;

import java.sql.Date;

public class OrderDAO {

	private int id;
    private int userId;
    private int stallId;
    private Double totalPrice;
    private String status;
    private Date createdAt;
    private String deliveryLocation;
    private String paymentMethod;
    
    public OrderDAO() {
    	
    }
	public OrderDAO(int id, int userId, int stallId, Double totalPrice, String status, Date createdAt,
			String deliveryLocation, String paymentMethod) {
		super();
		this.id = id;
		this.userId = userId;
		this.stallId = stallId;
		this.totalPrice = totalPrice;
		this.status = status;
		this.createdAt = createdAt;
		this.deliveryLocation = deliveryLocation;
		this.paymentMethod = paymentMethod;
	}
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public int getUserId() {
		return userId;
	}
	public void setUserId(int userId) {
		this.userId = userId;
	}
	public int getStallId() {
		return stallId;
	}
	public void setStallId(int stallId) {
		this.stallId = stallId;
	}
	public Double getTotalPrice() {
		return totalPrice;
	}
	public void setTotalPrice(Double totalPrice) {
		this.totalPrice = totalPrice;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public Date getCreatedAt() {
		return createdAt;
	}
	public void setCreatedAt(Date createdAt) {
		this.createdAt = createdAt;
	}
	public String getDeliveryLocation() {
		return deliveryLocation;
	}
	public void setDeliveryLocation(String deliveryLocation) {
		this.deliveryLocation = deliveryLocation;
	}
	public String getPaymentMethod() {
		return paymentMethod;
	}
	public void setPaymentMethod(String paymentMethod) {
		this.paymentMethod = paymentMethod;
	}
	
}
