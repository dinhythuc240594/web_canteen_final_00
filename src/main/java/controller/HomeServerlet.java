package controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.FoodDAO;
import model.Page;
import model.PageRequest;
import serviceimpl.FoodServiceImpl;
import utils.DataSourceUtil;
import utils.RequestUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import dto.FoodDTO;

/**
 * Servlet implementation class HomeServerlet
 */
@WebServlet("/home")
public class HomeServerlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public HomeServerlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	private FoodServiceImpl foodServiceImpl;
	private int PAGE_SIZE = 25;
	
	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.foodServiceImpl = new FoodServiceImpl(ds);
	}
    
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		String keyword = RequestUtil.getString(request, "keyword", "");
		String sortField = RequestUtil.getString(request, "sortField", "name");
		String orderField = RequestUtil.getString(request, "orderField", "ASC");
		int page = RequestUtil.getInt(request, "page", 1);
		
		PageRequest pageReq = new PageRequest(page, PAGE_SIZE, sortField, orderField, keyword);
		Page<FoodDTO> pageFood = this.foodServiceImpl.findAll(pageReq);
		
		List<FoodDTO> newFoods = this.foodServiceImpl.newFoods();
		List<FoodDTO> promotionFoods = this.foodServiceImpl.promotionFoods();
		
        request.setAttribute("pageFood", pageFood);
        request.setAttribute("newFoods", newFoods);
        request.setAttribute("promotionFoods", promotionFoods);
        request.setAttribute("pageReq", pageReq);
		
        RequestDispatcher rd = request.getRequestDispatcher("home.jsp");
        rd.forward(request, response);
	}

//	/**
//	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
//	 */
//	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//		// TODO Auto-generated method stub
//		doGet(request, response);
//	}

}
