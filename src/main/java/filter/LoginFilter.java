package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet Filter implementation class LoginFilter
 */
@WebFilter("/login")
public class LoginFilter extends HttpFilter implements Filter {
       
    /**
     * @see HttpFilter#HttpFilter()
     */
    public LoginFilter() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see Filter#destroy()
	 */
	public void destroy() {
		// TODO Auto-generated method stub
	}

	/**
	 * @see Filter#doFilter(ServletRequest, ServletResponse, FilterChain)
	 */
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req  = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

		HttpSession session = req.getSession(false);
		
		// // Kiểm tra nếu đã đăng nhập thì redirect về home
		// if (session != null && session.getAttribute("is_login") != null) {
		// 	Boolean isLogin = (Boolean) session.getAttribute("is_login");
		// 	if (isLogin != null && isLogin) {
		// 		// Đã đăng nhập, redirect về home
		// 		resp.sendRedirect(req.getContextPath() + "/home");
		// 		return;
		// 	}
		// }
		
		// Nếu chưa đăng nhập, lưu URL hiện tại để redirect sau khi đăng nhập
		// (chỉ lưu nếu chưa có và không phải là trang login để tránh vòng lặp)
		if (session == null) {
			session = req.getSession(true);
		}
		String requestedUrl = req.getRequestURI();
		String queryString = req.getQueryString();
		if (queryString != null) {
			requestedUrl += "?" + queryString;
		}
		// Chỉ lưu redirectAfterLogin nếu chưa có và không phải là trang login
		// (để giữ URL từ trang đặt hàng hoặc trang khác)
		if (session.getAttribute("redirectAfterLogin") == null && !requestedUrl.contains("/login")) {
			session.setAttribute("redirectAfterLogin", requestedUrl);
		}

		// pass the request along the filter chain
		chain.doFilter(request, response);
	}

	/**
	 * @see Filter#init(FilterConfig)
	 */
	public void init(FilterConfig fConfig) throws ServletException {
		// TODO Auto-generated method stub
	}

}
