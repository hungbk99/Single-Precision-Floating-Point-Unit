//===================================================================
// Design name:		Post Normalization For Multiplication and Divition							
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

`include"FPU_define.h"
import FPU_192_Package::*;
module Post_Normalization_MD
(
	output									overflow,
	output 									underflow,
	output 	[FORMAT_LENGTH-1:0] 			nor_result,
	input	[EXPONENT_LENGTH-1:0] 			exp,
	input 	[NORMALIZE_MANTISSA_LENGTH-1:0] mul_result,
											div_result,
	input 									redundant_mul,
	input 									div_mul,
	input 									sign
);	

//	Internal Signals
//	Signals for Checking Block
	logic 	left_right;
	logic 	[4:0] left_count;
//	logic 	zero_detect;
	
// 	Signals for Fraction Normalization	
	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0]	right_result,
											left_result,
											left_1,
											left_2,
											left_4,
											left_8,
											left_16,
											man;
	logic 	[FRACTION_LENGTH-1:0] 			nor_fra;

//	Signals for Exponent Normalization
	logic 	[7:0] lv1_inc_dec;
	logic 	[6:0] lv2_inc_dec;
	logic 	[5:0] lv3_inc_dec;	
	logic 	[4:0] lv4_inc_dec;	
	logic 	[3:0] lv5_inc_dec;
	logic 	[7:0] lv1_ex;
	logic 	[6:0] lv2_ex;
	logic 	[5:0] lv3_ex;
	logic 	[4:0] lv4_ex;
	logic 	[3:0] lv5_ex;
	logic 	[7:0] nor_ex;
	logic 	[6:0] gp_1_1;
	logic 	[5:0] gp_2_1;
	logic 	[4:0] gp_3_1;
	logic 	[3:0] gp_4_1;
	logic 	[2:0] gp_5_1;
	logic 	[6:0] gp_1_2;
	logic 	[5:0] gp_2_2;
	logic 	[4:0] gp_3_2;
	logic 	[3:0] gp_4_2;
	logic 	[2:0] gp_5_2;
	logic 	[6:0] gp_1_3;
	logic 	[5:0] gp_2_3;
	logic 	[4:0] gp_3_3;
	logic 	[3:0] gp_4_3;
	logic 	[2:0] gp_5_3;	
	logic 	[4:0] c_exp_o;
	
//	Checking Block
	always_comb begin
		if (!div_mul)
		begin
			left_right = 1'b0;
			man = mul_result;
			if(redundant_mul)
				left_count = 5'h01;
			else 
				left_count = '0;		
		end	
		else
		begin
			left_right = 1'b1;
			man = div_result;
			casez(div_result)
				24'b1???_????_????_????_????_????: 	left_count = 5'h00;
				24'b01??_????_????_????_????_????: 	left_count = 5'h01;
				24'b001?_????_????_????_????_????:	left_count = 5'h02;
				24'b0001_????_????_????_????_????:	left_count = 5'h03;
				24'b0000_1???_????_????_????_????:	left_count = 5'h04;
				24'b0000_01??_????_????_????_????: 	left_count = 5'h05;
				24'b0000_001?_????_????_????_????: 	left_count = 5'h06;
				24'b0000_0001_????_????_????_????: 	left_count = 5'h07;
				24'b0000_0000_1???_????_????_????: 	left_count = 5'h08;
				24'b0000_0000_01??_????_????_????: 	left_count = 5'h09;
				24'b0000_0000_001?_????_????_????: 	left_count = 5'h0a;
				24'b0000_0000_0001_????_????_????:	left_count = 5'h0b;
				24'b0000_0000_0000_1???_????_????: 	left_count = 5'h0c;
				24'b0000_0000_0000_01??_????_????: 	left_count = 5'h0d;
				24'b0000_0000_0000_001?_????_????:	left_count = 5'h0e;
				24'b0000_0000_0000_0001_????_????: 	left_count = 5'h0f;
				24'b0000_0000_0000_0000_1???_????: 	left_count = 5'h10;
				24'b0000_0000_0000_0000_01??_????: 	left_count = 5'h11;
				24'b0000_0000_0000_0000_001?_????: 	left_count = 5'h12;
				24'b0000_0000_0000_0000_0001_????: 	left_count = 5'h13;
				24'b0000_0000_0000_0000_0000_1???:	left_count = 5'h14;
				24'b0000_0000_0000_0000_0000_01??: 	left_count = 5'h15;
				24'b0000_0000_0000_0000_0000_001?: 	left_count = 5'h16;
				24'b0000_0000_0000_0000_0000_0001: 	left_count = 5'h17;
				default:	left_count = 5'h00;
			endcase
		end
	end
	
//	assign zero_detect = ~(|man);

//	Fraction Normalization	
//	Shift Right
	genvar	i;
	generate
		for(i = 0; i < NORMALIZE_MANTISSA_LENGTH - 1; i = i + 1)
		begin: shift_right
			assign	right_result[i] = mul_result[i+1];
		end
	endgenerate

//	Shift Left
	genvar	a;
	generate
		for(a = 1; a < NORMALIZE_MANTISSA_LENGTH; a  = a + 1)
		begin:	shift_1
			assign 	left_1[a] = (left_count[0]) ? left_2[a-1] : left_2[a];	 
		end
		assign	left_1[0] = (left_count[0]) ? 1'b0 : left_2[0];
	endgenerate	
	
	genvar	b;
	generate	
		for(b = 2; b < NORMALIZE_MANTISSA_LENGTH; b = b + 1)
		begin:	shift_2
			assign 	left_2[b] = (left_count[1]) ? left_4[b-2] : left_4[b];
		end
		assign 	left_2[0] = (left_count[1]) ? 1'b0 : left_4[0];
		assign 	left_2[1] = (left_count[1]) ? 1'b0 : left_4[1];
	endgenerate
	
	genvar 	c;
	generate
		for(c = 4; c < NORMALIZE_MANTISSA_LENGTH; c = c + 1)
		begin: 	shift_4
			assign	left_4[c] = (left_count[2]) ? left_8[c-4] : left_8[c];
		end
		assign 	left_4[0] = (left_count[2]) ? 1'b0 : left_8[0];
		assign	left_4[1] = (left_count[2]) ? 1'b0 : left_8[1];
		assign 	left_4[2] = (left_count[2]) ? 1'b0 : left_8[2];
		assign 	left_4[3] = (left_count[2]) ? 1'b0 : left_8[3];
	endgenerate
	
	genvar d;
	generate
		for(d = 0; d < 8; d = d + 1)
		begin:	shift_8_1
			assign	left_8[d] = (left_count[3]) ? 1'b0 : left_16[d];
		end
	endgenerate
	
	genvar e;
	generate
		for(e = 8; e < NORMALIZE_MANTISSA_LENGTH; e = e + 1)
		begin: 	shift_8_2
			assign 	left_8[e] = (left_count[3]) ? left_16[e-8] : left_16[e];
		end
	endgenerate
	
	genvar f;
	generate
		for(f = 0; f < 16; f = f + 1)
		begin: 	shift_16_1
			assign left_16[f] = (left_count[4]) ? 1'b0 : man[f];
		end	
	endgenerate
	
	genvar g;
	generate
		for(g = 16; g < NORMALIZE_MANTISSA_LENGTH; g = g + 1)
		begin:	shift_16_2
			assign 	left_16[g] = (left_count[4]) ? man[g-16] : man[g];
		end
	endgenerate
	
	assign 	left_result = left_1;
	
//	Exponent Normalization	
//	Level 1:	8 bit parallel-prefix incrementer-decrementer
// 	pre_inc_dec
	genvar h;
	generate 
		for(h = 0; h < 8; h = h + 1)
		begin:	inc_dec_lv1
			assign 	lv1_inc_dec[h] = exp[h] ^ (left_right);
		end
	endgenerate

//	stage 1 of level 1
	genvar j;
	generate
		for(j = 1; j < 4; j = j + 1)
		begin: 	stage1_level1
			assign 	gp_1_1[2*j-1] = lv1_inc_dec[2*j-1];	
			assign 	gp_1_1[2*j] = lv1_inc_dec[2*j] && lv1_inc_dec[2*j-1];
		end
		assign	gp_1_1[0] = lv1_inc_dec[0] && left_count[0];
	endgenerate

//	Stage 2 of level 1
	assign 	gp_1_2[0] = gp_1_1[0];
	assign 	gp_1_2[1] = gp_1_1[1] && gp_1_1[0];
	assign 	gp_1_2[2] = gp_1_1[2] && gp_1_1[0];
	assign  gp_1_2[3] = gp_1_1[3];
	assign 	gp_1_2[4] = gp_1_1[4];
	assign 	gp_1_2[5] = gp_1_1[5] && gp_1_1[4];
	assign 	gp_1_2[6] = gp_1_1[6] && gp_1_1[4];
	
//	Stage 3 of level 1
	assign 	gp_1_3[0] = gp_1_2[0];
	assign 	gp_1_3[1] = gp_1_2[1];
	assign 	gp_1_3[2] = gp_1_2[2];
	assign 	gp_1_3[3] = gp_1_2[2] && gp_1_2[3];
	assign 	gp_1_3[4] = gp_1_2[2] && gp_1_2[4];
	assign 	gp_1_3[5] = gp_1_2[2] && gp_1_2[5];
	assign 	gp_1_3[6] = gp_1_2[2] && gp_1_2[6];	
	
//	Post Level 1
	genvar k;
	generate
		for(k = 1; k < 8; k = k + 1)
		begin: 	post_level1
			assign	lv1_ex[k] = gp_1_3[k-1] ^ exp[k];
		end
		assign lv1_ex[0] = left_count[0] ^ exp[0];
		assign c_exp_o[0] = gp_1_3[6] && lv1_inc_dec[7]; 
	endgenerate	
	
//	Level 2: 7 bit parallel-prefix decrementer
// 	pre_inc_dec
	genvar u;
	generate 
		for(u = 0; u < 7; u = u + 1)
		begin:	inc_dec_lv2
			assign 	lv2_inc_dec[u] = lv1_ex[u+1] ^ (left_right);
		end
	endgenerate
	
//	Stage 1 of level 2
	assign	gp_2_1[0] = lv2_inc_dec[0] && left_count[1];
	assign 	gp_2_1[1] = lv2_inc_dec[1];
	assign 	gp_2_1[2] = lv2_inc_dec[2] && lv2_inc_dec[1];
	assign 	gp_2_1[3] = lv2_inc_dec[3];
	assign 	gp_2_1[4] = lv2_inc_dec[4] && lv2_inc_dec[3];
	assign 	gp_2_1[5] = lv2_inc_dec[5];
	
// 	Stage 2 of level 2
	assign 	gp_2_2[0] = gp_2_1[0];
	assign	gp_2_2[1] = gp_2_1[1] && gp_2_1[0];
	assign 	gp_2_2[2] = gp_2_1[2] && gp_2_1[0];
	assign 	gp_2_2[3] = gp_2_1[3];
	assign 	gp_2_2[4] = gp_2_1[4];
	assign 	gp_2_2[5] = gp_2_1[5] && gp_2_1[4];

// 	Stage 3 of level 2
	assign	gp_2_3[0] = gp_2_2[0];
	assign 	gp_2_3[1] = gp_2_2[1];
	assign 	gp_2_3[2] = gp_2_2[2];
	assign 	gp_2_3[3] = gp_2_2[3] && gp_2_2[2];
	assign 	gp_2_3[4] = gp_2_2[4] && gp_2_2[2];
	assign 	gp_2_3[5] = gp_2_2[5] && gp_2_2[2];

// 	Post Level 2
	genvar l;
	generate
		for(l = 1; l < 7; l = l + 1)
		begin: 	post_level2
			assign	lv2_ex[l] = lv1_ex[l+1] ^ gp_2_3[l-1];
		end
		assign 	lv2_ex[0] = lv1_ex[1] ^ left_count[1];
		assign 	c_exp_o[1] = lv2_inc_dec[6] && gp_2_3[5];
	endgenerate 
	
// 	Level 3: 	6 bit parallel-prefix decrementer
// 	pre_inc_dec
	genvar r;
	generate 
		for(r = 0; r < 6; r = r + 1)
		begin:	inc_dec_lv3
			assign 	lv3_inc_dec[r] = lv2_ex[r+1] ^ (left_right);
		end
	endgenerate
	
//	Stage 1 of level 3
	assign	gp_3_1[0] = lv3_inc_dec[0] && left_count[2];
	assign 	gp_3_1[1] = lv3_inc_dec[1];
	assign 	gp_3_1[2] = lv3_inc_dec[2] && lv3_inc_dec[1];
	assign 	gp_3_1[3] = lv3_inc_dec[3];
	assign 	gp_3_1[4] = lv3_inc_dec[4] && lv3_inc_dec[3];
	
// 	Stage 2 of level 3
	assign 	gp_3_2[0] = gp_3_1[0];
	assign	gp_3_2[1] = gp_3_1[1] && gp_3_1[0];
	assign 	gp_3_2[2] = gp_3_1[2] && gp_3_1[0];
	assign 	gp_3_2[3] = gp_3_1[3];
	assign 	gp_3_2[4] = gp_3_1[4];

// 	Stage 3 of level 3
	assign	gp_3_3[0] = gp_3_2[0];
	assign 	gp_3_3[1] = gp_3_2[1];
	assign 	gp_3_3[2] = gp_3_2[2];
	assign 	gp_3_3[3] = gp_3_2[3] && gp_3_2[2];
	assign 	gp_3_3[4] = gp_3_2[4] && gp_3_2[2];

// 	Post Level 3
	genvar x;
	generate
		for(x = 1; x < 6; x = x + 1)
		begin: 	post_level3
			assign	lv3_ex[x] = lv2_ex[x+1] ^ gp_3_3[x-1];
		end
		assign 	lv3_ex[0] = lv2_ex[1] ^ left_count[2];
		assign 	c_exp_o[2] = lv3_inc_dec[5] && gp_3_3[4];
	endgenerate

// 	Level 4: 	5 bit parallel-prefix decrementer
// 	pre_inc_dec
	genvar t;
	generate 
		for(t = 0; t < 5; t = t + 1)
		begin:	inc_dec_lv4
			assign 	lv4_inc_dec[t] = lv3_ex[t+1] ^ (left_right);
		end
	endgenerate
	
//	Stage 1 of level 4
	assign	gp_4_1[0] = lv4_inc_dec[0] && left_count[3];
	assign 	gp_4_1[1] = lv4_inc_dec[1];
	assign 	gp_4_1[2] = lv4_inc_dec[2] && lv4_inc_dec[1];
	assign 	gp_4_1[3] = lv4_inc_dec[3];

// 	Stage 2 of level 4
	assign 	gp_4_2[0] = gp_4_1[0];
	assign	gp_4_2[1] = gp_4_1[1] && gp_4_1[0];
	assign 	gp_4_2[2] = gp_4_1[2] && gp_4_1[0];
	assign 	gp_4_2[3] = gp_4_1[3];

// 	Stage 3 of level 4
	assign	gp_4_3[0] = gp_4_2[0];
	assign 	gp_4_3[1] = gp_4_2[1];
	assign 	gp_4_3[2] = gp_4_2[2];
	assign 	gp_4_3[3] = gp_4_2[3] && gp_4_2[2];

// 	Post Level 4
	genvar y;
	generate
		for(y = 1; y < 5; y = y + 1)
		begin: 	post_level4
			assign	lv4_ex[y] = lv3_ex[y+1] ^ gp_4_3[y-1];
		end
		assign 	lv4_ex[0] = lv3_ex[1] ^ left_count[3];
		assign 	c_exp_o[3] = lv4_inc_dec[4] && gp_4_3[3];
	endgenerate 

// 	Level 5: 	4 bit parallel-prefix decrementer
// 	pre_inc_dec
	genvar w;
	generate 
		for(w = 0; w < 4; w = w + 1)
		begin:	inc_dec_lv5
			assign 	lv5_inc_dec[w] = lv4_ex[w+1] ^ (left_right);
		end
	endgenerate
	
//	Stage 1 of level 5
	assign	gp_5_1[0] = lv5_inc_dec[0] && left_count[4];
	assign 	gp_5_1[1] = lv5_inc_dec[1];
	assign 	gp_5_1[2] = lv5_inc_dec[2] && lv5_inc_dec[1];

// 	Stage 2 of level 5
	assign 	gp_5_2[0] = gp_5_1[0];
	assign	gp_5_2[1] = gp_5_1[1] && gp_5_1[0];
	assign 	gp_5_2[2] = gp_5_1[2] && gp_5_1[0];

// 	Stage 3 of level 5
	assign	gp_5_3[0] = gp_5_2[0];
	assign 	gp_5_3[1] = gp_5_2[1];
	assign 	gp_5_3[2] = gp_5_2[2];

// 	Post Level 5
	genvar z;
	generate
		for(z = 1; z < 4; z = z + 1)
		begin: 	post_level5
			assign	lv5_ex[z] = lv4_ex[z+1] ^ gp_5_3[z-1];
		end
		assign 	lv5_ex[0] = lv4_ex[1] ^ left_count[4];
		assign 	c_exp_o[4] = lv5_inc_dec[2] && gp_5_3[2];
	endgenerate 
 	 
	assign 	nor_fra = (div_mul) ?  left_result : ((redundant_mul) ? right_result : mul_result);
	assign 	nor_ex[7:0] = {lv5_ex[3:0], lv4_ex[0], lv3_ex[0], lv2_ex[0], lv1_ex[0]};
	assign 	overflow = (exp == 8'hfe) && !left_right;
	assign 	underflow = |c_exp_o[4:0] && left_right;
	assign 	nor_result = {sign, nor_ex, nor_fra};
	

endmodule	