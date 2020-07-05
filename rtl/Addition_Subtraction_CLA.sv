//===================================================================
// Design name:		Addition & Subtraction
// Note: 			Carry Lookahead Adder								
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================


import FPU_192_Package::*;
module	Addition_Subtraction_CLA
#(
	parameter 	CALCULATE_LENGTH = 24
)
(
	output	[CALCULATE_LENGTH-1:0] 			result,
	output 									cout,
	input	[CALCULATE_LENGTH-1:0] 			man_x,
	input 	[CALCULATE_LENGTH-1:0] 			man_y,
	input 									sign_x,
	input 									sign_y,
	input 									add_sub
);
	
//=============================Interfaces=============================
//	Outputs	
	


//====================================================================		
//Internal signals
	logic 	operate;
	logic	[CALCULATE_LENGTH-1:0] g;
	logic 	[CALCULATE_LENGTH-1:0] p;
	logic 	[CALCULATE_LENGTH-1:0] c_in;
	logic 	[5:0] cout_L2;
	logic 	[1:0] cout_L3;
	logic 	[5:0] pin_L2;
	logic 	[1:0] pin_L3;
	logic 	[5:0] gin_L2;
	logic 	[1:0] gin_L3;

//====================================================================

//	Sign
	always_comb begin
		operate = 1'b0;
		case({add_sub, sign_x, sign_y})
		3'b000:	operate = 0;
		3'b001:	operate = 1;		
		3'b010:	operate = 1;		
		3'b011:	operate = 0;	
		3'b100:	operate = 1;		
		3'b101:	operate = 0;		
		3'b110:	operate = 0;		
		3'b111:	operate = 1;		
		endcase
	end
	
//	CLA	
//	FULL ADDER: Pre Processing Stage
	genvar a;
	generate
		for(a = 0; a < CALCULATE_LENGTH; a = a + 1)
		begin:	full_adder
			assign 	g[a] = man_x[a]&&(man_y[a]^operate); 
			assign 	p[a] = man_x[a]^(man_y[a]^operate); 
			assign 	result[a] = p[a]^c_in[a];
		end
	endgenerate	

//	CLA Level 1
//	6 block 4 bit CLA
	genvar b;
	generate
		for(b = 0; b < 6; b = b +1)
		begin:	level_1	
			assign c_in[4*b] = cout_L2[b];
			assign c_in[4*b+1] = g[4*b] || (p[4*b]&&c_in[4*b]);
			assign c_in[4*b+2] = g[4*b+1] || (p[4*b+1]&&g[4*b]) || (p[4*b+1]&&p[4*b]&&c_in[4*b]);
			assign c_in[4*b+3] = g[4*b+2] || (p[4*b+2]&&g[4*b+1]) || (p[4*b+2]&&p[4*b+1]&&g[4*b]) || (p[4*b+2]&&p[4*b+1]&&p[4*b]&&c_in[4*b]);
			assign pin_L2[b] = p[4*b]&&p[4*b+1]&&p[4*b+2]&&p[4*b+3];
			assign gin_L2[b] = g[4*b+3] || (p[4*b+3]&&g[4*b+2]) || (p[4*b+3]&&p[4*b+2]&&g[4*b+1]) || (p[4*b+3]&&p[4*b+2]&&p[4*b+1]&&g[4*b]);
		end	
	endgenerate	
	
//	CLA level 2
//	4 bit CLKA
	assign cout_L2[0] = operate;
	assign cout_L2[1] = gin_L2[0] || (pin_L2[0]&&operate);
	assign cout_L2[2] = gin_L2[1] || (pin_L2[1]&&gin_L2[0]) || (pin_L2[1]&&pin_L2[0]&&operate);
	assign cout_L2[3] = gin_L2[2] || (pin_L2[2]&&gin_L2[1]) || (pin_L2[2]&&pin_L2[1]&&gin_L2[0]) || (pin_L2[2]&&pin_L2[1]&&pin_L2[0]&&operate);
	assign pin_L3[0] = &pin_L2[3:0];
	assign gin_L3[0] = gin_L2[3] || (pin_L2[3]&&gin_L2[2]) || (pin_L2[3]&&pin_L2[2]&&gin_L2[1]) || (pin_L2[3]&&pin_L2[2]&&pin_L2[1]&&gin_L2[0]);
	
// 	2 bit CLA	
	assign cout_L2[4] = cout_L3[0];
	assign cout_L2[5] = gin_L2[4] || (pin_L2[4]&&cout_L3[0]);
	assign pin_L3[1] = &pin_L2[5:4];
	assign gin_L3[1] = gin_L2[5] || (pin_L2[5]&&gin_L2[4]);
	
//	CLA level 3
//	2 bit CLA	
	assign cout_L3[0] = gin_L3[0] || (pin_L3[0]&&operate);
	assign cout_L3[1] = gin_L3[1] || (pin_L3[1]&&gin_L3[0]) || (pin_L3[1]&&pin_L3[0]&&operate);
	
	assign cout = (operate) ? 1'b0 : cout_L3[1];

endmodule
