<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html lang="ko" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
        // WebSocket 초기화
        const socket = new SockJS("/ws");
        const stompClient = StompJs.Stomp.over(() => socket); // 팩토리 함수로 전달	

        stompClient.connect({}, function () {
            console.log("WebSocket 연결 성공");
        }, function (error) {
            console.error("WebSocket 연결 실패:", error);
        });

        // WebSocket 공유 함수
        function shareEventsWebSocket(eventIds, shareUser, permission) {
            if (!stompClient || !stompClient.connected) {
                alert("WebSocket 연결이 끊어졌습니다. 다시 시도해주세요.");
                return;
            }

            const shareData = {
                action: "share",
                eventId: eventIds, // 이벤트ID
                shared_with_user_name: shareUser, // 유저
                permission: permission, // 권한 정보 추가
            };

            stompClient.send(
                "/app/share-event", // 서버의 WebSocket 핸들러
                {},
                JSON.stringify(shareData)
            );
			console.log(shareData);
            alert(`선택된 일정이 \${shareUser}에게 공유되었습니다. (권한: \${permission})`);
        }
 
    let selectedDate = null; // 선택된 날짜를 저장하는 전역 변수
    let selectedEndDate = null;    // 선택된 종료 날짜 (전역 변수)
    let ownerName = "${loginedMemberName}"; // 로그인 멤버 저장 전역변수
    let memberId = "${rq.getLoginedMemberId()}"
    
	document.addEventListener("DOMContentLoaded", function () {
		initCalendar();
		themeInit();
	    // 이벤트 리스너 중복 방지: 기존 리스너를 초기화
	    resetButtonListeners();
		
	    // 이벤트 위임으로 버튼 클릭 이벤트 등록
	    document.getElementById("schedule-details").addEventListener("click", function (e) {
	        const target = e.target;

	        // 일정 생성 버튼
	        if (e.target && e.target.id === "create-event") {
	            if (selectedDate) {
	                const formattedDate = `\${selectedDate}T00:00`;
	                const formattedEndDate = `\${selectedEndDate}T23:59`;
	                const useOwnerName = `\${ownerName}`;
	                const userId = `\${memberId}`;
	                openAddEventModal(formattedDate, formattedEndDate, useOwnerName, userId);
	            } else {
	                alert("날짜를 먼저 선택해주세요.");
	                console.log(selectedDate);
	            }
	        }
	        // 일정 수정 버튼
	        if (target.id === "edit-event") {
	            const selectedIds = getSelectedEventIds();
	            if (selectedIds.length !== 1) {
	                alert("수정할 일정을 하나만 선택하세요.");
	                return;
	            }
	            const eventId = selectedIds[0];
	            openEditEventModal(eventId);
	        }

	        // 일정 삭제 버튼
	        else if (target.id === "delete-events") {
	            const selectedIds = getSelectedEventIds();
	            if (selectedIds.length === 0) {
	                alert("삭제할 일정을 선택하세요.");
	                return;
	            }
	            if (confirm("선택된 일정을 삭제하시겠습니까?")) {
	                deleteEvents(selectedIds);
	            }
	        }

	        // 일정 공유 버튼
	        else if (target.id === "share-events") {
	        	
	            const selectedIds = getSelectedEventIds();
	            
	            if (selectedIds.length === 0) {
	                alert("공유할 일정을 선택하세요.");
	                return;
	            }
	            	openShareModal(selectedIds); // 모달 열기
	            }
	    });
	});
	
	function initCalendar() {
		const calendar = new FullCalendar.Calendar(document.getElementById("calendar"), {
			locale: "ko",
			headerToolbar: { left: "prev,next", center: "title", right: "today" },
			initialView: "dayGridMonth",
			selectable: true,
			editable: true,
			dayMaxEvents: true,
			moreLinkClick: "popover",
			events: fetchEvents,
			select: handleDateSelect,
			eventDrop: handleEventDrop, // 드래그 앤 드롭 이벤트 핸들러 추가
		});
			calendar.render();
		
		// 이벤트 가져오기
		function fetchEvents(info, successCallback, failureCallback) {
			$.get("/api/events/search", { start: info.startStr, end: info.endStr })
				.done(data => {
					console.log(data);
					const events = data.map(event => ({
						id: event.id, // 아이디 필드
						owner: event.owner || "알 수 없음",
						ownerId: event.owner_id || "알 수 없음",
						title: event.title || "제목 없음", // 제목 기본값 설정
						start: event.start,
	                    end: event.end || null, // 종료 시간 없는 경우 처리
						allDay: false, // 필요하면 추가
						color: event.ownerId === memberId ? "#3788d8" : "#ffcc00", // 소유자와 공유받은 일정 색상 구분
					}));
                    console.log("Processed Events:", events); // 디버깅용
                    successCallback(events);
				})
				.fail(() => {
					alert("이벤트를 가져오는 데 실패했습니다.");
					failureCallback();
				});
		}
	
		// 날짜 클릭
		function handleDateSelect(info) {
		    // 버튼 활성화
		    enableButtons();
			
	    	// 선택한 날짜의 시작 및 종료 시간 계산
	    	selectedDate = info.startStr; // 선택한 날짜의 시작 시간
	    	
	        const endDate = new Date(info.endStr);
	        endDate.setDate(endDate.getDate() - 1);
	        selectedEndDate = endDate.toISOString().split("T")[0]; // YYYY-MM-DD 형식으로 변환
	    	
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
	            	userId: memberId,
	        	},
	        	success: function (data) {
	            	console.log("Fetched Data:", data); // 디버깅용
	
	            	details.classList.remove("hidden");
	
	            	if (data.length > 0) {
	            	    let listHTML = `
	            	        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
	            	    `;
	            	    data.forEach(event => {
	            	        const title = event.title || "제목 없음";
	            	        const ownerName = event.owner || "익명";
	            	        const start = event.start || "시작 시간 없음";
	            	        const end = event.end || "종료 시간 없음";
	            	        const description = event.description || "설명 없음";

	            	        listHTML += `
	            	            <div class="bg-white border-l-4 border-blue-500 shadow-md rounded-lg p-4 hover:shadow-lg transition-shadow duration-200 cursor-pointer"
	            	                 data-title="\${title}" 
	            	                 data-ownerName="\${ownerName}"
	            	                 data-start="\${start}" 
	            	                 data-end="\${end}" 
	            	                 data-description="\${description}">
	            	                <div class="flex justify-between items-center">
	            	                    <div>
	            	                        <h4 class="text-lg font-semibold text-gray-700 mb-1">\${title}</h4>
	            	                        <p class="text-sm text-gray-500">
	            	                            <i class="fas fa-calendar-alt mr-1"></i> \${start} ~ \${end}
	            	                        </p>
	            	                        <p class="text-sm text-gray-500 mt-1 truncate">
	            	                            <i class="fas fa-info-circle mr-1"></i> \${description}
	            	                        </p>
	            	                    </div>
	            	                    <label class="flex items-center">
	            	                        <input 
	            	                            type="checkbox" 
	            	                            name="selected-events" 
	            	                            value="\${event.id}" 
	            	                            class="h-5 w-5 text-blue-500 focus:ring focus:ring-blue-200"
	            	                        />
	            	                    </label>
	            	                </div>
	            	            </div>
	            	        `;
	            	    });
	            	    listHTML += `</div>`;
	            	    content.innerHTML = listHTML;

	            	    // 상세보기 카드 클릭 이벤트 연결
	            	    document.querySelectorAll(".grid > div").forEach(card => {
	            	        card.addEventListener("click", function (event) {
	            	            // 체크박스 클릭 시 이벤트 중단
	            	            if (event.target.type === "checkbox" || event.target.closest("input[type='checkbox']")) {
	            	                return; // 이벤트 중단
	            	            }
	            	        	
	            	            const modalTitle = this.getAttribute("data-title");
	            	            const modalOwner = this.getAttribute("data-OwnerName");
	            	            const modalStart = this.getAttribute("data-start");
	            	            const modalEnd = this.getAttribute("data-end");
	            	            const modalDescription = this.getAttribute("data-description");

	            	            // 모달에 데이터 삽입
	            	            document.getElementById("modal-title").innerText = modalTitle;
	            	            document.getElementById("modal-owner").innerHTML = `<strong>작성자:</strong> \${modalOwner}`;
	            	            document.getElementById("modal-start").innerHTML = `<strong>시작 시간:</strong> \${modalStart}`;
	            	            document.getElementById("modal-end").innerHTML = `<strong>종료 시간:</strong> \${modalEnd}`;
	            	            document.getElementById("modal-description").innerHTML = `<strong>설명:</strong> \${modalDescription}`;

	            	            // 모달 보이기
	            	            document.getElementById("event-detail-modal").classList.remove("hidden");
	            	        });
	            	    });
	            	 
	            	    // 모달 닫기 이벤트
	            	    document.getElementById("close-modal").addEventListener("click", function () {
	            	        document.getElementById("event-detail-modal").classList.add("hidden");
	            	    });
	            	    
	            	 // 모달 외부 클릭 시 닫기
	            	    window.addEventListener("click", function (event) {
	            	        const modal = document.getElementById("event-detail-modal");
	            	        if (event.target === modal) { // 클릭된 대상이 모달 배경일 경우
	            	            modal.classList.add("hidden"); // 모달 닫기
	            	        }
	            	    });
	            	} else {
	                	content.innerHTML = `<p>선택한 날짜에 일정이 없습니다.</p>`;
	            	}
	        	},
	        	error: function () {
	            	alert("일정을 불러오는 데 실패했습니다.");
	        	},
	    	});
	   		
	    	function enableButtons() {
	    	    document.getElementById("create-event").disabled = false;
	    	    document.getElementById("edit-event").disabled = false;
	    	    document.getElementById("delete-events").disabled = false;
	    	    document.getElementById("share-events").disabled = false;
	    	}
	   		
		}
	}
	
	// 선택된 일정 ID 가져오기
	function getSelectedEventIds() {
		
		let selectedIds = [];
		
		$("input[name='selected-events']:checked").each(function () {
			let selectedId = $(this).val();
			selectedIds.push(selectedId);
		})
		
		return selectedIds;
	}
	
    // 일정 추가
	// 모달 열기
	function openAddEventModal(startDate, endDate, ownerName, ownerId) {
	    $("#add-event-start").val(startDate); // 시작 날짜 자동 설정
	   	$("#add-event-end").val(endDate);   // 종료 날짜 기본값 설정
	   	$("#add-event-owner").val(ownerName);   // 작성자 값
	   	$("#add-event-ownerId").val(ownerId);   // 작성자 키값
	    $("#add-modal").removeClass("hidden");
	}
	
    //모달 닫기
	function closeAddEventModal() {
	    $("#add-modal").addClass("hidden");
	}
	
	$(document).ready(function () {
	    console.log("JQuery Ready!");

	    $("#add-event-form").on("submit", function (e) {
	        e.preventDefault();

	        // 폼 데이터 확인
	        const newEvent = {
	            title: $("#add-event-title").val(),
	            owner_id: $("#add-event-ownerId").val(),
	            start: $("#add-event-start").val(),
	            end: $("#add-event-end").val() || $("#add-event-start").val(),
	            description: $("#add-event-description").val(),
	        };
	        console.log("전송할 데이터:", newEvent);

	        // AJAX 요청 테스트
	        $.ajax({
	            url: "/api/events/add",
	            method: "POST",
	            contentType: "application/json",
	            data: JSON.stringify(newEvent),
	            success: function (response) {
	                closeAddEventModal();
		            location.reload(); // 새로고침하여 업데이트
	            },
	            error: function (xhr, status, error) {
	                console.error("AJAX 오류 발생:", error);
	            },
	        });
	    });
	});

	// 일정 수정
	// 모달 열기
	function openEditEventModal(eventId) {
		
	    $.ajax({
	        url: "/api/events/id", // 일정 상세 조회 API
	        method: "GET",
	        data: { id : eventId },
	        success: function (data) {
	            $("#edit-event-title").val(data.title || "");
	            $("#edit-event-start").val(data.start || "");
	            $("#edit-event-end").val(data.end || "");
	            $("#edit-event-description").val(data.description || "");
	            
	            $("#edit-modal").removeClass("hidden"); // 수정 모달 열기
	        },
	        error: function () {
	            alert("일정 정보를 가져오는 데 실패했습니다.");
	        },
	    });
	}

	function closeEditEventModal() {
	    $("#edit-modal").addClass("hidden"); // 수정 모달 닫기
	}

	$(document).ready(function () {
	    $("#edit-event-form").on("submit", function (e) {
	        e.preventDefault();

	        const updatedEvent = {
	            id: getSelectedEventIds()[0], // 선택된 일정 ID
	            title: $("#edit-event-title").val(),
	            start: $("#edit-event-start").val(),
	            end: $("#edit-event-end").val(),
	            description: $("#edit-event-description").val(),
	        };

	        $.ajax({
	            url: "/api/events/update", // 일정 수정 API
	            method: "POST",
	            contentType: "application/json",
	            data: JSON.stringify(updatedEvent),
	            success: function () {
	                alert("일정이 수정되었습니다.");
	                closeEditEventModal();
	                location.reload(); // 새로고침하여 변경사항 반영
	            },
	            error: function () {
	                alert("일정을 수정하는 데 실패했습니다.");
	            },
	        });
	    });
	});
	
	function formatDateForMysql(dateString) {
	    const date = new Date(dateString);
	    return date.toISOString().slice(0, 19).replace('T', ' ');
	}

	// 이벤트 Drag&Drop방식 수정
    function handleEventDrop(info) {
		
        const updatedEvent = {
            id: info.event.id,
            title: info.event.title, // 제목 유지
            start: formatDateForMysql(info.event.start), // 새로운 시작 시간
            end: formatDateForMysql(info.event.end), // 새로운 종료 시간
        };
        
        // AJAX로 서버에 변경된 이벤트 정보 전송
        $.ajax({
            url: "/api/events/update",
            method: "POST",
            contentType: "application/json",
            data: JSON.stringify(updatedEvent),
            success: function () {
                console.log("서버 업데이트 성공:", updatedEvent); // 전송 데이터 출력
                info.event.setDates(info.event.start, info.event.end); // 캘린더 업데이트
            },
            error: function () {
                alert("일정을 수정하는 데 실패했습니다.");
                info.revert(); // 실패 시 드래그 이전 위치로 되돌리기
            },
        });
    }
    
	// 일정 공유
    function openShareModal(eventIds) {
        // 선택된 일정 ID를 숨겨진 필드에 저장
        $("#share-event-ids").val(eventIds.join(","));
        $("#share-modal").removeClass("hidden"); // 모달 표시
    }

    function closeShareModal() {
        $("#share-modal").addClass("hidden"); // 모달 숨기기
    }
    
    // 공유 폼 제출 처리
	$(document).ready(function () {
	    $("#share-event-form").on("submit", function (e) {
	        e.preventDefault(); // 기본 폼 제출 방지
	        
	        // 폼 데이터 수집
	        const eventIds = $("#share-event-ids").val().split(",");
	        const shareUser = $("#share-user").val();
	        const sharePermission = $("#share-permission").val();
	
	        // WebSocket 공유 함수 호출
	        shareEventsWebSocket(eventIds, shareUser, sharePermission);
	
	        // 모달 닫기
	        closeShareModal();
	    });
	});
	
	// 일정 삭제 함수
	function deleteEvents(eventIds) {
		
		let param = [];
		console.log(eventIds);
		
        $("input[name='selected-events']:checked").each(function () {
            param.push($(this).val());
         })
		
	    $.ajax({
	        url: "/api/events/delete",
	        method: "POST",
	        data: { ids: param },
	        success: function (data) {
	            alert("선택된 일정이 삭제되었습니다.");
	            console.log(data);
	            location.reload(); // 새로고침하여 업데이트
	        },
	        error: function () {
	            alert("일정 삭제에 실패했습니다.");
	            console.log(error);
	        },
	    });
	}
	
	// 중복된 이벤트 리스너 제거 함수
	function resetButtonListeners() {
	    $("#create-event, #edit-event, #delete-events, #share-events").off("click");
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

<body class="bg-gray-50 dark:bg-gray-900 transition-colors duration-200">
    <header class="bg-white dark:bg-gray-800 shadow-md">
        <div class="container mx-auto px-4 h-16 flex items-center justify-between">
            <a href="${pageContext.request.contextPath}/" class="text-2xl font-bold text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300 transition-colors duration-200">
                <i class="fas fa-calendar-alt mr-2"></i>캘린더
            </a>
            <nav class="flex items-center space-x-4">
                <label class="swap swap-rotate">
                    <input id="themeToggle" type="checkbox" />
                    <i class="fas fa-sun swap-on text-yellow-500 text-2xl"></i>
                    <i class="fas fa-moon swap-off text-indigo-600 text-2xl"></i>
                </label>
                <ul class="flex space-x-4">
                    <c:if test="${rq.getLoginedMemberId() == -1 }">
                        <li><a href="${pageContext.request.contextPath}/usr/member/join" class="btn btn-sm btn-outline btn-primary">회원가입</a></li>
                        <li><a href="${pageContext.request.contextPath}/usr/member/login" class="btn btn-sm btn-primary">로그인</a></li>
                    </c:if>
                    <c:if test="${rq.getLoginedMemberId() != -1 }">
                        <li><a href="${pageContext.request.contextPath}/usr/member/myPage" class="btn btn-sm btn-outline btn-primary">마이페이지</a></li>
                        <li><a href="${pageContext.request.contextPath}/usr/member/doLogout" class="btn btn-sm btn-primary">로그아웃</a></li>
                    </c:if>
                </ul>
            </nav>
        </div>
    </header>

    <main class="container mx-auto p-4 mt-8">
        <div class="flex flex-col lg:flex-row gap-8">
			<!-- 캘린더 컨테이너 -->
            <div class="lg:w-2/3">
                <div id="calendar" class="bg-white dark:bg-gray-800 shadow-xl rounded-lg overflow-hidden transition-shadow duration-300 hover:shadow-2xl"></div>
            </div>

			<!-- 일정 상세 정보 -->
            <div class="lg:w-1/3">
                <div id="schedule-details" class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-xl transition-shadow duration-300 hover:shadow-2xl">
                    <div class="flex justify-between items-center mb-6">
                        <h3 class="text-2xl font-bold text-gray-800 dark:text-white">일정 상세보기</h3>
                    </div>
                    
					<!-- 버튼 영역 -->
                    <div class="flex flex-wrap gap-2 mb-6">
                        <button id="create-event" class="btn btn-primary btn-sm"><i class="fas fa-plus mr-2"></i>생성</button>
                        <button id="edit-event" class="btn btn-secondary btn-sm"><i class="fas fa-edit mr-2"></i>수정</button>
                        <button id="share-events" class="btn btn-accent btn-sm"><i class="fas fa-share-alt mr-2"></i>공유</button>
                        <button id="delete-events" class="btn btn-error btn-sm"><i class="fas fa-trash-alt mr-2"></i>삭제</button>
                    </div>

					<!-- 일정 내용 -->
                    <div id="schedule-content" class="bg-gray-100 dark:bg-gray-700 p-4 rounded-lg">
                        <p class="text-center text-gray-600 dark:text-gray-300"><i class="fas fa-info-circle mr-2"></i>날짜를 선택하여 일정을 확인하세요.</p>
                    </div>
                </div>
            </div>
        </div>

		<!-- 게시글 리스트 -->
        <section class="mt-12">
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow-xl p-6 transition-shadow duration-300 hover:shadow-2xl">
                <h2 class="text-2xl font-bold mb-6 text-gray-800 dark:text-white"><i class="fas fa-list-alt mr-2"></i>게시글 목록</h2>
                <div class="flex justify-between items-center mb-6">
                    <c:if test="${rq.getLoginedMemberId() != -1 }">
                        <a href="../article/write" class="btn btn-primary btn-sm"><i class="fas fa-pen mr-2"></i>글쓰기</a>
                    </c:if>
                    <form class="flex items-center space-x-2">
                        <select class="select select-bordered select-sm" name="searchType">
                            <option value="title" <c:if test="${searchType == 'title'}">selected</c:if>>제목</option>
                            <option value="body" <c:if test="${searchType == 'body'}">selected</c:if>>내용</option>
                            <option value="title,body" <c:if test="${searchType == 'title,body'}">selected</c:if>>제목 + 내용</option>
                        </select>
                        <input type="text" class="input input-bordered input-sm" name="searchKeyword" placeholder="검색어" maxlength="25" value="${searchKeyword}" />
                        <button class="btn btn-primary btn-sm"><i class="fas fa-search mr-2"></i>검색</button>
                    </form>
                </div>

                <!-- 테이블: 큰 화면 -->
                <div class="hidden sm:block overflow-x-auto">
                    <table class="table w-full">
                        <thead>
                            <tr>
                                <th class="bg-gray-100 dark:bg-gray-700">번호</th>
                                <th class="bg-gray-100 dark:bg-gray-700">제목</th>
                                <th class="bg-gray-100 dark:bg-gray-700">작성자</th>
                                <th class="bg-gray-100 dark:bg-gray-700">작성일</th>
                                <th class="bg-gray-100 dark:bg-gray-700">조회수</th>
                                <th class="bg-gray-100 dark:bg-gray-700">추천수</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="article" items="${articles}">
                                <tr class="hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors duration-150">
                                    <td>${article.id}</td>
                                    <td><a href="../article/detail?id=${article.id}" class="link link-hover text-primary">${article.title}</a></td>
                                    <td>${article.loginId}</td>
                                    <td>${article.regDate.substring(0, 10)}</td>
                                    <td><i class="fas fa-eye mr-1"></i>${article.views}</td>
                                    <td><i class="fas fa-thumbs-up mr-1"></i>${article.like}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- 카드: 작은 화면 -->
                <div class="sm:hidden space-y-4">
                    <c:forEach var="article" items="${articles}">
                        <div class="card bg-base-100 shadow-md transition-transform duration-300 hover:scale-105">
                            <div class="card-body">
                                <h2 class="card-title">
                                    <a href="../article/detail?id=${article.id}" class="link link-hover text-primary">${article.title}</a>
                                </h2>
                                <p><i class="fas fa-user mr-1"></i>작성자: ${article.loginId}</p>
                                <p><i class="fas fa-calendar-alt mr-1"></i>작성일: ${article.regDate.substring(0, 10)}</p>
                                <p>
                                    <i class="fas fa-eye mr-1"></i>조회수: ${article.views} 
                                    <i class="fas fa-thumbs-up ml-2 mr-1"></i>추천수: ${article.like}
                                </p>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </section>
    </main>
<!-- 상세 정보 모달 -->
<div id="event-detail-modal" class="hidden fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center z-50">
    <div class="bg-white w-80 md:w-96 p-6 rounded-lg shadow-lg">
        <h4 id="modal-title" class="text-lg font-bold mb-4"></h4>
        <p id="modal-owner" class="text-gray-600 mb-2"></p>
        <p id="modal-start" class="text-gray-600 mb-2"></p>
        <p id="modal-end" class="text-gray-600 mb-2"></p>
        <p id="modal-description" class="text-gray-700 mb-4"></p>
        <div class="flex justify-end">
            <button id="close-modal" class="btn btn-secondary">닫기</button>
        </div>
    </div>
</div>

<!-- 일정 추가 모달 -->
<div id="add-modal" class="hidden fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4 z-50">
    <div class="bg-white w-full max-w-sm p-6 rounded shadow-lg">
        <h3 class="text-lg font-bold mb-4">일정 추가</h3>
        <form id="add-event-form">
            <label for="add-event-title">제목:</label>
            <input type="text" id="add-event-title" class="input input-bordered w-full mb-4" required />
            
            <input type="text" id="add-event-ownerId" class="input input-bordered w-full mb-4" hidden />
            
            <label for="add-event-owner">작성자:</label>
			<input type="text" id="add-event-owner" class="input input-bordered w-full mb-4" readonly />

            <label for="add-event-start">시작 시간:</label>
            <input type="datetime-local" id="add-event-start" class="input input-bordered w-full mb-4" required />

            <label for="add-event-end">종료 시간:</label>
            <input type="datetime-local" id="add-event-end" class="input input-bordered w-full mb-4" />
            
            <label for="add-event-description">설명:</label>
            <input type="text" id="add-event-description" class="input input-bordered w-full mb-4" />

            <button type="submit" class="btn btn-primary w-full">저장</button>
            <button type="button" onclick="closeAddEventModal()" class="btn btn-secondary w-full mt-2">닫기</button>
        </form>
    </div>
</div>

<!-- 일정 수정 모달 -->
<div id="edit-modal" class="hidden fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4 z-50">
    <div class="bg-white w-full max-w-sm p-6 rounded shadow-lg">
        <h3 class="text-lg font-bold mb-4">일정 수정</h3>
        <form id="edit-event-form">
            <label for="edit-event-title">제목:</label>
            <input type="text" id="edit-event-title" class="input input-bordered w-full mb-4" required />
            
            <label for="edit-event-owner">작성자:</label>
			<input type="text" id="edit-event-owner" class="input input-bordered w-full mb-4" readonly />

            <label for="edit-event-start">시작 시간:</label>
            <input type="datetime-local" id="edit-event-start" class="input input-bordered w-full mb-4" required />

            <label for="edit-event-end">종료 시간:</label>
            <input type="datetime-local" id="edit-event-end" class="input input-bordered w-full mb-4" />
            
			<label for="edit-event-description">설명:</label>
            <input type="text" id="edit-event-description" class="input input-bordered w-full mb-4" />
            
            <button type="submit" class="btn btn-primary w-full">저장</button>
            <button type="button" onclick="closeEditEventModal()" class="btn btn-secondary w-full mt-2">닫기</button>
        </form>
    </div>
</div>

<!-- 공유 기능 모달 -->
<div id="share-modal" class="hidden fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center z-50">
    <div class="bg-white w-full max-w-sm p-6 rounded shadow-lg">
        <h3 class="text-lg font-bold mb-4">일정 공유</h3>
        <form id="share-event-form" action="">
            <!-- 숨겨진 필드에 선택된 일정 ID 저장 -->
            <input type="hidden" id="share-event-ids" />
            
            <label for="share-user">공유 대상:</label>
            <input type="text" id="share-user" class="input input-bordered w-full mb-4" placeholder="사용자 ID 입력" required />
            
            <label for="share-permission">권한:</label>
            <select id="share-permission" class="select select-bordered w-full mb-4">
                <option value="view">보기</option>
                <option value="edit">수정</option>
            </select>
            
            <button type="submit" class="btn btn-primary w-full">공유하기</button>
            <button type="button" onclick="closeShareModal()" class="btn btn-secondary w-full mt-2">닫기</button>
        </form>
    </div>
</div>

</body>
<script>
// 테마 토글 기능
$('#themeToggle').change(function() {
    $('html').attr('data-theme', this.checked ? 'dark' : 'light');
});
</script>
</html>
