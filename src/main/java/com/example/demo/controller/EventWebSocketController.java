package com.example.demo.controller;

import java.util.List;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

import com.example.demo.dto.CalendarEvent;
import com.example.demo.dto.ShareEventRequest;
import com.example.demo.service.CalendarEventsService;

@Controller
public class EventWebSocketController {

	private final CalendarEventsService calendarEventsService;

	public EventWebSocketController(CalendarEventsService calendarEventsService) {
		this.calendarEventsService = calendarEventsService;
	}

	@MessageMapping("/share-event") // 클라이언트가 보낼 메시지 경로
	@SendTo("/topic/events") // 메시지를 구독한 클라이언트로 전송
	public List<CalendarEvent> handleShareEvent(ShareEventRequest request) {
		
	    // 요청 데이터를 서비스 계층에 전달하여 처리
	    calendarEventsService.shareEvent(request);

	    // 공유된 이벤트 정보 리스트 생성 및 반환
	    return calendarEventsService.getEventsByIds(request.getEventId());
	}
}