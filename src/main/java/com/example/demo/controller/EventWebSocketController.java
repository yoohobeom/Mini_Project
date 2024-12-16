package com.example.demo.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

import com.example.demo.dto.SharedEventMessage;

@Controller
public class EventWebSocketController {

    // 클라이언트가 /app/share-event로 메시지를 보내면 처리
    @MessageMapping("/share-event")
    @SendTo("/topic/events")
    public SharedEventMessage handleEventSharing(SharedEventMessage message) {
        // 메시지 처리 로직 (DB 저장, 비즈니스 로직 등)
        return message; // 모든 구독자에게 전송
    }
}