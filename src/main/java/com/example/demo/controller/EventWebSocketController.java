package com.example.demo.controller;

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
    public CalendarEvent handleShareEvent(ShareEventRequest request) {
        // 요청 데이터를 기반으로 공유 처리
        calendarEventsService.shareEvent(request);
        
        System.out.println(request);
        // 공유된 이벤트 정보 반환
        return calendarEventsService.getEventById(request.getEventId());
    }
}