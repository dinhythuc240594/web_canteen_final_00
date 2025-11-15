package repositoryimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import model.FoodDAO;
import model.Food_CategoryDAO;
import model.PageRequest;
import repository.Food_CategoryRepository;

public class Food_CategoryRepositoryImpl implements Food_CategoryRepository{

	private final DataSource ds;
	
	public Food_CategoryRepositoryImpl(DataSource ds) {
		this.ds = ds;
	}
	
	@Override
	public List<Food_CategoryDAO> findAll() {
        List<Food_CategoryDAO> categories = new ArrayList<>();

//        int pageSize = pageRequest.getPageSize();
//        int offset = pageRequest.getOffset();
//        String keyword = pageRequest.getKeyword();
//        String sortField = pageRequest.getSortField();
//        String orderField = pageRequest.getOrderField();
        
        String sql = "SELECT id, name, description FROM food_categories ";
//        if(keyword != "") {
//        	sql += "WHERE name LIKE ? ";
//        }
//        sql += "ORDER BY %s %s LIMIT ? OFFSET ?";
//        sql = String.format(sql, sortField, orderField);
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);) {

//        	if(keyword != "") {
//        		String search = "%" + keyword + "%";
//        		ps.setString(1, search);
//        		ps.setInt(2, pageSize);
//        		ps.setInt(3, offset);
//        	} else {
//        		ps.setInt(1, pageSize);
//        		ps.setInt(2, offset);
//        	}
        	
        	ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                String description = rs.getString("description");

                categories.add(new Food_CategoryDAO(id, name, description));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return categories;
	}

	@Override
	public Food_CategoryDAO findById(int id) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public boolean delete(int id) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public int count(String keyword) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public List<Food_CategoryDAO> findAll(PageRequest pageRequest) {
		// TODO Auto-generated method stub
		return null;
	}

}
