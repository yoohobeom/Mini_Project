<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>일정 관리 앱</title>
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
    
    <script>
        // 테마 초기화 및 변경 함수
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

        // WebSocket 초기화 및 이벤트 공유 함수
        const socket = new SockJS("/ws");
        const stompClient = StompJs.Stomp.over(socket);

        stompClient.connect({}, function () {
            console.log("WebSocket Connected");
        }, function (error) {
            console.error("WebSocket Connection Failed:", error);
        });

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
                "/app/share-event",
                {},
                JSON.stringify(shareData)
            );

            alert(`선택된 일정이 ${shareUser}에게 공유되었습니다.`);
        }

        // 캘린더 초기화 및 이벤트 핸들링
        let selectedDate = null;
        let selectedEndDate = null;

        document.addEventListener("DOMContentLoaded", function () {
            initCalendar();
            themeInit();
            resetButtonListeners();

            document.getElementById("schedule-details").addEventListener("click", function (e) {
                const target = e.target;

                if (target.id === "create-event") {
                    if (selectedDate) {
                        const formattedDate = `${selectedDate}T00:00`;
                        const formattedEndDate = `${selectedEndDate}T23:59`;
                        openAddEventModal(formattedDate, formattedEndDate);
                    } else {
                        alert("날짜를 먼저 선택해주세요.");
                    }
                } else if (target.id === "edit-event") {
                    const selectedIds = getSelectedEventIds();
                    if (selectedIds.length !== 1) {
                        alert("수정할 일정을 하나만 선택하세요.");
                        return;
                    }
                    openEditEventModal(selectedIds[0]);
                } else if (target.id === "delete-events") {
                    const selectedIds = getSelectedEventIds();
                    if (selectedIds.length === 0) {
                        alert("삭제할 일정을 선택하세요.");
                        return;
                    }
                    if (confirm("선택된 일정을 삭제하시겠습니까?")) {
                        deleteEvents(selectedIds);
                    }
                } else if (target.id === "share-events") {
                    const selectedIds = getSelectedEventIds();
                    if (selectedIds.length === 0) {
                        alert("공유할 일정을 선택하세요.");
                        return;
                    }
                    const shareUser = prompt("공유할 사용자 ID를 입력하세요:");
                    if (shareUser) {
                        shareEventsWebSocket(selectedIds, shareUser);
                    }
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
                eventDrop: handleEventDrop,
            });
            calendar.render();
        }

        // 이벤트 가져오기
        function fetchEvents(info, successCallback, failureCallback) {
            $.get("/api/events/search", { start: info.startStr, end: info.endStr })
                .done(data => {
                    const events = data.map(event => ({
                        id: event.id,
                        ownerId: event.ownerId,
                        title: event.title || "제목 없음",
                        start: event.start,
                        end: event.end || null,
                        allDay: false,
                        color: "#3788d8"
                    }));
                    successCallback(events);
                })
                .fail(() => {
                    alert("이벤트를 가져오는 데 실패했습니다.");
                    failureCallback();
                });
        }

        // 날짜 선택 핸들러
        function handleDateSelect(info) {
            enableButtons();
            
            selectedDate = info.startStr;
            
            const endDate = new Date(info.endStr);
            endDate.setDate(endDate.getDate() - 1);
            selectedEndDate = endDate.toISOString().split("T")[0];
            
            const nextDate = new Date(info.start);
            nextDate.setDate(nextDate.getDate() + 1);
            const endOfDay = nextDate.toISOString().split("T")[0];

            const details = document.getElementById("schedule-details");
            const content = document.getElementById("schedule-content");

            $.ajax({
                url: "/api/events/search",
                method: "GET",
                data: {
                    start: info.startStr,
                    end: info.endStr,
                },
                success: function (data) {
                    details.classList.remove("hidden");

                    if (data.length > 0) {
                        let listHTML = `
                            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
                        `;
                        data.forEach(event => {
                            const title = event.title || "제목 없음";
                            const start = event.start || "시작 시간 없음";
                            const end = event.end || "종료 시간 없음";
                            const description = event.description || "설명 없음";

                            listHTML += `
                                <div class="bg-white dark:bg-gray-800 border-l-4 border-blue-500 shadow-md rounded-lg p-4 hover:shadow-lg transition-shadow duration-200 cursor-pointer"
                                     data-title="${title}" 
                                     data-start="${start}" 
                                     data-end="${end}" 
                                     data-description="${description}">
                                    <div class="flex justify-between items-center">
                                        <div>
                                            <h4 class="text-lg font-semibold text-gray-700 dark:text-gray-200 mb-1">${title}</h4>
                                            <p class="text-sm text-gray-500 dark:text-gray-400">
                                                <i class="fas fa-calendar-alt mr-1"></i> ${start} ~ ${end}
                                            </p>
                                            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1 truncate">
                                                <i class="fas fa-info-circle mr-1"></i> ${description}
                                            </p>
                                        </div>
                                        <label class="flex items-center">
                                            <input 
                                                type="checkbox" 
                                                name="selected-events" 
                                                value="${event.id}" 
                                                class="h-5 w-5 text-blue-500 focus:ring focus:ring-blue-200"
                                            />
                                        </label>
                                    </div>
                                </div>
                            `;
                        });
                        listHTML += `</div>`;
                        content.innerHTML = listHTML;

                        document.querySelectorAll(".grid > div").forEach(card => {
                            card.addEventListener("click", function (event) {
                                if (event.target.type === "checkbox" || event.target.closest("input[type='checkbox']")) {
                                    return;
                                }
                                
                                const modalTitle = this.getAttribute("data-title");
                                const modalStart = this.getAttribute("data-start");
                                const modalEnd = this.getAttribute("data-end");
                                const modalDescription = this.getAttribute("data-description");

                                document.getElementById("modal-title").innerText = modalTitle;
                                document.getElementById("modal-start").innerHTML = `<strong>시작 시간:</strong> ${modalStart}`;
                                document.getElementById("modal-end").innerHTML = `<strong>종료 시간:</strong> ${modalEnd}`;
                                document.getElementById("modal-description").innerHTML = `<strong>설명:</strong> ${modalDescription}`;

                                document.getElementById("event-detail-modal").classList.remove("hidden");
                            });
                        });
                    } else {
                        content.innerHTML = `<p class="text-gray-600 dark:text-gray-400">선택한 날짜에 일정이 없습니다.</p>`;
                    }
                },
                error: function () {
                    alert("일정을 불러오는 데 실패했습니다.");
                },
            });
        }

        function enableButtons() {
            document.getElementById("create-event").disabled = false;
            document.getElementById("edit-event").disabled = false;
            document.getElementById("delete-events").disabled = false;
            document.getElementById("share-events").disabled = false;
        }

        // 선택된 일정 ID 가져오기
        function getSelectedEventIds() {
            let selectedIds = [];
            $("input[name='selected-events']:checked").each(function () {
                selectedIds.push($(this).val());
            });
            return selectedIds;
        }

        // 일정 추가 모달
        function openAddEventModal(startDate, endDate) {
            $("#add-event-start").val(startDate);
            $("#add-event-end").val(endDate);
            $("#add-modal").removeClass("hidden");
        }

        function closeAddEventModal() {
            $("#add-modal").addClass("hidden");
        }

        $(document).ready(function () {
            $("#add-event-form").on("submit", function (e) {
                e.preventDefault();

                const newEvent = {
                    title: $("#add-event-title").val(),
                    start: $("#add-event-start").val(),
                    end: $("#add-event-end").val() || $("#add-event-start").val(),
                    description: $("#add-event-description").val(),
                };

                $.ajax({
                    url: "/api/events/add",
                    method: "POST",
                    contentType: "application/json",
                    data: JSON.stringify(newEvent),
                    success: function (response) {
                        closeAddEventModal();
                        location.reload();
                    },
                    error: function (xhr, status, error) {
                        console.error("AJAX 오류 발생:", error);
                    },
                });
            });
        });

        // 일정 수정
        function openEditEventModal(eventId) {
            $.ajax({
                url: "/api/events/id",
                method: "GET",
                data: { id: eventId },
                success: function (data) {
                    $("#edit-event-title").val(data.title || "");
                    $("#edit-event-start").val(data.start || "");
                    $("#edit-event-end").val(data.end || "");
                    $("#edit-event-description").val(data.description || "");
                    
                    $("#edit-modal").removeClass("hidden");
                },
                error: function () {
                    alert("일정 정보를 가져오는 데 실패했습니다.");
                },
            });
        }

        function closeEditEventModal() {
            $("#edit-modal").addClass("hidden");
        }

        $(document).ready(function () {
            $("#edit-event-form").on("submit", function (e) {
                e.preventDefault();

                const updatedEvent = {
                    id: getSelectedEventIds()[0],
                    title: $("#edit-event-title").val(),
                    start: $("#edit-event-start").val(),
                    end: $("#edit-event-end").val(),
                    description: $("#edit-event-description").val(),
                };

                $.ajax({
                    url: "/api/events/update",
                    method: "POST",
                    contentType: "application/json",
                    data: JSON.stringify(updatedEvent),
                    success: function () {
                        alert("일정이 수정되었습니다.");
                        closeEditEventModal();
                        location.reload();
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
        title: info.event.title,
        start: formatDateForMysql(info.event.start),
        end: formatDateForMysql(info.event.end),
    };
    
    $.ajax({
        url: "/api/events/update",
        method: "POST",
        contentType: "application/json",
        data: JSON.stringify(updatedEvent),
        success: function () {
            console.log(updatedEvent);
        },
        error: function () {
            alert("일정을 수정하는 데 실패했습니다.");
            info.revert();
        },
    });
}

// 일정 삭제 함수
function deleteEvents(eventIds) {
    let param = [];
    console.log(eventIds);
    
    $("input[name='selected-events']:checked").each(function () {
        param.push($(this).val());
    });
    
    $.ajax({
        url: "/api/events/delete",
        method: "POST",
        data: { ids: param },
        success: function (data) {
            alert("선택된 일정이 삭제되었습니다.");
            console.log(data);
            location.reload();
        },
        error: function (error) {
            alert("일정 삭제에 실패했습니다.");
            console.log(error);
        },
    });
}

// 중복된 이벤트 리스너 제거 함수
function resetButtonListeners() {
    $("#create-event, #edit-event, #delete-events, #share-events").off("click");
}

    </script>
</head>
<body class="bg-gray-100 dark:bg-gray-900">
    <div class="container mx-auto px-4 py-8">
        <header class="mb-8">
            <div class="flex justify-between items-center">
                <h1 class="text-3xl font-bold text-gray-800 dark:text-white">일정 관리 앱</h1>
                <button onclick="themeSwap()" class="p-2 rounded-full bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-white">
                    <i class="fas fa-moon dark:fas fa-sun"></i>
                </button>
            </div>
        </header>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div class="lg:col-span-2">
                <div id="calendar" class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6"></div>
            </div>
            <div>
                <div id="schedule-details" class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-2xl font-bold text-gray-700 dark:text-gray-200">일정 상세보기</h3>
                        
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

                    <div id="schedule-content" class="bg-gray-50 dark:bg-gray-700 p-6 rounded-lg shadow-inner">
                        <p class="text-center text-gray-500 dark:text-gray-400">날짜를 선택하여 일정을 확인하세요.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 상세 정보 모달 -->
        <div id="event-detail-modal" class="hidden fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center z-50">
            <div class="bg-white dark:bg-gray-800 w-80 md:w-96 p-6 rounded-lg shadow-lg">
                <h4 id="modal-title" class="text-lg font-bold mb-4 text-gray-800 dark:text-white"></h4>
                <p id="modal-start" class="text-gray-600 dark:text-gray-400 mb-2"></p>
                <p id="modal-end" class="text-gray-600 dark:text-gray-400 mb-2"></p>
                <p id="modal-description" class="text-gray-700 dark:text-gray-300 mb-4"></p>
                <div class="flex justify-end">
                    <button id="close-modal" class="btn btn-secondary">닫기</button>
                </div>
            </div>
        </div>

        <!-- 일정 추가 모달 -->
        <div id="add-modal" class="hidden fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4 z-50">
            <div class="bg-white dark:bg-gray-800 w-full max-w-sm p-6 rounded shadow-lg">
                <h3 class="text-lg font-bold mb-4 text-gray-800 dark:text-white">일정 추가</h3>
                <form id="add-event-form">
                    <label for="add-event-title" class="block text-sm font-medium text-gray-700 dark:text-gray-300">제목:</label>
                    <input type="text" id="add-event-title" class="input input-bordered w-full mb-4" required />

                    <label for="add-event-start" class="block text-sm font-medium text-gray-700 dark:text-gray-300">시작 시간:</label>
                    <input type="datetime-local" id="add-event-start" class="input input-bordered w-full mb-4" required />

                    <label for="add-event-end" class="block text-sm font-medium text-gray-700 dark:text-gray-300">종료 시간:</label>
                    <input type="datetime-local" id="add-event-end" class="input input-bordered w-full mb-4" />
                    
                    <label for="add-event-description" class="block text-sm font-medium text-gray-700 dark:text-gray-300">설명:</label>
                    <input type="text" id="add-event-description" class="input input-bordered w-full mb-4" />

                    <button type="submit" class="btn btn-primary w-full">저장</button>
                    <button type="button" onclick="closeAddEventModal()" class="btn btn-secondary w-full mt-2">닫기</button>
                </form>
            </div>
        </div>

        <!-- 일정 수정 모달 -->
        <div id="edit-modal" class="hidden fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4 z-50">
            <div class="bg-white dark:bg-gray-800 w-full max-w-sm p-6 rounded shadow-lg">
                <h3 class="text-lg font-bold mb-4 text-gray-800 dark:text-white">일정 수정</h3>
                <form id="edit-event-form">
                    <label for="edit-event-title" class="block text-sm font-medium text-gray-700 dark:text-gray-300">제목:</label>
                    <input type="text" id="edit-event-title" class="input input-bordered w-full mb-4" required />

                    <label for="edit-event-start" class="block text-sm font-medium text-gray-700 dark:text-gray-300">시작 시간:</label>
                    <input type="datetime-local" id="edit-event-start" class="input input-bordered w-full mb-4" required />

                    <label for="edit-event-end" class="block text-sm font-medium text-gray-700 dark:text-gray-300">종료 시간:</label>
                    <input type="datetime-local" id="edit-event-end" class="input input-bordered w-full mb-4" />
                    
                    <label for="edit-event-description" class="block text-sm font-medium text-gray-700 dark:text-gray-300">설명:</label>
                    <input type="text" id="edit-event-description" class="input input-bordered w-full mb-4" />
                    
                    <button type="submit" class="btn btn-primary w-full">저장</button>
                    <button type="button" onclick="closeEditEventModal()" class="btn btn-secondary w-full mt-2">닫기</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>