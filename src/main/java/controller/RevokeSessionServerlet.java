package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import serviceimpl.TokenServiceImpl;
import serviceimpl.UserServiceImpl;
import utils.DataSourceUtil;

import java.io.IOException;

import javax.sql.DataSource;

/**
 * Servlet implementation class RevokeSessionServerlet
 */
@WebServlet("/revokesession")
public class RevokeSessionServerlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
   
//	private UserServiceImpl userSerImpl;
	private TokenServiceImpl tokenSerImpl;

	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
//		this.userSerImpl = new UserServiceImpl(ds);
		this.tokenSerImpl = new TokenServiceImpl(ds);
	}
	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public RevokeSessionServerlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("is_login") == null) {
            response.sendRedirect("/login");
            return;
        }

        String username = (String) session.getAttribute("username");
        String seriesToDelete = request.getParameter("series");

        if (seriesToDelete != null && !seriesToDelete.isEmpty()) {

            boolean isTokenOwned = this.tokenSerImpl.isTokenOwnedByUser(username, seriesToDelete);
            
            if (isTokenOwned) {
                this.tokenSerImpl.deleteTokenBySeries(seriesToDelete);
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/account/sessions");
	}

}
