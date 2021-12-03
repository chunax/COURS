----------------------------------------------

-- Mux 4->1

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity mux4_1 is
  generic (size : integer);
  port(
    reg0, reg1, reg2, reg3 : in std_logic_vector(size-1 downto 0);
    reg_out : out std_logic_vector(size-1 downto 0);
    c : in std_logic_vector(1 downto 0)
    );
end entity;

architecture cmp_mux4_1 of mux4_1 is
begin
  reg_out <= reg0 when c = "00" else
               reg1 when c = "01" else
               reg2 when c = "10" else
               reg3;

end cmp_mux4_1;

----------------------------------------------------

--Simple adder for 32 bit words

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity add is
  port(
    reg1, reg2 : in std_logic_vector(31 downto 0);
    reg3 : out std_logic_vector(31 downto 0)
    );
end entity;

architecture fdd_add of add is
  begin
    reg3 <= std_logic_vector(unsigned(reg1) + unsigned(reg2));
  
  end fdd_add;

------------------------------------------------------

-- Full 32b adder with carry bits out

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity full_add1 is
  port(
    a, b, cin : in std_logic;
    s, cout : out std_logic
  );
end entity;

architecture struct_full_add1 of full_add1 is
  begin
    s <= (a xor b) xor cin;
    cout <= ((a xor b) and cin) or (a and b);
  end struct_full_add1;



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity addCarry is
  port(
    A, B: in std_logic_vector(31 downto 0);
    cin: in std_logic;
    s : out std_logic_vector(31 downto 0);
    c30, c31: out std_logic);
end entity;


architecture struct_full_add32 of addCarry is
  component full_add1
  port(
    A, B, cin : in std_logic;
    S, cout : out std_logic
  );
  end component;
  signal c: std_logic_vector(32 downto 0);
begin

  c(0) <= cin;
  c31 <= c(32);
  c30 <= c(31);
  G: for I in 0 to 31 generate
   inst: full_add1 port map(A(I), B(I), c(I), S(I), c(I+1));
  end generate G;


end struct_full_add32;
-----------------------------------------------

-- Barrel shifter


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.bus_mux_pkg.ALL;

entity BarrelShifter IS
  port (
    A : in std_logic_vector(31 downto 0);
    ValDec : in std_logic_vector(4 downto 0);
    SR, SL : out std_logic_vector(31 downto 0)
    );
end entity;


architecture arch_barrel_shifter of BarrelShifter is
  signal tab_droite : bus_mux_array(32 downto 0);
  signal tab_gauche : bus_mux_array(32 downto 0);
begin
  tab_droite(0) <= A;
  tab_gauche(0) <= A;
  loop_droite : FOR i IN 1 to 32 generate
    tab_droite(i) <= '0' & tab_droite(i-1)(31 downto 1);
    tab_gauche(i) <= tab_gauche(i-1)(30 downto 0) & '0';
  end generate loop_droite;
  SR <= tab_droite( to_integer(unsigned(ValDec)) );
  SL <= tab_gauche( to_integer(unsigned(ValDec)) );
end arch_barrel_shifter ;


-----------------------------------------------

-- Full ALU

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity AND2 is
  port(A, B: in STD_LOGIC_VECTOR(31 downto 0);
       S: out STD_LOGIC_VECTOR(31 downto 0));
end entity;
architecture fdd of AND2 is 
begin 
  S <=  A and B;
end fdd;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity AND2_1bit is
  port(A, B: in STD_LOGIC;
       S: out STD_LOGIC);
end entity;
architecture fdd of AND2_1bit is 
begin 
  S <=  A and B;
end fdd;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity OR2 is
  port(A, B: in STD_LOGIC_VECTOR(31 downto 0);
       S: out STD_LOGIC_VECTOR(31 downto 0));
end entity;
architecture fdd of OR2 is 
begin
  S <=  A or B;
end fdd;



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity OR2_1bit is
  port(A, B: in STD_LOGIC;
       S: out STD_LOGIC);
end entity;
architecture fdd of OR2_1bit is 
begin
  S <=  A or B;
end fdd;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity XOR2 is
  port(A, B: in STD_LOGIC_VECTOR(31 downto 0);
       S: out STD_LOGIC_VECTOR(31 downto 0));
