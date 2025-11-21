package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.TokenDAO;
import serviceimpl.TokenServiceImpl;
import utils.DataSourceUtil;
import utils.SHA256;

import java.io.IOException;

import javax.sql.DataSource;

/**
 * Servlet implementation class LogoutServerlet
 */
@WebServlet("/logout")
public class LogoutServerlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TokenServiceImpl tokenSerImpl;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LogoutServerlet() {
        super();
    }

	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.tokenSerImpl = new TokenServiceImpl(ds);
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String rawToken = getRememberMeToken(request);
		
		if (rawToken != null) {
			String tokenHash = SHA256.hash256(rawToken);
			TokenDAO dbToken = this.tokenSerImpl.findTokenByHash(tokenHash);
			if (dbToken != null) {
				this.tokenSerImpl.deleteTokenBySeries(dbToken.getSeries());
			}
			deleteRememberMeCookie(response);
		}
		
		HttpSession session = request.getSession(false);
        if (session != null) {
        	session.invalidate();
        }
        
        response.sendRedirect(request.getContextPath() + "/home");
	}

	/**
	 * Get remember me token from cookies
	 */
	private String getRememberMeToken(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("canteenSID")) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }
	
	/**
	 * Delete remember me cookie by setting max age to 0
	 */
	private void deleteRememberMeCookie(HttpServletResponse response) {
        Cookie expiredCookie = new Cookie("canteenSID", "");
        expiredCookie.setMaxAge(0);
        expiredCookie.setHttpOnly(true);
        expiredCookie.setPath("/");
        response.addCookie(expiredCookie);
    }

//	/**
//	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
//	 */
//	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//		// TODO Auto-generated method stub
//		doGet(request, response);
//	}

}
