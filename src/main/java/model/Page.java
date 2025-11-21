package model;

import java.util.List;

public class Page<T> {

	private List<T> data;
	private int currentPage;
	private int totalPage;
	private int totalItem;
	
	public Page() {
		
	}

	public Page(List<T> data, int currentPage, int totalItem, int pageSize) {
		this.data = data;
		this.currentPage = currentPage;
		this.totalItem = totalItem;
		if (pageSize > 0) {
			this.totalPage = (int) Math.ceil((double) totalItem / pageSize);
		} else {
			this.totalPage = 0;
		}
	}

	public List<T> getData() {
		return data;
	}

	public void setData(List<T> data) {
		this.data = data;
	}

	public int getCurrentPage() {
		return currentPage;
	}

	public void setCurrentPage(int currentPage) {
		this.currentPage = currentPage;
	}

	public int getTotalPage() {
		return totalPage;
	}

	public void setTotalPage(int totalPage) {
		this.totalPage = totalPage;
	}

	public int getTotalItem() {
		return totalItem;
	}

	public void setTotalItem(int totalItem) {
		this.totalItem = totalItem;
	}	
}