end entity;
architecture fdd of XOR2 is 
begin
  S <=  A xor B;
end fdd;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity XOR2_1bit is
  port(A, B: in STD_LOGIC;
       S: out STD_LOGIC);
end entity;
architecture fdd of XOR2_1bit is 
begin
  S <=  A xor B;
end fdd;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity NOR2 is
  port(A, B: in STD_LOGIC_VECTOR(31 downto 0);
       S: out STD_LOGIC_VECTOR(31 downto 0));
end entity;
architecture fdd of NOR2 is 
begin
  S <=  A nor B;
end fdd;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity NOT1 is
  port(A: in STD_LOGIC;
       S: out STD_LOGIC);
end entity;
architecture fdd of NOT1 is 
begin
  S <=  not A;
end fdd;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity CONCAT31 is
  port(A: in STD_LOGIC;
       S: out STD_LOGIC_VECTOR(31 downto 0));
end entity;
architecture fdd of CONCAT31 is 
signal s_zeros : std_logic_vector( 30 downto 0);
begin
  s_zeros <= (others => '0');
  S <=  s_zeros & A;
end fdd;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity AFFECT is
  port(A: in STD_LOGIC_VECTOR(31 downto 0);
       S: out STD_LOGIC_VECTOR(31 downto 0));
end entity;
architecture fdd of AFFECT is 
begin
  S <= A;
end fdd;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity NOR31_BIT is
  port(A: in STD_LOGIC_VECTOR(31 downto 0);
       S: out STD_LOGIC);
end entity;
architecture fdd of NOR31_BIT is 
signal nor31, nor30, nor29, nor28, nor27, nor26, nor25, nor24,
nor23, nor22, nor21, nor20, nor19, nor18, nor17, nor16, nor15,
nor14, nor13, nor12, nor11, nor10, nor9, nor8, nor7, nor6,
nor5, nor4, nor3, nor2: std_logic; 
begin
  nor31 <= A(31) nor A(30);
  nor30 <= nor31 nor A(29);
  nor29 <= nor30 nor A(28);
  nor28 <= nor29 nor A(27);
  nor27 <= nor28 nor A(26);
  nor26 <= nor27 nor A(25);
  nor25 <= nor26 nor A(24);
  nor24 <= nor25 nor A(23);
  nor23 <= nor24 nor A(22);
  nor22 <= nor23 nor A(21);
  nor21 <= nor22 nor A(20);
  nor20 <= nor21 nor A(19);
  nor19 <= nor20 nor A(18);
  nor18 <= nor19 nor A(17);
  nor17 <= nor18 nor A(16);
  nor16 <= nor17 nor A(15);
  nor15 <= nor16 nor A(14);
  nor14 <= nor15 nor A(13);
  nor13 <= nor14 nor A(12);
  nor12 <= nor13 nor A(11);
  nor11 <= nor12 nor A(10);
  nor10 <= nor11 nor A(9);
  nor9 <= nor10 nor A(8);
  nor8 <= nor9 nor A(7);
  nor7 <= nor8 nor A(6);
  nor6 <= nor7 nor A(5);
  nor5 <= nor6 nor A(4);
  nor4 <= nor5 nor A(3);
  nor3 <= nor4 nor A(2);
  nor2 <= nor3 nor A(1);
  S <= nor2 nor A(0);
end fdd;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity multiplexeur81_32bits is 
port (entree0 : in std_logic_vector(31 downto 0);
      entree1 : in std_logic_vector(31 downto 0);
      entree2 : in std_logic_vector(31 downto 0);
      entree3 : in std_logic_vector(31 downto 0);
      entree4 : in std_logic_vector(31 downto 0);
      entree5 : in std_logic_vector(31 downto 0);
      entree6 : in std_logic_vector(31 downto 0);
      entree7 : in std_logic_vector(31 downto 0);
      selecteur : in std_logic_vector(2 downto 0);
      sortie  : out std_logic_vector(31 downto 0));
end multiplexeur81_32bits;

architecture fdd_multi81_32bits of multiplexeur81_32bits is
begin
  With selecteur select
  sortie<= entree0 when "000",
           entree1 when "001",
           entree2 when "010",
           entree3 when "011",
           entree4 when "100",
           entree5 when "101",
           entree6 when "110",
           entree7 when "111",
           "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" when others;
