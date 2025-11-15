package model;

public class StallDAO {

	private int id;
    private String name;
    private String description;
    private int managerUserId;
    private Boolean isOpen;

    public StallDAO() {
    	
    }

    public StallDAO(String name, String description, int managerUserId, Boolean isOpen) {
        this.name = name;
        this.description = description;
        this.managerUserId = managerUserId;
        this.isOpen = isOpen;
    }

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public int getManagerUserId() {
		return managerUserId;
	}

	public void setManagerUserId(int managerUserId) {
		this.managerUserId = managerUserId;
	}

	public Boolean getIsOpen() {
		return isOpen;
	}

	public void setIsOpen(Boolean isOpen) {
		this.isOpen = isOpen;
	}
	
}
