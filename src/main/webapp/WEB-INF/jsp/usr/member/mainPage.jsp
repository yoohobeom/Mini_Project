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
        // WebSocket 초기화
        const socket = new SockJS("/ws");
        const stompClient = StompJs.Stomp.over(() => socket); // 팩토리 함수로 전달	

        stompClient.connect({}, function () {
            console.log("WebSocket Connected");
        }, function (error) {
            console.error("WebSocket Connection Failed:", error);
        });

        // WebSocket을 통해 공유 데이터 전송
        function shareEventsWebSocket(eventIds, shareUser) {
            if (!stompClient.connected) {
                alert("WebSocket 연결이 끊어졌습니다. 다시 시도해주세요.");
                return;
            }

            const shareData = {
                action: "share",
                eventIds: eventIds,
                sharedWith: shareUser,
            };

            stompClient.send(
                "/app/share-event", // 서버의 WebSocket 핸들러
                {},
                JSON.stringify(shareData)
            );

            alert(`선택된 일정이 \${shareUser}에게 공유되었습니다.`);
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
			headerToolbar: { left: "", center: "prev title next", right: "today" },
			initialView: "dayGridMonth",
			height: "500px",
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
					const events = data.map(event => ({
						id: event.id, // 아이디 필드
						owner: event.owner || "알 수 없음",
						ownerId: event.ownerId || "알 수 없음",
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
	            ownerId: $("#add-event-ownerId").val(),
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
                console.log(updatedEvent); // 전송 데이터 출력
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
			<c:if test="${rq.getLoginedMemberId() == -1 }">
				<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/usr/member/join">JOIN</a></li>
				<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/usr/member/login">LOGIN</a></li>
			</c:if>
			<c:if test="${rq.getLoginedMemberId() != -1 }">
				<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/usr/member/myPage">MYPAGE</a></li>
				<li class="link link-hover"><a class="h-full px-3 flex items-center" href="${pageContext.request.contextPath}/usr/member/doLogout">LOGOUT</a></li>
			</c:if>
		</ul>
	</div>

<!-- 캘린더 컨테이너 -->
<div id="calendar-container" class="hidden sm:block p-4 sm:ml-44">
    <div id="calendar" class="shadow-lg rounded-lg overflow-hidden border border-gray-200"></div>
</div>
<!-- 일정 상세 정보 -->
<div id="schedule-details" class="p-4 sm:ml-44 sm:mr-44 mt-20 bg-white border border-gray-200 shadow-lg rounded-lg">
    <div class="flex justify-between items-center mb-4">
        <h3 class="text-2xl font-bold text-gray-700">일정 상세보기</h3>
        
        <!-- 버튼 영역 -->
        <div class="flex flex-wrap gap-2">
            <button id="create-event" class="btn btn-primary flex items-center">
                <i class="fas fa-plus mr-2"></i> 생성
            </button>
            <button id="edit-event" class="btn btn-secondary flex items-center">
                <i class="fas fa-edit mr-2"></i> 수정
            </button>
            <button id="share-events" class="btn btn-accent flex items-center">
                <i class="fas fa-share-alt mr-2"></i> 공유
            </button>
            <button id="delete-events" class="btn btn-error flex items-center">
                <i class="fas fa-trash mr-2"></i> 삭제
            </button>
        </div>
    </div>

    <!-- 일정 내용 -->
    <div id="schedule-content" class="bg-gray-50 p-6 rounded-lg shadow-inner">
        <p class="text-center text-gray-500">날짜를 선택하여 일정을 확인하세요.</p>
    </div>
</div>

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
        <form id="share-event-form">
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

<!-- 게시글 리스트 -->
<section class="mt-8">
    <div class="container mx-auto">
    	<h2>게시글 목록</h2>
        <div class="w-full mb-4 pl-3 text-sm flex justify-between items-end">
            <div>총 : ${articlesCnt}개</div>
            
            <c:if test="${rq.getLoginedMemberId() != -1 }">
			<div class="w-9/12 mx-auto flex justify-end my-3">
				<a class="btn btn-active btn-sm" href="../article/write">글쓰기</a>
			</div>
			</c:if>
            <form class="flex items-center">
                <select class="select select-bordered select-sm mr-2" name="searchType">
                    <option value="title" <c:if test="${searchType == 'title'}">selected</c:if>>제목</option>
                    <option value="body" <c:if test="${searchType == 'body'}">selected</c:if>>내용</option>
                    <option value="title,body" <c:if test="${searchType == 'title,body'}">selected</c:if>>제목 + 내용</option>
                </select>
                <input type="text" class="input input-bordered input-sm w-60" name="searchKeyword" placeholder="검색어" maxlength="25" value="${searchKeyword}" />
                <button class="btn btn-primary btn-sm ml-2">검색</button>
            </form>
        </div>

        <!-- 테이블: 큰 화면 -->
        <div class="hidden sm:block w-full overflow-x-auto">
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
                            <td><a href="../article/detail?id=${article.id}">${article.title}</a></td>
                            <td>${article.loginId}</td>
                            <td>${article.regDate.substring(0, 10)}</td>
                            <td>${article.views}</td>
                            <td>${article.like}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- 카드: 작은 화면 -->
        <div class="sm:hidden">
            <c:forEach var="article" items="${articles}">
                <div class="border border-gray-300 rounded p-4 mb-2 bg-white shadow">
                    <h4 class="font-bold mb-2">
                        <a href="detail?id=${article.id}" class="text-blue-600">${article.title}</a>
                    </h4>
                    <p>작성자: ${article.loginId}</p>
                    <p>작성일: ${article.regDate.substring(0, 10)}</p>
                    <p>조회수: ${article.views} | 추천수: ${article.like}</p>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

</body>
</html>
