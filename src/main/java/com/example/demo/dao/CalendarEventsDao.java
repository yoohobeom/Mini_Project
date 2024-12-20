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

    // 이벤트 추가
    @Insert("""
            INSERT INTO calendar_events
            (title, description, start, end, all_day, category_id, owner_id, created_at, updated_at)
            VALUES
            (#{title}, #{description}, #{start}, #{end}, #{allDay}, #{categoryId}, #{ownerId}, NOW(), NOW())
            """)
    void addEvent(CalendarEvent event);

    // 특정 ID로 이벤트 조회
    @Select("""
            SELECT e.*, c.name AS category_name, m.name AS owner_name
            FROM calendar_events e
            LEFT JOIN categories c ON e.category_id = c.id
            LEFT JOIN member m ON e.owner_id = m.id
            WHERE e.id = #{id}
            """)
    CalendarEvent getEventById(int id);

    // 모든 이벤트 조회
    @Select("""
            SELECT e.*, c.name AS category_name, u.username AS owner_name
            FROM calendar_events e
            LEFT JOIN categories c ON e.category_id = c.id
            LEFT JOIN member m ON e.owner_id = m.id
            """)
    List<CalendarEvent> getAllEvents();

    // 이벤트 업데이트
    @Update("""
            UPDATE calendar_events
            SET title = #{title}, description = #{description}, start = #{start},
                end = #{end}, all_day = #{allDay}, category_id = #{categoryId},
                owner_id = #{ownerId}, updated_at = NOW()
            WHERE id = #{id}
            """)
    void updateEvent(CalendarEvent event);

    // 이벤트 삭제
    @Delete("""
	    	<script>
	        DELETE FROM calendar_events WHERE id IN
	        <foreach collection='ids' item='id' open='(' separator=',' close=')'>
	        #{id}
	        </foreach>
	        </script>
    		""")
    void deleteEvent(List<Integer> ids);

    // 특정 날짜 범위의 이벤트 검색
    @Select("""
			SELECT e.*, c.name AS category_name, m.name AS owner
				FROM calendar_events e
				LEFT JOIN categories c ON e.category_id = c.id
    			LEFT JOIN member m ON e.owner_id = m.id
				WHERE (e.owner_id = #{loginedMemberId} OR e.id IN (
				    SELECT event_id
				    FROM event_shares
				    WHERE shared_with_user_id = #{loginedMemberId}
				))
				AND e.start < #{end} AND e.end > #{start};
            """)
    List<CalendarEvent> searchEvents(int loginedMemberId, @Param("start") String start, @Param("end") String end);

    // 이벤트 공유 추가
    @Insert("""
    		INSERT INTO event_shares (event_id, shared_user_id, permission)
    			VALUES (#{eventId}, #{sharedUserId}, #{permission})
    		""")
	void addShare(@Param("eventId") int eventId, @Param("sharedUserId") int sharedUserId, @Param("permission") String permission);
    
    // 일정 공유 조회
    @Select("""
    		SELECT permission
    			FROM event_shares
    			WHERE event_id = #{eventId}
    			AND shared_user_id = #{userId}
    		""")
    String getUserPermission(@Param("userId") int userId, @Param("eventId") int eventId);
    
    @Delete("""
    		DELETE FROM calendar_events
    			WHERE id = #{eventId}
    		""")
	void deleteShareEvent(@Param("eventId") int eventId);

}
