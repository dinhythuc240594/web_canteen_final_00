package controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.FoodDAO;
import model.Food_CategoryDAO;
import model.PageRequest;
import model.StallDAO;
import repositoryimpl.Food_CategoryRepositoryImpl;
import serviceimpl.FoodServiceImpl;
import serviceimpl.Food_CategoryServiceImpl;
import serviceimpl.StallServiceImpl;
import utils.DataSourceUtil;
import utils.RequestUtil;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.sql.DataSource;

import dto.FoodDTO;


@WebServlet("/foods")
@MultipartConfig(
    fileSizeThreshold = 2 * 1024 * 1024,
    maxFileSize = 10 * 1024 * 1024,
    maxRequestSize = 20 * 1024 * 1024
)
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
		Integer userId = (Integer) (session != null ? session.getAttribute("userId") : null);
		
		// Operations that require authentication and authorization
		if ("create".equals(action) || "update".equals(action) || "delete".equals(action)) {
			if (username == null || userId == null) {
				response.sendRedirect(request.getContextPath() + "/login");
				return;
			}
			// Only stall role can create/update/delete foods
			if (!"stall".equals(userRole)) {
				response.sendRedirect(request.getContextPath() + "/home");
				return;
			}
			
			// Get user's stall to verify ownership
			List<StallDAO> userStalls = this.stallServiceImpl.findByManagerUserId(userId);
			if (userStalls.isEmpty()) {
				response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không quản lý quầy nào");
				return;
			}
			int userStallId = userStalls.getFirst().getId();
			
			// For update and delete, verify that the food belongs to the user's stall
			if ("update".equals(action) || "delete".equals(action)) {
				FoodDTO food = this.foodServiceImpl.findById(id);
				if (food == null) {
					response.sendError(HttpServletResponse.SC_NOT_FOUND);
					return;
				}
				// Verify ownership: food must belong to user's stall
				if (food.getStallId() != userStallId) {
					response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền chỉnh sửa hoặc xóa món này");
					return;
				}
			}
			
			// Store userStallId in request for create/update operations
			request.setAttribute("userStallId", userStallId);
		}
		
		RequestDispatcher rd;
		switch (action) {
			case "list":
				
				PageRequest pageReq = new PageRequest(page, PAGE_SIZE, sortField, orderField, keyword, stallId);
				List<StallDAO> stalls = this.stallServiceImpl.findAll();
		        request.setAttribute("pageReq", pageReq);
		        request.setAttribute("stalls", stalls);
		        request.setAttribute("userRole", userRole);
		        
		        // Get user's stall ID if user is a stall owner
		        Integer userStallId = null;
		        if ("stall".equals(userRole) && userId != null) {
		        	List<StallDAO> userStalls = this.stallServiceImpl.findByManagerUserId(userId);
		        	if (!userStalls.isEmpty()) {
		        		userStallId = userStalls.get(0).getId();
		        	}
		        }
		        request.setAttribute("userStallId", userStallId);

		        LocalDate today = LocalDate.now();
		        Date _today = Date.valueOf(today);
		        List<FoodDTO> dailyMenuFoods = this.foodServiceImpl.findByUpdatedDate(_today, stallId, keyword);

		        Map<Integer, List<FoodDTO>> dailyMenuByStall = new HashMap<>();
		        if (dailyMenuFoods != null) {
		        	for (FoodDTO menuFood : dailyMenuFoods) {
		        		if (menuFood == null) continue;
		        		dailyMenuByStall.computeIfAbsent(menuFood.getStallId(), k -> new ArrayList<>()).add(menuFood);
		        	}
		        }

		        List<StallDAO> dailyMenuStalls = new ArrayList<>();
		        if (stalls != null) {
		        	if (stallId != null && stallId > 0) {
		        		for (StallDAO stall : stalls) {
		        			if (stall.getId() == stallId) {
		        				dailyMenuStalls.add(stall);
		        				break;
		        			}
		        		}
		        	} else {
		        		dailyMenuStalls.addAll(stalls);
		        	}
		        }
		        
		        request.setAttribute("dailyMenuDate", today);
		        request.setAttribute("dailyMenuByStall", dailyMenuByStall);
		        request.setAttribute("dailyMenuStalls", dailyMenuStalls);
		        request.setAttribute("dailyMenuFoods", dailyMenuFoods);
		        
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
				List<Food_CategoryDAO> categoriesForUpdate = this.categoryServiceImpl.findAll();
				request.setAttribute("categories", categoriesForUpdate);
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
		Integer userId = (Integer) (session != null ? session.getAttribute("userId") : null);
		
		if (username == null || userId == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		
		// Only stall role can create/update foods
		if (!"stall".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		// Get user's stall to verify ownership
		List<StallDAO> userStalls = this.stallServiceImpl.findByManagerUserId(userId);
		if (userStalls.isEmpty()) {
			response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không quản lý quầy nào");
			return;
		}
		int userStallId = userStalls.get(0).getId();
		
		String action = RequestUtil.getString(request, "action", null);
		System.out.println(action);
		// Handle JSON response for AJAX requests
		response.setContentType("application/json; charset=UTF-8");
		PrintWriter out = response.getWriter();
		
		try {
			if (action == null || action.isBlank()) {
				out.print("{\"success\":false,\"message\":\"Thiếu tham số action\"}");
				return;
			}
			
			switch (action) {
				case "create": {
					String nameFood = request.getParameter("nameFood");
					double priceFood = Double.parseDouble(request.getParameter("priceFood"));
					int inventoryFood = Integer.parseInt(request.getParameter("inventoryFood"));
					
					// Get optional fields
					String categoryIdStr = request.getParameter("category_id");
					Integer categoryId = (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) 
						? Integer.parseInt(categoryIdStr) : null;
					
					String description = request.getParameter("description");
					if (description == null) description = "";
					
					String promotionStr = request.getParameter("promotion");
					Double promotion = (promotionStr != null && !promotionStr.trim().isEmpty()) 
						? Double.parseDouble(promotionStr) : 0.0;
					
					String isAvailableStr = request.getParameter("is_available");
					Boolean isAvailable = (isAvailableStr != null && "1".equals(isAvailableStr));
					
					String imageUrl = handleImageUpload(request);
					
					boolean isCreate = this.foodServiceImpl.create(
						nameFood, priceFood, inventoryFood, userStallId, 
						categoryId, imageUrl, description, promotion, isAvailable
					);
					if (isCreate) {
						out.print("{\"success\":true,\"message\":\"Tạo món ăn thành công!\"}");
					} else {
						out.print("{\"success\":false,\"message\":\"Lỗi khi tạo món ăn\"}");
					}
					break;
				}
				
				case "update": {
					int id = Integer.parseInt(request.getParameter("id"));
					String nameFood = request.getParameter("nameFood");
					double priceFood = Double.parseDouble(request.getParameter("priceFood"));
					int inventoryFood = Integer.parseInt(request.getParameter("inventoryFood"));
					
					String categoryIdStr = request.getParameter("category_id");
					Integer categoryId = (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) 
						? Integer.parseInt(categoryIdStr) : null;
					
					String description = request.getParameter("description");
					if (description == null) description = "";
					
					String promotionStr = request.getParameter("promotion");
					Double promotion = (promotionStr != null && !promotionStr.trim().isEmpty()) 
						? Double.parseDouble(promotionStr) : 0.0;
					
					String isAvailableStr = request.getParameter("is_available");
					Boolean isAvailable = (isAvailableStr != null && "1".equals(isAvailableStr));
					
					String imageUrl = handleImageUpload(request);
					
					// Verify ownership before updating
					FoodDTO food = this.foodServiceImpl.findById(id);
					if (food == null) {
						out.print("{\"success\":false,\"message\":\"Không tìm thấy món ăn\"}");
						return;
					}
					if (food.getStallId() != userStallId) {
						out.print("{\"success\":false,\"message\":\"Bạn không có quyền chỉnh sửa món này\"}");
						return;
					}
					
					// If no new image uploaded, keep the existing one
					if (imageUrl == null) {
						imageUrl = food.getImage();
					}
					
					boolean isUpdate = this.foodServiceImpl.update(
						id, nameFood, priceFood, inventoryFood, 
						categoryId, imageUrl, description, promotion, isAvailable
					);
					if (isUpdate) {
						out.print("{\"success\":true,\"message\":\"Cập nhật món ăn thành công!\"}");
					} else {
						out.print("{\"success\":false,\"message\":\"Lỗi khi cập nhật món ăn\"}");
					}
					break;
				}
				
				case "delete": {
					int id = Integer.parseInt(request.getParameter("id"));
					FoodDTO food = this.foodServiceImpl.findById(id);
					if (food == null) {
						out.print("{\"success\":false,\"message\":\"Không tìm thấy món ăn\"}");
						return;
					}
					if (food.getStallId() != userStallId) {
						out.print("{\"success\":false,\"message\":\"Bạn không có quyền xóa món này\"}");
						return;
					}
					
					boolean isDelete = this.foodServiceImpl.delete(id);
					if (isDelete) {
						out.print("{\"success\":true,\"message\":\"Đã xóa món ăn\"}");
					} else {
						out.print("{\"success\":false,\"message\":\"Lỗi khi xóa món ăn\"}");
					}
					break;
				}
					
				default:
					out.print("{\"success\":false,\"message\":\"Action không hợp lệ\"}");
			}
		} catch (Exception e) {
			e.printStackTrace();
			out.print("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage().replace("\"", "\\\"") + "\"}");
		} finally {
			out.close();
		}
	}
	
	private String handleImageUpload(HttpServletRequest request) throws IOException, ServletException {
		Part imagePart = request.getPart("image");
		if (imagePart != null && imagePart.getSize() > 0) {
			String contentType = imagePart.getContentType();
			if (contentType != null && contentType.startsWith("image/")) {
				String submitted = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
				String ext = submitted.contains(".") ? submitted.substring(submitted.lastIndexOf(".")) : ".jpg";
				String safeName = UUID.randomUUID().toString().replace("-", "") + ext.toLowerCase();
				
				String appRealPath = request.getServletContext().getRealPath("");
				if (appRealPath == null) {
					appRealPath = System.getProperty("user.home") + "/uploads";
				}
				
				Path uploadDir = Paths.get(appRealPath, "uploads", "foods");
				Files.createDirectories(uploadDir);
				
				try (InputStream in = imagePart.getInputStream()) {
					Files.copy(in, uploadDir.resolve(safeName), StandardCopyOption.REPLACE_EXISTING);
				}
				
				return request.getContextPath() + "/uploads/foods/" + URLEncoder.encode(safeName, "UTF-8");
			}
		}
		return null;
	}

}
