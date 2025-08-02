package com.biotech.lis.config;

import java.util.Collections;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

//reference used for token generation: https://medium.com/@bubu.tripathy/token-based-authentication-in-spring-boot-applications-6299ca25a7d9

public class JwtAuthenticationFilter extends OncePerRequestFilter{
    private final JwtService jwtService;

     public JwtAuthenticationFilter(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws ServletException, IOException {
        String path = request.getRequestURI();
        if (path.contains("/user/v1/login") || path.contains("/user/v1/addUser")) {
            chain.doFilter(request, response);
            return;
        }

        String header = request.getHeader("Authorization");
        
        if(header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);
            if(jwtService.validateToken(token)) {
                String username = jwtService.extractId(token);
                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(username, null, Collections.emptyList());

                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        }

        chain.doFilter(request, response);
    }
}
