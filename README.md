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
    1.  Addition (Carry Select Adder)
    2.  Subtraction (Carry Select Adder)
    3.  Multiplication (Vedic Multiplication)  
    4.  Division (Newton–Raphson division)
    
* Note: This design is not optimized. For example, Pre_Normalization 
and Pre_Normalization_MD can be merged into one, the same idea for 
Post_Normalization and Post_Normalization_MD. N-th Root will give a 
slightly different results from the real answer.
