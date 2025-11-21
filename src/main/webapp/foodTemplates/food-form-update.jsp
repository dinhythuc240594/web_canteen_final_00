<%@page import="model.Food_CategoryDAO"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Cập nhật món ăn</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body class="bg-gray-50">
<jsp:include page="/WEB-INF/jsp/common/header.jsp" />

<% 
    dto.FoodDTO food = (dto.FoodDTO) request.getAttribute("food");
    String previewImg = food != null && food.getImage() != null && !food.getImage().isEmpty() ? food.getImage():"";
    java.util.List<Food_CategoryDAO> categories = (java.util.List<Food_CategoryDAO>) request.getAttribute("categories");
//    if (categories == null) {
//        // Load categories if not provided
//        // This should ideally be done in the controller
//    }
%>

<% if (food != null) { %>
<div class="max-w-5xl mx-auto px-4 py-8">
    <div class="bg-white rounded-lg shadow-md p-6">
        <h2 class="text-2xl font-bold mb-6 text-gray-800">Cập nhật Món Ăn</h2>
        <form id="updateProductForm" enctype="multipart/form-data">
            <input type="hidden" id="id" name="id" value="<%= food.getId() %>" />
            <input type="hidden" id="action" name="action" value="update" />
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <div class="mb-4">
                        <label for="nameFood" class="block text-sm font-medium text-gray-700 mb-2">Tên Món Ăn <span class="text-red-500">*</span></label>
                        <input type="text" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" id="nameFood" name="nameFood" value="<%= food.getNameFood() != null ? food.getNameFood() : "" %>" required>
                    </div>
                    <div class="mb-4">
                        <label for="category_id" class="block text-sm font-medium text-gray-700 mb-2">Danh Mục</label>
                        <select class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" id="category_id" name="category_id">
                            <option value="">-- Chọn danh mục --</option>
                            <% 
                                if (categories != null) {
                                    for(Food_CategoryDAO category: categories) { 
                                        boolean selected = food.getCategory_id() == category.getId();
                            %>
                                <option value="<%= category.getId() %>" <%= selected ? "selected" : "" %>><%= category.getName() %></option>
                            <% 
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <div class="mb-4">
                        <label for="priceFood" class="block text-sm font-medium text-gray-700 mb-2">Giá (VND) <span class="text-red-500">*</span></label>
                        <input type="number" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" id="priceFood" name="priceFood" step="0.01" min="0" value="<%= food.getPriceFood() != null ? food.getPriceFood() : 0 %>" required>
                    </div>
                    <div class="mb-4" style="display: none;">
                        <label for="inventoryFood" class="block text-sm font-medium text-gray-700 mb-2">Tồn Kho <span class="text-red-500">*</span></label>
                        <input type="number" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" id="inventoryFood" name="inventoryFood" min="0" value="<%= food.getInventoryFood() %>" required>
                    </div>
                    <div class="mb-4" style="display: none;">
                        <label for="promotion" class="block text-sm font-medium text-gray-700 mb-2">Khuyến Mãi (%)</label>
                        <input type="number" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" id="promotion" name="promotion" min="0" max="100" value="<%= food.getPromotion() != null ? food.getPromotion() : 0 %>">
                    </div>
                    <div class="mb-4">
                        <label class="flex items-center" style="display: none;">
                            <input type="checkbox" class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500" id="is_available" name="is_available" value="1" checked>
                            <span class="ml-2 text-sm text-gray-700">Còn Hàng</span>
                        </label>
                    </div>
                </div>

                <div>
                    <div class="mb-4">
                        <label for="image" class="block text-sm font-medium text-gray-700 mb-2">Hình Ảnh</label>
                        <div id="imagePreview" class="mb-3 w-full h-48 border-2 border-dashed border-gray-300 rounded-lg flex items-center justify-center overflow-hidden bg-gray-50">
                          <% if(previewImg == "") { %>
                            <img src="${pageContext.request.contextPath}/static/img/food-thumbnail.png" alt="Xem trước ảnh" id="previewImg" class="max-w-full max-h-full object-contain">
                          <% } else { %>
                            <img src="<%= previewImg  %>" alt="Xem trước ảnh" id="previewImg" class="max-w-full max-h-full object-contain">
                            <% } %>
                          </div>
                        <input type="file" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" id="image" name="image" accept="image/*">
                        <p class="text-xs text-gray-500 mt-1">Để trống nếu không muốn thay đổi ảnh</p>
                    </div>
                    <div class="mb-4">
                        <label for="description" class="block text-sm font-medium text-gray-700 mb-2">Mô Tả Món Ăn</label>
                        <textarea class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" id="description" name="description" rows="8"><%= food.getDescription() != null ? food.getDescription() : "" %></textarea>
                    </div>
                </div>
            </div>

            <div class="flex gap-3 mt-4">
                <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition">
                    Cập nhật
                </button>
                <a href="foods?action=list" class="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600 transition inline-block">
                    Quay lại
                </a>
            </div>
            <div id="responseMessage" class="mt-3"></div>
        </form>
    </div>
</div>
<% } else { %>
<div class="max-w-5xl mx-auto px-4 py-8">
    <div class="bg-white rounded-lg shadow-md p-6">
        <p class="text-red-600">Không tìm thấy món ăn để cập nhật.</p>
        <a href="foods?action=list" class="text-blue-600 hover:underline mt-4 inline-block">Quay lại danh sách</a>
    </div>
</div>
<% } %>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />

<script>
CKEDITOR.replace('description', {
    toolbar: [
      { name: 'document', items: [ 'Source', '-', 'Preview' ] },
      { name: 'clipboard', items: [ 'Cut', 'Copy', 'Paste', '-', 'Undo', 'Redo' ] },
      { name: 'styles', items: [ 'Format', 'Font', 'FontSize' ] },
      { name: 'colors', items: [ 'TextColor', 'BGColor' ] },
      { name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', '-', 'RemoveFormat' ] },
      { name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight' ] },
      { name: 'insert', items: [ 'Image', 'Table', 'Link', 'Unlink' ] }
    ],
    contentsCss: [
      'https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css',
      'body { font-family: "Roboto", "Helvetica Neue", Arial, sans-serif; padding: 15px; }'
    ],
    filebrowserUploadUrl: '${pageContext.request.contextPath}/upload-image',
    imageUploadUrl: '${pageContext.request.contextPath}/upload-image',
    
    extraPlugins: 'uploadimage',
    removePlugins: 'imagebase64, elementspath',
    height: 300,
    resize_enabled: false,
    image2_alignClasses: ['image-align-left', 'image-align-center', 'image-align-right'],
});

$(document).ready(function() {
	
	$('#image').on('change', function() {
        if (this.files && this.files[0]) {
            var reader = new FileReader();

            reader.onload = function(e) {
                $('#previewImg').attr('src', e.target.result).show();
            };

            reader.readAsDataURL(this.files[0]);
        } else {
            $('#previewImg').attr('src', "<%= previewImg %>");
        }
    });
	
    $('#updateProductForm').on('submit', function(e) {
        e.preventDefault();

        var formData = new FormData(this);

        if (!formData.has('is_available')) {
            formData.append('is_available', '0');
        }

        $.ajax({
            url: 'foods?action=update',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            dataType: 'json',

            beforeSend: function() {
                $('#responseMessage').html('<div class="bg-blue-100 border border-blue-400 text-blue-700 px-4 py-3 rounded mb-4">Đang cập nhật món ăn...</div>');
            },
            success: function(response) {
            	if (response.success) {
                    $('#responseMessage').html('<div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">' + response.message + '</div>');
                    setTimeout(function() {
                        window.location.href = 'foods?action=list';
                    }, 1500);
                } else {
                    $('#responseMessage').html('<div class="bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded mb-4">Lỗi: ' + response.message + '</div>');
                }
            },
            error: function(jqXHR, textStatus, errorThrown) {
                console.log(jqXHR.responseText);
                $('#responseMessage').html('<div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">Đã xảy ra lỗi khi gửi dữ liệu. Vui lòng thử lại.</div>');
            }
        });
    });
});
</script>
</body>
</html>
