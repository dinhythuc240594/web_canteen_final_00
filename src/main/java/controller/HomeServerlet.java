package controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.PageRequest;
import model.StallDAO;
import serviceimpl.FoodServiceImpl;
import serviceimpl.StallServiceImpl;
import utils.DataSourceUtil;
import utils.RequestUtil;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
	private StallServiceImpl stallServiceImpl;
	private int PAGE_SIZE = 25;
	
	@Override
	public void init() throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.foodServiceImpl = new FoodServiceImpl(ds);
		this.stallServiceImpl = new StallServiceImpl(ds);
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
		
		List<StallDAO> stalls = this.stallServiceImpl.findAll();
		LocalDate today = LocalDate.now();
		Date _today = Date.valueOf(today);
		List<FoodDTO> dailyMenuFoods = this.foodServiceImpl.findByUpdatedDate(_today, null, keyword);
		
		Map<Integer, List<FoodDTO>> dailyMenuByStall = new HashMap<>();
		if (dailyMenuFoods != null) {
			for (FoodDTO menuFood : dailyMenuFoods) {
				if (menuFood == null) continue;
				dailyMenuByStall.computeIfAbsent(menuFood.getStallId(), k -> new ArrayList<>()).add(menuFood);
			}
		}
		
		List<StallDAO> dailyMenuStalls = new ArrayList<>();
		if (stalls != null) {
			dailyMenuStalls.addAll(stalls);
		}
		
        request.setAttribute("pageReq", pageReq);
        request.setAttribute("stalls", stalls);
        request.setAttribute("dailyMenuDate", today);
        request.setAttribute("dailyMenuByStall", dailyMenuByStall);
        request.setAttribute("dailyMenuStalls", dailyMenuStalls);
        request.setAttribute("dailyMenuFoods", dailyMenuFoods);
		
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
