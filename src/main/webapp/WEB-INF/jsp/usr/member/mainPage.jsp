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
	function initShareFeature() {
	    const shareButton = document.getElementById("share-button");
	    const shareModal = document.getElementById("share-modal");
	    const closeShareButton = document.getElementById("close-share");
	    const confirmShareButton = document.getElementById("confirm-share");
	
	    // 공유 버튼 클릭 시 모달 표시
	    shareButton.addEventListener("click", function () {
	        shareModal.classList.remove("hidden");
	    });
	
	    // 모달 닫기
	    closeShareButton.addEventListener("click", function () {
	        shareModal.classList.add("hidden");
	    });
	
	    // 공유하기 버튼 클릭 시 처리
	    confirmShareButton.addEventListener("click", function () {
	        const eventTitle = document.getElementById("event-title").value;
	        const shareUser = document.getElementById("share-user").value;
	        const permission = document.getElementById("share-permission").value;
	
	        if (!shareUser) {
	            alert("공유 대상을 입력해주세요.");
	            return;
	        }
	
	        // WebSocket을 통해 공유 요청 전송
	        sendShareEvent({
	            action: "share",
	            eventTitle: eventTitle,
	            sharedWith: shareUser,
	            permission: permission,
	        });
	
	        alert(`"${eventTitle}" 일정이 ${shareUser}에게 공유되었습니다.`);
	        shareModal.classList.add("hidden");
	    });
	}

	// WebSocket으로 공유 이벤트 전송
	function sendShareEvent(shareData) {
	    const socket = new SockJS("/ws"); // WebSocket 연결
	    const stompClient = StompJs.Stomp.over(socket); // Stomp 클라이언트 생성
	
	    // WebSocket 연결 및 메시지 전송
	    stompClient.connect({}, function () {
	        console.log("WebSocket Connected");
	
	        stompClient.send(
	            "/app/share-event", // 서버의 WebSocket 핸들러
	            {},
	            JSON.stringify(shareData) // 공유 데이터 전송
	        );
	    }, function (error) {
	        console.error("WebSocket Connection Failed:", error);
	    });
	}

   
	document.addEventListener("DOMContentLoaded", function () {
		sendShareEvent(); // 함수가 선언된 후 호출
		initCalendar();
		connectWebSocket();
		initShareFeature();
		themeInit();
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
			select: handleDateSelect,
		});
			calendar.render();
	
		function fetchEvents(info, successCallback, failureCallback) {
			$.get("/api/events/search", { start: info.startStr, end: info.endStr })
				.done(data => {
					const events = data.map(event => ({
						title: event.title || "제목 없음", // 제목 기본값 설정
						start: event.start,
	                    end: event.end || null, // 종료 시간 없는 경우 처리
						allDay: false, // 필요하면 추가
	                    color: "#3788d8" // 필요하면 색상 추가
					}));
	                    console.log("Processed Events:", events); // 디버깅용
	                      successCallback(events);
				})
				.fail(() => {
					alert("이벤트를 가져오는 데 실패했습니다.");
					failureCallback();
				});
		}
	
	//           function showEventDetails(info) {
	//               const event = info.event;
	//               const details = document.getElementById("schedule-details");
	//               const content = document.getElementById("schedule-content");
	
	//               details.classList.remove("hidden");
	
	//               // 종료 시간 처리: 종료 시간이 없는 경우 대체 텍스트 표시
	//               const endTime = event.end ? event.end.toISOString() : "종료 시간 없음";
	
	//               content.innerHTML = `
	//                   <div>
	//                       <h4>${event.title}</h4>
	//                       <p>설명: ${event.extendedProps.description || "설명 없음"}</p>
	//                       <p>시작: ${event.start.toISOString()}</p>
	//                       <p>종료: ${endTime}</p>
	//                   </div>`;
	//           }
	          
		// 날짜 선택
		function handleDateSelect(info) {
	    	// 선택한 날짜의 시작 및 종료 시간 계산
	    	const selectedDate = info.startStr; // 선택한 날짜의 시작 시간
	    	const nextDate = new Date(info.start); // 선택한 날짜의 다음 날
	    	nextDate.setDate(nextDate.getDate() + 1);
	    	const endOfDay = nextDate.toISOString().split("T")[0]; // 다음 날의 00:00:00
	
	    	// 일정 디테일 표시 영역
	    	const event = info.event;
	    	const details = document.getElementById("schedule-details");
	    	const content = document.getElementById("schedule-content");
	
	   		// AJAX 요청으로 해당 날짜의 일정 가져오기
	    	$.ajax({
	        	url: "/api/events/search",
	        	method: "GET",
	        	data: {
	            	start: info.startStr, // 시작 날짜
	            	end: info.endStr,       // 종료 날짜
	        	},
	        	success: function (data) {
	            	console.log("Fetched Data:", data); // 디버깅용
	
	            	details.classList.remove("hidden");
	
	            	if (data.length > 0) {
	                	// 필요한 속성만 사용하여 리스트 생성
	                	let listHTML = "<ul class='list-disc list-inside'>";
	                	data.forEach(event => {
	                    	const title = event.title || "제목 없음"; // `title` 속성 추출
	                    	console.log(event.title);
	                    	const start = event.start || "시작 시간 없음";
	                    	const end = event.end || "종료 시간 없음";
	
	                    	listHTML += `
	                        	<li>
	                            	<strong>\${title}</strong> (\${start} - \${end})
	                        	</li>`;
	                	});
	                	listHTML += "</ul>";
	                	content.innerHTML = listHTML;
	            	} else {
	                	content.innerHTML = `<p>선택한 날짜에 일정이 없습니다.</p>`;
	            	}
	        	},
	        	error: function () {
	            	alert("일정을 불러오는 데 실패했습니다.");
	        	},
	    	});
		}
	
		// 일정추가
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
<div id="schedule-details" class="p-4 ml-44 mr-44 mt-20 bg-gray-100 border border-gray-300 rounded">
    <h3 class="text-lg font-bold mb-2">선택한 날짜의 일정</h3>
    <div id="schedule-content">
        <p>날짜를 선택하여 일정을 확인하세요.</p>
    </div>
    
