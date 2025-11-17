package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.OrderDAO;
import model.UserDAO;
import serviceimpl.OrderServiceImpl;
import serviceimpl.UserServiceImpl;
import utils.DataSourceUtil;
import utils.FileUpload;
import utils.FileUpload.FileUploadException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

@WebServlet("/customer")
@MultipartConfig(
		fileSizeThreshold = 1024 * 1024,
		maxFileSize = 5 * 1024 * 1024,
		maxRequestSize = 6 * 1024 * 1024
)
public class CustomerServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private UserServiceImpl userService;
	private OrderServiceImpl orderService;
	
	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.userService = new UserServiceImpl(ds);
		this.orderService = new OrderServiceImpl(ds);
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// Security check: Only customer can access
		HttpSession session = request.getSession(false);
		String userRole = (String) (session != null ? session.getAttribute("type_user") : null);
		String username = (String) (session != null ? session.getAttribute("username") : null);
		Integer userId = (Integer) (session != null ? session.getAttribute("userId") : null);
		
		if (username == null || userId == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		
		if (!"customer".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		// Get user information
		UserDAO user = userService.getUserById(userId);
		
		// Get user's orders
		List<OrderDAO> orders = orderService.findByUserId(userId);
		
		// Calculate statistics
		int totalOrders = orders.size();
		double totalSpent = 0.0;
		int pendingOrders = 0;
		int completedOrders = 0;
		
		for (OrderDAO order : orders) {
			totalSpent += order.getTotalPrice();
			if ("delivered".equals(order.getStatus())) {
				completedOrders++;
			} else {
				pendingOrders++;
			}
		}
		
		// Get recent orders (last 5)
		List<OrderDAO> recentOrders = orders.size() > 5 ? orders.subList(0, 5) : orders;
		
		request.setAttribute("user", user);
		request.setAttribute("totalOrders", totalOrders);
		request.setAttribute("totalSpent", totalSpent);
		request.setAttribute("pendingOrders", pendingOrders);
		request.setAttribute("completedOrders", completedOrders);
		request.setAttribute("recentOrders", recentOrders);
		request.setAttribute("allOrders", orders);
		
		if (session != null) {
			String flashSuccess = (String) session.getAttribute("customerFlashSuccess");
			if (flashSuccess != null) {
				request.setAttribute("profileSuccess", flashSuccess);
				session.removeAttribute("customerFlashSuccess");
			}
		}
		
		String view = request.getParameter("view");
		if ("edit".equals(view)) {
			prepareProfileFormDefaults(request, user);
			request.getRequestDispatcher("/customer_edit.jsp").forward(request, response);
			return;
		}
		
		request.getRequestDispatcher("/customer.jsp").forward(request, response);
	}
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		String userRole = (String) (session != null ? session.getAttribute("type_user") : null);
		String username = (String) (session != null ? session.getAttribute("username") : null);
		Integer userId = (Integer) (session != null ? session.getAttribute("userId") : null);
		
		if (username == null || userId == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		
		if (!"customer".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		UserDAO user = userService.getUserById(userId);
		if (user == null) {
			response.sendRedirect(request.getContextPath() + "/customer");
			return;
		}
		
		List<String> errors = new ArrayList<>();
		String fullName = trimToNull(request.getParameter("fullName"));
		String email = trimToNull(request.getParameter("email"));
		String phone = trimToNull(request.getParameter("phone"));
		
		if (fullName == null) {
			errors.add("Họ và tên không được để trống.");
		}
		if (email == null) {
			errors.add("Email không được để trống.");
		}
		
		String existingAvatarPath = user.getAvatar();
		String newAvatarPath = null;
		boolean hasNewAvatar = false;
		String appRealPath = null;
		
		Part avatarPart = null;
		try {
			avatarPart = request.getPart("avatar");
		} catch (IllegalStateException e) {
			errors.add("Ảnh đại diện vượt quá dung lượng cho phép (5MB).");
		}
		
		if (avatarPart != null && avatarPart.getSize() > 0) {
			try {
				appRealPath = FileUpload.safeAppRealPath(getServletContext());
				newAvatarPath = FileUpload.uploadImageReturnPath(avatarPart, "avatars", appRealPath);
				hasNewAvatar = true;
			} catch (FileUploadException e) {
				errors.add(e.getMessage());
			}
		}
		
		if (!errors.isEmpty()) {
			if (hasNewAvatar && newAvatarPath != null && appRealPath != null) {
				FileUpload.deleteFile(newAvatarPath, appRealPath);
			}
			request.setAttribute("profileError", String.join(" ", errors));
			request.setAttribute("profileFormFullName", fullName);
			request.setAttribute("profileFormEmail", email);
			request.setAttribute("profileFormPhone", phone);
			request.setAttribute("user", user);
			request.getRequestDispatcher("/customer_edit.jsp").forward(request, response);
			return;
		}
		
		String finalAvatarPath = hasNewAvatar ? newAvatarPath : existingAvatarPath;
		user.setFull_name(fullName);
		user.setEmail(email);
		user.setPhone(phone);
		user.setAvatar(finalAvatarPath);
		
		boolean updated = userService.updateProfile(user);
		if (updated) {
			if (hasNewAvatar && existingAvatarPath != null && !existingAvatarPath.isBlank()) {
				if (appRealPath == null) {
					appRealPath = FileUpload.safeAppRealPath(getServletContext());
				}
				FileUpload.deleteFile(existingAvatarPath, appRealPath);
			}
			if (session != null) {
				session.setAttribute("customerFlashSuccess", "Cập nhật thông tin thành công!");
			}
			response.sendRedirect(request.getContextPath() + "/customer");
			return;
		} else {
			if (hasNewAvatar && newAvatarPath != null) {
				if (appRealPath == null) {
					appRealPath = FileUpload.safeAppRealPath(getServletContext());
				}
				FileUpload.deleteFile(newAvatarPath, appRealPath);
			}
			request.setAttribute("profileError", "Không thể cập nhật thông tin. Vui lòng thử lại.");
			request.setAttribute("profileFormFullName", fullName);
			request.setAttribute("profileFormEmail", email);
			request.setAttribute("profileFormPhone", phone);
			request.setAttribute("user", user);
			request.getRequestDispatcher("/customer_edit.jsp").forward(request, response);
		}
	}
	
	private String trimToNull(String value) {
		if (value == null) {
			return null;
		}
		String trimmed = value.trim();
		return trimmed.isEmpty() ? null : trimmed;
	}
	
	private void prepareProfileFormDefaults(HttpServletRequest request, UserDAO user) {
		if (request.getAttribute("profileFormFullName") == null) {
			request.setAttribute("profileFormFullName", user != null ? user.getFull_name() : "");
		}
		if (request.getAttribute("profileFormEmail") == null) {
			String email = (user != null && user.getEmail() != null) ? user.getEmail() : "";
			request.setAttribute("profileFormEmail", email);
		}
		if (request.getAttribute("profileFormPhone") == null) {
			String phone = (user != null && user.getPhone() != null) ? user.getPhone() : "";
			request.setAttribute("profileFormPhone", phone);
		}
	}
}

