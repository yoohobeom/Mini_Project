package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ShareEventRequest {
    private int eventId; // 공유된 일정 ID
    private int SharedUserId;
    private String sharedWith; // 공유 대상 (사용자 이름 또는 그룹)
    private String permission; // 권한 (view/edit)
    private String action; // 액션 타입 (add/update/delete)
}
