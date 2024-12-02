<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>

<c:set var="pageTitle" value="회원가입" />

<!DOCTYPE html>

<html class= "max-h-full" data-theme="light">

<head>
<meta charset="UTF-8">
<title>${pageTitle }</title>
<!-- 테일윈드CSS -->
<script src="https://cdn.tailwindcss.com"></script>
<!-- 데이지 UI -->
<link href="https://cdn.jsdelivr.net/npm/daisyui@4.12.14/dist/full.min.css" rel="stylesheet" type="text/css" />
<!-- JQuery -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<!-- 폰트어썸 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
<!-- common css -->
<link rel="stylesheet" href="/resource/common.css" />
</head>

<body>

<script>
	let validLoginId = null;

	const joinForm_onSubmit = function(form) {
		form.loginId.value = form.loginId.value.trim();
		form.loginPw.value = form.loginPw.value.trim();
		form.pwChk.value = form.pwChk.value.trim();
		form.name.value = form.name.value.trim();
		
		if (form.loginId.value.length == 0) {
			alert('아이디를 입력해주세요');
			form.loginId.focus();
			return;
		}
		
		if (form.loginId.value != validLoginId) {
			alert('[ ' + form.loginId.value + ' ] 은(는) 사용할 수 없는 아이디입니다');
			form.loginId.value = '';
			form.loginId.focus();
			return;
		}
		
		if (form.loginPw.value.length == 0) {
			alert('비밀번호를 입력해주세요');
			form.loginPw.focus();
			return;
		}
		
		if (form.name.value.length == 0) {
			alert('이름을 입력해주세요');
			form.name.focus();
			return;
		}
		
		if (form.loginPw.value != form.pwChk.value) {
			alert('비밀번호가 일치하지 않습니다');
			form.loginPw.value = '';
			form.pwChk.value = '';
			form.loginPw.focus();
			return;
		}
		
		form.submit();
	}
	
	const loginIdDupChk = function(el) {
		el.value = el.value.trim();
		
		let loginIdDupChkMsg = $('#loginIdDupChkMsg');
		
		if (el.value.length == 0) {
			loginIdDupChkMsg.removeClass('text-green-500');
			loginIdDupChkMsg.addClass('text-red-500');
			loginIdDupChkMsg.html(`<span>아이디는 필수 입력 정보입니다</span>`);
			return;
		}
		
		$.ajax({
			url : '/usr/member/loginIdDupChk',
			type : 'GET',
			data : {
				loginId : el.value
			},
			dataType : 'json',
			success : function(data) {
				if (data.success) {
					loginIdDupChkMsg.removeClass('text-red-500');
					loginIdDupChkMsg.addClass('text-green-500');
					loginIdDupChkMsg.html(`<span>\${data.resultMsg }</span>`);
					validLoginId = el.value;
				} else {
					loginIdDupChkMsg.removeClass('text-green-500');
					loginIdDupChkMsg.addClass('text-red-500');
					loginIdDupChkMsg.html(`<span>\${data.resultMsg }</span>`);
					validLoginId = null;
				}
			},
			error : function(xhr, status, error) {
				console.log(error);
			}
		})
	}
</script>

<div class="flex items-center justify-center h-screen bg-gray-100">
    <div class="p-6 bg-white rounded-lg shadow-lg w-96">
        <h2 class="text-2xl font-bold text-center mb-6">회원가입</h2>
        
        <form class="space-y-4" action="doJoin" method="post" onsubmit="joinForm_onSubmit(this); return false;">
            <div class="form-control">
                <label class="label">
                    <span class="label-text">아이디</span>
                </label>
                <input type="text" name="loginId" placeholder="아이디를 입력하세요" class="input input-bordered w-full" onblur="loginIdDupChk(this);">
                <div id="loginIdDupChkMsg" class="mt-2 text-sm h-5 w-96"></div>
            </div>
            <div class="form-control">
                <label class="label">
                    <span class="label-text">비밀번호</span>
                </label>
                <input type="password" name="loginPw" placeholder="비밀번호를 입력하세요" class="input input-bordered w-full">
            </div>
            <div class="form-control">
                <label class="label">
                    <span class="label-text">비밀번호 확인</span>
                </label>
                <input type="password" name="pwChk" placeholder="비밀번호를 입력하세요" class="input input-bordered w-full">
            </div>
            <div class="form-control">
                <label class="label">
                    <span class="label-text">이름</span>
                </label>
                <input type="password" name="name" placeholder="이름을 입력해주세요" class="input input-bordered w-full">
            </div>
            <button class="btn btn-success w-full">회원가입</button>
        </form>
    </div>
</div>

<%@ include file="/WEB-INF/jsp/common/footer.jsp" %>