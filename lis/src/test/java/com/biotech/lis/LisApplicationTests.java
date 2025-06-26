package com.biotech.lis;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.beans.factory.annotation.Autowired;
import javax.sql.DataSource;
import java.sql.SQLException;

@SpringBootTest
class LisApplicationTests {

	//Database Connection Test
	@Autowired
    private DataSource dataSource;

    @Test
    public void testConnection() throws SQLException {
        try (var connection = dataSource.getConnection()) {
            System.out.println("Database: " + connection.getMetaData().getDatabaseProductName());
            System.out.println("Connection successful!");
        }
    }
}
