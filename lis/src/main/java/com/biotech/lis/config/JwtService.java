package com.biotech.lis.config;

import java.util.Date;
import java.util.*;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;

//reference used for token generation: https://medium.com/@bubu.tripathy/token-based-authentication-in-spring-boot-applications-6299ca25a7d9

@Service
public class JwtService {

    @Value("${jwt.secret-key}")
    private String secretKey;

    private long expirationMs = 1800000; //adjust according to client's preference 30 mins right now
    private SecretKey codedKey;

    public void getSignInKey() {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        this.codedKey = Keys.hmacShaKeyFor(keyBytes);
    }

    //generates user token
    public String generateToken(Long userId) {
        getSignInKey();
        return Jwts.builder()
                   .subject(userId.toString())
                   .issuedAt(new Date())
                   .expiration(new Date(System.currentTimeMillis() + expirationMs))
                   .signWith(codedKey)
                   .compact();
    }

    //checks if token is still valid
    public boolean validateToken(String token) {
        try {
            Jwts.parser()
                .verifyWith(codedKey)
                .build()
                .parseSignedClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public String extractId(String token) {
        Claims claims = Jwts.parser()
                            .verifyWith(codedKey)
                            .build()
                            .parseSignedClaims(token)
                            .getPayload();
        return claims.getSubject(); // Extracts the id
    }
}
