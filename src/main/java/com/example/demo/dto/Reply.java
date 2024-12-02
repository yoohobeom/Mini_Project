package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Reply {
	private int id;
	private String regDate;
	private String updateDate;
	private int memberId;
	private String relTypeCode;
	private String relId;
	private String body;
	
	private String loginId;
	
	public String getForPrintBody( ) {
		return this.body.replaceAll("\n", "<br />");
	}
}