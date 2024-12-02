package com.example.demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.dto.Member;
import com.example.demo.dto.ResultData;
import com.example.demo.dto.Rq;
import com.example.demo.service.MemberService;
import com.example.demo.util.Util;

import jakarta.servlet.http.HttpServletRequest;

@Controller
public class UsrMemberController {
	
	private MemberService memberService;
	
	public UsrMemberController(MemberService memberService) {
		this.memberService = memberService;
	}
	
	@GetMapping("/usr/member/join")
	public String join() {
		return "usr/member/realJoin";
	}
	
	@PostMapping("/usr/member/doJoin")
	@ResponseBody
	public String doJoin(String loginId, String loginPw, String name) {
		memberService.joinMember(loginId, Util.encryptSHA256(loginPw), name);
		
		return Util.jsReturn(String.format("[ %s ] 님이 가입되었습니다", loginId), "login");
	}
	
	@GetMapping("/usr/member/loginIdDupChk")
	@ResponseBody
	public ResultData loginIdDupChk(String loginId) {
		
		Member member = memberService.getMemberByLoginId(loginId);
		
		if (member != null) {
			return ResultData.from("F-1", String.format("[ %s ]은(는) 이미 사용중인 아이디입니다", loginId));
		}
		
		return ResultData.from("S-1", String.format("[ %s ]은(는) 사용가능한 아이디입니다", loginId));
	}
	
	@GetMapping("/usr/member/login")
	public String login() {
		return "usr/member/realLogin";
	}
	
	@PostMapping("/usr/home/doLogin")
	@ResponseBody
	public String doLogin(HttpServletRequest req, String loginId, String loginPw) {
		
		Rq rq = (Rq) req.getAttribute("rq");

		Member member = memberService.getMemberByLoginId(loginId);
		
		if (member == null) {
			return Util.jsReturn(String.format("존재하지 않는 아이디입니다", loginId), null);
		}
		
		if (member.getLoginPw().equals(Util.encryptSHA256(loginPw)) == false) {
			return Util.jsReturn("비밀번호를 확인해주세요", null);
		}
		
		rq.login(member.getId());
		
		return Util.jsReturn(String.format("%s님 환영합니다", member.getName()), "/");
	}
	
	@GetMapping("/usr/member/myPage")
	public String myPage(HttpServletRequest req, Model model) {
		Rq rq = (Rq) req.getAttribute("rq");

		Member member = memberService.getMemberById(rq.getLoginedMemberId());
		
		model.addAttribute("member", member);
		
		return "usr/member/myPage";
	}
	
	@GetMapping("/usr/member/checkPw")
	public String checkPw() {
		return "usr/member/checkPw";
	}
	
	@GetMapping("/usr/member/getMemberById")
	@ResponseBody
	public ResultData<Member> getMemberById(HttpServletRequest req) {
		
		Rq rq = (Rq) req.getAttribute("rq");
		
		Member member = memberService.getMemberById(rq.getLoginedMemberId());
		
		return ResultData.from("S-1", "회원정보 조회", member);
	}
	
	@PostMapping("/usr/member/doCheckPw")
	public String doCheckPw() {
		return "usr/member/modifyPw";
	}
	
	@PostMapping("/usr/member/doModifyPw")
	@ResponseBody
	public String doModifyPw(HttpServletRequest req, String loginPw) {
		Rq rq = (Rq) req.getAttribute("rq");
		
		memberService.modifyPassword(rq.getLoginedMemberId(), Util.encryptSHA256(loginPw));
		
		rq.logout();
		return Util.jsReturn("비밀번호 수정이 완료되었습니다. 다시 로그인 해주세요", "login");
	}
	
	@GetMapping("/usr/member/doLogout")
	@ResponseBody
	public String doLogout(HttpServletRequest req) {
		Rq rq = (Rq) req.getAttribute("rq");
		
		rq.logout();
		
		return Util.jsReturn("정상적으로 로그아웃 되었습니다", "/");
	}
	
	@GetMapping("/usr/member/getLoginId")
	@ResponseBody
	public String getLoginId(HttpServletRequest req) {
		Rq rq = (Rq) req.getAttribute("rq");

		Member member = memberService.getMemberById(rq.getLoginedMemberId());
		
		return member.getLoginId();
	}
}