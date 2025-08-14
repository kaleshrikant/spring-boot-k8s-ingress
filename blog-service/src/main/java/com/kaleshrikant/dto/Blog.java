package com.kaleshrikant.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * @author Shrikant Kale
 * @Date 8/14/25
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Blog {
	private String id;
	private String title;
	private String content;
	private String author;
}
