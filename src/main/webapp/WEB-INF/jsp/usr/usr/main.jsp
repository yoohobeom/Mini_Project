<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html>
<head>

<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.15/index.global.min.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!-- calendar css -->
<link rel="stylesheet" href="/resource/calendar.css" />

<title>Google Calendar Events</title>

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
            height: 'auto', // 부모 컨테이너의 높이에 맞게 조정
            contentHeight: 'auto', // 콘텐츠 높이도 자동 조정
            aspectRatio: 1.2, // 가로 세로 비율을 조정
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
</script>

</head>

<body>
    <div id="calendar-container" class="w-full mx-auto p-4">
        <div id="calendar"></div>
    </div>
    <div id="schedule-details">
        <p>Please select a date to view its schedule.</p>
    </div>
</body>
</html>
