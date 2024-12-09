<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<!DOCTYPE html>
<c:set var="pageTitle" value="로그인" />
<html data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
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
<!-- GSAP CDN -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
    <style>

    </style>
</head>
<body class="flex items-center justify-center h-screen bg-gray-100">

<script>        
	//	공백 검증
	const loginForm_onSubmit = function(form) {
		form.loginId.value = form.loginId.value.trim();
		form.loginPw.value = form.loginPw.value.trim();
		
		if (form.loginId.value.length == 0) {
			alert('아이디를 입력해주세요');
			form.loginId.focus();
			return;
		}
		
		if (form.loginPw.value.length == 0) {
			alert('비밀번호를 입력해주세요');
			form.loginPw.focus();
			return;
		}
		
		form.submit();
	}
	
	//	테마변경
	function themeApply(themeName) {
		$('html').attr('data-theme', themeName);
	}
	
	function themeSwap() {
		const theme = localStorage.getItem("theme") ?? "light";
		
		let editorTheme = $('.toastui-editor-defaultUI');
		
		if (theme == "light") {
			localStorage.setItem("theme", "dark");
			editorTheme.addClass('toastui-editor-dark');
		} else {
			localStorage.setItem("theme", "light");
			editorTheme.removeClass('toastui-editor-dark');
		}
		
		themeApply(localStorage.getItem("theme"));
	}
	
	function themeInit() {
		
		let swapCheck = $('#swapCheck');
		
		const theme = localStorage.getItem("theme") ?? "light";
		
		if (theme == "light") {
			swapCheck.prop('checked', true);
		} else {
			swapCheck.prop('checked', false);
		}
		
		themeApply(theme);
	}
	
	themeInit();

</script>

    <div class="notebook perspective">
        <!-- Notebook Cover -->
        <div class="cover cursor-pointer">
            <h1 class="text-white font-bold text-2xl">My Notebook</h1>
        </div>

        <!-- Login Form -->
        <div class="login-form">
            <h2 class="text-2xl font-bold text-center mb-6">로그인
		        <label class="swap swap-rotate">
					<!-- this hidden checkbox controls the state -->
					<input id="swapCheck" type="checkbox" onchange="themeSwap();"/>
					<!-- sun icon -->
					<svg
					  class="swap-on h-10 w-10 fill-current"
					  xmlns="http://www.w3.org/2000/svg"
					  viewBox="0 0 24 24">
					  <path
					    d="M21.64,13a1,1,0,0,0-1.05-.14,8.05,8.05,0,0,1-3.37.73A8.15,8.15,0,0,1,9.08,5.49a8.59,8.59,0,0,1,.25-2A1,1,0,0,0,8,2.36,10.14,10.14,0,1,0,22,14.05,1,1,0,0,0,21.64,13Zm-9.5,6.69A8.14,8.14,0,0,1,7.08,5.22v.27A10.15,10.15,0,0,0,17.22,15.63a9.79,9.79,0,0,0,2.1-.22A8.11,8.11,0,0,1,12.14,19.73Z" />
					</svg>
					<!-- moon icon -->
					<svg
					  class="swap-off h-10 w-10 fill-current"
					  xmlns="http://www.w3.org/2000/svg"
					  viewBox="0 0 24 24">
					  <path
					    d="M5.64,17l-.71.71a1,1,0,0,0,0,1.41,1,1,0,0,0,1.41,0l.71-.71A1,1,0,0,0,5.64,17ZM5,12a1,1,0,0,0-1-1H3a1,1,0,0,0,0,2H4A1,1,0,0,0,5,12Zm7-7a1,1,0,0,0,1-1V3a1,1,0,0,0-2,0V4A1,1,0,0,0,12,5ZM5.64,7.05a1,1,0,0,0,.7.29,1,1,0,0,0,.71-.29,1,1,0,0,0,0-1.41l-.71-.71A1,1,0,0,0,4.93,6.34Zm12,.29a1,1,0,0,0,.7-.29l.71-.71a1,1,0,1,0-1.41-1.41L17,5.64a1,1,0,0,0,0,1.41A1,1,0,0,0,17.66,7.34ZM21,11H20a1,1,0,0,0,0,2h1a1,1,0,0,0,0-2Zm-9,8a1,1,0,0,0-1,1v1a1,1,0,0,0,2,0V20A1,1,0,0,0,12,19ZM18.36,17A1,1,0,0,0,17,18.36l.71.71a1,1,0,0,0,1.41,0,1,1,0,0,0,0-1.41ZM12,6.5A5.5,5.5,0,1,0,17.5,12,5.51,5.51,0,0,0,12,6.5Zm0,9A3.5,3.5,0,1,1,15.5,12,3.5,3.5,0,0,1,12,15.5Z" />
					</svg>
				</label>
            </h2>
            <form class="space-y-4" action="doLogin" method="post" onsubmit="loginForm_onSubmit(this); return false;">
                <div class="form-control">
                    <label class="label">
                        <span class="label-text">아이디</span>
                    </label>
                    <input type="text" name="loginId" placeholder="아이디를 입력하세요" class="input input-bordered w-full">
                </div>
                <div class="form-control">
                    <label class="label">
                        <span class="label-text">비밀번호</span>
                    </label>
                    <input type="password" name="loginPw" placeholder="비밀번호를 입력하세요" class="input input-bordered w-full">
                </div>
                <button class="btn btn-success w-full">로그인</button>
            </form>
	        <div class="divider">또는</div>
	        <button class="btn btn-success w-full" onclick="location.href='${pageContext.request.contextPath}/usr/member/join'">회원가입</button>
        </div>
    </div>

    <script>
        document.querySelector('.cover').addEventListener('click', function () {
            const notebook = document.querySelector('.notebook');
            const cover = document.querySelector('.cover');
            const loginForm = document.querySelector('.login-form');

            // Step 1: Open the cover
            gsap.to(cover, {
                rotationY: -180,
                duration: 1,
                transformOrigin: "left center",
                ease: "power2.inOut"
            });

            // Step 2: Expand the notebook to fill the screen
            gsap.to(notebook, {
                width: "100vw",
                height: "100vh",
                x: 0,
                y: 0,
                duration: 1.5,
                delay: 1,
                ease: "power2.inOut",
                onComplete: function () {
                    // Step 3: Show the login form
                    gsap.to(loginForm, {
                        opacity: 1,
                        pointerEvents: "all",
                        duration: 0.8
                    });
                }
            });
        });
    </script>
</body>
</html>