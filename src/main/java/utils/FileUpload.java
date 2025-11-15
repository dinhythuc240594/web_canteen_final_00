package utils;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;

import java.util.logging.Logger;

import javax.imageio.ImageIO;

import jakarta.servlet.http.Part;
import utils.FileUpload;

public class FileUpload {
	
	private static final Logger log = Logger.getLogger(FileUpload.class.getName());

	
    // Base upload directory
    private static final String BASE_UPLOAD_DIR = "uploads";

    // File size limits
    private static final long MAX_IMAGE_SIZE = 5 * 1024 * 1024; // 5MB
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final int MAX_FILENAME_LENGTH = 255;

    // Thumbnail settings
    private static final int THUMB_WIDTH = 300;
    private static final int THUMB_HEIGHT = 300;

    // Allowed MIME types for images
    private static final Set<String> IMAGE_MIME_TYPES = Set.of(
            "image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"
    );

    // Allowed MIME types for documents
    private static final Set<String> DOCUMENT_MIME_TYPES = Set.of(
            "application/pdf",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document", // .docx
            "application/vnd.ms-excel",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", // .xlsx
            "text/plain",
            "text/csv"
    );

    // Magic bytes for validation
    private static final Map<String, byte[][]> MAGIC_BYTES = Map.of(
            "jpg", new byte[][]{{(byte)0xFF, (byte)0xD8, (byte)0xFF}},
            "png", new byte[][]{{(byte)0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A}},
            "gif", new byte[][]{{0x47, 0x49, 0x46, 0x38, 0x37, 0x61}, {0x47, 0x49, 0x46, 0x38, 0x39, 0x61}},
            "webp", new byte[][]{{0x52, 0x49, 0x46, 0x46}},
            "pdf", new byte[][]{{0x25, 0x50, 0x44, 0x46}}
    );

    private static final AtomicInteger counter = new AtomicInteger(0);

    /**
     * Custom Exception
     */
    public static class FileUploadException extends IOException {
        public enum ErrorType {
            FILE_TOO_LARGE, INVALID_TYPE, SECURITY_VIOLATION,
            INVALID_FORMAT, IO_ERROR, EMPTY_FILE
        }

        private final ErrorType type;

        public FileUploadException(ErrorType type, String message) {
            super(message);
            this.type = type;
        }

        public ErrorType getType() { return type; }
    }

    /**
     * ========================================
     * UPLOAD IMAGE - Dành cho ảnh, có tạo thumbnail
     * ========================================
     * @param part File part từ request
     * @param folderName Tên folder con (VD: "books", "users", "products")
     * @param appRealPath Đường dẫn webapp root
     * @param createThumbnail true nếu muốn tạo thumbnail
     * @return Map với key "original" và "thumbnail" (nếu có)
     */
    public static Map<String, String> uploadImage(Part part, String folderName,
                                                  String appRealPath, boolean createThumbnail)
            throws FileUploadException {

        // Validate part
        validatePart(part, true, MAX_IMAGE_SIZE);

        // Validate image MIME type
        String contentType = part.getContentType();
        if (!IMAGE_MIME_TYPES.contains(contentType.toLowerCase())) {
            throw new FileUploadException(
                    FileUploadException.ErrorType.INVALID_TYPE,
                    "Chỉ chấp nhận file ảnh: JPG, PNG, GIF, WebP"
            );
        }

        // Sanitize và tạo unique filename
        String fileName = sanitizeFileName(getSubmittedFileName(part));
        fileName = uniqueName(fileName);

        // Validate magic bytes (chống fake extension)
        try (InputStream is = part.getInputStream()) {
            String ext = getExtension(fileName);
            if (!validateMagicBytes(is, ext)) {
                throw new FileUploadException(
                        FileUploadException.ErrorType.INVALID_FORMAT,
                        "File không đúng định dạng ảnh"
                );
            }
        } catch (IOException e) {
            log.warning("Cannot validate magic bytes: " + e.getMessage());
        }

        // Tạo đường dẫn: uploads/{folderName}/
        String uploadDir = BASE_UPLOAD_DIR + "/" + sanitizeFolderName(folderName);
        Path uploadRoot = Path.of(appRealPath, uploadDir);

        Map<String, String> result = new HashMap<>();

        try {
            // Tạo thư mục nếu chưa có
            Files.createDirectories(uploadRoot);

            // Lưu file gốc
            Path dest = uploadRoot.resolve(fileName);
            try (InputStream in = part.getInputStream()) {
                Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
            }

            String originalPath = uploadDir + "/" + fileName;
            result.put("original", originalPath);
            log.info("Image uploaded: " + originalPath);

            // Tạo thumbnail nếu cần
            if (createThumbnail) {
                try {
                    String thumbPath = createThumbnail(originalPath, folderName, appRealPath);
                    result.put("thumbnail", thumbPath);
                } catch (IOException e) {
                    log.warning("Failed to create thumbnail: " + e.getMessage());
                    // Không throw, vì file gốc đã lưu thành công
                }
            }

        } catch (IOException e) {
            log.severe("Failed to save image: " + e.getMessage());
            throw new FileUploadException(
                    FileUploadException.ErrorType.IO_ERROR,
                    "Không thể lưu ảnh: " + e.getMessage()
            );
        }

        return result;
    }