<!--      <h3 class="text-lg font-bold mt-4">새로운 일정 추가</h3> -->
<!--         <form id="event-form" class="mt-2"> -->
<!--             <label class="block">제목:</label> -->
<!--             <input type="text" id="event-title" class="input input-bordered w-full mb-2" required> -->
            
<!--             <label class="block">시작 시간:</label> -->
<!--             <input type="datetime-local" id="event-start" class="input input-bordered w-full mb-2" required> -->
            
<!--             <label class="block">종료 시간:</label> -->
<!--             <input type="datetime-local" id="event-end" class="input input-bordered w-full mb-4"> -->
            
<!--             <button type="submit" class="btn btn-primary w-full">일정 추가</button> -->
<!--         </form> -->
        
	 <button id="share-button" class="btn btn-secondary mt-4 w-full">공유</button>
</div>

<!-- 공유 설정 모달 -->
<div id="share-modal" class="hidden fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
    <div class="bg-white p-6 rounded shadow-lg">
        <h3 class="text-lg font-bold mb-4">일정 공유</h3>
        <label for="share-user">공유 대상:</label>
        <input type="text" id="share-user" class="input input-bordered w-full mb-4" placeholder="사용자 ID 또는 그룹 입력" />
        <label for="share-permission">권한:</label>
        <select id="share-permission" class="select select-bordered w-full mb-4">
            <option value="view">보기</option>
            <option value="edit">수정</option>
        </select>
        <button id="confirm-share" class="btn btn-primary w-full">공유하기</button>
        <button id="close-share" class="btn btn-secondary w-full mt-2">닫기</button>
    </div>
</div>

 <!-- WebSocket 메시지 영역 -->
<!--     <div id="messages" class="p-4 ml-44 bg-gray-100 border border-gray-300 rounded mt-4"></div> -->

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
