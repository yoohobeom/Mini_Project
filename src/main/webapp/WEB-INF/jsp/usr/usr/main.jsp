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
			
			initialView: "dayGridMonth",
			height: '100%', // 부모 컨테이너의 높이에 맞게 조정
		    aspectRatio: 1.2, // 가로 세로 비율을 조정
			
	        headerToolbar: {
	            right: '',
	            center: 'prev title next',
	            left: 'today',
				},
				
		});
        		
	calendar.render();
	
	});
 </script>
 
</head>

<body>
	<div id="calendar-container" class="w-full max-w-4xl mx-auto p-4">
		<div id="calendar"></div>
	</div>
</body>
</html>