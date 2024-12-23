package com.example.demo.dao;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import com.example.demo.dto.EventShare;

@Mapper
public interface ShareEventsDao {
    // 이벤트 공유 추가
    @Insert("""
    		INSERT INTO event_shares (eventId, shared_whith_user_name, permission)
    			VALUES (#{eventId}, #{shared_whith_user_name}, #{permission})
    		""")
	void addShare(EventShare share);
    
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
