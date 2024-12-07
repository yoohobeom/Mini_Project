<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html>
<head>

<!-- fullcalendar -->
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.15/index.global.min.js"></script>
<!-- 테일윈드CSS -->
<script src="https://cdn.tailwindcss.com"></script>
<!-- 데이지 UI -->
<link href="https://cdn.jsdelivr.net/npm/daisyui@4.12.14/dist/full.min.css" rel="stylesheet" type="text/css" />
<!-- JQuery -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<!-- 폰트어썸 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<!-- calendar css -->
<link rel="stylesheet" href="/resource/calendar.css" />

<title>유저 메인</title>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        var calendarEl = document.getElementById("calendar");
        var calendar = new FullCalendar.Calendar(calendarEl, {
            locale: 'ko',
            headerToolbar: {
                right: 'today',
                center: 'prev title next',
                left: ''
            },
            initialView: "dayGridMonth",
            height: '500px', // 부모 컨테이너의 높이에 맞게 조정
            contentHeight: '50px', // 콘텐츠 높이도 자동 조정
            aspectRatio: 1.5, // 가로 세로 비율을 조정
            selectable: true, // 날짜 선택가능
//             navLinks: true, // 달력 일자 선택가능
            validRange: {
                start: function(currentDate) {
                    // 현재 날짜의 첫 번째 날을 범위의 시작으로 설정
                    return currentDate.startOf('month');
                },
                end: function(currentDate) {
                    // 현재 날짜의 마지막 날을 범위의 끝으로 설정
                    return currentDate.endOf('month');
                }
            }, // 달력 일자 선택가능
            displayEventTime: true, // 달력 주력 등 화면에서 시작 시간 표기 여부
            events: function(fetchInfo, successCallback, failureCallback) {
                $.ajax({
                    url: '/api/events/all',
                    method: 'GET',
                    success: function(data) {
                        successCallback(data);
                    },
                    error: function() {
                        failureCallback();
                    }
                });
            },
            dateClick: function(info) {
                loadScheduleDetails(info.dateStr);
            }
        });
        calendar.render();
    });
    function loadScheduleDetails(dateStr) {
        $.ajax({
            url: '/api/events/search',
            method: 'GET',
            data: { start: dateStr, end: dateStr },
            success: function(data) {
                var scheduleDetails = document.getElementById('schedule-details');
                scheduleDetails.innerHTML = '';
                if (data.length > 0) {
                    data.forEach(function(event) {
                        var eventItem = document.createElement('div');
                        eventItem.className = 'event-item';
                        eventItem.innerHTML = '<h4>' + event.title + '</h4><p>' + event.start + '</p>';
                        scheduleDetails.appendChild(eventItem);
                    });
                } else {
                    scheduleDetails.innerHTML = '<p>No events for this date.</p>';
                }
            },
            error: function() {
                alert('Failed to load events for the selected date.');
            }
        });
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

</head>

<body>
	<div class="h-20 flex container mx-auto text-3xl">
		<div><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/">로고</a></div>
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
		<div class="grow"></div>
		<ul class="flex">
<%-- 			<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/">HOME</a></li> --%>
<%-- 			<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/usr/article/list?boardId=1">NOTICE</a></li> --%>
<%-- 			<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/usr/article/list?boardId=2">FREE</a></li> --%>
			<c:if test="${rq.getLoginedMemberId() == -1 }">
				<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/usr/member/join">JOIN</a></li>
				<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/usr/member/login">LOGIN</a></li>
			</c:if>
			<c:if test="${rq.getLoginedMemberId() != -1 }">
<%-- 				<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/usr/member/myPage">MYPAGE</a></li> --%>
				<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/usr/member/doLogout">LOGOUT</a></li>
			</c:if>
<%-- 			<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/usr/home/apiTest1">APITEST1</a></li> --%>
<%-- 			<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/usr/home/apiTest2">APITEST2</a></li> --%>
		</ul>
	</div>

    <div id="calendar-container" class="ml-44 p-4">
        <div id="calendar"></div>
    </div>
    <div id="schedule-details">
        <p>Please select a date to view its schedule.</p>
    </div>

	<section class="mt-8">
	<div class="container mx-auto">
		<div class="w-9/12 mx-auto mb-2 pl-3 text-sm flex justify-between items-end">
			<div>총 : ${articlesCnt }개</div>
			<form>
				<input type="hidden" name="boardId" value="${board.getId() }" />
				<div class="flex">
					<select class="select select-bordered select-sm mr-2" name="searchType">
						<option value="title" <c:if test="${searchType == 'title' }">selected="selected"</c:if>>제목</option>
						<option value="body" <c:if test="${searchType == 'body' }">selected="selected"</c:if>>내용</option>
						<option value="title,body" <c:if test="${searchType == 'title,body' }">selected="selected"</c:if>>제목 + 내용</option>
					</select>
					
					<label class="input input-bordered input-sm flex items-center gap-2 w-60">
					  <input type="text" class="grow" name="searchKeyword" placeholder="검색어를 입력해주세요" maxlength="25" value="${searchKeyword }"/>
					  <svg
					    xmlns="http://www.w3.org/2000/svg"
					    viewBox="0 0 16 16"
					    fill="currentColor"
					    class="h-4 w-4 opacity-70">
					    <path
					      fill-rule="evenodd"
					      d="M9.965 11.026a5 5 0 1 1 1.06-1.06l2.755 2.754a.75.75 0 1 1-1.06 1.06l-2.755-2.754ZM10.5 7a3.5 3.5 0 1 1-7 0 3.5 3.5 0 0 1 7 0Z"
					      clip-rule="evenodd" />
					  </svg>
					</label>
					
					<button class="hidden">검색</button>
				</div>
			</form>
		</div>
		<div class="w-9/12 mx-auto">
			<table class="table table-lg">
				<colgroup>
					<col width="60" />
					<col />
					<col width="60" />
					<col width="200" />
					<col width="40"/>
					<col width="40"/>
				</colgroup>
				<thead>
					<tr>
						<th>번호</th>
						<th>제목</th>
						<th>작성자</th>
						<th>작성일</th>
						<th>조회수</th>
						<th>추천수</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="article" items="${articles }">
						<tr class="hover">
							<td>${article.getId() }</td>
							<td class="link link-hover"><a href="detail?id=${article.getId() }">${article.getTitle() }</a></td>
							<td>${article.getLoginId() }</td>
							<td>${article.getRegDate().substring(2,16) }</td>
							<td>${article.getViews() }</td>
							<td>${article.getLike() }</td>
						</tr>
					</c:forEach>
				</tbody>
			</table>
		</div>
		
		<c:if test="${rq.getLoginedMemberId() != -1 }">
			<div class="w-9/12 mx-auto flex justify-end my-3">
				<a class="btn btn-active btn-sm" href="write">글쓰기</a>
			</div>
		</c:if>
		
		<div class="mt-2 flex justify-center">
			<div class="join">
				<c:set var="path" value="?boardId=${board.getId() }&searchType=${searchType }&searchKeyword=${searchKeyword }" />
			
				<c:if test="${from != 1 }">
					<a class="join-item btn btn-sm" href="${path }&cPage=1"><i class="fa-solid fa-angles-left"></i></a>
					<a class="join-item btn btn-sm" href="${path }&cPage=${from - 1 }"><i class="fa-solid fa-angle-left"></i></a>
				</c:if>
				
				<c:forEach var="i" begin="${from }" end="${end }">
					<a class="join-item btn btn-sm ${cPage == i ? 'btn-active' : '' }" href="${path }&cPage=${i }">${i }</a>
				</c:forEach>
				
				<c:if test="${end != totalPagesCnt }">
					<a class="join-item btn btn-sm" href="${path }&cPage=${end + 1 }"><i class="fa-solid fa-angle-right"></i></a>
					<a class="join-item btn btn-sm" href="${path }&cPage=${totalPagesCnt }"><i class="fa-solid fa-angles-right"></i></a>
				</c:if>
			</div>
		</div>
	</div>
</section>
</body>
</html>
