package repositoryimpl;

import repository.AdminRepository;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AdminRepositoryImpl implements AdminRepository {

    private final DataSource ds;
	public AdminRepositoryImpl(DataSource ds) {
		this.ds = ds;
	}

    @Override
    public List<Map<String, Object>> getBestSellingFoods() {

        List<Map<String, Object>> bestSelling = new ArrayList<>();

        String sql = "SELECT ofd.food_id, f.name, SUM(ofd.quantity) as total_quantity, SUM(ofd.quantity * ofd.price_at_order) as total_revenue " +
                "FROM order_foods ofd " +
                "INNER JOIN orders o ON ofd.order_id = o.id " +
                "INNER JOIN foods f ON ofd.food_id = f.id " +
                "WHERE o.status = 'delivered' " +
                "GROUP BY ofd.food_id, f.name " +
                "ORDER BY total_quantity DESC " +
                "LIMIT 10";

        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> foodData = new HashMap<>();
                foodData.put("foodId", rs.getInt("food_id"));
                foodData.put("foodName", rs.getString("name"));
                foodData.put("totalQuantity", rs.getInt("total_quantity"));
                foodData.put("totalRevenue", rs.getDouble("total_revenue"));
                bestSelling.add(foodData);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return bestSelling;
    }
}
