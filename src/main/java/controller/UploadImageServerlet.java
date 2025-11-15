package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/**
 * Servlet implementation class UploadImageServerlet
 */
@WebServlet(name="/upload-image", urlPatterns= {"/upload-image"})

@MultipartConfig (
	fileSizeThreshold = 2 * 1024 * 1024,
	maxFileSize = 10 * 1024 * 1024,
	maxRequestSize =  20 * 1024 * 1024
)

public class UploadImageServerlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UploadImageServerlet() {
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
        // CKEditor 4 gởi file với key 'upload'
        Part filePart = request.getPart("upload");
        String funcNum = request.getParameter("CKEditorFuncNum"); // có => dùng script callback

        if (filePart == null || filePart.getSize() == 0) {
            writeError(response, funcNum, "No file uploaded");
            return;
        }
        String ct = String.valueOf(filePart.getContentType());
        if (!ct.startsWith("image/")) {
            writeError(response, funcNum, "Invalid file type");
            return;
        }

        // Tạo tên file an toàn
        String submitted = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String ext = submitted.contains(".") ? submitted.substring(submitted.lastIndexOf(".")) : "";
        String safeName = UUID.randomUUID().toString().replace("-", "") + ext.toLowerCase();

        // Lưu ngoài webapp (đừng để trong war)
        Path root = Paths.get(System.getProperty("uploads.dir", "C:/uploads"), "ck4");
        Files.createDirectories(root);
        try (InputStream in = filePart.getInputStream()) {
            Files.copy(in, root.resolve(safeName), StandardCopyOption.REPLACE_EXISTING);
        }

        // URL public—bạn cần có servlet tĩnh /static/* hoặc map qua Nginx
        String publicUrl = request.getContextPath() + "/static/ck4/" + URLEncoder.encode(safeName, "UTF-8");

        if (funcNum != null) {
            // ===== Kiểu B: callback cho file dialog =====
        	response.setContentType("text/html; charset=UTF-8");
            String message = ""; // có thể để rỗng
            response.getWriter().printf(
                    "<script>window.parent.CKEDITOR.tools.callFunction(%s,'%s','%s');</script>",
                    funcNum, publicUrl, escapeJs(message)
            );
        } else {
            // ===== Kiểu A: JSON cho plugin uploadimage (drag & drop / paste) =====
            response.setContentType("application/json; charset=UTF-8");
            String json = String.format("{\"uploaded\":1,\"fileName\":\"%s\",\"url\":\"%s\"}",
                    safeName.replace("\"","\\\""), publicUrl.replace("\"","\\\""));
            response.getWriter().write(json);
        }
	}
	
    private void writeError(HttpServletResponse resp, String funcNum, String msg) throws IOException {
        if (funcNum != null) {
            resp.setContentType("text/html; charset=UTF-8");
            resp.getWriter().printf(
                    "<script>window.parent.CKEDITOR.tools.callFunction(%s,'','%s');</script>",
                    funcNum, escapeJs(msg)
            );
        } else {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"uploaded\":0,\"error\":{\"message\":\""+ msg.replace("\"","\\\"") +"\"}}");
        }
    }

    private String escapeJs(String s){
        return s == null ? "" : s.replace("\\","\\\\").replace("'","\\'").replace("\"","\\\"");
    }

}
