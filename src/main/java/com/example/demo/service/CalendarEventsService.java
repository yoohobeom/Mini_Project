
package com.example.demo.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.dao.CalendarEventsDao;
import com.example.demo.dto.CalendarEvent;

@Service
public class CalendarEventsService {

    @Autowired
    private CalendarEventsDao calendarEventsDao;

    // 이벤트 추가
    public void addEvent(CalendarEvent event) {
        calendarEventsDao.addEvent(event);
    }

    // ID로 이벤트 조회
    public CalendarEvent getEventById(int id) {
        return calendarEventsDao.getEventById(id);
    }

    // 모든 이벤트 조회
    public List<CalendarEvent> getAllEvents() {
        return calendarEventsDao.getAllEvents();
    }

    // 기존 이벤트 업데이트
    public void updateEvent(CalendarEvent event) {
        calendarEventsDao.updateEvent(event);
    }

    // ID로 이벤트 삭제
    public void deleteEvent(int id) {
        calendarEventsDao.deleteEvent(id);
    }

    // 특정 날짜 범위로 이벤트 검색
    public List<CalendarEvent> searchEvents(String start, String end) {
        return calendarEventsDao.searchEvents(start, end);
    }
}
