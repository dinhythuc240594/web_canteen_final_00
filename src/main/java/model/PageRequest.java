package model;

public class PageRequest {

	private int page;
	private int pageSize;
	private String sortField;
	private String orderField;
	private String keyword;
	
	public PageRequest() {
		
	}
	
	public PageRequest(int page, int pageSize, String sortField, String orderField, String keyword) {
		this.page = page;
		this.pageSize = pageSize;
		this.sortField = sortField;
		this.orderField = orderField;
		this.keyword = keyword;
	}
	
	public int getOffset() {
		return ((page - 1) * pageSize);
	}

	public int getPage() {
		return page;
	}

	public void setPage(int page) {
		this.page = page;
	}

	public int getPageSize() {
		return pageSize;
	}

	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}

	public String getSortField() {
		return sortField;
	}

	public void setSortField(String sortField) {
		this.sortField = sortField;
	}

	public String getOrderField() {
		return orderField;
	}

	public void setOrderField(String orderField) {
		this.orderField = orderField;
	}

	public String getKeyword() {
		return keyword;
	}

	public void setKeyword(String keyword) {
		this.keyword = keyword;
	}
	
}
