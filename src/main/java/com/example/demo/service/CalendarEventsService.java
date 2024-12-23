
package com.example.demo.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.dao.CalendarEventsDao;
import com.example.demo.dao.ShareEventsDao;
import com.example.demo.dto.CalendarEvent;
import com.example.demo.dto.EventShare;
import com.example.demo.dto.ShareEventRequest;

@Service
public class CalendarEventsService {
	private CalendarEventsDao calendarEventsDao;
	private ShareEventsDao shareEventsDao;

    @Autowired
    public void ShareEventsDao(CalendarEventsDao calendarEventsDao, ShareEventsDao shareEventsDao) {
    	this.calendarEventsDao = calendarEventsDao;
        this.shareEventsDao = shareEventsDao;
    }
    
    // 이벤트 추가
    public void addEvent(CalendarEvent event) {
        calendarEventsDao.addEvent(event);
    }

    // ID로 이벤트 조회
    public CalendarEvent getEventById(int id) {
        return calendarEventsDao.getEventById(id);
    }
    
    // 여러 이벤트 ID 조회
    public List<CalendarEvent> getEventsByIds(int[] eventIds) {
        List<CalendarEvent> events = new ArrayList<>();
        for (int id : eventIds) {
            CalendarEvent event = getEventById(id); // 기존 단일 ID 메서드 재사용
            if (event != null) {
                events.add(event);
            }
        }
        return events;
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
    public List<CalendarEvent> searchEvents(int loginedMemberId, String loginedMemberName, String start, String end) {
        System.out.println("Before DAO call:");
        System.out.println("loginedMemberId: " + loginedMemberId);
        System.out.println("loginedMemberName: " + loginedMemberName);
        System.out.println("start: " + start);
        System.out.println("end: " + end);
        return calendarEventsDao.searchEvents(loginedMemberId, loginedMemberName, start, end);
    }
    
    // 공유 처리 로직
    public void shareEvent(ShareEventRequest request) {
        for (int eventId : request.getEventId()) {
        	
            // 각 이벤트에 대해 공유 처리
            EventShare share = new EventShare();
            share.setEventId(eventId);
            share.setShared_with_user_name(request.getShared_with_user_name());
            share.setPermission(request.getPermission());
            
            // 데이터베이스에 저장
            shareEventsDao.addShare(share);
        }
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

}
