<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html>
<head>

<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.15/index.global.min.js"></script>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!-- calendar css -->
<link rel="stylesheet" href="/resource/calendar.css" />

<title>Google Calendar Events</title>

<script>
	document.addEventListener("DOMContentLoaded", function(){
		var calendarEl = document.getElementById("calendar");
		var calendar = new FullCalendar.Calendar(calendarEl, {
			locale:'ko',
			
	        headerToolbar: {
	            right: 'today',
	            center: 'prev title next',
	            left: 'dayGridMonth,timeGridWeek,dayGridDay',
			},
				
			initialView: "dayGridMonth",
			height: 'auto', // 부모 컨테이너의 높이에 맞게 조정
			contentHeight: 'auto', // 콘텐츠 높이도 자동 조정
		    aspectRatio: 1.2, // 가로 세로 비율을 조정
		    selectable: true, // 날짜 선택가능
		    navLinks: true, // 달력 일자 선택가능
		    displayEventTime: true,	// 달력 주력 등 화면에서 시작 시간 표기 여부
		    
		});
        		
		calendar.render();
	
	});
 </script>
 
</head>

<body>
	<div id="calendar-container" class="w-full mx-auto p-4">
  		<div id="calendar"></div>
	</div>
</body>
</html>