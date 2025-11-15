package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.StallDAO;
import serviceimpl.StallServiceImpl;
import utils.DataSourceUtil;

import java.io.IOException;
import java.util.List;

import javax.sql.DataSource;

/**
 * Servlet implementation class StoreServerlet
 */
@WebServlet("/store")
public class StoreServerlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private StallServiceImpl stallService;
	
	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.stallService = new StallServiceImpl(ds);
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String action = request.getParameter("action");
		
		if (action == null) {
			action = "list";
		}
		
		switch (action) {
			case "list":
				handleList(request, response);
				break;
			case "detail":
				handleDetail(request, response);
				break;
			default:
				handleList(request, response);
				break;
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
	
	private void handleList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		List<StallDAO> stalls = stallService.findAll();
		request.setAttribute("stalls", stalls);
		request.getRequestDispatcher("/store.jsp").forward(request, response);
	}
	
	private void handleDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		int id = Integer.parseInt(request.getParameter("id"));
		StallDAO stall = stallService.findById(id);
		
		if (stall != null) {
			request.setAttribute("stall", stall);
			request.getRequestDispatcher("/store-detail.jsp").forward(request, response);
		} else {
			response.sendRedirect(request.getContextPath() + "/store");
		}
	}
}
