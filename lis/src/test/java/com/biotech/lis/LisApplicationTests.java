package com.biotech.lis;

import java.sql.SQLException;
import javax.sql.DataSource;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(classes = UserApplication.class)
class LisApplicationTests {

  @Autowired private DataSource dataSource;

  @Test
  void testConnection() throws SQLException {
    try (var connection = dataSource.getConnection()) {
      System.out.println("Database: " + connection.getMetaData().getDatabaseProductName());
      System.out.println("Connection successful!");
    }
  }
}
