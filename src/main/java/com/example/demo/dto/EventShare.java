package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class EventShare {
    private int eventId; // 공유된 일정 ID
    private int shared_with_user_id;
    private String shared_whith_user_name; // 공유 대상 (사용자 이름)
    private String permission; // 권한 (view/edit)
}
