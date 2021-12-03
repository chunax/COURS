LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity test_reg is
end test_reg;

architecture cmp_Reg of test_reg is
    signal s_source: std_logic_vector(31 downto 0);
    signal s_output : std_logic_vector(31 downto 0);
    signal s_wr, s_clk : std_logic;
begin
    pgen0 : entity work.Reg(cmp_Reg)
        port map(source => s_source,
                output => s_output,
                wr => s_wr,
                clk => s_clk);

    process
    begin
        s_clk <= '0';
        s_wr <= '0';
        s_source <= (others => '1');
        wait for 5 ns;
        s_wr <= '1';
        s_clk <= '1';
        wait for 5 ns;
        s_clk <= '0';
        s_wr <= '0';
        s_source <= (others => '0');
        wait for 5 ns;
        s_wr <= '1';
        s_clk <= '1';
        wait for 5 ns;
    wait;
    end process;

end cmp_Reg;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity test_banc_reg is
end test_banc_reg;


architecture cmp_Reg of test_banc_reg is
    signal sig_s_reg_0 : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00001";
	signal sig_data_o_0 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal sig_s_reg_1 : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
	signal sig_data_o_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal sig_dest_reg : STD_LOGIC_VECTOR(4 DOWNTO 0);
	signal sig_data_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal sig_wr_reg : STD_LOGIC;
	signal sig_clk : STD_LOGIC;
begin
    pgen1 : entity work.RegisterBank(cmp_Reg_bank)
        port map(s_reg_0 => sig_s_reg_0,
                data_o_0 => sig_data_o_0,
                s_reg_1 => sig_s_reg_1,
                data_o_1 => sig_data_o_1,
                dest_reg => sig_dest_reg,
                data_i => sig_data_i,
                wr_reg => sig_wr_reg,
                clk => sig_clk );

    process
    begin
        sig_clk <= '0';
        sig_wr_reg <= '0';
        sig_data_i <= (others => '1');
        sig_dest_reg <= ("00001");
        wait for 5 ns;
        sig_clk <= '1';
        wait for 5 ns;
        sig_clk <= '0';
        sig_wr_reg <= '1';
        wait for 5 ns;
        sig_clk <= '1';
        wait for 5 ns;
       
    wait;
    end process;

end cmp_Reg;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity test_mux4_1 is
end test_mux4_1;


architecture cmp_mux4_1 of test_mux4_1 is
    
    signal s_reg0 : std_logic_vector(3 downto 0) := "0000";
    signal s_reg1 : std_logic_vector(3 downto 0) := "0001";
    signal s_reg2 : std_logic_vector(3 downto 0) := "0010";
    signal s_reg3 : std_logic_vector(3 downto 0) := "0011";
    signal s_reg_out : std_logic_vector(3 downto 0);
    signal s_c : std_logic_vector(1 downto 0);
begin
    pgen2 : entity work.mux4_1(cmp_mux4_1)
    generic map(4)
    port map(reg0 => s_reg0,
            reg1 => s_reg1,
            reg2 => s_reg2,
            reg3 => s_reg3,
            reg_out => s_reg_out,
            c => s_c);
    process
    begin
        s_c <= "00";
        wait for 5 ns;
        s_c <= "01";
        wait for 5 ns;
        s_c <= "10";
        wait for 5 ns;
        s_c <= "11";
        wait for 5 ns;
        s_c <= "00";
        wait for 5 ns;        
    wait;
    end process;
end cmp_mux4_1;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity test_add is
end test_add;


architecture fdd_add of test_add is
    signal s_reg1 : std_logic_vector(31 downto 0);
    signal s_reg2 : std_logic_vector(31 downto 0);
    signal s_reg3 : std_logic_vector(31 downto 0);
begin
    pgen3 : entity work.add(fdd_add)
    port map(reg1 => s_reg1,
             reg2 => s_reg2,
             reg3 => s_reg3);
    process
    begin
        s_reg1 <= (0 => '1' , others => '0');
        s_reg2 <= (0 => '1',others => '0');
        wait for 5 ns;
    wait;
    end process;
end fdd_add;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity test_add32 is
end test_add32;

