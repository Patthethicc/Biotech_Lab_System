package com.biotech.lis.Entity;
import lombok.Data;

@Data
public class LogInReq {
    private String email;
    private String password;
    private String token;
    private Boolean check;
}
