package controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.UserDAO;
import serviceimpl.TokenServiceImpl;
import serviceimpl.UserServiceImpl;
import utils.DataSourceUtil;
import utils.SHA256;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.Date;
import java.util.UUID;

import javax.sql.DataSource;

import com.mysql.cj.Session;

/**
 * Servlet implementation class LoginServerlet
 */
@WebServlet("/login")
public class LoginServerlet extends HttpServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = 6032073007253274585L;
	private UserServiceImpl userSerImpl;
	private TokenServiceImpl tokenSerImpl;

	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.userSerImpl = new UserServiceImpl(ds);
		this.tokenSerImpl = new TokenServiceImpl(ds);
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Boolean isLogin = (Boolean) session.getAttribute("is_login");
		
		// Nếu đã đăng nhập, điều hướng về trang home
		if (isLogin != null) {
            if(isLogin){
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
		}
		
		// Nếu chưa đăng nhập, hiển thị trang login
        RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
        rd.forward(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		// ========== COMMENT: Chức năng Remember Me đã được tắt ==========
		// String rememberMe = request.getParameter("remember");
		// ========== END COMMENT: Remember Me ==========
		boolean isLogin = this.userSerImpl.isAuthenticated(username, password);
		HttpSession session = request.getSession();
		UserDAO user = this.userSerImpl.getUser(username);
		if(isLogin) {
			session.setAttribute("is_login", isLogin);
			session.setAttribute("userId", user.getId());
			session.setAttribute("username", user.getUsername());
			session.setAttribute("type_user", user.getRole());
			
			// ========== COMMENT: Chức năng Remember Me đã được tắt ==========
			// if (rememberMe != null && rememberMe.equals("on")) {
			// 	String rawToken = UUID.randomUUID().toString();
			// 	String tokenHash = SHA256.hash256(rawToken);
			// 	
			// 	Cookie rememberCookie = new Cookie("canteenSID", rawToken);
			// 	
			// 	int days = 30; 
			// 	Calendar calendar = Calendar.getInstance();
			// 	calendar.add(Calendar.DAY_OF_MONTH, days);
			// 	Date expirationDate = calendar.getTime();
			// 	long currentTimeMillis = System.currentTimeMillis();
			// 	long expirationTimeMillis = expirationDate.getTime();
			// 	long durationMillis = expirationTimeMillis - currentTimeMillis;
			// 	
			// 	int maxAgeInSeconds = (int) (durationMillis / 1000);
			//     rememberCookie.setMaxAge(maxAgeInSeconds); 
			//     rememberCookie.setHttpOnly(true);
			//     rememberCookie.setSecure(request.isSecure());
			//     rememberCookie.setPath("/");
			//     String series = UUID.randomUUID().toString();
			//     this.tokenSerImpl.saveToken(user.getUsername(), series, tokenHash, new Timestamp(expirationDate.getTime()));
			//     
			//     response.addCookie(rememberCookie);
			// }
			// ========== END COMMENT: Remember Me ==========
			
			// Check if there's a saved URL to redirect to after login
			String redirectUrl = (String) session.getAttribute("redirectAfterLogin");
			if (redirectUrl != null && !redirectUrl.isEmpty()) {
				session.removeAttribute("redirectAfterLogin");
				response.sendRedirect(redirectUrl);
			} else {
				// Nếu không có URL redirect, chuyển về trang home
				response.sendRedirect(request.getContextPath() + "/home");
			}
		}
		else {
			String msg_error = "";
			if(user == null) {
				msg_error = "Login Failed, check user name and password";
			} else {
				if(user.isStatus() == false) {
					msg_error = "Login Failed, user blocked - please contact admin";
				}
			}
            request.setAttribute("error", msg_error);
            request.getRequestDispatcher("login.jsp").forward(request, response);
		}
	}

}
