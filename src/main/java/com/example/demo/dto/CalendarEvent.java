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
    private LocalDateTime start;
    private LocalDateTime end;
    private boolean allDay;
    private String location;
    private String color;
    private String category;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String recurrence;
    private int organizerId;
    private String status;
}
