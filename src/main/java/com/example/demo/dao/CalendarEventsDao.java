package com.example.demo.dao;

import java.util.List;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import com.example.demo.dto.CalendarEvent;

@Mapper
public interface CalendarEventsDao {

    @Insert("""
            INSERT INTO calendar_events
                SET title = #{title}
                , description = #{description}
                , start = #{start}
                , end = #{end}
                , all_day = #{allDay}
                , location = #{location}
                , color = #{color}
                , category = #{category}
                , created_at = NOW()
                , updated_at = NOW()
                , recurrence = #{recurrence}
                , organizer_id = #{organizerId}
                , status = #{status}
            """)
    void addEvent(CalendarEvent event);

    @Select("SELECT * FROM calendar_events WHERE id = #{id}")
    CalendarEvent getEventById(int id);

    @Select("SELECT * FROM calendar_events")
    List<CalendarEvent> getAllEvents();

    @Update("""
            UPDATE calendar_events
                SET title = #{title}
                , description = #{description}
                , start = #{start}
                , end = #{end}
                , all_day = #{allDay}
                , location = #{location}
                , color = #{color}
                , category = #{category}
                , updated_at = NOW()
                , recurrence = #{recurrence}
                , organizer_id = #{organizerId}
                , status = #{status}
            WHERE id = #{id}
            """)
    void updateEvent(CalendarEvent event);

    @Delete("DELETE FROM calendar_events WHERE id = #{id}")
    void deleteEvent(int id);
    
    // 특정 날짜의 이벤트 검색
    @Select("SELECT * FROM calendar_events WHERE start >= #{start} AND end <= #{end}")
    List<CalendarEvent> searchEvents(@Param("start") String start, @Param("end") String end);
}