end fdd_multi81_32bits;



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY ALU IS
	PORT
	(
		A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		sel : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		Enable_V : IN STD_LOGIC;
		ValDec : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		Slt : IN STD_LOGIC;
		CLK : IN STD_LOGIC;
		Res : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		N : OUT STD_LOGIC;
		Z : OUT STD_LOGIC;
		C : OUT STD_LOGIC;
		V : OUT STD_LOGIC
	);
END ENTITY ALU;


architecture arch_ALU of ALU is
  signal and_000, or_001, xor_add, add_010, res0_011, nor_100, xor_101, SR_110, SL_111, tmp_Res : std_logic_vector(31 downto 0);
  signal s_c30, s_c31, xor_c30_c31 : std_logic;
  signal xor_c3031_add010_31, not_enable, xor_sel3_c31 : std_logic;
  signal and_xorsel3c31_notenable, and_enable_xorc3031_add010_31 : std_logic;
  signal res0, s_nor31, not_slt : std_logic;
  signal sel3_32bit : std_logic_vector(31 downto 0);
begin
  U1 : entity work.AND2 port map(A => A, B => B, S => and_000);
  U2 : entity work.OR2 port map(A => A, B => B, S => or_001);
  U3 : entity work.CONCAT31 port map(A => sel(3), S => sel3_32bit);
  U4 : entity work.XOR2 port map(A => B, B => sel3_32bit , S => xor_add );
  U5 : entity work.addCarry port map(A => A, B => xor_add, cin => sel(3), s => add_010, c30 => s_c30, c31 => s_c31);
  U6 : entity work.XOR2_1bit port map(A => s_c31, B => s_c30, S => xor_c30_c31);
  U7 : entity work.XOR2_1bit port map(A => sel(3), B => s_c31, S => xor_sel3_c31);
  U8 : entity work.XOR2_1bit port map(A => xor_c30_c31, B => add_010(31) , S => xor_c3031_add010_31);
  U9 : entity work.NOT1 port map(A => Enable_V, S => not_enable);
  U10 : entity work.AND2_1bit port map(A => xor_sel3_c31, B => not_enable, S => and_xorsel3c31_notenable);
  U11 : entity work.AND2_1bit port map(A => Enable_V, B => xor_c3031_add010_31, S => and_enable_xorc3031_add010_31);
  U12 : entity work.OR2_1bit port map(A => and_xorsel3c31_notenable, B => and_enable_xorc3031_add010_31, S => res0);
  U13 : entity work.CONCAT31 port map(A => res0, S => res0_011);
  U14 : entity work.NOR2 port map(A => A, B => B, S => nor_100);
  U15 : entity work.XOR2 port map(A => A, B => B, S => xor_101);
  U16 : entity work.BarrelShifter port map(A => B, ValDec => ValDec, SR => SR_110, SL => SL_111);
  U17 : entity work.multiplexeur81_32bits port map(entree0 => and_000, entree1 => or_001,
  entree2 => add_010, entree3 => res0_011, entree4 => nor_100, entree5 => xor_101,
  entree6 => SR_110, entree7 => SL_111, selecteur => sel(2 downto 0), sortie => tmp_Res);
  U18 : entity work.AFFECT port map (A => tmp_res, S => Res);
  U19 : entity work.NOR31_BIT port map(A => tmp_Res, S => s_nor31);
  U20 : entity work.NOT1 port map(A => Slt, S => not_slt);
  process(CLK)
  begin
    if falling_edge(CLK) then
      C <= xor_sel3_c31;
      V <= Enable_V and not_slt and xor_c30_c31;
      N <= add_010(31);
      Z <= s_nor31;
    end if;
  end process;


end arch_ALU ;

---------------------------------------------------

-- Extension logic for immediate inputs

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity extension is
  port(
    inst : in std_logic_vector(31 downto 0);
    ExtOp : in std_logic;
    ExtOut : out std_logic_vector(31 downto 0)
    );
end entity;


architecture arch_extension of extension is 
begin
  ExtOut <= "1111111111111111" & inst(15 downto 0) when (ExtOp  and inst(15))= '1' else
            "0000000000000000" & inst(15 downto 0);

end arch_extension ; -- arch_extension