<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>달력 애플리케이션</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/daisyui@2.51.5/dist/full.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.10.2/main.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.10.2/main.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css" rel="stylesheet">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap');
        body {
            font-family: 'Noto Sans KR', sans-serif;
        }
        .fc-theme-standard td, .fc-theme-standard th {
            border-color: #e2e8f0;
        }
        .fc .fc-daygrid-day-number {
            color: #4a5568;
        }
        .fc .fc-col-header-cell-cushion {
            color: #2d3748;
        }
        .transition-transform {
            transition-property: transform;
            transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
            transition-duration: 150ms;
        }
        .hover\:scale-105:hover {
            transform: scale(1.05);
        }
    </style>
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

    <!-- 모달 컴포넌트들 -->
    <!-- 상세 정보 모달 -->
    <div id="event-detail-modal" class="modal">
        <div class="modal-box">
            <h3 id="modal-title" class="font-bold text-lg mb-4"></h3>
            <p id="modal-owner" class="mb-2"><i class="fas fa-user mr-2"></i></p>
            <p id="modal-start" class="mb-2"><i class="fas fa-calendar-plus mr-2"></i></p>
            <p id="modal-end" class="mb-2"><i class="fas fa-calendar-minus mr-2"></i></p>
            <p id="modal-description" class="mb-4"><i class="fas fa-info-circle mr-2"></i></p>
            <div class="modal-action">
                <button id="close-modal" class="btn">닫기</button>
            </div>
        </div>
    </div>

    <!-- 일정 추가 모달 -->
    <div id="add-modal" class="modal">
        <div class="modal-box">
            <h3 class="font-bold text-lg mb-4">일정 추가</h3>
            <form id="add-event-form">
                <div class="form-control mb-4">
                    <label class="label" for="add-event-title">
                        <span class="label-text">제목</span>
                    </label>
                    <input type="text" id="add-event-title" class="input input-bordered w-full" required />
                </div>
                
                <input type="hidden" id="add-event-ownerId" />
                
                <div class="form-control mb-4">
                    <label class="label" for="add-event-owner">
                        <span class="label-text">작성자</span>
                    </label>
                    <input type="text" id="add-event-owner" class="input input-bordered w-full" readonly />
                </div>

                <div class="form-control mb-4">
                    <label class="label" for="add-event-start">
                        <span class="label-text">시작 시간</span>
                    </label>
                    <input type="datetime-local" id="add-event-start" class="input input-bordered w-full" required />
                </div>

                <div class="form-control mb-4">
                    <label class="label" for="add-event-end">
                        <span class="label-text">종료 시간</span>
                    </label>
                    <input type="datetime-local" id="add-event-end" class="input input-bordered w-full" />
                </div>
                
                <div class="form-control mb-4">
                    <label class="label" for="add-event-description">
                        <span class="label-text">설명</span>
                    </label>
                    <textarea id="add-event-description" class="textarea textarea-bordered h-24 w-full"></textarea>
                </div>

                <div class="modal-action">
                    <button type="submit" class="btn btn-primary">저장</button>
                    <button type="button" onclick="closeAddEventModal()" class="btn">닫기</button>
                </div>
            </form>
        </div>
    </div>

    <!-- 일정 수정 모달 -->
    <div id="edit-modal" class="modal">
        <div class="modal-box">
            <h3 class="font-bold text-lg mb-4">일정 수정</h3>
            <form id="edit-event-form">
                <div class="form-control mb-4">
                    <label class="label" for="edit-event-title">
                        <span class="label-text">제목</span>
                    </label>
                    <input type="text" id="edit-event-title" class="input input-bordered w-full" required />
                </div>
                
                <div class="form-control mb-4">
                    <label class="label" for="edit-event-owner">
                        <span class="label-text">작성자</span>
                    </label>
                    <input type="text" id="edit-event-owner" class="input input-bordered w-full" readonly />
                </div>

                <div class="form-control mb-4">
                    <label class="label" for="edit-event-start">
                        <span class="label-text">시작 시간</span>
                    </label>
                    <input type="datetime-local" id="edit-event-start" class="input input-bordered w-full" required />
                </div>

                <div class="form-control mb-4">
                    <label class="label" for="edit-event-end">
                        <span class="label-text">종료 시간</span>
                    </label>
                    <input type="datetime-local" id="edit-event-end" class="input input-bordered w-full" />
                </div>
                
                <div class="form-control mb-4">
                    <label class="label" for="edit-event-description">
                        <span class="label-text">설명</span>
                    </label>
                    <textarea id="edit-event-description" class="textarea textarea-bordered h-24 w-full"></textarea>
                </div>
                
                <div class="modal-action">
                    <button type="submit" class="btn btn-primary">저장</button>
                    <button type="button" onclick="closeEditEventModal()" class="btn">닫기</button>
                </div>
            </form>
        </div>
    </div>

    <!-- 공유 기능 모달 -->
    <div id="share-modal" class="modal">
        <div class="modal-box">
            <h3 class="font-bold text-lg mb-4">일정 공유</h3>
            <form id="share-event-form">
                <input type="hidden" id="share-event-ids" />
                
                <div class="form-control mb-4">
                    <label class="label" for="share-user">
                        <span class="label-text">공유 대상</span>
                    </label>
                    <input type="text" id="share-user" class="input input-bordered w-full" placeholder="사용자 ID 입력" required />
                </div>
                
                <div class="form-control mb-4">
                    <label class="label" for="share-permission">
                        <span class="label-text">권한</span>
                    </label>
                    <select id="share-permission" class="select select-bordered w-full">
                        <option value="view">보기</option>
                        <option value="edit">수정</option>
                    </select>
                </div>
                
                <div class="modal-action">
                    <button type="submit" class="btn btn-primary">공유하기</button>
                    <button type="button" onclick="closeShareModal()" class="btn">닫기</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var calendarEl = document.getElementById('calendar');
            var calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,timeGridDay'
                },
                events: [
                    // 여기에 이벤트 데이터를 추가하세요
                ],
                eventClick: function(info) {
                    showEventDetails(info.event);
                }
            });
            calendar.render();

            // 테마 토글 기능
            $('#themeToggle').change(function() {
                $('html').attr('data-theme', this.checked ? 'dark' : 'light');
            });

            // 이벤트 상세 정보 표시 함수
            function showEventDetails(event) {
                $('#modal-title').text(event.title);
                $('#modal-owner').html('<i class="fas fa-user mr-2"></i>작성자: ' + (event.extendedProps.owner || '없음'));
                $('#modal-start').html('<i class="fas fa-calendar-plus mr-2"></i>시작: ' + event.start.toLocaleString());
                $('#modal-end').html('<i class="fas fa-calendar-minus mr-2"></i>종료: ' + (event.end ? event.end.toLocaleString() : '없음'));
                $('#modal-description').html('<i class="fas fa-info-circle mr-2"></i>설명: ' + (event.extendedProps.description || '없음'));
                $('#event-detail-modal').addClass('modal-open');
            }

            // 모달 닫기
            $('#close-modal, .modal-backdrop').click(function() {
                $('.modal').removeClass('modal-open');
            });

            // 이벤트 추가
            $('#create-event').click(function() {
                $('#add-modal').addClass('modal-open');
            });

            $('#add-event-form').submit(function(e) {
                e.preventDefault();
                // 여기에 이벤트 추가 로직을 구현하세요
                $('#add-modal').removeClass('modal-open');
            });

            // 이벤트 수정
            $('#edit-event').click(function() {
                // 선택된 이벤트 정보를 폼에 채우는 로직을 구현하세요
                $('#edit-modal').addClass('modal-open');
            });

            $('#edit-event-form').submit(function(e) {
                e.preventDefault();
                // 여기에 이벤트 수정 로직을 구현하세요
                $('#edit-modal').removeClass('modal-open');
            });

            // 이벤트 공유
            $('#share-events').click(function() {
                $('#share-modal').addClass('modal-open');
            });

            $('#share-event-form').submit(function(e) {
                e.preventDefault();
                // 여기에 이벤트 공유 로직을 구현하세요
                $('#share-modal').removeClass('modal-open');
            });

            // 이벤트 삭제
            $('#delete-events').click(function() {
                // 여기에 이벤트 삭제 로직을 구현하세요
            });
        });

        function closeAddEventModal() {
            $('#add-modal').removeClass('modal-open');
        }

        function closeEditEventModal() {
            $('#edit-modal').removeClass('modal-open');
        }

        function closeShareModal() {
            $('#share-modal').removeClass('modal-open');
        }
    </script>
</body>
</html>