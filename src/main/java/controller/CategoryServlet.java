package controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Food_CategoryDAO;
import model.Page;
import model.PageRequest;
import serviceimpl.FoodServiceImpl;
import serviceimpl.Food_CategoryServiceImpl;
import utils.DataSourceUtil;
import utils.RequestUtil;

import java.io.IOException;
import java.util.List;

import javax.sql.DataSource;

import dto.FoodDTO;

@WebServlet("/category")
public class CategoryServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private FoodServiceImpl foodServiceImpl;
	private Food_CategoryServiceImpl categoryServiceImpl;
	private int PAGE_SIZE = 12;
	
	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.foodServiceImpl = new FoodServiceImpl(ds);
		this.categoryServiceImpl = new Food_CategoryServiceImpl(ds);
	}
	
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		String keyword = RequestUtil.getString(request, "keyword", "");
		String sortField = RequestUtil.getString(request, "sortField", "name");
		String orderField = RequestUtil.getString(request, "orderField", "ASC");
		int page = RequestUtil.getInt(request, "page", 1);
		int categoryId = RequestUtil.getInt(request, "categoryId", 0);
		
		// Load all categories
		List<Food_CategoryDAO> categories = this.categoryServiceImpl.findAll();
		
		// Create page request with category filter
		PageRequest pageReq = new PageRequest(page, PAGE_SIZE, sortField, orderField, keyword, null, categoryId > 0 ? categoryId : null);
		Page<FoodDTO> pageFood = this.foodServiceImpl.findAll(pageReq);
		
		request.setAttribute("pageFood", pageFood);
		request.setAttribute("pageReq", pageReq);
		request.setAttribute("categories", categories);
		request.setAttribute("selectedCategoryId", categoryId);
		
		RequestDispatcher rd = request.getRequestDispatcher("category.jsp");
		rd.forward(request, response);
	}
}

