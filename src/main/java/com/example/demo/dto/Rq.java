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
	
	private HttpServletResponse resp;
	private HttpSession session;
	
	public Rq(HttpServletRequest req, HttpServletResponse resp) {
		this.session = req.getSession();
		
		int loginedMemberId = -1;
		
		if (this.session.getAttribute("loginedMemberId") != null) {
			loginedMemberId = (int) this.session.getAttribute("loginedMemberId");
		}
		
		this.loginedMemberId = loginedMemberId;
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

	public void login(int loginedMemberId) {
		this.session.setAttribute("loginedMemberId", loginedMemberId);
	}

	public void logout() {
		this.session.removeAttribute("loginedMemberId");
	}
}