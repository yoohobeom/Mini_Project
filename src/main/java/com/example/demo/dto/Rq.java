package com.example.demo.dto;

import java.io.IOException;

import com.example.demo.util.Util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.Getter;

public class Rq {
	
	@Getter
	private int loginedMemberId;
	
	@Getter
	private String loginedMemberName;
	
	private HttpServletResponse resp;
	private HttpSession session;

	
	public Rq(HttpServletRequest req, HttpServletResponse resp) {
		this.session = req.getSession();
		
		// 로그인된 사용사 id 가져오기
		int loginedMemberId = -1;
		
		if (this.session.getAttribute("loginedMemberId") != null) {
			loginedMemberId = (int) this.session.getAttribute("loginedMemberId");
		}
		
		this.loginedMemberId = loginedMemberId;
		
        // 로그인된 사용자 이름 가져오기
        String loginedMemberName = null;
        
        if (this.session.getAttribute("loginedMemberName") != null) {
        	loginedMemberName = (String) this.session.getAttribute("loginedMemberName");
        }
        
        this.loginedMemberName = loginedMemberName;
		
		this.resp = resp;
	}
	
	

	public void jsPrintReplace(String msg, String uri) {
		resp.setContentType("text/html; charset=UTF-8;");
		
		try {
			resp.getWriter().append(Util.jsReturn(msg, uri));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void login(int loginedMemberId, String loginedMemberName) {
		this.session.setAttribute("loginedMemberId", loginedMemberId);
		this.session.setAttribute("loginedMemberName", loginedMemberName);
	}

	public void logout() {
		this.session.removeAttribute("loginedMemberId");
		this.session.removeAttribute("loginedMemberName");
	}
}