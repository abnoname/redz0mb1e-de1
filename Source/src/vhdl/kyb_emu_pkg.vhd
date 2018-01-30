------------------------------------------------------------------------------
-- Project    : Red Zombie
------------------------------------------------------------------------------
-- File       :  kyb_emu_pkg.vhd
-- Author     :  fpgakuechle
-- Company    : hobbyist
-- Created    : 2012-12
-- Last update: 2013-04-02
-- Licence    : GNU General Public License (http://www.gnu.de/documents/gpl.de.html)
------------------------------------------------------------------------------
-- Description: 
-- tables for converting PS2 kexboard to switchmatrix keyboard
------------------------------------------------------------------------------
-- Status:
-- all definitons done
-- all standard keys (letters, numbers, signs, enter, lft, right) done

-- Firmware keyboard relation
-- 2.02 -> 8x4 (only!)
-- A.2  -> 8x8 (only?)
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package scancode_pkg is

type T_KEYS is (
K_1,  K_2,  K_3,  K_4, K_5, K_6, K_7, K_8, K_9,  K_0,  K_SZ,
K_Q,  K_W,  K_E,  K_R, K_T, K_Z, K_U, K_I, K_O,  K_P,  K_UE,
K_A,  K_S,  K_D,  K_F, K_G, K_H, K_J, K_K, K_L,
K_Y,  K_X,  K_C,  K_V, K_B, K_N, K_M, K_CM,K_DT, --cOmMa,dOt
K_UP, K_LF, K_DW, K_RG,K_EN,K_SP,                --Up left down right enter space
K_NS, K_PLUS,K_ML,K_MN,K_CL,                     --number sign, plus, star (multiplicator),
-- keys together with shift ps/2 key
K_0_S, K_1_S, K_2_S, K_4_S, K_5_S,     --
K_6_S, K_7_S, K_8_S, K_9_S,          --
K_A_S, K_B_S, K_C_S, K_D_S,
K_E_S, K_F_S, K_G_S, K_H_S,
K_I_S, K_J_S, K_K_S, K_L_S,
K_M_S, K_N_S, K_O_S, K_P_S,
K_Q_S, K_R_S, K_S_S, K_T_S,
K_U_S, K_V_S, K_W_S,
K_X_S, K_Y_S, K_Z_S,
K_KA,  K_KA_S,K_SZ_S
);
--minus, Print (Clear Screen)
type    T_SHIFT_LVL   is (NONE,S1,S2,S3,S4);

--128 scancodes - 7 bit enough
subtype T_SCANCODE is integer range 0 to 2**8 - 1;

--colum left (x,H,P,S1) is 1, colum right (G,O,W,ENTER) is 8 
subtype T_COL_SEL  is integer range 1 to 8;
--upper line (A-G) is 1, low line (with shift keys S1-S4) is 4
subtype T_ROW_SEL  is integer range 1 to 4;

type T_TRANS_PS2_8X4 is
record
  scancode  : T_SCANCODE;
  shift_lvl : T_SHIFT_LVL;
  col_sel   : T_COL_SEL;            --select 1 of 8 cols
  Row_sel   : T_ROW_SEL;            --sect 1 of 4 rows
end record T_TRANS_PS2_8X4;

--convert to bitvector for LUT-ROM
FUNCTION c8x4slv (op_in: T_TRANS_PS2_8X4) return std_logic_vector;

TYPE T_ALL_KEYS is array (T_KEYS) of T_TRANS_PS2_8X4;

CONSTANT C_ALL_KEYS : T_ALL_KEYS := (
--Index =>  Scancode   , Shift, Col,  Row
  K_0    => (16#45#, S1, 1, 2),
  K_0_S  => (16#C5#, S1, 6, 3),         --=
  K_1    => (16#16#, S1, 2, 2),
  K_1_S  => (16#96#, S2, 2, 2),         --!
  K_2    => (16#1E#, S1, 3, 2),
  K_2_S  => (16#9E#, S2, 3, 2),         --"
  K_3    => (16#26#, S1, 4, 2),
  K_4    => (16#25#, S1, 5, 2),
  K_4_S  => (16#A5#, S2, 5, 2),        --$
  K_5    => (16#2E#, S1, 6, 2),
  K_5_S  => (16#AE#, S2, 6, 2),        --%
  K_6    => (16#36#, S1, 7, 2),
  K_6_S  => (16#B6#, S2, 7, 2),        --& 
  K_7    => (16#3D#, S1, 8, 2),
  K_7_S  => (16#BD#, S2, 8, 3),        --/
  K_8    => (16#3E#, S1, 1, 3),
  K_8_S  => (16#BE#, S2, 1, 3),        --(
  K_9    => (16#46#, S1, 2, 3),
  K_9_S  => (16#C6#, S2, 2, 3),        --)
  K_PLUS => (16#5B#, S2, 4, 3),
  K_NS   => (16#5D#, S2, 4, 2),         --number sign   
  K_KA   => (16#61#, S1, 5, 3),       --<         
  K_KA_S => (16#E1#, S1, 7, 3),       -->         
  K_A    => (16#1C#, NONE, 2, 1),
  K_A_S  => (16#9C#, S3, 2, 1),
  K_B    => (16#32#, NONE, 3, 1),
  K_B_S  => (16#B2#, S3, 3, 1),       --b
  K_C    => (16#21#, NONE, 4, 1),
  K_C_S  => (16#A1#, S3, 4, 1),
  K_D    => (16#23#, NONE, 5, 1),
  K_D_S  => (16#A3#, S3, 5, 1),
  K_E    => (16#24#, NONE, 6, 1),
  K_E_S  => (16#A4#, S3, 6, 1),
  K_F    => (16#2B#, NONE, 7, 1),
  K_G    => (16#34#, NONE, 8, 1),
  K_H    => (16#33#, NONE, 1, 2),
  K_I    => (16#43#, NONE, 2, 2),
  K_J    => (16#3B#, NONE, 3, 2),
  K_K    => (16#42#, NONE, 4, 2),
  K_L    => (16#4B#, NONE, 5, 2),
  K_M    => (16#3A#, NONE, 6, 2),
  K_N    => (16#31#, NONE, 7, 2),
  K_O    => (16#44#, NONE, 8, 2),
  K_P    => (16#4D#, NONE, 1, 3),
  K_Q    => (16#15#, NONE, 2, 3),
  K_R    => (16#2D#, NONE, 3, 3),
  K_S    => (16#1B#, NONE, 4, 3),
  K_T    => (16#2C#, NONE, 5, 3),
  K_U    => (16#3C#, NONE, 6, 3),
  K_V    => (16#2A#, NONE, 7, 3),
  K_W    => (16#1D#, NONE, 8, 3),
  K_F_S  => (16#AB#, S3 , 7, 1),
  K_G_S  => (16#B4#, S3 , 8, 1),
  K_H_S  => (16#B3#, S3 , 1, 2),
  K_I_S  => (16#C3#, S3 , 2, 2),
  K_J_S  => (16#BB#, S3 , 3, 2),
  K_K_S  => (16#C2#, S3 , 4, 2),
  K_L_S  => (16#CB#, S3 , 5, 2),
  K_M_S  => (16#BA#, S3 , 6, 2),
  K_N_S  => (16#B1#, S3 , 7, 2),
  K_O_S  => (16#C4#, S3 , 8, 2),
  K_P_S  => (16#CD#, S3 , 1, 3),
  K_Q_S  => (16#95#, S3 , 2, 3),
  K_R_S  => (16#AD#, S3 , 3, 3),
  K_S_S  => (16#9B#, S3 , 4, 3),
  K_T_S  => (16#AC#, S3 , 5, 3),
  K_U_S  => (16#BC#, S3 , 6, 3),
  K_V_S  => (16#AA#, S3 , 7, 3),
  K_W_S  => (16#9D#, S3 , 8, 3),
  K_X    => (16#22#, S1, 1, 1),
  K_X_S  => (16#A2#, S2, 1, 1),
  K_Y    => (16#1A#, S1, 2, 1),
  K_Y_S  => (16#9A#, S2, 2, 1),
  K_Z    => (16#35#, S1, 3, 1),
  K_Z_S  => (16#B5#, S2, 3, 1),
  K_CM   => (16#41#, S2, 5, 3),         --komma
  K_DT   => (16#49#, S2, 7, 3),         --dot
  K_MN   => (16#4A#, S2, 6, 3),         --minus
  K_ML   => (16#7C#, S2, 3, 3),         --* Multiplicator
  K_EN   => (16#5A#, NONE, 8, 4),       --enter   
  K_RG   => (16#74#, NONE, 7, 4),       --rigth arrow   
  K_SP   => (16#29#, NONE, 6, 4),       --space
  K_LF   => (16#6B#, NONE, 5, 4),      --arrow Left
  K_SZ   => (16#4E#, S2, 7, 2),
  K_SZ_S => (16#CE#, S1, 8, 3),         --?
  K_CL   => (16#12#, S4, 5, 3),         --Print -> clear screen     
  others => (scancode => 16#4E#, shift_lvl => NONE, col_sel => 8, row_sel => 4));   

--  subtype T_KYBTRANS_INDEX is INTEGER range 0            to 2**7 - 1;  
  subtype T_KYBTRANS       is std_logic_vector(0 to 6);--INTEGER range 0 to  2**7 - 1;
  type    T_KYBTRANS_TABLE is array (T_SCANCODE'low to T_SCANCODE'high) of T_KYBTRANS; --assuming 128 scancodes

constant C_KYBTRANS_INIT  : T_KYBTRANS_TABLE := (
--  C_ALL_KEYS(K_0).scancode => c8x4slv(C_ALL_KEYS(K_0 )),
  16#45# => c8x4slv(C_ALL_KEYS(K_0)),
  16#C5# => c8x4slv(C_ALL_KEYS(K_0_S)),
  16#16# => c8x4slv(C_ALL_KEYS(K_1)),
  16#96# => c8x4slv(C_ALL_KEYS(K_1_S)),
  16#1E# => c8x4slv(C_ALL_KEYS(K_2)),
  16#9E# => c8x4slv(C_ALL_KEYS(K_2_S)),
  16#26# => c8x4slv(C_ALL_KEYS(K_3)),
  16#25# => c8x4slv(C_ALL_KEYS(K_4)),
  16#A5# => c8x4slv(C_ALL_KEYS(K_4_S)),
  16#2E# => c8x4slv(C_ALL_KEYS(K_5)),
  16#AE# => c8x4slv(C_ALL_KEYS(K_5_S)),
  16#36# => c8x4slv(C_ALL_KEYS(K_6)),
  16#B6# => c8x4slv(C_ALL_KEYS(K_6_S)),
  16#3D# => c8x4slv(C_ALL_KEYS(K_7)),
  16#BD# => c8x4slv(C_ALL_KEYS(K_7_S)),
  16#3E# => c8x4slv(C_ALL_KEYS(K_8)),
  16#BE# => c8x4slv(C_ALL_KEYS(K_8_S)),
  16#46# => c8x4slv(C_ALL_KEYS(K_9)),
  16#C6# => c8x4slv(C_ALL_KEYS(K_9_S)),
  16#1C# => c8x4slv(C_ALL_KEYS(K_A)),
  16#9C# => c8x4slv(C_ALL_KEYS(K_A_S)),
  16#32# => c8x4slv(C_ALL_KEYS(K_B)),
  16#B2# => c8x4slv(C_ALL_KEYS(K_B_S)),
  16#21# => c8x4slv(C_ALL_KEYS(K_C)),
  16#A1# => c8x4slv(C_ALL_KEYS(K_C_S)),
  16#23# => c8x4slv(C_ALL_KEYS(K_D)),
  16#A3# => c8x4slv(C_ALL_KEYS(K_D_S)),
  16#24# => c8x4slv(C_ALL_KEYS(K_E)),
  16#A4# => c8x4slv(C_ALL_KEYS(K_E_S)),
  16#2B# => c8x4slv(C_ALL_KEYS(K_F)),
  16#34# => c8x4slv(C_ALL_KEYS(K_G)),
  16#33# => c8x4slv(C_ALL_KEYS(K_H)),
  16#43# => c8x4slv(C_ALL_KEYS(K_I)),
  16#3B# => c8x4slv(C_ALL_KEYS(K_J)),
  16#42# => c8x4slv(C_ALL_KEYS(K_K)),
  16#4B# => c8x4slv(C_ALL_KEYS(K_L)),
  16#3A# => c8x4slv(C_ALL_KEYS(K_M)),
  16#31# => c8x4slv(C_ALL_KEYS(K_N)),
  16#44# => c8x4slv(C_ALL_KEYS(K_O)),
  16#4D# => c8x4slv(C_ALL_KEYS(K_P)),
  16#15# => c8x4slv(C_ALL_KEYS(K_Q)),
  16#2D# => c8x4slv(C_ALL_KEYS(K_R)),
  16#1B# => c8x4slv(C_ALL_KEYS(K_S)),
  16#2C# => c8x4slv(C_ALL_KEYS(K_T)),
  16#3C# => c8x4slv(C_ALL_KEYS(K_U)),
  16#2A# => c8x4slv(C_ALL_KEYS(K_V)),
  16#1D# => c8x4slv(C_ALL_KEYS(K_W)),
--
  16#AB# => c8x4slv(C_ALL_KEYS(K_F_S)),
  16#B4# => c8x4slv(C_ALL_KEYS(K_G_S)),
  16#B3# => c8x4slv(C_ALL_KEYS(K_H_S)),
  16#C3# => c8x4slv(C_ALL_KEYS(K_I_S)),
  16#BB# => c8x4slv(C_ALL_KEYS(K_J_S)),
  16#C2# => c8x4slv(C_ALL_KEYS(K_K_S)),
  16#CB# => c8x4slv(C_ALL_KEYS(K_L_S)),
  16#BA# => c8x4slv(C_ALL_KEYS(K_M_S)),
  16#B1# => c8x4slv(C_ALL_KEYS(K_N_S)),
  16#C4# => c8x4slv(C_ALL_KEYS(K_O_S)),
  16#CD# => c8x4slv(C_ALL_KEYS(K_P_S)),
  16#95# => c8x4slv(C_ALL_KEYS(K_Q_S)),
  16#AD# => c8x4slv(C_ALL_KEYS(K_R_S)),
  16#9B# => c8x4slv(C_ALL_KEYS(K_S_S)),
  16#AC# => c8x4slv(C_ALL_KEYS(K_T_S)),
  16#BC# => c8x4slv(C_ALL_KEYS(K_U_S)),
  16#AA# => c8x4slv(C_ALL_KEYS(K_V_S)),
  16#9D# => c8x4slv(C_ALL_KEYS(K_W_S)),
--  
  16#22# => c8x4slv(C_ALL_KEYS(K_X)),
  16#A2# => c8x4slv(C_ALL_KEYS(K_X_S)),
  16#1A# => c8x4slv(C_ALL_KEYS(K_Y)),
  16#9A# => c8x4slv(C_ALL_KEYS(K_Y_S)),
  16#35# => c8x4slv(C_ALL_KEYS(K_Z)),
  16#B5# => c8x4slv(C_ALL_KEYS(K_Z_S)),
  16#61# => c8x4slv(C_ALL_KEYS(K_KA)),    --'<'
  16#E1# => c8x4slv(C_ALL_KEYS(K_KA_S)),  --'>'
  16#41# => c8x4slv(C_ALL_KEYS(K_CM)),
  16#49# => c8x4slv(C_ALL_KEYS(K_DT)),
  16#4A# => c8x4slv(C_ALL_KEYS(K_MN)),
  16#5A# => c8x4slv(C_ALL_KEYS(K_EN)),
  16#29# => c8x4slv(C_ALL_KEYS(K_SP)),
  16#74# => c8x4slv(C_ALL_KEYS(K_RG)),
  16#6B# => c8x4slv(C_ALL_KEYS(K_LF)),
  16#5D# => c8x4slv(C_ALL_KEYS(K_NS)),    --'#'
  16#5B# => c8x4slv(C_ALL_KEYS(K_PLUS)),  --'+'
  16#7C# => c8x4slv(C_ALL_KEYS(K_ML)),    --'*'
  16#4E# => c8x4slv(C_ALL_KEYS(K_SZ)),     
  16#CE# => c8x4slv(C_ALL_KEYS(K_SZ_S)),     
  others => c8x4slv(C_ALL_KEYS(K_SP)));    --not implemented key -> space
end package scancode_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package body scancode_pkg is
  function c8x4slv (op_in : T_TRANS_PS2_8X4) return std_logic_vector is
    variable v_shift_lvl_slv2 : std_logic_vector(0 to 1);
    variable v_row_sel_slv2   : std_logic_vector(0 to 1);
    variable v_col_sel_slv3   : std_logic_vector(0 to 2);
    variable v_return         : T_KYBTRANS;
  begin
    case op_in.shift_lvl is
      when NONE   => v_shift_lvl_slv2 := "00";
      when S1     => v_shift_lvl_slv2 := "01";
      when S2     => v_shift_lvl_slv2 := "10";
      when S3     => v_shift_lvl_slv2 := "11";
      when others => v_shift_lvl_slv2 := "11";
    end case;
    v_row_sel_slv2 := std_logic_vector(to_unsigned((op_in.row_sel - 1), 2));
    v_col_sel_slv3 := std_logic_vector(to_unsigned((op_in.col_sel - 1), 3));
    --0 .. 2 col_sel | 3 .. 4 row_sel  | 5.. 6 Shift 
    v_return(6) := v_shift_lvl_slv2(1); 
    v_return(5) := v_shift_lvl_slv2(0); 
    v_return(4) := v_row_sel_slv2(1);
    v_return(3) := v_row_sel_slv2(0);
    v_return(2) := v_col_sel_slv3(2);
    v_return(1) := v_col_sel_slv3(1); 
    v_return(0) := v_col_sel_slv3(0);
    return v_return;
  end function c8x4slv;
end package body scancode_pkg;
