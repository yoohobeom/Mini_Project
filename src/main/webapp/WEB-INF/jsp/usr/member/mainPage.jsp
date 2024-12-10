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
<!-- 웹소켓 -->
<script src="https://cdn.jsdelivr.net/npm/sockjs-client"></script>
<script src="https://cdn.jsdelivr.net/npm/@stomp/stompjs@7.0.0/bundles/stomp.umd.min.js"></script>
<title>유저 메인</title>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            initCalendar();
            connectWebSocket();
            themeInit();

            // Hide schedule details on outside click
            document.addEventListener("click", function (e) {
                const details = document.getElementById("schedule-details");
                const calendar = document.getElementById("calendar-container");
                if (!details.contains(e.target) && !calendar.contains(e.target)) {
                    details.classList.add("hidden");
                }
            });
        });

        function initCalendar() {
            const calendar = new FullCalendar.Calendar(document.getElementById("calendar"), {
                locale: "ko",
                headerToolbar: { left: "", center: "prev title next", right: "today" },
                initialView: "dayGridMonth",
                height: "500px",
                selectable: true,
                editable: true,
                dayMaxEvents: true,
                moreLinkClick: "popover",
                events: fetchEvents,
                eventClick: showEventDetails,
                select: showScheduleDetails,
            });
            calendar.render();

            function fetchEvents(info, successCallback) {
                $.get("/api/events/search", { start: info.startStr, end: info.endStr }).done(data =>
                    successCallback(data.map(event => ({ ...event, color: event.color })))
                );
            }

            function showEventDetails(info) {
                const event = info.event;
                const details = document.getElementById("schedule-details");
                const content = document.getElementById("schedule-content");

                details.classList.remove("hidden");

                // 종료 시간 처리: 종료 시간이 없는 경우 대체 텍스트 표시
                const endTime = event.end ? event.end.toISOString() : "종료 시간 없음";

                content.innerHTML = `
                    <div>
                        <h4>${event.title}</h4>
                        <p>설명: ${event.extendedProps.description || "설명 없음"}</p>
                        <p>시작: ${event.start.toISOString()}</p>
                        <p>종료: ${endTime}</p>
                    </div>`;
            }

            function showScheduleDetails(info) {
                const details = document.getElementById("schedule-details");
                const content = document.getElementById("schedule-content");

                // 날짜 변환 및 필드 값 설정
                const startValue = formatDate(info.startStr);
                const endValue = info.endStr ? formatDate(info.endStr) : "";

                document.getElementById("event-start").value = startValue;
                document.getElementById("event-end").value = endValue;

                // AJAX로 선택한 날짜의 일정 조회
                $.ajax({
                    url: "/api/events/search",
                    method: "GET",
                    data: { start: info.startStr, end: info.endStr },
                    success: function (data) {
                        details.classList.remove("hidden");
                        content.innerHTML = data.length > 0
                            ? data.map(event => `<p>${event.title}</p>`).join("")
                            : "<p>선택한 날짜에 일정이 없습니다.</p>";
                    },
                    error: function () {
                        alert("일정을 불러오는 데 실패했습니다.");
                    },
                });
            }

            document.getElementById("event-form").addEventListener("submit", function (e) {
                e.preventDefault();
                const newEvent = {
                    title: document.getElementById("event-title").value,
                    start: document.getElementById("event-start").value,
                    end: document.getElementById("event-end").value || null,
                    allDay: false,
                };
                $.post({
                    url: "/api/events/add",
                    contentType: "application/json",
                    data: JSON.stringify(newEvent),
                }).done(() => {
                    calendar.addEvent(newEvent);
                    this.reset();
                });
            });
        }

        function connectWebSocket() {
            const socket = new SockJS("/ws");
            const stompClient = StompJs.Stomp.over(socket);
            stompClient.connect({}, () => {
                stompClient.subscribe("/topic/events", message => {
                    const event = JSON.parse(message.body);
                    console.log(event); // Handle incoming WebSocket event
                });
            });
        }

        function themeInit() {
            const theme = localStorage.getItem("theme") || "light";
            document.documentElement.setAttribute("data-theme", theme);
        }

        function themeSwap() {
            const current = document.documentElement.getAttribute("data-theme");
            const next = current === "light" ? "dark" : "light";
            document.documentElement.setAttribute("data-theme", next);
            localStorage.setItem("theme", next);
        }

        function formatDate(dateString) {
            const date = new Date(dateString);

            // 날짜와 시간을 2자리로 맞춥니다.
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, "0");
            const day = String(date.getDate()).padStart(2, "0");
            const hours = String(date.getHours()).padStart(2, "0");
            const minutes = String(date.getMinutes()).padStart(2, "0");

            return `${year}-${month}-${day}T${hours}:${minutes}`;
        }

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

<!-- 캘린더 -->
<div id="calendar-container" class="ml-44 p-4">
    <div id="calendar"></div>
</div>

<!-- 일정 상세 정보 -->
<div id="schedule-details" class="hidden p-4 ml-44 bg-gray-100 border border-gray-300 rounded">
    <h3 class="text-lg font-bold mb-2">선택한 날짜의 일정</h3>
    <div id="schedule-content">
        <p>날짜를 선택하여 일정을 확인하세요.</p>
    </div>
    
     <h3 class="text-lg font-bold mt-4">새로운 일정 추가</h3>
        <form id="event-form" class="mt-2">
            <label class="block">제목:</label>
            <input type="text" id="event-title" class="input input-bordered w-full mb-2" required>
            
            <label class="block">시작 시간:</label>
            <input type="datetime-local" id="event-start" class="input input-bordered w-full mb-2" required>
            
            <label class="block">종료 시간:</label>
            <input type="datetime-local" id="event-end" class="input input-bordered w-full mb-4">
            
            <button type="submit" class="btn btn-primary w-full">일정 추가</button>
        </form>
</div>

 <!-- WebSocket 메시지 영역 -->
    <div id="messages" class="p-4 ml-44 bg-gray-100 border border-gray-300 rounded mt-4"></div>

<!-- 게시글 리스트 -->
<section class="mt-8">
    <div class="container mx-auto">
        <div class="w-9/12 mx-auto mb-2 pl-3 text-sm flex justify-between items-end">
            <div>총 : ${articlesCnt}개</div>
            <form>
                <input type="hidden" name="boardId" value="${board.getId()}" />
                <div class="flex">
                    <select class="select select-bordered select-sm mr-2" name="searchType">
                        <option value="title" <c:if test="${searchType == 'title'}">selected="selected"</c:if>>제목</option>
                        <option value="body" <c:if test="${searchType == 'body'}">selected="selected"</c:if>>내용</option>
                        <option value="title,body" <c:if test="${searchType == 'title,body'}">selected="selected"</c:if>>제목 + 내용</option>
                    </select>

                    <label class="input input-bordered input-sm flex items-center gap-2 w-60">
                        <input type="text" class="grow" name="searchKeyword" placeholder="검색어를 입력해주세요" maxlength="25" value="${searchKeyword}" />
                    </label>

                    <button class="hidden">검색</button>
                </div>
            </form>
        </div>

        <!-- 게시글 테이블 -->
        <div class="w-9/12 mx-auto">
            <table class="table table-lg">
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
                    <c:forEach var="article" items="${articles}">
                        <tr>
                            <td>${article.id}</td>
                            <td><a href="detail?id=${article.id}">${article.title}</a></td>
                            <td>${article.loginId}</td>
                            <td>${article.regDate.substring(0, 10)}</td>
                            <td>${article.views}</td>
                            <td>${article.like}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</section>
</body>
</html>
