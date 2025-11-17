package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import serviceimpl.UserServiceImpl;
import utils.DataSourceUtil;

import javax.sql.DataSource;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {
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
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}

		String role = (String) session.getAttribute("type_user");
		if (!isSupportedRole(role)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}

		request.setAttribute("pageRole", role);
		request.getRequestDispatcher("/change_password.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		String username = session != null ? (String) session.getAttribute("username") : null;
		Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
		String role = session != null ? (String) session.getAttribute("type_user") : null;

		if (session == null || username == null || userId == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}

		if (!isSupportedRole(role)) {
			response.sendRedirect(request.getContextPath() + "/home");
			return;
		}

		List<String> errors = new ArrayList<>();
		String currentPassword = trimToNull(request.getParameter("currentPassword"));
		String newPassword = trimToNull(request.getParameter("newPassword"));
		String confirmPassword = trimToNull(request.getParameter("confirmPassword"));

		if (currentPassword == null) {
			errors.add("Vui lòng nhập mật khẩu hiện tại.");
		}
		if (newPassword == null) {
			errors.add("Vui lòng nhập mật khẩu mới.");
		}
		if (confirmPassword == null) {
			errors.add("Vui lòng xác nhận mật khẩu mới.");
		}
		if (newPassword != null && newPassword.length() < 6) {
			errors.add("Mật khẩu mới phải có tối thiểu 6 ký tự.");
		}
		if (newPassword != null && confirmPassword != null && !newPassword.equals(confirmPassword)) {
			errors.add("Mật khẩu xác nhận không khớp.");
		}
		if (currentPassword != null && newPassword != null && currentPassword.equals(newPassword)) {
			errors.add("Mật khẩu mới phải khác mật khẩu hiện tại.");
		}

		if (!errors.isEmpty()) {
			forwardWithErrors(errors, request, response, role);
			return;
		}

		boolean validCurrentPassword = userService.isAuthenticated(username, currentPassword);
		if (!validCurrentPassword) {
			errors.add("Mật khẩu hiện tại không chính xác.");
			forwardWithErrors(errors, request, response, role);
			return;
		}

		boolean updated = userService.updatePassword(userId, newPassword);
		if (updated) {
			if ("customer".equals(role)) {
				session.setAttribute("customerFlashSuccess", "Đổi mật khẩu thành công!");
				response.sendRedirect(request.getContextPath() + "/customer");
				return;
			}
			if ("stall".equals(role)) {
				session.setAttribute("stallFlashSuccess", "Đổi mật khẩu thành công!");
				response.sendRedirect(request.getContextPath() + "/stall");
				return;
			}
		}

		errors.add("Không thể cập nhật mật khẩu. Vui lòng thử lại.");
		forwardWithErrors(errors, request, response, role);
	}

	private boolean isSupportedRole(String role) {
		return "customer".equals(role) || "stall".equals(role);
	}

	private void forwardWithErrors(List<String> errors, HttpServletRequest request, HttpServletResponse response, String role)
			throws ServletException, IOException {
		request.setAttribute("passwordErrors", errors);
		request.setAttribute("pageRole", role);
		request.getRequestDispatcher("/change_password.jsp").forward(request, response);
	}

	private String trimToNull(String value) {
		if (value == null) {
			return null;
		}
		String trimmed = value.trim();
		return trimmed.isEmpty() ? null : trimmed;
	}
}

