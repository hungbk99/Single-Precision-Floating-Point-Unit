//===================================================================
// Design name:		Braun Multiplication
// Note: 			Configurable Braun Multiplication
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

module Vedic_Multiplication 
#(
parameter	BIT_LENGTH = 24
)
(
	output	logic	[BIT_LENGTH-1:0]		result,
	output 	logic 							redundant_mul,
	input	[BIT_LENGTH-1:0]				man_x,
	input 	[BIT_LENGTH-1:0]				man_y
);
	logic 	[11:0] 	r0,
					r1;
					
	logic 	[23:0]	r2,
					r3,
					r4;
	
	logic	[23:0]	c_out_1,
					c_out_2,
					c_out_3,
					addr_slot2_1,
					addr_slot2_2,
					s_out_1,
					r5,
					r6;
					
	logic 	[24:0]	c_in_1,
					c_in_2,
					c_in_3;
					
	Vedic_12x12	V1212_1
	(
	.result({r1, r0}),
	.in1(man_x[11:0]),
	.in2(man_y[11:0])
	);
	
	Vedic_12x12	V1212_2
	(
	.result(r2),
	.in1(man_x[23:12]),
	.in2(man_y[11:0])
	);
	
	Vedic_12x12	V1212_3
	(
	.result(r3),
	.in1(man_x[11:0]),
	.in2(man_y[23:12])
	);
	
	Vedic_12x12	V1212_4	
	(
	.result(r4),
	.in1(man_x[23:12]),
	.in2(man_y[23:12])
	);
	
	assign 	c_in_1[0] = 1'b0;
	
	genvar a;
	generate
		for(a = 0; a < 24; a = a + 1)
		begin:	full_adder_1
			assign r5[a] = r3[a] ^ r2[a] ^ c_in_1[a];
			assign c_out_1[a] = r3[a] && r2[a] || c_in_1[a] && (r3[a] ^ r2[a]);
			assign c_in_1[a+1] = c_out_1[a];
		end
	endgenerate	
	
	assign	addr_slot2_1 = {12'b0, r1};
	assign 	c_in_2[0] = 1'b0;
	
	genvar b;
	generate
		for(b = 0; b < 24; b = b + 1)
		begin:	full_adder_2
			assign s_out_1[b] = r5[b] ^ addr_slot2_1[b] ^ c_in_2[b];
			assign c_out_2[b] = r5[b] && addr_slot2_1[b] || c_in_2[b] && (r5[b] ^ addr_slot2_1[b]);
			assign c_in_2[b+1] = c_out_2[b];
		end
	endgenerate		
	

	assign	addr_slot2_2 = {11'b0, c_out_1[23] || c_out_2[23],s_out_1[23:12]};
	assign 	c_in_3[0] = 1'b0;
	
	genvar c;
	generate
		for(c = 0; c < 24; c = c + 1)
		begin:	full_adder_3
			assign r6[c] = r4[c] ^ addr_slot2_2[c] ^ c_in_3[c];
			assign c_out_3[c] = r4[c] && addr_slot2_2[c] || c_in_3[c] && (r4[c] ^ addr_slot2_2[c]);
			assign c_in_3[c+1] = c_out_3[c];
		end
	endgenerate	
	
	assign 	redundant_mul  = r6[23];
	assign	result = {r6[22:0], s_out_1[11]};
/*
	logic 	[24*2-1:0]	check;
	assign 	check = {r6, s_out_1[11:0], r0};
*/
endmodule	

//===================================================================
//	3x3 Vedic multiplier
module	Vedic_3x3
(
	output 	[5:0]	result,
	input 	[2:0]	in1,
	input 	[2:0]	in2
);
	logic 	[8:0]			i_stage_1_1;
	
	logic 					r1,
							r2,
							r3,
							r4,
							r5,
							s2,
							s3;
							
	assign 	i_stage_1_1[0] = in1[0] && in2[0];
	assign 	i_stage_1_1[1] = in1[0] && in2[1];
	assign 	i_stage_1_1[2] = in1[1] && in2[0];
	assign 	i_stage_1_1[3] = in1[1] && in2[1];
	assign 	i_stage_1_1[4] = in1[2] && in2[0];
	assign 	i_stage_1_1[5] = in1[0] && in2[2];			
	assign 	i_stage_1_1[6] = in1[1] && in2[2];
	assign 	i_stage_1_1[7] = in1[2] && in2[1];
	assign 	i_stage_1_1[8] = in1[2] && in2[2];	
	
	assign 	result[0]	   = i_stage_1_1[0];
	
	assign 	result[1]	   = i_stage_1_1[1] ^ i_stage_1_1[2];	
	assign 	r1			   = i_stage_1_1[1] && i_stage_1_1[2];	
	
	assign 	s2			   = i_stage_1_1[3] ^ i_stage_1_1[4] ^ i_stage_1_1[5]; 
	assign 	r2 			   = i_stage_1_1[3] && i_stage_1_1[4] || i_stage_1_1[5] && (i_stage_1_1[3] ^ i_stage_1_1[4]);
	
	assign 	result[2]	   = r1 ^ s2; 
	assign 	r3			   = r1 && s2; 
	
	assign 	s3			   = i_stage_1_1[6] ^ i_stage_1_1[7];
	assign 	r4			   = i_stage_1_1[6] && i_stage_1_1[7]; 
	
	assign 	result[3]	   = s3 ^ r2 ^ r3;
	assign 	r5			   = s3 && r2 || r3 && (s3 ^ r2);
	
	assign 	result[4]	   = i_stage_1_1[8] ^ r4 ^ r5;
	assign 	result[5] 	   = i_stage_1_1[8] && r4 || r5 && (i_stage_1_1[8] ^ r4);
	
endmodule

//===================================================================
//	6x6 Vedic multiplier	
module Vedic_6x6
(
	output	[11:0]	result,
	input 	[5:0]	in1,
	input 	[5:0]	in2
);
	logic 	[2:0] 	r0,
					r1;
					
	logic 	[5:0]	r2,
					r3,
					r4;
	
	logic	[5:0]	c_out_1,
					c_out_2,
					c_out_3,
					addr_slot2_1,
					addr_slot2_2,
					s_out_1,
					r5,
					r6;
					
	logic 	[6:0]	c_in_1,
					c_in_2,
					c_in_3;
					
	Vedic_3x3	V33_1
	(
	.result({r1, r0}),
	.in1(in1[2:0]),
	.in2(in2[2:0])
	);
	
	Vedic_3x3	V33_2
	(
	.result(r2),
	.in1(in1[5:3]),
	.in2(in2[2:0])
	);
	
	Vedic_3x3	V33_3
	(
	.result(r3),
	.in1(in1[2:0]),
	.in2(in2[5:3])
	);
	
	Vedic_3x3	V33_4	
	(
	.result(r4),
	.in1(in1[5:3]),
	.in2(in2[5:3])
	);
	
	assign 	c_in_1[0] = 1'b0;
	
	genvar a;
	generate
		for(a = 0; a < 6; a = a + 1)
		begin:	full_adder_1
			assign r5[a] = r3[a] ^ r2[a] ^ c_in_1[a];
			assign c_out_1[a] = r3[a] && r2[a] || c_in_1[a] && (r3[a] ^ r2[a]);
			assign c_in_1[a+1] = c_out_1[a];
		end
	endgenerate	
	
	assign	addr_slot2_1 = {3'b0, r1};
	assign 	c_in_2[0] = 1'b0;
	
	genvar b;
	generate
		for(b = 0; b < 6; b = b + 1)
		begin:	full_adder_2
			assign s_out_1[b] = r5[b] ^ addr_slot2_1[b] ^ c_in_2[b];
			assign c_out_2[b] = r5[b] && addr_slot2_1[b] || c_in_2[b] && (r5[b] ^ addr_slot2_1[b]);
			assign c_in_2[b+1] = c_out_2[b];
		end
	endgenerate		
	

	assign	addr_slot2_2 = {2'b0, c_out_1[5] || c_out_2[5],s_out_1[5:3]};
	assign 	c_in_3[0] = 1'b0;
	
	genvar c;
	generate
		for(c = 0; c < 6; c = c + 1)
		begin:	full_adder_3
			assign r6[c] = r4[c] ^ addr_slot2_2[c] ^ c_in_3[c];
			assign c_out_3[c] = r4[c] && addr_slot2_2[c] || c_in_3[c] && (r4[c] ^ addr_slot2_2[c]);
			assign c_in_3[c+1] = c_out_3[c];
		end
	endgenerate	
	
	assign	result = {r6, s_out_1[2:0], r0};
	
endmodule

//===================================================================
//	12x12 Vedic multiplier 	
module	Vedic_12x12
(
	output 	[23:0]	result,
	input 	[11:0]	in1,
	input	[11:0]	in2 	
);
	logic 	[5:0] 	r0,
					r1;
					
	logic 	[11:0]	r2,
					r3,
					r4;
	
	logic	[11:0]	c_out_1,
					c_out_2,
					c_out_3,
					addr_slot2_1,
					addr_slot2_2,
					s_out_1,
					r5,
					r6;
					
	logic 	[12:0]	c_in_1,
					c_in_2,
					c_in_3;
					
	Vedic_6x6	V66_1
	(
	.result({r1, r0}),
	.in1(in1[5:0]),
	.in2(in2[5:0])
	);
	
	Vedic_6x6	V66_2
	(
	.result(r2),
	.in1(in1[11:6]),
	.in2(in2[5:0])
	);
	
	Vedic_6x6	V66_3
	(
	.result(r3),
	.in1(in1[5:0]),
	.in2(in2[11:6])
	);
	
	Vedic_6x6	V66_4	
	(
	.result(r4),
	.in1(in1[11:6]),
	.in2(in2[11:6])
	);
	
	assign 	c_in_1[0] = 1'b0;
	
	genvar a;
	generate
		for(a = 0; a < 12; a = a + 1)
		begin:	full_adder_1
			assign r5[a] = r3[a] ^ r2[a] ^ c_in_1[a];
			assign c_out_1[a] = r3[a] && r2[a] || c_in_1[a] && (r3[a] ^ r2[a]);
			assign c_in_1[a+1] = c_out_1[a];
		end
	endgenerate	
	
	assign	addr_slot2_1 = {6'b0, r1};
	assign 	c_in_2[0] = 1'b0;
	
	genvar b;
	generate
		for(b = 0; b < 12; b = b + 1)
		begin:	full_adder_2
			assign s_out_1[b] = r5[b] ^ addr_slot2_1[b] ^ c_in_2[b];
			assign c_out_2[b] = r5[b] && addr_slot2_1[b] || c_in_2[b] && (r5[b] ^ addr_slot2_1[b]);
			assign c_in_2[b+1] = c_out_2[b];
		end
	endgenerate		
	

	assign	addr_slot2_2 = {5'b0, c_out_1[11] || c_out_2[11],s_out_1[11:6]};
	assign 	c_in_3[0] = 1'b0;
	
	genvar c;
	generate
		for(c = 0; c < 12; c = c + 1)
		begin:	full_adder_3
			assign r6[c] = r4[c] ^ addr_slot2_2[c] ^ c_in_3[c];
			assign c_out_3[c] = r4[c] && addr_slot2_2[c] || c_in_3[c] && (r4[c] ^ addr_slot2_2[c]);
			assign c_in_3[c+1] = c_out_3[c];
		end
	endgenerate	
	
	assign	result = {r6, s_out_1[5:0], r0};
endmodule