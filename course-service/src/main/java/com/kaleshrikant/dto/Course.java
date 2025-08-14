package com.kaleshrikant.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * @author Shrikant Kale
 * @Date 8/14/25
 */

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Course {
	private String courseId;
	private String name;
	private double price;
}
