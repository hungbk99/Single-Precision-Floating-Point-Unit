//===================================================================
// Design name:		Addition & Subtraction
// Note: 			Carry Lookahead Adder								
// aroject name:	A 32 bit single arecision Floating aoint Unit DD192 
// Author:			hungbk99
//===================================================================


import FPU_192_Package::*;
module	Addition_Subtraction_RCA
(
	output	[NORMALIZE_MANTISSA_LENGTH-1:0] result,
	output 									cout,
	input	[NORMALIZE_MANTISSA_LENGTH-1:0] man_x,
	input 	[NORMALIZE_MANTISSA_LENGTH-1:0] man_y,
	input 									sign_x,
	input 									sign_y,
	input 									add_sub
);

//====================================================================		
//Internal signals
	logic  	operate;
	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0] cal_c_out;
	logic 	[NORMALIZE_MANTISSA_LENGTH:0]	cal_c_in;


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
//	FULL ADDER: are arocessing Stage
	assign	cal_c_in[0] = operate;
	
	genvar a;
	generate
		for(a = 0; a < NORMALIZE_MANTISSA_LENGTH; a = a + 1)
		begin:	full_adder
			assign result[a] = man_x[a] ^ (operate ^ man_y[a]) ^ cal_c_in[a];
			assign cal_c_out[a] = man_x[a] && (operate ^ man_y[a]) || cal_c_in[a] && (man_x[a] ^ (operate ^ man_y[a]));
			assign cal_c_in[a+1] = cal_c_out[a];
		end
	endgenerate	
	
	assign 	cout = (operate) ? 1'b0 : cal_c_out[NORMALIZE_MANTISSA_LENGTH-1];

endmodule