architecture struct_add32 of test_add32 is
    signal s_A, s_B, s_S : std_logic_vector(31 downto 0);
    signal s_cin, s_c30, s_c31 : std_logic;
begin
    pgen4 : entity work.addCarry(struct_full_add32)
    port map( A => s_A,
             B => s_B,
             cin => s_cin,
             s => s_S,
             c30 => s_c30,
             c31 => s_c31);
    process
    begin
        s_A <= (others => '1');
        s_B <= (others => '1');
        s_cin <= '0';
        wait for 5 ns;
    wait;
    end process;

end struct_add32;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity test_barrel_shifter is
end test_barrel_shifter;

architecture fdd_barrel_shifter of test_barrel_shifter is
    signal s_A, s_SR, s_SL : std_logic_vector(31 downto 0);
    signal s_ValDec : std_logic_vector(4 downto 0) := "00000";
begin
    pgen5 : entity work.BarrelShifter(arch_barrel_shifter)
    port map(A => s_A,
            ValDec => s_ValDec,
            SR => s_SR,
            SL => s_SL);
    process
    begin
        s_A <= (0 => '1' , others => '0');
        s_ValDec <= (1 => '1' , others => '0');
        wait for 5 ns;
        s_ValDec <= (0 => '1' , others => '0');
        wait for 5 ns;

    wait;
    end process;
end fdd_barrel_shifter;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity test_ALU is
end test_ALU;

architecture struct_ALU of test_ALU is
    signal s_A, s_B, s_Res : std_logic_vector(31 downto 0);
    signal s_ValDec : std_logic_vector(4 downto 0);
    signal s_sel : std_logic_vector(3 downto 0);
    signal s_Enable_V, s_Slt, s_CLK, s_N, s_Z, s_C, s_V : std_logic;
begin
    pgen6 : entity work.ALU(arch_ALU)
    port map(A => s_A, B => s_B, sel => s_sel, Enable_V => s_Enable_V, ValDec => s_ValDec,
    Slt => s_Slt, CLK => s_CLK, Res => s_Res, N => s_N, Z => s_Z, C => s_C, V => s_V);
    process
    begin
        s_CLK <= '1';
        s_A <= (0 => '1' , others => '0');
        s_B <= (others => '1');
        s_sel <= "0000";
        s_Enable_V <= '0';
        s_ValDec <= "00010";
        s_Slt <= '0';
        wait for 5 ns;
        s_CLK <= '0';
        s_sel <= "0001";
        wait for 5 ns;
        s_CLK <= '1';
        wait for 5 ns;
        s_CLK <= '0';
        s_sel <= "0010";
        wait for 5 ns;
        s_CLK <= '1';
        wait for 5 ns;
        s_CLK <= '0';
        s_sel <= "0011";
        wait for 5 ns;
        s_CLK <= '1';
        wait for 5 ns;
        s_CLK <= '0';
        s_sel <= "0100";
        wait for 5 ns;
        s_CLK <= '1';
        wait for 5 ns;
        s_CLK <= '0';
        s_sel <= "0101";
        wait for 5 ns;
        s_CLK <= '1';
        wait for 5 ns;
        s_CLK <= '0';
        s_sel <= "0110";
        wait for 5 ns;
        s_CLK <= '1';
        wait for 5 ns;
        s_CLK <= '0';
        s_sel <= "0111";
        wait for 5 ns;
        s_CLK <= '1';
        wait for 5 ns;
        

    wait;
    end process;
end struct_ALU;




LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity test_extension is
end test_extension;

architecture arch_extension of test_extension is
    signal s_inst, s_ExtOut : std_logic_vector(31 downto 0);
    signal s_ExtOp : std_logic;
begin
    pgen7 : entity work.extension(arch_extension)
    port map(inst => s_inst, ExtOp => s_ExtOp, ExtOut => s_ExtOut);
    process
    begin
        s_ExtOp <= '0';
        s_inst <= "00000000000000000000000000000000";
        wait for 5 ns;
        s_ExtOp <= '1';
        s_inst <= "00000000000000001000000000000000";
        wait for 5 ns;
        s_ExtOp <= '1';
        s_inst <= "00000000000000000000000000000000";
        wait for 5 ns;
        

    wait;
    end process;
end arch_extension;