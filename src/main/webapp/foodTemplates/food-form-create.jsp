<%@page import="model.Food_CategoryDAO"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>New Food</title>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp" />
</head>
<body>

  <% 
		java.util.List<Food_CategoryDAO> categories = (java.util.List<Food_CategoryDAO>) request.getAttribute("categories");
  %>

  <div id="container">

	<div class="container mt-5">
    	<h2 class="mb-4">Tạo Sản Phẩm Mới</h2>
    	<form id="createProductForm" enctype="multipart/form-data">
        	<div class="row">
            	<div class="col-md-6">
                	<div class="mb-3">
                    	<label for="name" class="form-label">Tên Sản Phẩm <span class="text-danger">*</span></label>
                    	<input type="text" class="form-control" id="name" name="name" required>
                	</div>
	                <div class="mb-3">
	                    <label for="category_id" class="form-label">Danh Mục</label>
	                    <select class="form-select" id="category_id" name="category_id">
	                        <% for(Food_CategoryDAO category: categories) { %>
						  		a<option value="<%= category.getId() %>"><%= category.getName() %></option>
						  	<% } %>
	                    </select>
	                </div>
	                <div class="mb-3">
	                    <label for="price" class="form-label">Giá (VND) <span class="text-danger">*</span></label>
	                    <input type="number" class="form-control" id="price" name="price" step="0.01" required>
	                </div>
	                <div class="mb-3">
	                    <label for="inventory" class="form-label">Tồn Kho <span class="text-danger">*</span></label>
	                    <input type="number" class="form-control" id="inventory" name="inventory" required>
	                </div>
	                <div class="mb-3">
	                    <label for="stall_id" class="form-label">Mã Gian Hàng</label>
	                    <input type="text" class="form-control" id="stall_id" name="stall_id">
	                </div>
            	</div>

	            <div class="col-md-6">
	                <div class="mb-3">
	                	<div id="imagePreview" class="mt-2" style="max-width: 200px; max-height: 200px; overflow: hidden; border: 1px solid #ddd; padding: 5px;">
                        	<img src="${pageContext.request.contextPath}/image/food-thumbnail.png" alt="Xem trước ảnh" class="img-fluid">
                    	</div>
	                    <label for="image" class="form-label">Hình Ảnh</label>
	                    <input type="file" class="form-control" id="image" name="image" accept="image/*">
	                </div>
	                <div class="mb-3 form-check">
	                    <input type="checkbox" class="form-check-input" id="is_available" name="is_available" value="1" checked>
	                    <label class="form-check-label" for="is_available">Còn Hàng</label>
	                </div>
	                <div class="mb-3">
	                    <label for="promotion" class="form-label">Khuyến Mãi (%)</label>
	                    <input type="number" class="form-control" id="promotion" name="promotion" min="0" max="100">
	                </div>
	                <div class="mb-3">
	                    <label for="description" class="form-label">Mô Tả Sản Phẩm</label>
	                    <textarea class="form-control" id="description" name="description" rows="5"></textarea>
	                </div>
                </div>
        	</div>

        <button type="submit" class="btn btn-primary">Tạo Sản Phẩm</button>
        <div id="responseMessage" class="mt-3"></div>
    </form>
	<a href="foods?action=list">Go back to Home</a>
    </div>
  </div>

</body>
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
            var reader = new FileReader(); // Tạo một đối tượng FileReader

            reader.onload = function(e) {
                // Khi file đã được đọc xong, cập nhật src của thẻ <img>
                $('#imagePreview img').attr('src', e.target.result).show();
            };

            // Đọc file ảnh như một URL dữ liệu (base64)
            reader.readAsDataURL(this.files[0]);
        } else {
            // Nếu không có file nào được chọn, ẩn ảnh preview
            $('#imagePreview img').attr('src', '#').hide();
        }
    });
	
    $('#createProductForm').on('submit', function(e) {
        e.preventDefault();

        var formData = new FormData(this);

        // Xử lý giá trị checkbox (vì checkbox chỉ gửi đi khi được check)
        if (!formData.has('is_available')) {
            formData.append('is_available', '0');
        }

        // Thực hiện AJAX call
        $.ajax({
            url: 'foods?action=create',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            dataType: 'json',

            beforeSend: function() {
                $('#responseMessage').html('<div class="alert alert-info">Đang tạo sản phẩm...</div>');
            },
            success: function(response) {
            	if (response.success) {
                    $('#responseMessage').html('<div class="alert alert-success">' + response.message + '</div>');
                    $('#createProductForm')[0].reset();

                    $('#imagePreview img').attr('src', '#').hide();
                } else {
                    $('#responseMessage').html('<div class="alert alert-warning">Lỗi: ' + response.message + '</div>');
                }
            },
            error: function(jqXHR, textStatus, errorThrown) {
                console.log(jqXHR.responseText);
                $('#responseMessage').html('<div class="alert alert-danger">Đã xảy ra lỗi khi gửi dữ liệu. Vui lòng thử lại.</div>');
            }
        });
    });
});
</script>
</html>
