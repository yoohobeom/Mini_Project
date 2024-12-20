package com.example.demo.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.dto.CalendarEvent;
import com.example.demo.dto.Rq;
import com.example.demo.dto.ShareEventRequest;
import com.example.demo.service.CalendarEventsService;

import jakarta.servlet.http.HttpServletRequest;

@Controller
@RequestMapping("/api/events")
public class UsrCalendarEventController {

    @Autowired
    private CalendarEventsService calendarEventsService;

    // 모든 이벤트 조회
    @GetMapping("/all")
    @ResponseBody
    public List<CalendarEvent> getAllEvents() {
        return calendarEventsService.getAllEvents();
    }

    // 새로운 이벤트 추가
    @PostMapping("/add")
    @ResponseBody
    public String addEvent(@RequestBody CalendarEvent event) {
        calendarEventsService.addEvent(event);
        return "Event added successfully";
    }

    // 특정 ID로 이벤트 조회
    @GetMapping("/id")
    @ResponseBody
    public CalendarEvent getEventById(@RequestParam("id") int id) {
    	System.out.println(id);
        return calendarEventsService.getEventById(id);
    }

    // 기존 이벤트 업데이트
    @PostMapping("/update")
    @ResponseBody
    public String updateEvent(@RequestBody CalendarEvent event) {
        calendarEventsService.updateEvent(event);
        return "Event updated successfully";
    }

//    // ID로 이벤트 삭제
    @PostMapping("/delete")
    @ResponseBody
    public String deleteEvent(@RequestParam(value="ids[]") List<Integer> ids) {
    	for (int a : ids) {
    		System.out.println(a);
    	}
    	calendarEventsService.deleteEvent(ids);
    	return "Event deleted successfully";
    }

    // 특정 날짜 범위로 이벤트 검색
    @GetMapping("/search")
    @ResponseBody
    public List<CalendarEvent> searchEvents(
            @RequestParam String start,
            @RequestParam String end, 
            HttpServletRequest req) {
    	
    	Rq rq = (Rq) req.getAttribute("rq");
    	
    	int loginedMemberId = rq.getLoginedMemberId();
    	
        return calendarEventsService.searchEvents(loginedMemberId, start, end);
    }
    
    @PostMapping("/share")
    public ResponseEntity<String> shareEvent(@RequestBody ShareEventRequest request) {
        calendarEventsService.shareEvent(request);
        return ResponseEntity.ok("이벤트가 성공적으로 공유되었습니다.");
    }
}

