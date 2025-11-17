package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.UserDAO;
import serviceimpl.UserServiceImpl;
import utils.DataSourceUtil;
import utils.FileUpload;
import utils.FileUpload.FileUploadException;

import javax.sql.DataSource;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/stall-profile")
@MultipartConfig(
		fileSizeThreshold = 1024 * 1024,
		maxFileSize = 5 * 1024 * 1024,
		maxRequestSize = 6 * 1024 * 1024
)
public class StallProfileServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private UserServiceImpl userService;
	
	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.userService = new UserServiceImpl(ds);
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		String userRole = (String) (session != null ? session.getAttribute("type_user") : null);
		String username = (String) (session != null ? session.getAttribute("username") : null);
		Integer userId = (Integer) (session != null ? session.getAttribute("userId") : null);
		
		if (username == null || userId == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		
		if (!"stall".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		UserDAO user = userService.getUserById(userId);
		if (user == null) {
			response.sendRedirect(request.getContextPath() + "/stall");
			return;
		}
		
		request.setAttribute("user", user);
		prepareProfileFormDefaults(request, user);
		request.getRequestDispatcher("/stall_profile.jsp").forward(request, response);
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
		
		if (!"stall".equals(userRole)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}
		
		UserDAO user = userService.getUserById(userId);
		if (user == null) {
			response.sendRedirect(request.getContextPath() + "/stall");
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
			request.getRequestDispatcher("/stall_profile.jsp").forward(request, response);
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
				session.setAttribute("stallFlashSuccess", "Cập nhật thông tin thành công!");
				session.setAttribute("userAvatar", finalAvatarPath);
			}
			response.sendRedirect(request.getContextPath() + "/stall");
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
			request.getRequestDispatcher("/stall_profile.jsp").forward(request, response);
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

