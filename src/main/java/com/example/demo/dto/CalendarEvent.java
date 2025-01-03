package com.example.demo.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CalendarEvent {
    private int id;
    private String title;
    private String description;
    private String start;
    private String end;
    private boolean allDay;
    private String location;
    private String color;
    private int categoryId; // 기존 category를 정규화
    private int recurrenceId; // 반복 규칙
    private int owner_id; // 작성자 고유번호
    private String owner; // 작성자 이름
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String status;
}