    /**
     * Overload: uploadImage mặc định có thumbnail
     */
    public static Map<String, String> uploadImage(Part part, String folderName, String appRealPath)
            throws FileUploadException {
        return uploadImage(part, folderName, appRealPath, true);
    }

    /**
     * ========================================
     * UPLOAD FILE - Dành cho documents (PDF, DOC, XLS, TXT...)
     * ========================================
     * @param part File part từ request
     * @param folderName Tên folder con (VD: "documents", "contracts", "reports")
     * @param appRealPath Đường dẫn webapp root
     * @return Đường dẫn tương đối của file (VD: uploads/documents/file_xxx.pdf)
     */
    public static String uploadFile(Part part, String folderName, String appRealPath)
            throws FileUploadException {

        // Validate part
        validatePart(part, false, MAX_FILE_SIZE);

        // Validate document MIME type
        String contentType = part.getContentType();
        if (!DOCUMENT_MIME_TYPES.contains(contentType.toLowerCase())) {
            throw new FileUploadException(
                    FileUploadException.ErrorType.INVALID_TYPE,
                    "Chỉ chấp nhận file: PDF, DOC, DOCX, XLS, XLSX, TXT, CSV"
            );
        }

        // Sanitize và tạo unique filename
        String fileName = sanitizeFileName(getSubmittedFileName(part));
        fileName = uniqueName(fileName);

        // Validate magic bytes cho PDF
        String ext = getExtension(fileName);
        if (ext.equalsIgnoreCase("pdf")) {
            try (InputStream is = part.getInputStream()) {
                if (!validateMagicBytes(is, ext)) {
                    throw new FileUploadException(
                            FileUploadException.ErrorType.INVALID_FORMAT,
                            "File PDF không hợp lệ"
                    );
                }
            } catch (IOException e) {
                log.warning("Cannot validate PDF magic bytes: " + e.getMessage());
            }
        }

        // Tạo đường dẫn: uploads/{folderName}/
        String uploadDir = BASE_UPLOAD_DIR + "/" + sanitizeFolderName(folderName);
        Path uploadRoot = Path.of(appRealPath, uploadDir);

        try {
            // Tạo thư mục nếu chưa có
            Files.createDirectories(uploadRoot);

            // Lưu file
            Path dest = uploadRoot.resolve(fileName);
            try (InputStream in = part.getInputStream()) {
                Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
            }

            String filePath = uploadDir + "/" + fileName;
            log.info("File uploaded: " + filePath);
            return filePath;

        } catch (IOException e) {
            log.severe("Failed to save file: " + e.getMessage());
            throw new FileUploadException(
                    FileUploadException.ErrorType.IO_ERROR,
                    "Không thể lưu file: " + e.getMessage()
            );
        }
    }

    /**
     * ========================================
     * HELPER METHODS
     * ========================================
     */

    /**
     * Validate Part đầy đủ
     */
    private static void validatePart(Part part, boolean isImage, long maxSize)
            throws FileUploadException {

        // Check null/empty
        if (part == null || part.getSize() == 0) {
            throw new FileUploadException(
                    FileUploadException.ErrorType.EMPTY_FILE,
                    "File không được để trống"
            );
        }

        // Validate size
        if (part.getSize() > maxSize) {
            throw new FileUploadException(
                    FileUploadException.ErrorType.FILE_TOO_LARGE,
                    String.format("File vượt quá kích thước cho phép: %.2f MB",
                            maxSize / 1024.0 / 1024.0)
            );
        }

        // Validate filename
        String fileName = sanitizeFileName(getSubmittedFileName(part));
        if (fileName == null || fileName.isBlank()) {
            throw new FileUploadException(
                    FileUploadException.ErrorType.INVALID_FORMAT,
                    "Tên file không hợp lệ"
            );
        }

        // Validate path traversal
        validateSecurePath(fileName);
    }

