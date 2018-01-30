--rom image
--Z1013 EPROM-image U2632- Bitmuster bm204
--Riesa-Monitor 2.02


library ieee;
use ieee.std_logic_1164.all;

package bm204_202_pkg is
  constant c_addrline_high : INTEGER := 10;
  subtype T_INDEX is INTEGER range 0 to 2**(c_addrline_high+1) - 1;
  signal  addr_integer : T_INDEX;

  subtype T_WORD is integer range 255 downto 0;
  type    T_Mem is array (T_INDEX'low to T_INDEX'high) of T_word;

constant C_MEM_ARRAY_INIT : T_Mem := (
16#18#, 16#0d#, 16#21#, 16#4d#, 16#00#, 16#11#, 16#4e#, 16#00#, 16#36#, 16#00#, 16#01#, 16#15#, 16#00#, 16#ed#, 16#b0#, 16#31#,
16#b0#, 16#00#, 16#af#, 16#32#, 16#27#, 16#00#, 16#3e#, 16#c3#, 16#32#, 16#20#, 16#00#, 16#21#, 16#e8#, 16#f0#, 16#22#, 16#21#,
16#00#, 16#3e#, 16#cf#, 16#d3#, 16#03#, 16#3e#, 16#7f#, 16#d3#, 16#03#, 16#21#, 16#f2#, 16#f1#, 16#11#, 16#33#, 16#00#, 16#01#,
16#1a#, 16#00#, 16#ed#, 16#b0#, 16#e7#, 16#02#, 16#0c#, 16#0d#, 16#0d#, 16#72#, 16#6f#, 16#62#, 16#6f#, 16#74#, 16#72#, 16#6f#,
16#6e#, 16#20#, 16#5a#, 16#20#, 16#31#, 16#30#, 16#31#, 16#33#, 16#2f#, 16#32#, 16#2e#, 16#30#, 16#32#, 16#8d#, 16#21#, 16#90#,
16#00#, 16#22#, 16#63#, 16#00#, 16#ed#, 16#5e#, 16#18#, 16#07#, 16#31#, 16#b0#, 16#00#, 16#cd#, 16#a5#, 16#f2#, 16#bf#, 16#cd#,
16#b3#, 16#f2#, 16#ed#, 16#5b#, 16#16#, 16#00#, 16#cd#, 16#ca#, 16#f2#, 16#47#, 16#13#, 16#1a#, 16#4f#, 16#c5#, 16#13#, 16#cd#,
16#f4#, 16#f2#, 16#20#, 16#05#, 16#1a#, 16#fe#, 16#3a#, 16#28#, 16#0f#, 16#22#, 16#1b#, 16#00#, 16#cd#, 16#f4#, 16#f2#, 16#22#,
16#1d#, 16#00#, 16#cd#, 16#f4#, 16#f2#, 16#22#, 16#23#, 16#00#, 16#c1#, 16#08#, 16#ed#, 16#53#, 16#25#, 16#00#, 16#21#, 16#b1#,
16#f0#, 16#7e#, 16#b8#, 16#28#, 16#11#, 16#23#, 16#23#, 16#23#, 16#b7#, 16#20#, 16#f6#, 16#78#, 16#fe#, 16#40#, 16#20#, 16#b8#,
16#21#, 16#b0#, 16#00#, 16#41#, 16#18#, 16#eb#, 16#23#, 16#5e#, 16#23#, 16#56#, 16#eb#, 16#08#, 16#01#, 16#5f#, 16#f0#, 16#c5#,
16#e9#, 16#41#, 16#c5#, 16#f6#, 16#42#, 16#87#, 16#f5#, 16#43#, 16#77#, 16#f7#, 16#44#, 16#ce#, 16#f4#, 16#45#, 16#99#, 16#f5#,
16#46#, 16#a2#, 16#f7#, 16#47#, 16#b3#, 16#f5#, 16#48#, 16#b8#, 16#f6#, 16#49#, 16#02#, 16#f0#, 16#4a#, 16#a5#, 16#f5#, 16#4b#,
16#0b#, 16#f5#, 16#4c#, 16#f8#, 16#f3#, 16#4d#, 16#25#, 16#f3#, 16#4e#, 16#27#, 16#f7#, 16#52#, 16#df#, 16#f5#, 16#53#, 16#69#,
16#f3#, 16#54#, 16#1d#, 16#f5#, 16#57#, 16#d1#, 16#f6#, 16#00#, 16#e3#, 16#f5#, 16#7e#, 16#32#, 16#03#, 16#00#, 16#23#, 16#f1#,
16#e3#, 16#e5#, 16#c5#, 16#f5#, 16#21#, 16#08#, 16#f1#, 16#3a#, 16#03#, 16#00#, 16#cb#, 16#27#, 16#4f#, 16#06#, 16#00#, 16#09#,
16#7e#, 16#23#, 16#66#, 16#6f#, 16#f1#, 16#c1#, 16#e3#, 16#c9#, 16#1b#, 16#f2#, 16#0c#, 16#f2#, 16#a5#, 16#f2#, 16#f4#, 16#f2#,
16#30#, 16#f1#, 16#b3#, 16#f2#, 16#01#, 16#f3#, 16#1a#, 16#f3#, 16#69#, 16#f3#, 16#f8#, 16#f3#, 16#25#, 16#f3#, 16#d1#, 16#f6#,
16#c7#, 16#f5#, 16#c4#, 16#f5#, 16#cf#, 16#f5#, 16#1d#, 16#f5#, 16#b9#, 16#f2#, 16#0b#, 16#f5#, 16#b8#, 16#f6#, 16#c5#, 16#f6#,
16#af#, 16#67#, 16#6f#, 16#cd#, 16#88#, 16#f1#, 16#30#, 16#4b#, 16#19#, 16#cd#, 16#9e#, 16#f1#, 16#0e#, 16#44#, 16#38#, 16#07#,
16#eb#, 16#cb#, 16#5a#, 16#28#, 16#0b#, 16#18#, 16#14#, 16#cb#, 16#5a#, 16#28#, 16#05#, 16#eb#, 16#cb#, 16#5a#, 16#20#, 16#0b#,
16#cd#, 16#a5#, 16#f1#, 16#c5#, 16#cd#, 16#dc#, 16#f1#, 16#c1#, 16#28#, 16#06#, 16#eb#, 16#cd#, 16#dc#, 16#f1#, 16#20#, 16#23#,
16#83#, 16#21#, 16#27#, 16#00#, 16#86#, 16#21#, 16#04#, 16#00#, 16#be#, 16#28#, 16#c5#, 16#47#, 16#7e#, 16#b7#, 16#78#, 16#20#,
16#bf#, 16#32#, 16#04#, 16#00#, 16#fe#, 16#91#, 16#28#, 16#07#, 16#fe#, 16#17#, 16#c0#, 16#3e#, 16#80#, 16#18#, 16#01#, 16#af#,
16#32#, 16#27#, 16#00#, 16#af#, 16#32#, 16#04#, 16#00#, 16#c9#, 16#5f#, 16#d3#, 16#08#, 16#06#, 16#20#, 16#db#, 16#02#, 16#e6#,
16#0f#, 16#57#, 16#db#, 16#02#, 16#e6#, 16#0f#, 16#ba#, 16#20#, 16#03#, 16#fe#, 16#0f#, 16#c0#, 16#10#, 16#ef#, 16#7b#, 16#3c#,
16#fe#, 16#08#, 16#20#, 16#e4#, 16#c9#, 16#3e#, 16#01#, 16#bb#, 16#28#, 16#29#, 16#30#, 16#24#, 16#c6#, 16#02#, 16#bb#, 16#28#,
16#28#, 16#30#, 16#23#, 16#c6#, 16#02#, 16#bb#, 16#28#, 16#0f#, 16#30#, 16#11#, 16#c6#, 16#02#, 16#bb#, 16#28#, 16#04#, 16#3e#,
16#09#, 16#18#, 16#0a#, 16#3e#, 16#0d#, 16#18#, 16#06#, 16#3e#, 16#20#, 16#18#, 16#02#, 16#3e#, 16#08#, 16#c1#, 16#18#, 16#95#,
16#0e#, 16#41#, 16#c9#, 16#0e#, 16#3e#, 16#c9#, 16#0e#, 16#3b#, 16#c9#, 16#0e#, 16#35#, 16#c9#, 16#cb#, 16#42#, 16#20#, 16#05#,
16#69#, 16#26#, 16#00#, 16#7e#, 16#c9#, 16#0c#, 16#cb#, 16#4a#, 16#20#, 16#02#, 16#18#, 16#f4#, 16#0c#, 16#cb#, 16#52#, 16#c0#,
16#18#, 16#ee#, 16#d0#, 16#07#, 16#10#, 16#00#, 16#08#, 16#c3#, 16#58#, 16#f0#, 16#60#, 16#68#, 16#70#, 16#78#, 16#20#, 16#28#,
16#58#, 16#30#, 16#38#, 16#40#, 16#48#, 16#50#, 16#e0#, 16#03#, 16#00#, 16#ec#, 16#00#, 16#f0#, 16#c5#, 16#d5#, 16#e5#, 16#cd#,
16#30#, 16#f1#, 16#b7#, 16#28#, 16#fa#, 16#e1#, 16#d1#, 16#c1#, 16#c9#, 16#e6#, 16#7f#, 16#f5#, 16#c5#, 16#d5#, 16#e5#, 16#2a#,
16#2b#, 16#00#, 16#f5#, 16#3a#, 16#1f#, 16#00#, 16#77#, 16#f1#, 16#fe#, 16#0d#, 16#28#, 16#53#, 16#fe#, 16#0c#, 16#28#, 16#5e#,
16#fe#, 16#08#, 16#28#, 16#48#, 16#fe#, 16#09#, 16#28#, 16#01#, 16#77#, 16#23#, 16#eb#, 16#2a#, 16#4b#, 16#00#, 16#af#, 16#ed#,
16#52#, 16#eb#, 16#20#, 16#2a#, 16#ed#, 16#5b#, 16#49#, 16#00#, 16#21#, 16#20#, 16#00#, 16#19#, 16#ed#, 16#4b#, 16#47#, 16#00#,
16#78#, 16#b1#, 16#28#, 16#02#, 16#ed#, 16#b0#, 16#d5#, 16#e1#, 16#e5#, 16#13#, 16#36#, 16#20#, 16#01#, 16#1f#, 16#00#, 16#ed#,
16#b0#, 16#2a#, 16#16#, 16#00#, 16#11#, 16#20#, 16#00#, 16#af#, 16#ed#, 16#52#, 16#22#, 16#16#, 16#00#, 16#e1#, 16#7e#, 16#32#,
16#1f#, 16#00#, 16#36#, 16#ff#, 16#22#, 16#2b#, 16#00#, 16#e1#, 16#d1#, 16#c1#, 16#f1#, 16#c9#, 16#2b#, 16#18#, 16#bb#, 16#3e#,
16#e0#, 16#a5#, 16#c6#, 16#20#, 16#4f#, 16#36#, 16#20#, 16#23#, 16#7d#, 16#b9#, 16#20#, 16#f9#, 16#18#, 16#ac#, 16#2a#, 16#47#,
16#00#, 16#01#, 16#1f#, 16#00#, 16#09#, 16#e5#, 16#c1#, 16#2a#, 16#49#, 16#00#, 16#e5#, 16#36#, 16#20#, 16#e5#, 16#d1#, 16#13#,
16#ed#, 16#b0#, 16#e1#, 16#18#, 16#c9#, 16#e3#, 16#7e#, 16#23#, 16#f5#, 16#cd#, 16#19#, 16#f2#, 16#f1#, 16#cb#, 16#7f#, 16#28#,
16#f5#, 16#e3#, 16#c9#, 16#cd#, 16#a5#, 16#f2#, 16#20#, 16#23#, 16#a0#, 16#e5#, 16#2a#, 16#2b#, 16#00#, 16#22#, 16#16#, 16#00#,
16#e7#, 16#01#, 16#e7#, 16#00#, 16#fe#, 16#0d#, 16#20#, 16#f8#, 16#e1#, 16#c9#, 16#1a#, 16#fe#, 16#20#, 16#c0#, 16#13#, 16#18#,
16#f9#, 16#cd#, 16#ca#, 16#f2#, 16#af#, 16#21#, 16#13#, 16#00#, 16#77#, 16#23#, 16#77#, 16#1a#, 16#2b#, 16#d6#, 16#30#, 16#f8#,
16#fe#, 16#0a#, 16#38#, 16#08#, 16#d6#, 16#07#, 16#fe#, 16#0a#, 16#f8#, 16#fe#, 16#10#, 16#f0#, 16#13#, 16#ed#, 16#6f#, 16#23#,
16#ed#, 16#6f#, 16#18#, 16#e7#, 16#c5#, 16#cd#, 16#d1#, 16#f2#, 16#44#, 16#4d#, 16#6e#, 16#03#, 16#0a#, 16#67#, 16#b5#, 16#c1#,
16#c9#, 16#f5#, 16#1f#, 16#1f#, 16#1f#, 16#1f#, 16#cd#, 16#0a#, 16#f3#, 16#f1#, 16#f5#, 16#e6#, 16#0f#, 16#c6#, 16#30#, 16#fe#,
16#3a#, 16#38#, 16#02#, 16#c6#, 16#07#, 16#cd#, 16#1b#, 16#f2#, 16#f1#, 16#c9#, 16#f5#, 16#7c#, 16#cd#, 16#01#, 16#f3#, 16#7d#,
16#cd#, 16#01#, 16#f3#, 16#f1#, 16#c9#, 16#2a#, 16#1b#, 16#00#, 16#e7#, 16#07#, 16#e5#, 16#e7#, 16#0e#, 16#7e#, 16#e7#, 16#06#,
16#cd#, 16#b3#, 16#f2#, 16#ed#, 16#5b#, 16#16#, 16#00#, 16#1a#, 16#08#, 16#e1#, 16#2b#, 16#23#, 16#e5#, 16#cd#, 16#f4#, 16#f2#,
16#28#, 16#0d#, 16#7d#, 16#e1#, 16#77#, 16#be#, 16#28#, 16#f3#, 16#e7#, 16#02#, 16#45#, 16#52#, 16#a0#, 16#18#, 16#d9#, 16#1a#,
16#fe#, 16#20#, 16#28#, 16#ee#, 16#e1#, 16#23#, 16#22#, 16#1d#, 16#00#, 16#fe#, 16#3b#, 16#c8#, 16#08#, 16#fe#, 16#20#, 16#28#,
16#c7#, 16#2b#, 16#fe#, 16#52#, 16#20#, 16#c2#, 16#2b#, 16#18#, 16#bf#, 16#2a#, 16#1b#, 16#00#, 16#cd#, 16#7d#, 16#f3#, 16#eb#,
16#2a#, 16#1d#, 16#00#, 16#a7#, 16#ed#, 16#52#, 16#eb#, 16#d8#, 16#cd#, 16#83#, 16#f3#, 16#18#, 16#f2#, 16#ed#, 16#5b#, 16#33#,
16#00#, 16#18#, 16#03#, 16#11#, 16#0e#, 16#00#, 16#06#, 16#70#, 16#10#, 16#fe#, 16#cd#, 16#f1#, 16#f3#, 16#1b#, 16#7b#, 16#b2#,
16#20#, 16#f4#, 16#0e#, 16#02#, 16#06#, 16#35#, 16#10#, 16#fe#, 16#cd#, 16#f1#, 16#f3#, 16#0d#, 16#11#, 16#00#, 16#00#, 16#20#,
16#f3#, 16#d5#, 16#dd#, 16#e1#, 16#06#, 16#12#, 16#10#, 16#fe#, 16#cd#, 16#d0#, 16#f3#, 16#06#, 16#0f#, 16#10#, 16#fe#, 16#0e#,
16#10#, 16#5e#, 16#23#, 16#56#, 16#dd#, 16#19#, 16#23#, 16#c5#, 16#cd#, 16#d0#, 16#f3#, 16#c1#, 16#0d#, 16#28#, 16#06#, 16#06#,
16#0e#, 16#10#, 16#fe#, 16#18#, 16#ec#, 16#dd#, 16#e5#, 16#d1#, 16#06#, 16#10#, 16#10#, 16#fe#, 16#cd#, 16#d0#, 16#f3#, 16#c9#,
16#0e#, 16#10#, 16#cb#, 16#3a#, 16#cb#, 16#1b#, 16#30#, 16#07#, 16#06#, 16#03#, 16#10#, 16#fe#, 16#00#, 16#18#, 16#03#, 16#cd#,
16#f1#, 16#f3#, 16#06#, 16#19#, 16#10#, 16#fe#, 16#cd#, 16#f1#, 16#f3#, 16#0d#, 16#c8#, 16#06#, 16#15#, 16#10#, 16#fe#, 16#18#,
16#e1#, 16#db#, 16#02#, 16#ee#, 16#80#, 16#d3#, 16#02#, 16#c9#, 16#2a#, 16#1b#, 16#00#, 16#cd#, 16#17#, 16#f4#, 16#28#, 16#0c#,
16#cd#, 16#a5#, 16#f2#, 16#43#, 16#53#, 16#bc#, 16#cd#, 16#1a#, 16#f3#, 16#cd#, 16#cf#, 16#f5#, 16#eb#, 16#2a#, 16#1d#, 16#00#,
16#a7#, 16#ed#, 16#52#, 16#eb#, 16#d8#, 16#18#, 16#e4#, 16#cd#, 16#bc#, 16#f4#, 16#cd#, 16#c6#, 16#f4#, 16#0e#, 16#07#, 16#11#,
16#10#, 16#09#, 16#3e#, 16#07#, 16#3d#, 16#20#, 16#fd#, 16#cd#, 16#bc#, 16#f4#, 16#cd#, 16#bc#, 16#f4#, 16#20#, 16#e8#, 16#15#,
16#20#, 16#f8#, 16#0d#, 16#28#, 16#0c#, 16#db#, 16#02#, 16#a8#, 16#cb#, 16#77#, 16#20#, 16#e3#, 16#1d#, 16#20#, 16#f6#, 16#18#,
16#d6#, 16#cd#, 16#c6#, 16#f4#, 16#3e#, 16#44#, 16#3d#, 16#20#, 16#fd#, 16#cd#, 16#bc#, 16#f4#, 16#20#, 16#f3#, 16#cd#, 16#c6#,
16#f4#, 16#3e#, 16#1e#, 16#3d#, 16#20#, 16#fd#, 16#cd#, 16#9d#, 16#f4#, 16#0e#, 16#10#, 16#d5#, 16#dd#, 16#e1#, 16#3e#, 16#1a#,
16#3d#, 16#20#, 16#fd#, 16#cd#, 16#9d#, 16#f4#, 16#dd#, 16#19#, 16#c5#, 16#4d#, 16#44#, 16#2a#, 16#1d#, 16#00#, 16#af#, 16#ed#,
16#42#, 16#69#, 16#60#, 16#c1#, 16#38#, 16#05#, 16#73#, 16#23#, 16#72#, 16#18#, 16#06#, 16#3e#, 16#01#, 16#3d#, 16#20#, 16#fd#,
16#23#, 16#23#, 16#0d#, 16#28#, 16#07#, 16#3e#, 16#12#, 16#3d#, 16#20#, 16#fd#, 16#18#, 16#d7#, 16#3e#, 16#12#, 16#3d#, 16#20#,
16#fd#, 16#cd#, 16#9d#, 16#f4#, 16#eb#, 16#dd#, 16#e5#, 16#c1#, 16#af#, 16#ed#, 16#42#, 16#eb#, 16#c9#, 16#e5#, 16#2e#, 16#10#,
16#cd#, 16#bc#, 16#f4#, 16#20#, 16#03#, 16#af#, 16#18#, 16#01#, 16#37#, 16#cb#, 16#1a#, 16#cb#, 16#1b#, 16#cd#, 16#c6#, 16#f4#,
16#2d#, 16#28#, 16#07#, 16#3e#, 16#1e#, 16#3d#, 16#20#, 16#fd#, 16#18#, 16#e6#, 16#e1#, 16#c9#, 16#db#, 16#02#, 16#a8#, 16#cb#,
16#77#, 16#f5#, 16#a8#, 16#47#, 16#f1#, 16#c9#, 16#db#, 16#02#, 16#a8#, 16#cb#, 16#77#, 16#28#, 16#f9#, 16#c9#, 16#2a#, 16#1b#,
16#00#, 16#ed#, 16#5b#, 16#1d#, 16#00#, 16#37#, 16#e5#, 16#ed#, 16#52#, 16#e1#, 16#d0#, 16#e7#, 16#07#, 16#01#, 16#00#, 16#08#,
16#1e#, 16#00#, 16#e7#, 16#02#, 16#a0#, 16#7e#, 16#e7#, 16#06#, 16#81#, 16#4f#, 16#30#, 16#04#, 16#3e#, 16#00#, 16#8b#, 16#5f#,
16#23#, 16#10#, 16#ef#, 16#e7#, 16#02#, 16#a0#, 16#7b#, 16#cd#, 16#0a#, 16#f3#, 16#79#, 16#e7#, 16#06#, 16#18#, 16#d2#, 16#2a#,
16#1b#, 16#00#, 16#ed#, 16#5b#, 16#1d#, 16#00#, 16#ed#, 16#4b#, 16#23#, 16#00#, 16#c9#, 16#cd#, 16#ff#, 16#f4#, 16#71#, 16#e5#,
16#af#, 16#eb#, 16#ed#, 16#52#, 16#44#, 16#4d#, 16#e1#, 16#54#, 16#5d#, 16#13#, 16#ed#, 16#b0#, 16#c9#, 16#cd#, 16#ff#, 16#f4#,
16#af#, 16#e5#, 16#ed#, 16#52#, 16#e1#, 16#38#, 16#03#, 16#ed#, 16#b0#, 16#c9#, 16#09#, 16#eb#, 16#09#, 16#eb#, 16#2b#, 16#1b#,
16#ed#, 16#b8#, 16#c9#, 16#ed#, 16#73#, 16#13#, 16#00#, 16#31#, 16#61#, 16#00#, 16#dd#, 16#e5#, 16#fd#, 16#e5#, 16#f5#, 16#c5#,
16#d5#, 16#e5#, 16#d9#, 16#08#, 16#f5#, 16#c5#, 16#d5#, 16#e5#, 16#18#, 16#15#, 16#ed#, 16#73#, 16#13#, 16#00#, 16#31#, 16#4d#,
16#00#, 16#e1#, 16#d1#, 16#c1#, 16#f1#, 16#d9#, 16#08#, 16#e1#, 16#d1#, 16#c1#, 16#f1#, 16#fd#, 16#e1#, 16#dd#, 16#e1#, 16#ed#,
16#7b#, 16#13#, 16#00#, 16#c9#, 16#cd#, 16#33#, 16#f5#, 16#e1#, 16#ed#, 16#73#, 16#63#, 16#00#, 16#31#, 16#b0#, 16#00#, 16#2b#,
16#2b#, 16#2b#, 16#22#, 16#61#, 16#00#, 16#ed#, 16#5b#, 16#0b#, 16#00#, 16#21#, 16#0d#, 16#00#, 16#01#, 16#03#, 16#00#, 16#ed#,
16#b0#, 16#cd#, 16#e4#, 16#f5#, 16#c3#, 16#5f#, 16#f0#, 16#2a#, 16#1b#, 16#00#, 16#22#, 16#0b#, 16#00#, 16#11#, 16#0d#, 16#00#,
16#01#, 16#03#, 16#00#, 16#ed#, 16#b0#, 16#cd#, 16#e4#, 16#f5#, 16#c9#, 16#2a#, 16#0b#, 16#00#, 16#36#, 16#cd#, 16#23#, 16#11#,
16#64#, 16#f5#, 16#73#, 16#23#, 16#72#, 16#2a#, 16#1b#, 16#00#, 16#22#, 16#61#, 16#00#, 16#ed#, 16#7b#, 16#63#, 16#00#, 16#e5#,
16#c3#, 16#4a#, 16#f5#, 16#2a#, 16#61#, 16#00#, 16#22#, 16#1b#, 16#00#, 16#ed#, 16#5b#, 16#0b#, 16#00#, 16#af#, 16#ed#, 16#52#,
16#20#, 16#d7#, 16#18#, 16#e1#, 16#e7#, 16#02#, 16#ba#, 16#7e#, 16#e7#, 16#06#, 16#2b#, 16#7e#, 16#e7#, 16#06#, 16#2b#, 16#e7#,
16#02#, 16#a0#, 16#c9#, 16#e7#, 16#02#, 16#31#, 16#a0#, 16#c9#, 16#20#, 16#f9#, 16#e7#, 16#02#, 16#30#, 16#a0#, 16#c9#, 16#fe#,
16#3a#, 16#c2#, 16#5a#, 16#f6#, 16#e7#, 16#02#, 16#0d#, 16#42#, 16#d0#, 16#21#, 16#0c#, 16#00#, 16#e7#, 16#0d#, 16#e7#, 16#02#,
16#42#, 16#53#, 16#ba#, 16#06#, 16#03#, 16#21#, 16#0d#, 16#00#, 16#7e#, 16#e7#, 16#06#, 16#23#, 16#10#, 16#fa#, 16#e7#, 16#02#,
16#20#, 16#20#, 16#20#, 16#53#, 16#20#, 16#5a#, 16#20#, 16#43#, 16#a0#, 16#3a#, 16#5b#, 16#00#, 16#6f#, 16#cb#, 16#7d#, 16#cd#,
16#d8#, 16#f5#, 16#cb#, 16#75#, 16#cd#, 16#d8#, 16#f5#, 16#cb#, 16#45#, 16#cd#, 16#d8#, 16#f5#, 16#21#, 16#64#, 16#00#, 16#06#,
16#02#, 16#e7#, 16#02#, 16#53#, 16#d0#, 16#e7#, 16#0d#, 16#e7#, 16#02#, 16#50#, 16#c3#, 16#e7#, 16#0d#, 16#e7#, 16#02#, 16#49#,
16#d8#, 16#e7#, 16#0d#, 16#e7#, 16#02#, 16#49#, 16#d9#, 16#e7#, 16#0d#, 16#e7#, 16#02#, 16#41#, 16#c6#, 16#e7#, 16#0d#, 16#e7#,
16#02#, 16#42#, 16#c3#, 16#e7#, 16#0d#, 16#e7#, 16#02#, 16#44#, 16#c5#, 16#e7#, 16#0d#, 16#e7#, 16#02#, 16#48#, 16#cc#, 16#e7#,
16#0d#, 16#10#, 16#e6#, 16#2a#, 16#2b#, 16#00#, 16#2b#, 16#36#, 16#27#, 16#c9#, 16#01#, 16#00#, 16#04#, 16#2a#, 16#16#, 16#00#,
16#23#, 16#23#, 16#11#, 16#23#, 16#f6#, 16#1a#, 16#be#, 16#28#, 16#17#, 16#13#, 16#e5#, 16#21#, 16#05#, 16#00#, 16#19#, 16#eb#,
16#e1#, 16#0c#, 16#10#, 16#f1#, 16#06#, 16#04#, 16#79#, 16#fe#, 16#08#, 16#20#, 16#ea#, 16#f1#, 16#ff#, 16#2b#, 16#18#, 16#ea#,
16#13#, 16#23#, 16#1a#, 16#e6#, 16#7f#, 16#be#, 16#20#, 16#f5#, 16#23#, 16#7e#, 16#fe#, 16#27#, 16#79#, 16#20#, 16#02#, 16#c6#,
16#04#, 16#cb#, 16#27#, 16#4f#, 16#06#, 16#00#, 16#21#, 16#64#, 16#00#, 16#ed#, 16#42#, 16#44#, 16#4d#, 16#e7#, 16#0c#, 16#cd#,
16#b3#, 16#f2#, 16#ed#, 16#5b#, 16#16#, 16#00#, 16#cd#, 16#f4#, 16#f2#, 16#20#, 16#04#, 16#1a#, 16#fe#, 16#3b#, 16#c8#, 16#eb#,
16#c5#, 16#e1#, 16#72#, 16#2b#, 16#73#, 16#c3#, 16#e4#, 16#f5#, 16#21#, 16#48#, 16#50#, 16#22#, 16#42#, 16#00#, 16#21#, 16#30#,
16#38#, 16#22#, 16#45#, 16#00#, 16#c9#, 16#21#, 16#f4#, 16#f1#, 16#11#, 16#35#, 16#00#, 16#01#, 16#12#, 16#00#, 16#ed#, 16#b0#,
16#c9#, 16#cd#, 16#ed#, 16#f6#, 16#38#, 16#4c#, 16#22#, 16#47#, 16#00#, 16#ed#, 16#43#, 16#49#, 16#00#, 16#2a#, 16#1d#, 16#00#,
16#22#, 16#4b#, 16#00#, 16#2a#, 16#2b#, 16#00#, 16#36#, 16#20#, 16#ed#, 16#43#, 16#2b#, 16#00#, 16#c9#, 16#3a#, 16#1c#, 16#00#,
16#fe#, 16#ec#, 16#d8#, 16#3a#, 16#1b#, 16#00#, 16#e6#, 16#e0#, 16#32#, 16#1b#, 16#00#, 16#3a#, 16#1d#, 16#00#, 16#e6#, 16#e0#,
16#32#, 16#1d#, 16#00#, 16#2a#, 16#1d#, 16#00#, 16#ed#, 16#4b#, 16#1b#, 16#00#, 16#ed#, 16#42#, 16#d8#, 16#28#, 16#11#, 16#2b#,
16#3e#, 16#03#, 16#bc#, 16#d8#, 16#23#, 16#11#, 16#40#, 16#00#, 16#ed#, 16#52#, 16#d8#, 16#11#, 16#20#, 16#00#, 16#19#, 16#c9#,
16#37#, 16#c9#, 16#f1#, 16#ff#, 16#fe#, 16#97#, 16#df#, 16#3e#, 16#f7#, 16#ed#, 16#47#, 16#f3#, 16#21#, 16#24#, 16#f7#, 16#01#,
16#03#, 16#03#, 16#ed#, 16#b3#, 16#2a#, 16#0b#, 16#00#, 16#2b#, 16#7e#, 16#32#, 16#69#, 16#00#, 16#36#, 16#fb#, 16#ed#, 16#73#,
16#6a#, 16#00#, 16#ed#, 16#7b#, 16#63#, 16#00#, 16#e5#, 16#c3#, 16#4a#, 16#f5#, 16#f3#, 16#cd#, 16#33#, 16#f5#, 16#3e#, 16#07#,
16#d3#, 16#03#, 16#2a#, 16#0b#, 16#00#, 16#2b#, 16#3a#, 16#69#, 16#00#, 16#77#, 16#e1#, 16#22#, 16#0b#, 16#00#, 16#22#, 16#61#,
16#00#, 16#ed#, 16#73#, 16#63#, 16#00#, 16#ed#, 16#7b#, 16#6a#, 16#00#, 16#11#, 16#0d#, 16#00#, 16#01#, 16#03#, 16#00#, 16#ed#,
16#b0#, 16#21#, 16#e4#, 16#f5#, 16#e5#, 16#ed#, 16#4d#, 16#cd#, 16#ff#, 16#f4#, 16#1a#, 16#be#, 16#20#, 16#08#, 16#0b#, 16#23#,
16#13#, 16#78#, 16#b1#, 16#c8#, 16#18#, 16#f4#, 16#e7#, 16#07#, 16#e7#, 16#0e#, 16#7e#, 16#e7#, 16#06#, 16#e7#, 16#0e#, 16#eb#,
16#e7#, 16#07#, 16#e7#, 16#0e#, 16#eb#, 16#1a#, 16#e7#, 16#06#, 16#e7#, 16#02#, 16#8d#, 16#e7#, 16#01#, 16#fe#, 16#0d#, 16#c0#,
16#18#, 16#dc#, 16#ed#, 16#5b#, 16#25#, 16#00#, 16#1b#, 16#1b#, 16#ed#, 16#53#, 16#23#, 16#00#, 16#ed#, 16#4b#, 16#1b#, 16#00#,
16#ed#, 16#5b#, 16#23#, 16#00#, 16#e7#, 16#03#, 16#0a#, 16#bd#, 16#28#, 16#07#, 16#03#, 16#78#, 16#b1#, 16#28#, 16#32#, 16#18#,
16#f5#, 16#c5#, 16#d5#, 16#ed#, 16#5b#, 16#1d#, 16#00#, 16#1b#, 16#ed#, 16#53#, 16#6c#, 16#00#, 16#03#, 16#7a#, 16#b3#, 16#d1#,
16#28#, 16#13#, 16#e7#, 16#03#, 16#0a#, 16#bd#, 16#20#, 16#15#, 16#d5#, 16#ed#, 16#5b#, 16#6c#, 16#00#, 16#1b#, 16#ed#, 16#53#,
16#6c#, 16#00#, 16#03#, 16#18#, 16#e8#, 16#c1#, 16#ed#, 16#43#, 16#1b#, 16#00#, 16#c3#, 16#25#, 16#f3#, 16#c1#, 16#03#, 16#18#,
16#bf#, 16#e7#, 16#02#, 16#4e#, 16#4f#, 16#54#, 16#20#, 16#46#, 16#4f#, 16#55#, 16#4e#, 16#44#, 16#8d#, 16#c9#, 16#4a#, 16#f7#);
end package bm204_202_pkg;
