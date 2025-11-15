package dto;

import java.util.List;

import model.FoodDAO;
import java.util.stream.Collectors;

public class FoodDTO {

	private int id;
	private String nameFood;
	private Double priceFood;
	private int inventoryFood;
	private int category_id;
	private String image;
	private String description;
	private Double promotion;
	private Double priceAfterPromotion;
	private int stallId;
	
	public FoodDTO() {
		
	}
	
	public FoodDTO(FoodDAO entity, int category_id, String image, String description, Double promotion) {
		this.id = entity.getId();
        this.nameFood = entity.getNameFood();
        this.priceFood = entity.getPriceFood();
        this.inventoryFood = entity.getInventoryFood();
		this.category_id = category_id;
		this.image = image;
		this.description = description;
		this.setPromotion(promotion);
	}

	public FoodDTO(FoodDAO entity, Double promotion, int stallId) {
		this.id = entity.getId();
        this.nameFood = entity.getNameFood();
        this.priceFood = entity.getPriceFood();
        this.inventoryFood = entity.getInventoryFood();
		this.category_id = entity.getCategory_id();
		this.image = entity.getImage();
		this.description = entity.getDescription();
		this.promotion = promotion;
		this.priceAfterPromotion = entity.getPriceFood() * (1- (promotion/100));
		this.stallId = stallId;
	}
	
	public static FoodDTO toDto(FoodDAO dao, Double promotion, int stallId) {
        if (dao == null) return null;
        return new FoodDTO(dao, promotion, stallId);
    }
	
	public static List<FoodDTO> toDtoList(List<FoodDAO> daoList, Double promotion, int stallId) {
        return daoList.stream().map(dao -> toDto(dao, promotion, stallId)).collect(Collectors.toList());
    }

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getNameFood() {
		return nameFood;
	}

	public void setNameFood(String nameFood) {
		this.nameFood = nameFood;
	}

	public Double getPriceFood() {
		return priceFood;
	}

	public void setPriceFood(Double priceFood) {
		this.priceFood = priceFood;
	}

	public int getInventoryFood() {
		return inventoryFood;
	}

	public void setInventoryFood(int inventoryFood) {
		this.inventoryFood = inventoryFood;
	}

	public int getCategory_id() {
		return category_id;
	}

	public void setCategory_id(int category_id) {
		this.category_id = category_id;
	}

	public String getImage() {
		return image;
	}

	public void setImage(String image) {
		this.image = image;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Double getPriceAfterPromotion() {
		return priceAfterPromotion;
	}

	public void setPriceAfterPromotion(Double priceAfterPromotion) {
		this.priceAfterPromotion = priceAfterPromotion;
	}

	public Double getPromotion() {
		return promotion;
	}

	public void setPromotion(Double promotion) {
		this.promotion = promotion;
	}

	public int getStallId() {
		return stallId;
	}

	public void setStallId(int stallId) {
		this.stallId = stallId;
	}
	
}