    /**
     * Lấy tên file từ Part
     */
    private static String getSubmittedFileName(Part part) {
        return part.getSubmittedFileName();
    }

    /**
     * Sanitize filename
     */
    private static String sanitizeFileName(String name) {
        if (name == null || name.isBlank()) return null;

        // Loại bỏ path
        name = name.replace("\\", "/");
        int lastSlash = name.lastIndexOf('/');
        if (lastSlash >= 0) {
            name = name.substring(lastSlash + 1);
        }

        // Chỉ giữ ký tự an toàn
        name = name.replaceAll("[^a-zA-Z0-9._-]", "_");

        // Giới hạn độ dài
        if (name.length() > MAX_FILENAME_LENGTH) {
            String ext = getExtension(name);
            int maxBase = MAX_FILENAME_LENGTH - ext.length() - 1;
            name = name.substring(0, maxBase) + "." + ext;
        }

        return name;
    }

    /**
     * Sanitize folder name
     */
    private static String sanitizeFolderName(String folderName) {
        if (folderName == null || folderName.isBlank()) {
            return "general";
        }
        // Chỉ cho phép chữ, số, gạch ngang, gạch dưới
        return folderName.replaceAll("[^a-zA-Z0-9_-]", "_").toLowerCase();
    }

    /**
     * Validate path traversal
     */
    private static void validateSecurePath(String fileName) throws FileUploadException {
        if (fileName.contains("..") ||
                fileName.contains("/") ||
                fileName.contains("\\") ||
                fileName.startsWith(".")) {
            throw new FileUploadException(
                    FileUploadException.ErrorType.SECURITY_VIOLATION,
                    "Tên file không hợp lệ (path traversal detected)"
            );
        }
    }

    /**
     * Tạo unique name
     */
    private static String uniqueName(String base) {
        String ts = LocalDateTime.now().format(
                DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss_SSS")
        );
        int count = counter.incrementAndGet() % 1000;

        int dot = base.lastIndexOf('.');
        if (dot > 0) {
            return base.substring(0, dot) + "_" + ts + "_" + count + base.substring(dot);
        }
        return base + "_" + ts + "_" + count;
    }

    /**
     * Lấy extension
     */
    private static String getExtension(String fileName) {
        int dot = fileName.lastIndexOf('.');
        return dot > 0 ? fileName.substring(dot + 1) : "";
    }

    /**
     * Validate magic bytes
     */
    private static boolean validateMagicBytes(InputStream is, String extension) throws IOException {
        byte[][] signatures = MAGIC_BYTES.get(extension.toLowerCase());
        if (signatures == null) return true; // Không có signature thì bỏ qua

        byte[] header = new byte[12];
        is.mark(12);
        int read = is.read(header);
        is.reset();

        if (read < 1) return false;

        for (byte[] signature : signatures) {
            boolean match = true;
            for (int i = 0; i < signature.length && i < read; i++) {
                if (header[i] != signature[i]) {
                    match = false;
                    break;
                }
            }
            if (match) return true;
        }

        return false;
    }

