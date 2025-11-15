package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Order_FoodDAO;
import model.TokenDAO;
import model.UserDAO;
import serviceimpl.TokenServiceImpl;
import serviceimpl.UserServiceImpl;
import utils.DataSourceUtil;
import utils.SHA256;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import javax.sql.DataSource;

/**
 * Servlet Filter implementation class AuthFilter
 */
@WebFilter("/*")
public class AuthFilter extends HttpFilter implements Filter {
       
    /**
     * @see HttpFilter#HttpFilter()
     */
    public AuthFilter() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see Filter#destroy()
	 */
	public void destroy() {
		// TODO Auto-generated method stub
	}

	private UserServiceImpl userSerImpl;
	private TokenServiceImpl tokenSerImpl;
	
	/**
	 * @see Filter#init(FilterConfig)
	 */
	public void init(FilterConfig fConfig) throws ServletException {
		DataSource ds = DataSourceUtil.getDataSource();
		this.userSerImpl = new UserServiceImpl(ds);
		this.tokenSerImpl = new TokenServiceImpl(ds);
	}
	
	private static final String[] STATIC_RESOURCE_EXTENSIONS = {
	        ".css", ".js", ".jpg", ".jpeg", ".png", ".gif", ".ico", ".svg", ".woff", ".ttf", ".eot"
	};
	
	/**
	 * @see Filter#doFilter(ServletRequest, ServletResponse, FilterChain)
	 */
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        
		HttpServletRequest req  = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getRequestURI().substring(req.getContextPath().length());
        if(path.equals("/")) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;        	
        }
        String requestURI = req.getRequestURI().toLowerCase();
        
        boolean isStaticResource = false;
        for (String extension : STATIC_RESOURCE_EXTENSIONS) {
            if (requestURI.endsWith(extension)) {
                isStaticResource = true;
                break;
            }
        }
       
        if (isStaticResource) {
        	chain.doFilter(request, response);
        	return;
        }
        
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        // ========== COMMENT: Chức năng Remember Me đã được tắt ==========
        // // Kiểm tra token trước để tự động đăng nhập nếu token còn thời hạn
        // String rawToken = getRememberMeToken(req);        
        // if (rawToken != null) {
        //     String tokenHash = SHA256.hash256(rawToken);
        //     TokenDAO dbToken = this.tokenSerImpl.findTokenByHash(tokenHash);
        //
        //     if (dbToken != null) {
        //         // Nếu token còn thời hạn, tự động tạo session và đăng nhập
        //         if(!isTokenExpired(dbToken)) {
        //             UserDAO user = this.userSerImpl.getUser(dbToken.getUsername());
        //             System.out.println("Token còn thời hạn - tự động đăng nhập");
        //             HttpSession newSession = req.getSession(true);
        //             newSession.setAttribute("is_login", true);
        //             newSession.setAttribute("userId", user.getId());
        //             newSession.setAttribute("username", user.getUsername());
        //             newSession.setAttribute("type_user", user.getRole());
        //             
        //             // Tạo token mới để bảo mật
        //             String newToken = UUID.randomUUID().toString();
        //             String newTokenHash = SHA256.hash256(newToken);
        //             
        //             Cookie newCookie = new Cookie("canteenSID", newToken);
        //             newCookie.setMaxAge(30 * 24 * 60 * 60); // 30 ngày
        //             newCookie.setHttpOnly(true);
        //             newCookie.setPath("/");
        //
        //             this.tokenSerImpl.updateTokenHash(dbToken.getSeries(), newTokenHash);
        //
        //             ((HttpServletResponse) response).addCookie(newCookie);	
        //         } else {
        //             // Token đã hết hạn - xóa token và cookie
        //         	System.out.println("Token đã hết hạn - xóa token");
        //         	this.tokenSerImpl.deleteTokenBySeries(dbToken.getSeries());
        //         	deleteRememberMeCookie(resp);
        //         }
        //     } else {
        //         // Token không tồn tại trong database - xóa cookie
        //     	System.out.println("Token không tồn tại - xóa cookie");
        //     	deleteRememberMeCookie(resp);
        //     }
        // }
        // ========== END COMMENT: Remember Me ==========

        // 1. Kiểm tra đăng nhập: Lấy thông tin session hiện tại
        // Sử dụng getSession(false) để không tạo session mới nếu chưa có
        HttpSession ses = req.getSession(false);

        boolean is_login = false;
        String username = "";
        String type_user = "";
        
        // Nếu session tồn tại và có thuộc tính is_login, lấy thông tin
        if (ses != null) {
            Object isLoginAttr = ses.getAttribute("is_login");
            if (isLoginAttr != null) {
                is_login = (boolean) isLoginAttr;
                username = (String) ses.getAttribute("username");
                type_user = (String) ses.getAttribute("type_user");
            }
        }

        // 2. Kiểm tra các trang cần đăng nhập (checkout và các trang khác)
        // Danh sách các URL cần đăng nhập
        String[] protectedPaths = {"/cart", "/order", "/profile", "/admin", "/food"};
        boolean isProtectedPath = false;
        
        // Kiểm tra nếu là /foods, cho phép list và detail không cần đăng nhập
        if (path.startsWith("/foods")) {
            String action = req.getParameter("action");
            // Nếu action là list, detail hoặc không có (mặc định là list), không yêu cầu đăng nhập
            if (action == null || action.equals("list") || action.equals("detail")) {
                isProtectedPath = false;
            } else {
                // Các action khác (create, update, delete) vẫn yêu cầu đăng nhập
                isProtectedPath = true;
            }
        } else {
            // Kiểm tra các path khác
            for (String protectedPathItem : protectedPaths) {
                if (path.startsWith(protectedPathItem)) {
                    isProtectedPath = true;
                    break;
                }
            }
        }
        
        // Nếu là trang cần đăng nhập nhưng chưa đăng nhập, redirect về trang login
        if (isProtectedPath && !is_login) {
            // Lưu URL hiện tại để redirect về sau khi đăng nhập
            if (ses == null) {
                ses = req.getSession(true);
            }
            String requestedUrl = req.getRequestURI();
            String queryString = req.getQueryString();
            if (queryString != null) {
                requestedUrl += "?" + queryString;
            }
            ses.setAttribute("redirectAfterLogin", requestedUrl);
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Set attribute cho request để JSP có thể sử dụng
        request.setAttribute("is_login", is_login);
        request.setAttribute("username", username);
        request.setAttribute("type_user", type_user);       
        System.out.println("AuthFilter: is_login=" + is_login + ", path=" + path);
        chain.doFilter(request, response);
     
	}	
	
	private void deleteRememberMeCookie(HttpServletResponse response) {
        Cookie expiredCookie = new Cookie("canteenSID", "");
        expiredCookie.setMaxAge(0);
        expiredCookie.setHttpOnly(true);
        expiredCookie.setPath("/");
        response.addCookie(expiredCookie);
    }
	
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
	
	private boolean isTokenExpired(TokenDAO dbToken) {
	    if (dbToken == null || dbToken.getExpires() == null) {
	        return true; 
	    }
	    
	    long expirationTimeMillis = dbToken.getExpires().getTime();
	    
	    long currentTimeMillis = System.currentTimeMillis();
	    
	    return expirationTimeMillis <= currentTimeMillis;
	}

}
