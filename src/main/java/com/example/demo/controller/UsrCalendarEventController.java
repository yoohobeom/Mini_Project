package com.example.demo.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.dto.CalendarEvent;
import com.example.demo.service.CalendarEventsService;

@Controller
public class UsrCalendarEventController {

    @Autowired
    private CalendarEventsService calendarEventsService;

    // 모든 이벤트 조회 (FullCalendar에 이벤트를 제공하기 위한 형식)
    @GetMapping("/all")
    @ResponseBody
    public List<CalendarEvent> getAllEvents() {
        return calendarEventsService.getAllEvents();
    }

    // 새로운 이벤트 추가 (FullCalendar에서 사용자가 직접 추가)
    @PostMapping("/add")
    @ResponseBody
    public String addEvent(@RequestBody CalendarEvent event) {
        calendarEventsService.addEvent(event);
        return "Event added successfully";
    }

    // ID로 이벤트 조회
    @GetMapping("/{id}")
    @ResponseBody
    public CalendarEvent getEventById(@PathVariable int id) {
        return calendarEventsService.getEventById(id);
    }

    // 기존 이벤트 업데이트
    @PutMapping("/update")
    @ResponseBody
    public String updateEvent(@RequestBody CalendarEvent event) {
        calendarEventsService.updateEvent(event);
        return "Event updated successfully";
    }

    // ID로 이벤트 삭제
    @DeleteMapping("/delete/{id}")
    @ResponseBody
    public String deleteEvent(@PathVariable int id) {
        calendarEventsService.deleteEvent(id);
        return "Event deleted successfully";
    }

    // 특정 날짜의 이벤트 조회 (FullCalendar에서 날짜 클릭 시 스케줄을 표시하기 위함)
    @GetMapping("/api/events/search")
    @ResponseBody
    public List<CalendarEvent> searchEvents(@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) String start,
                                            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) String end) {
        return calendarEventsService.searchEvents(start, end);
    }

    // 특정 날짜 클릭 시 추가 정보를 제공하기 위한 메서드
    @GetMapping("/details")
    @ResponseBody
    public List<CalendarEvent> getEventDetails(@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) String date) {
        return calendarEventsService.searchEvents(date, date);
    }
}

