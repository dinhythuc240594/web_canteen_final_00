package repositoryimpl;

import java.sql.Connection;
import java.sql.Date;
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
                int category_id = rs.getInt("category_id");
                double promotion = rs.getDouble("promotion");
                int stall_id = rs.getInt("stall_id");

                FoodDAO foodDAO = new FoodDAO(idFood, nameFood, priceFood, inventoryFood);
                foodDAO.setImage(imageFood);
                foodDAO.setDescription(descriptionFood);
                foodDAO.setCategory_id(category_id);
                foundFood = FoodDTO.toDto(foodDAO, promotion, stall_id);
                break;
            }

        } catch (Exception e) {
        	System.err.println("Lỗi findById: " + e.getMessage());
        }
        return foundFood;
	}

	@Override
	public boolean create(String nameFood, double priceFood, int inventoryFood, int stallId, Integer categoryId, String image, String description, Double promotion, Boolean isAvailable) {
        String sql = "INSERT INTO foods (name, price, inventory, stall_id, category_id, image, description, promotion, is_available) VALUES (?,?,?,?,?,?,?,?,?)";
        try (
        	Connection conn = ds.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);) {
            ps.setString(1, nameFood);
            ps.setDouble(2, priceFood);
            ps.setInt(3, inventoryFood);
            ps.setInt(4, stallId);
            if (categoryId != null && categoryId > 0) {
                ps.setInt(5, categoryId);
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            ps.setString(6, image);
            ps.setString(7, description);
            if (promotion != null) {
                ps.setDouble(8, promotion);
            } else {
                ps.setDouble(8, 0.0);
            }
            ps.setBoolean(9, isAvailable != null ? isAvailable : true);
            ps.executeUpdate();
            return true;
	    } catch (Exception e) {
	    	System.err.println("Lỗi create: " + e.getMessage());
	    	e.printStackTrace();
	    	return false;
	    }
	}

	@Override
	public boolean update(int id, String nameFood, double priceFood, int inventoryFood, Integer categoryId, String image, String description, Double promotion, Boolean isAvailable) {
        // Build dynamic SQL based on which fields are provided
        StringBuilder sql = new StringBuilder("UPDATE foods SET name = ?, price = ?, inventory = ?");
        List<Object> params = new ArrayList<>();
        params.add(nameFood);
        params.add(priceFood);
        params.add(inventoryFood);
        
        int paramIndex = 4;
        
        if (categoryId != null) {
            sql.append(", category_id = ?");
            params.add(categoryId);
            paramIndex++;
        }
        
        if (image != null && !image.trim().isEmpty()) {
            sql.append(", image = ?");
            params.add(image);
            paramIndex++;
        }
        
        if (description != null) {
            sql.append(", description = ?");
            params.add(description);
            paramIndex++;
        }
        
        if (promotion != null) {
            sql.append(", promotion = ?");
            params.add(promotion);
            paramIndex++;
        }
        
        if (isAvailable != null) {
            sql.append(", is_available = ?");
            params.add(isAvailable);
            paramIndex++;
        }
        
        sql.append(" WHERE id = ?");
        params.add(id);
        
        try (
      	Connection conn = ds.getConnection();
          PreparedStatement ps = conn.prepareStatement(sql.toString());) {

          for (int i = 0; i < params.size(); i++) {
              Object param = params.get(i);
              if (param instanceof String) {
                  ps.setString(i + 1, (String) param);
              } else if (param instanceof Integer) {
                  ps.setInt(i + 1, (Integer) param);
              } else if (param instanceof Double) {
                  ps.setDouble(i + 1, (Double) param);
              } else if (param instanceof Boolean) {
                  ps.setBoolean(i + 1, (Boolean) param);
              }
          }
          
          ps.executeUpdate();
          return true;
	  } catch (Exception e) {
		  System.err.println("Lỗi update: " + e.getMessage());
		  e.printStackTrace();
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
        Integer categoryId = pageRequest.getCategoryId();
        
        String sql = "SELECT id, name, price, inventory, promotion, stall_id, category_id, image FROM foods ";
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
        
        if(categoryId != null && categoryId > 0) {
        	conditions.add("category_id = ?");
        	params.add(categoryId);
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
                int category_id = rs.getInt("category_id");
                String image = rs.getString("image");

                FoodDAO foodDAO = new FoodDAO(id, name, price, inventory);
                foodDAO.setCategory_id(category_id);
                foodDAO.setImage(image);
                foods.add(FoodDTO.toDto(foodDAO, promotion, stall_id));
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
        return count(keyword, stallId, null);
	}
	
	public int count(String keyword, Integer stallId, Integer categoryId) {
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
        
        if(categoryId != null && categoryId > 0) {
        	conditions.add("category_id = ?");
        	params.add(categoryId);
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

	@Override
	public List<FoodDTO> findByUpdatedDate(Date targetDate, PageRequest pageRequest) {
		List<FoodDTO> foods = new ArrayList<>();
		if (targetDate == null) {
			return foods;
		}
		
		int limit = pageRequest != null ? pageRequest.getPageSize() : 25;
		int offset = pageRequest != null ? pageRequest.getOffset() : 0;
		String sortField = resolveSortField(pageRequest != null ? pageRequest.getSortField() : null);
		String orderField = resolveOrderField(pageRequest != null ? pageRequest.getOrderField() : null);
		Integer stallId = pageRequest != null ? pageRequest.getStallId() : null;
		String keyword = pageRequest != null ? pageRequest.getKeyword() : null;
		
		StringBuilder sql = new StringBuilder("SELECT id, name, price, inventory, promotion, stall_id, category_id, image FROM foods WHERE DATE(updated_at) = ?");
		List<Object> params = new ArrayList<>();
		params.add(targetDate);
		
		if (stallId != null && stallId > 0) {
			sql.append(" AND stall_id = ?");
			params.add(stallId);
		}
		
		if (keyword != null && !keyword.trim().isEmpty()) {
			sql.append(" AND (name LIKE ? OR CAST(price AS CHAR) LIKE ?)");
			String likeKeyword = "%" + keyword.trim() + "%";
			params.add(likeKeyword);
			params.add(likeKeyword);
		}
		
		sql.append(" ORDER BY ").append(sortField).append(" ").append(orderField);
		sql.append(" LIMIT ? OFFSET ?");
		params.add(limit);
		params.add(offset);
		
		try (Connection conn = ds.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql.toString())) {
			
			for (int i = 0; i < params.size(); i++) {
				Object param = params.get(i);
				if (param instanceof String) {
					ps.setString(i + 1, (String) param);
				} else if (param instanceof Integer) {
					ps.setInt(i + 1, (Integer) param);
				} else if (param instanceof Double) {
					ps.setDouble(i + 1, (Double) param);
				} else if (param instanceof Boolean) {
					ps.setBoolean(i + 1, (Boolean) param);
				} else if (param instanceof Date) {
					ps.setDate(i + 1, (Date) param);
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
				int category_id = rs.getInt("category_id");
				String image = rs.getString("image");
				
				FoodDAO foodDAO = new FoodDAO(id, name, price, inventory);
				foodDAO.setCategory_id(category_id);
				foodDAO.setImage(image);
				foods.add(FoodDTO.toDto(foodDAO, promotion, stall_id));
			}
		} catch (Exception e) {
			System.err.println("Lỗi findByUpdatedDate: " + e.getMessage());
		}
		
		return foods;
	}
	
	@Override
	public int countByUpdatedDate(Date targetDate, PageRequest pageRequest) {
		if (targetDate == null) {
			return 0;
		}
		
		Integer stallId = pageRequest != null ? pageRequest.getStallId() : null;
		String keyword = pageRequest != null ? pageRequest.getKeyword() : null;
		
		StringBuilder sql = new StringBuilder("SELECT COUNT(1) FROM foods WHERE DATE(updated_at) = ?");
		List<Object> params = new ArrayList<>();
		params.add(targetDate);
		
		if (stallId != null && stallId > 0) {
			sql.append(" AND stall_id = ?");
			params.add(stallId);
		}
		
		if (keyword != null && !keyword.trim().isEmpty()) {
			sql.append(" AND (name LIKE ? OR CAST(price AS CHAR) LIKE ?)");
			String likeKeyword = "%" + keyword.trim() + "%";
			params.add(likeKeyword);
			params.add(likeKeyword);
		}
		
		try (Connection conn = ds.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql.toString())) {
			
			for (int i = 0; i < params.size(); i++) {
				Object param = params.get(i);
				if (param instanceof String) {
					ps.setString(i + 1, (String) param);
				} else if (param instanceof Integer) {
					ps.setInt(i + 1, (Integer) param);
				} else if (param instanceof Double) {
					ps.setDouble(i + 1, (Double) param);
				} else if (param instanceof Boolean) {
					ps.setBoolean(i + 1, (Boolean) param);
				} else if (param instanceof Date) {
					ps.setDate(i + 1, (Date) param);
				}
			}
			
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				return rs.getInt(1);
			}
		} catch (Exception e) {
			System.err.println("Lỗi countByUpdatedDate: " + e.getMessage());
		}
		
		return 0;
	}
	
	private String resolveSortField(String sortField) {
		if (sortField == null || sortField.isBlank()) {
			return "name";
		}
		return switch (sortField) {
			case "price", "updated_at", "name" -> sortField;
			default -> "name";
		};
	}
	
	private String resolveOrderField(String orderField) {
		if ("DESC".equalsIgnoreCase(orderField)) {
			return "DESC";
		}
		return "ASC";
	}
}
