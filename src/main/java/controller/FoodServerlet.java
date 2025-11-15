package controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.FoodDAO;
import model.Food_CategoryDAO;
import model.Page;
import model.PageRequest;
import repositoryimpl.Food_CategoryRepositoryImpl;
import serviceimpl.FoodServiceImpl;
import serviceimpl.Food_CategoryServiceImpl;
import serviceimpl.StallServiceImpl;
import utils.DataSourceUtil;
import utils.RequestUtil;

import java.io.IOException;
import java.util.List;

import javax.sql.DataSource;

import dto.FoodDTO;
import model.StallDAO;


@WebServlet("/foods")
public class FoodServerlet extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private FoodServiceImpl foodServiceImpl;
	private Food_CategoryServiceImpl categoryServiceImpl;
	private StallServiceImpl stallServiceImpl;
	private int PAGE_SIZE = 25;
	
	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.foodServiceImpl = new FoodServiceImpl(ds);
		this.categoryServiceImpl = new Food_CategoryServiceImpl(ds);
		this.stallServiceImpl = new StallServiceImpl(ds);
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		String action = RequestUtil.getString(request, "action", "list");
		String keyword = RequestUtil.getString(request, "keyword", "");
		String sortField = RequestUtil.getString(request, "sortField", "id");
		String orderField = RequestUtil.getString(request, "orderField", "DESC");
		int page = RequestUtil.getInt(request, "page", 1);
		int id = RequestUtil.getInt(request, "id", 1);
		String stallIdParam = request.getParameter("stallId");
		Integer stallId = null;
		if (stallIdParam != null && !stallIdParam.trim().isEmpty()) {
			try {
				int sid = Integer.parseInt(stallIdParam);
				stallId = sid > 0 ? sid : null;
			} catch (NumberFormatException e) {
				stallId = null;
			}
		}
		FoodDTO foundFood = null;
		
		// Check authentication for sensitive operations
		HttpSession session = request.getSession(false);
		String userRole = (String) (session != null ? session.getAttribute("type_user") : null);
		String username = (String) (session != null ? session.getAttribute("username") : null);
		
		// Operations that require authentication and authorization
		if ("create".equals(action) || "update".equals(action) || "delete".equals(action)) {
			if (username == null) {
				response.sendRedirect(request.getContextPath() + "/login");
				return;
			}
			// Only stall role can create/update/delete foods
			if (!"stall".equals(userRole)) {
				response.sendRedirect(request.getContextPath() + "/home");
				return;
			}
		}
		
		RequestDispatcher rd;
		switch (action) {
			case "list":
				
				PageRequest pageReq = new PageRequest(page, PAGE_SIZE, sortField, orderField, keyword, stallId);
				Page<FoodDTO> pageFood = this.foodServiceImpl.findAll(pageReq);
				List<StallDAO> stalls = this.stallServiceImpl.findAll();
		        request.setAttribute("pageFood", pageFood);
		        request.setAttribute("pageReq", pageReq);
		        request.setAttribute("stalls", stalls);
		        request.setAttribute("userRole", userRole);
		        rd = request.getRequestDispatcher("/foodTemplates/food-list.jsp");
		        rd.forward(request, response);
		        break;
			
			case "create":
				PageRequest pageReq1 = new PageRequest(page, PAGE_SIZE, sortField, orderField, keyword);
				List<Food_CategoryDAO> categories = this.categoryServiceImpl.findAll();
				request.setAttribute("categories", categories);
		        rd = request.getRequestDispatcher("/foodTemplates/food-form-create.jsp");
		        rd.forward(request, response);
		        break;

			case "detail":
				
		        foundFood = this.foodServiceImpl.findById(id);

		        if (foundFood != null) {
		        	request.setAttribute("food", foundFood);
		            rd = request.getRequestDispatcher("/foodTemplates/food-form-detail.jsp");
		            rd.forward(request, response);
		        } else {
		        	response.sendError(HttpServletResponse.SC_NOT_FOUND);
	            	return;
		        }
		        break;    
		        
			case "update":
				
		        foundFood = this.foodServiceImpl.findById(id);

		        if (foundFood != null) {
		        	request.setAttribute("food", foundFood);
		            rd = request.getRequestDispatcher("/foodTemplates/food-form-update.jsp");
		            rd.forward(request, response);
		        } else {
		        	response.sendError(HttpServletResponse.SC_NOT_FOUND);
	            	return;
		        }
		        break;
			
			case "delete":
				
		        boolean isDelete = this.foodServiceImpl.delete(id);
		        if(isDelete) {
		        	response.sendRedirect(request.getContextPath()+"/foods?action=list");
		        }else {
		        	response.sendError(HttpServletResponse.SC_NOT_FOUND);
	            	return;
		        }	
				break;
			default:
				response.sendError(HttpServletResponse.SC_NOT_FOUND);
            	return;
		}
		
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// Check authentication for POST operations (create, update, delete)
		HttpSession session = request.getSession(false);
		String userRole = (String) (session != null ? session.getAttribute("type_user") : null);
		String username = (String) (session != null ? session.getAttribute("username") : null);
		
		if (username == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		
		// Only stall role can create/update foods
		if (!"stall".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		String action = request.getParameter("action");
		
        String nameFood = request.getParameter("nameFood");
        double priceFood = Double.parseDouble(request.getParameter("priceFood"));
        int inventoryFood = Integer.parseInt(request.getParameter("inventoryFood"));
		
		switch (action) {
			case "create":
	            
	            boolean isCreate = this.foodServiceImpl.create(nameFood, priceFood, inventoryFood);
	            if(isCreate) {
	            	response.sendRedirect(request.getContextPath()+"/foods?action=list");
	            } else {
	            	response.sendError(HttpServletResponse.SC_NOT_FOUND);
	            	return;
	            }
	            break;
			
			case "update":
				int id = Integer.parseInt(request.getParameter("id"));
		        boolean isUpdate = this.foodServiceImpl.update(id, nameFood, priceFood, inventoryFood);
		        if(isUpdate) {
		        	response.sendRedirect(request.getContextPath()+"/foods?action=list");
		        }else {
		        	response.sendError(HttpServletResponse.SC_NOT_FOUND);
	            	return;
		        }
				break;
		}
	}

}