    /**
     * Tạo thumbnail từ ảnh gốc
     */
    private static String createThumbnail(String originalPath, String folderName, String appRealPath)
            throws IOException {

        Path original = Path.of(appRealPath, originalPath);
        BufferedImage img = ImageIO.read(original.toFile());

        if (img == null) {
            throw new IOException("Cannot read image");
        }

        // Calculate dimensions (giữ tỷ lệ)
        int width = img.getWidth();
        int height = img.getHeight();
        double ratio = (double) width / height;

        int thumbW = THUMB_WIDTH;
        int thumbH = THUMB_HEIGHT;

        if (ratio > 1) {
            thumbH = (int) (THUMB_WIDTH / ratio);
        } else {
            thumbW = (int) (THUMB_HEIGHT * ratio);
        }

        // Resize image
        BufferedImage thumb = new BufferedImage(thumbW, thumbH, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = thumb.createGraphics();
        g.drawImage(img.getScaledInstance(thumbW, thumbH, BufferedImage.SCALE_SMOOTH),
                0, 0, null);
        g.dispose();

        // Save thumbnail: uploads/{folderName}/thumbs/
        String thumbDir = BASE_UPLOAD_DIR + "/" + sanitizeFolderName(folderName) + "/thumbs";
        Path thumbRoot = Path.of(appRealPath, thumbDir);
        Files.createDirectories(thumbRoot);

        String fileName = Path.of(originalPath).getFileName().toString();
        Path thumbPath = thumbRoot.resolve(fileName);

        String ext = getExtension(fileName);
        ImageIO.write(thumb, ext.equals("jpg") ? "jpeg" : ext, thumbPath.toFile());

        return thumbDir + "/" + fileName;
    }

    /**
     * ========================================
     * PUBLIC UTILITY METHODS
     * ========================================
     */

    /**
     * Xóa file (và thumbnail nếu có)
     */
    public static boolean deleteFile(String relativePath, String appRealPath) {
        if (relativePath == null || relativePath.isBlank()) return false;

        try {
            Path p = Path.of(appRealPath, relativePath);
            boolean deleted = Files.deleteIfExists(p);

            if (deleted) {
                log.info("File deleted: " + relativePath);

                // Xóa thumbnail nếu có
                if (relativePath.contains(BASE_UPLOAD_DIR)) {
                    String fileName = Path.of(relativePath).getFileName().toString();
                    String folder = extractFolderName(relativePath);
                    if (folder != null) {
                        String thumbPath = BASE_UPLOAD_DIR + "/" + folder + "/thumbs/" + fileName;
                        Files.deleteIfExists(Path.of(appRealPath, thumbPath));
                    }
                }
            }

            return deleted;
        } catch (IOException e) {
            log.warning("Failed to delete: " + relativePath + " - " + e.getMessage());
            return false;
        }
    }

    /**
     * Lấy folder name từ path
     */
    private static String extractFolderName(String relativePath) {
        String[] parts = relativePath.split("/");
        return parts.length >= 2 ? parts[1] : null;
    }

    /**
     * Lấy thông tin file
     */
    public static FileInfo getFileInfo(String relativePath, String appRealPath) throws IOException {
        Path p = Path.of(appRealPath, relativePath);
        if (!Files.exists(p)) {
            throw new FileNotFoundException("File not found: " + relativePath);
        }

        return new FileInfo(
                Path.of(relativePath).getFileName().toString(),
                Files.size(p),
                Files.getLastModifiedTime(p).toMillis(),
                getExtension(relativePath)
        );
    }

    /**
     * FileInfo class
     */
    public static class FileInfo {
        private final String name;
        private final long size;
        private final long lastModified;
        private final String extension;

        public FileInfo(String name, long size, long lastModified, String extension) {
            this.name = name;
            this.size = size;
            this.lastModified = lastModified;
            this.extension = extension;
        }

        public String getName() { return name; }
        public long getSize() { return size; }
        public long getLastModified() { return lastModified; }
        public String getExtension() { return extension; }

        public String getReadableSize() {
            if (size < 1024) return size + " B";
            if (size < 1024 * 1024) return String.format("%.2f KB", size / 1024.0);
            return String.format("%.2f MB", size / 1024.0 / 1024.0);
        }
    }

    /**
     * Convenience helper: upload a single image and return ONLY the relative path of the original image.
     * Use this when you want to store just one string into the database (e.g., "uploads/books/xxx.jpg").
     *
     * @param part        image part from request
     * @param folderName  sub-folder under BASE_UPLOAD_DIR (e.g., "books")
     * @param appRealPath absolute app path (use {@link #safeAppRealPath(jakarta.servlet.ServletContext)} if unsure)
     * @return relative path (e.g., "uploads/books/abc.jpg")
     * @throws FileUploadException on validation or IO errors
     */
    public static String uploadImageReturnPath(Part part, String folderName, String appRealPath)
            throws FileUploadException {
        Map<String, String> map = uploadImage(part, folderName, appRealPath, false);
        // prefer "original"; if for some reason missing, try "thumbnail"
        String path = map.get("original");
        if (path == null || path.isBlank()) path = map.get("thumbnail");
        return path;
    }

    /**
     * Get a safe real path for uploads. If ServletContext.getRealPath("") returns null
     * (e.g., running from a WAR or certain IDE configurations), fall back to the system temp directory.
     */
    public static String safeAppRealPath(jakarta.servlet.ServletContext ctx) {
        String real = null;
        try {
            real = ctx != null ? ctx.getRealPath("") : null;
        } catch (Throwable ignore) { /* ignore */ }
        if (real == null) {
            real = System.getProperty("java.io.tmpdir");
        }
        return real;
    }

}
