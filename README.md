# Single-Precision-Floating-Point-Unit
A Single Precision Floating Point Unit Using SystemVerilog
==========================================================
# Features:
*   Support 5  arithmetic operations 
    1.  Addition (Ripple Carry Adder)
    2.  Subtraction (Ripple Carry Adder)
    3.  Multiplication (Braun Multiplication)
    4.  Division (Non-Restoring Division)
    5.  N-th Root (2th-root, 3th-root, 4th-root, 5th-root)
*   Second Algorithm  
    1.  Addition (Carry Lookahead Adder)
    2.  Subtraction (Carry Lookahead Adder)
    3.  Multiplication (Vedic Multiplication)  
    4.  Division (Newton–Raphson division)
* Floating Point Number to Decimal Number Converter    
* Note: 
    1.  This design is not optimized. For example, Pre_Normalization 
    and Pre_Normalization_MD can be merged into one, the same idea for 
    Post_Normalization and Post_Normalization_MD. N-th Root will give a 
    slightly different results from the real answer. 
    2.  This FPU design does not support Sub-Normal number. If the 
    result after calculated is a Sub-Normal number, then the actual 
    outcome will be underflow or zero.
    3.  Define SECOND_ALGORITHM in FPU_define.h file to run the secound 
    algorithm
    4.  Define SIMULATE in FPU_define.h file to run simulation, clear it 
    to synthesis.
* Update: The first division algorithm (Non-Restoring Division) described
in the NRD_Division.sv file is not perfectly correct, the correct one is
Modified_NRD_Division_CV module in FP2D_Converter.sv file. Thanks!!!
