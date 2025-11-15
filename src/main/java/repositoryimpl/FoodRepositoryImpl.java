package repositoryimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import dto.FoodDTO;
import model.FoodDAO;
import model.PageRequest;
import repository.FoodRepository;

public class FoodRepositoryImpl implements FoodRepository{
	private final DataSource ds;
	
	public FoodRepositoryImpl(DataSource ds) {
		this.ds = ds;
	}

	@Override
	public FoodDTO findById(int id) {
        int idFood = id;
        FoodDTO foundFood = null;
        String sql = "SELECT id, name, price, inventory, image, description, category_id, promotion, stall_id FROM foods where id = ?";
        try (
        	Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);) {

            ps.setInt(1, idFood);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {

                String nameFood = rs.getString("name");
                double priceFood = rs.getDouble("price");
                int inventoryFood  = rs.getInt("inventory");
                String imageFood = rs.getString("image");
                String descriptionFood = rs.getString("description");
                double promotion = rs.getDouble("promotion");
                int stall_id = rs.getInt("stall_id");

                foundFood = FoodDTO.toDto(new FoodDAO(idFood, nameFood, priceFood, inventoryFood), promotion, stall_id);
                break;
            }

        } catch (Exception e) {
        	System.err.println("Lỗi findById: " + e.getMessage());
        }
        return foundFood;
	}

	@Override
	public boolean create(String nameFood, double priceFood, int inventoryFood) {
        String sql = "INSERT INTO foods (name, price, inventory) VALUES (?,?,?)";
        try (
        	Connection conn = ds.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);) {
            ps.setString(1, nameFood);
            ps.setDouble(2, priceFood);
            ps.setInt(3, inventoryFood);
            ps.executeUpdate();
            return true;
	    } catch (Exception e) {
	    	System.err.println("Lỗi create: " + e.getMessage());
	    	return false;
	    }
	}

	@Override
	public boolean update(int id, String nameFood, double priceFood, int inventoryFood) {
        String sql = "UPDATE foods SET name = ?, price = ?, inventory = ? WHERE id = ?";
      try (
      	Connection conn = ds.getConnection();
          PreparedStatement ps = conn.prepareStatement(sql);) {

          ps.setString(1, nameFood);
          ps.setDouble(2, priceFood);
          ps.setInt(3, inventoryFood);
          ps.setInt(4, id); 
          ps.executeUpdate();
          return true;
	  } catch (Exception e) {
		  System.err.println("Lỗi update: " + e.getMessage());
		  return false;
	  }
	}

	@Override
	public boolean delete(int id) {
      String sql = "DELETE FROM foods WHERE id = ?";
      try (Connection conn = ds.getConnection();
           PreparedStatement ps = conn.prepareStatement(sql)) {
      	 	ps.setInt(1, id); 
      	 	ps.executeUpdate();
      	 	return true;
		} catch (Exception e) {
			System.err.println("Lỗi delete: " + e.getMessage());
			return false;
      }
	}

	@Override
	public List<FoodDTO> findAll(PageRequest pageRequest) {
        List<FoodDTO> foods = new ArrayList<>();

        int pageSize = pageRequest.getPageSize();
        int offset = pageRequest.getOffset();
        String keyword = pageRequest.getKeyword();
        String sortField = pageRequest.getSortField();
        String orderField = pageRequest.getOrderField();
        Integer stallId = pageRequest.getStallId();
        
        String sql = "SELECT id, name, price, inventory, promotion, stall_id FROM foods ";
        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        
        if(keyword != null && !keyword.trim().isEmpty()) {
        	conditions.add("(name LIKE ? OR CAST(price AS CHAR) LIKE ?)");
        	params.add("%" + keyword + "%");
        	params.add("%" + keyword + "%");
        }
        
        if(stallId != null && stallId > 0) {
        	conditions.add("stall_id = ?");
        	params.add(stallId);
        }
        
        if(!conditions.isEmpty()) {
        	sql += "WHERE " + String.join(" AND ", conditions) + " ";
        }
        
        sql += "ORDER BY " + sortField + " " + orderField + " LIMIT ? OFFSET ?";
        params.add(pageSize);
        params.add(offset);
        
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);) {

        	for(int i = 0; i < params.size(); i++) {
        		Object param = params.get(i);
        		if(param instanceof String) {
        			ps.setString(i + 1, (String) param);
        		} else if(param instanceof Integer) {
        			ps.setInt(i + 1, (Integer) param);
        		}
        	}
        	
        	ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                double price = rs.getDouble("price");
                int inventory = rs.getInt("inventory");
                double promotion = rs.getDouble("promotion");
                int stall_id = rs.getInt("stall_id");

                foods.add(FoodDTO.toDto(new FoodDAO(id, name, price, inventory), promotion, stall_id));
            }
        } catch (Exception e) {
        	System.err.println("Lỗi findAll: " + e.getMessage());
        }
        return foods;
	}

	@Override
	public int count(String keyword) {
        return count(keyword, null);
	}
	
	public int count(String keyword, Integer stallId) {
        String sql = "SELECT COUNT(1) FROM foods";
        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        
        boolean hasKeywords = keyword != null && !keyword.trim().isEmpty();
        
        if (hasKeywords) {
            conditions.add("(name LIKE ? OR CAST(price AS CHAR) LIKE ?)");
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }
        
        if(stallId != null && stallId > 0) {
        	conditions.add("stall_id = ?");
        	params.add(stallId);
        }
        
        if(!conditions.isEmpty()) {
        	sql += " WHERE " + String.join(" AND ", conditions);
        }
        
        int total = 0;
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for(int i = 0; i < params.size(); i++) {
        		Object param = params.get(i);
        		if(param instanceof String) {
        			ps.setString(i + 1, (String) param);
        		} else if(param instanceof Integer) {
        			ps.setInt(i + 1, (Integer) param);
        		}
        	}
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt(1);
            }

        } catch (Exception e) {
        	System.err.println("Lỗi count: " + e.getMessage());
            return -1;
        }
        
        return total;
	}

	@Override
	public List<FoodDTO> newFoods() {
        List<FoodDTO> foods = new ArrayList<>();
        
        String sql = "SELECT id, name, price, inventory, promotion, stall_id, updated_at FROM foods ORDER BY updated_at DESC LIMIT 8";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);) {

        	ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                double price = rs.getDouble("price");
                int inventory = rs.getInt("inventory");
                double promotion = rs.getDouble("promotion");
                int stall_id =  rs.getInt("stall_id");
                foods.add(FoodDTO.toDto(new FoodDAO(id, name, price, inventory), promotion, stall_id));
            }
        } catch (Exception e) {
        	System.err.println("Lỗi newFoods: " + e.getMessage());
        }
        return foods;
	}

	@Override
	public List<FoodDTO> promotionFoods() {
        List<FoodDTO> foods = new ArrayList<>();
        
        String sql = "SELECT id, name, price, inventory, promotion, stall_id FROM foods ORDER BY promotion DESC LIMIT 8";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);) {

        	ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                double price = rs.getDouble("price");
                int inventory = rs.getInt("inventory");
                double promotion = rs.getDouble("promotion");
                int stall_id = rs.getInt("stall_id");
                foods.add(FoodDTO.toDto(new FoodDAO(id, name, price, inventory), promotion, stall_id));
            }
        } catch (Exception e) {
        	System.err.println("Lỗi promotionFoods: " + e.getMessage());
        }
        return foods;
	}
}
