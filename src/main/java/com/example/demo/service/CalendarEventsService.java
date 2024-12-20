
package com.example.demo.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.dao.CalendarEventsDao;
import com.example.demo.dto.CalendarEvent;
import com.example.demo.dto.ShareEventRequest;

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
    public void deleteEvent(List<Integer> ids) {
        calendarEventsDao.deleteEvent(ids);
    }

    // 특정 날짜 범위로 이벤트 검색
    public List<CalendarEvent> searchEvents(int loginedMemberId, String start, String end) {
        return calendarEventsDao.searchEvents(loginedMemberId, start, end);
    }
    
    // 이벤트 공유
	public void shareEvent(ShareEventRequest request) {
		 calendarEventsDao.addShare(request.getEventId(), request.getSharedUserId(), request.getPermission());
	}
	
    // 권한 검증 메서드
    public boolean hasPermission(int userId, int eventId, String requiredPermission) {
        String permission = calendarEventsDao.getUserPermission(userId, eventId);

        if (permission == null) {
            return false; // 권한 없음
        }

        // 권한 검증 로직
        if ("edit".equals(requiredPermission)) {
            return "edit".equals(permission);
        } else if ("view".equals(requiredPermission)) {
            return "edit".equals(permission) || "view".equals(permission);
        }

        return false; // 알 수 없는 권한 요청
    }

    // 이벤트 수정 로직 (권한 검증 포함)
    public void updateEvent(int userId, CalendarEvent event) {
        if (!hasPermission(userId, event.getId(), "edit")) {
            throw new IllegalStateException("권한이 없습니다.");
        }

        calendarEventsDao.updateEvent(event);
    }

    // 이벤트 삭제 로직 (권한 검증 포함)
    public void deleteEvent(int userId, int eventId) {
        if (!hasPermission(userId, eventId, "edit")) {
            throw new IllegalStateException("권한이 없습니다.");
        }

        calendarEventsDao.deleteShareEvent(eventId);
    }

    // 이벤트 조회 로직 (권한 포함)
    public List<CalendarEvent> getEventsWithPermission(int userId, String start, String end) {
        return calendarEventsDao.searchEvents(userId, start, end);
    }
}
