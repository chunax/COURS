LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY Port_Lecture IS
	PORT
	(
		adress : IN std_logic_vector(31 downto 0);
        Read_in : IN std_logic_vector(31 downto 0);
        ReadMem_W : IN std_logic;
        ReadMem_SH : IN std_logic;
        ReadMem_UH : IN std_logic;
        ReadMem_SB : IN std_logic;
        ReadMem_UB : IN std_logic;
        Read_out : OUT std_logic_vector(31 downto 0)
	);
END ENTITY Port_Lecture;


architecture fdd_port_lecture of Port_Lecture is
    signal zero_15 : std_logic_vector(15 downto 0) := (others => '0');
    signal zero_23 : std_logic_vector(23 downto 0) := (others => '0');
    signal ext_SH_31 : std_logic_vector(15 downto 0);
    signal ext_SH_15 : std_logic_vector(15 downto 0);
    signal ext_SB_31 : std_logic_vector(23 downto 0);
    signal ext_SB_23 : std_logic_vector(23 downto 0);
    signal ext_SB_15 : std_logic_vector(23 downto 0);
    signal ext_SB_7 : std_logic_vector(23 downto 0);
    signal tmp_W : std_logic_vector(31 downto 0);
    signal tmp_SH : std_logic_vector(31 downto 0);
    signal tmp_UH : std_logic_vector(31 downto 0);
    signal tmp_SB : std_logic_vector(31 downto 0);
    signal tmp_UB : std_logic_vector(31 downto 0);
begin 
    tmp_W <= Read_in; 
    ext_SH_31 <= (others => Read_in(31));
    ext_SH_15 <= (others => Read_in(15));
    ext_SB_31 <= (others => Read_in(31));
    ext_SB_23 <= (others => Read_in(23));
    ext_SB_15 <= (others => Read_in(15));
    ext_SB_7 <= (others => Read_in(7));
    tmp_SH <= ext_SH_31 & Read_in(31 downto 16) when (adress(1) = '1' and adress(0) = '0') else
              ext_SH_15 & Read_in(15 downto 0) when (adress(1) = '0' and adress(0) = '0') else 
              "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    tmp_UH <= zero_15 & Read_in(31 downto 16) when (adress(1) = '1' and adress(0) = '0') else
              zero_15 & Read_in(15 downto 0) when (adress(1) = '0' and adress(0) = '0') else
              "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    tmp_SB <= ext_SB_7 & Read_in(7 downto 0) when (adress(1) = '0' and adress(0) = '0') else
              ext_SB_15 & Read_in(15 downto 8) when (adress(1) = '0' and adress(0) = '1') else
              ext_SB_23 & Read_in(23 downto 16) when (adress(1) = '1' and adress(0) = '0') else
              ext_SB_23 & Read_in(31 downto 24) when (adress(1) = '1' and adress(0) = '0') else
              "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    tmp_UB <= zero_23 & Read_in(7 downto 0) when (adress(1) = '0' and adress(0) = '0') else
              zero_23 & Read_in(15 downto 8) when (adress(1) = '0' and adress(0) = '1') else
              zero_23 & Read_in(23 downto 16) when (adress(1) = '1' and adress(0) = '0') else
              zero_23 & Read_in(31 downto 24) when (adress(1) = '1' and adress(0) = '0') else
              "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    Read_out <= tmp_W when ReadMem_W = '1' else
                tmp_SH when ReadMem_SH = '1' else
                tmp_UH when ReadMem_UH = '1' else
                tmp_SB when ReadMem_SB = '1' else
                tmp_UB when ReadMem_UB = '1' else
                "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
end fdd_port_lecture;




LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY Port_Ecriture IS
	PORT
	(
		adress : IN std_logic_vector(31 downto 0);
        data_in : IN std_logic_vector(31 downto 0);
        current_mem : IN std_logic_vector(31 downto 0);
        WriteMem_W : IN std_logic;
        WriteMem_H : IN std_logic;
        WriteMem_B : IN std_logic;
        data_out : OUT std_logic_vector(31 downto 0)
	);
END ENTITY Port_Ecriture;

architecture fdd_port_ecriture of Port_Ecriture is
    signal tmp_W : std_logic_vector(31 downto 0);
    signal tmp_H : std_logic_vector(31 downto 0);
    signal tmp_B : std_logic_vector(31 downto 0);
    signal tmp_currmem_31 : std_logic_vector(15 downto 0);
    signal tmp_currmem_15 : std_logic_vector(15 downto 0);
    signal tmp_SB_31 : std_logic_vector(23 downto 0);
    signal tmp_SB_23_1 : std_logic_vector(7 downto 0);
    signal tmp_SB_23_2 : std_logic_vector(15 downto 0);
    signal tmp_SB_15_1 : std_logic_vector(15 downto 0);
    signal tmp_SB_15_2 : std_logic_vector(7 downto 0);
    signal tmp_SB_7 : std_logic_vector(23 downto 0);
begin
    tmp_W <= data_in when adress(1 downto 0) = "00" else (others => 'X');
    tmp_currmem_31 <= current_mem(31 downto 16);
    tmp_currmem_15 <= current_mem(15 downto 0);
    tmp_H <=  data_in(15 downto 0) & tmp_currmem_15 when (adress(1) = '1' and adress(0) = '0') else
              tmp_currmem_31 & data_in(15 downto 0) when (adress(1) = '0' and adress(0) = '0') else
              "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    tmp_SB_7 <= current_mem(31 downto 8);
    tmp_SB_15_1 <= current_mem(31 downto 16);
    tmp_SB_15_2 <= current_mem(7 downto 0);
    tmp_SB_23_1 <= current_mem(31 downto 24);
    tmp_SB_23_2 <= current_mem(15 downto 0);
    tmp_SB_31 <= current_mem(23 downto 0);
    
    tmp_B <= tmp_SB_7 & data_in(7 downto 0) when (adress(1) = '0' and adress(0) = '0') else
             tmp_SB_15_1 & data_in(7 downto 0) & tmp_SB_15_2 when (adress(1) = '0' and adress(0) = '1') else
             tmp_SB_23_1 & data_in(7 downto 0) & tmp_SB_23_2 when (adress(1) = '1' and adress(0) = '0') else
             data_in(7 downto 0) & tmp_SB_31 when (adress(1) = '1' and adress(0) = '0') else
             "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    data_out <= tmp_W when WriteMem_W = '1' else
                tmp_H when WriteMem_H = '1' else
                tmp_B when WriteMem_B = '1' else
                "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

end fdd_port_ecriture ; -- fdd_port_ecriture



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.bus_mux_pkg.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Module_Memoire IS
	PORT
	(adress : IN std_logic_vector(31 downto 0);
     data_in : IN std_logic_vector(31 downto 0);
     ReadMem_W : IN std_logic;
     ReadMem_SH : IN std_logic;
     ReadMem_UH : IN std_logic;
     ReadMem_SB : IN std_logic;
     ReadMem_UB : IN std_logic;
     WriteMem_W : IN std_logic;
	 WriteMem_H : IN std_logic;
     WriteMem_B : IN std_logic;
     WE : IN std_logic;
     OE : IN std_logic;
     clk : IN std_logic;
     init : IN std_logic;
     data_instr : IN std_logic;
     data_out : OUT std_logic_vector(31 downto 0)
	);
END ENTITY Module_Memoire;

architecture fdd_module_memoire of Module_Memoire is
    signal banc_reg : bus_mux_array(2047 downto 0);
    signal read_out : std_logic_vector(31 downto 0);
    signal data_out_ecriture : std_logic_vector(31 downto 0);
    signal read_in_mem : std_logic_vector(31 downto 0);
begin
    read_in_mem <= banc_reg(to_integer(unsigned(adress(31 downto 0))));
    U1 : entity work.Port_Lecture port map(adress => adress, Read_in => read_in_mem,
         ReadMem_W => ReadMem_W, ReadMem_SH => ReadMem_SH, ReadMem_UH => ReadMem_UH,
         ReadMem_SB => ReadMem_SB, ReadMem_UB => ReadMem_UB, Read_out => read_out);
    U2 : entity work.Port_Ecriture port map(adress => adress, data_in => data_in,
         current_mem => read_in_mem, WriteMem_W => WriteMem_W, WriteMem_H => WriteMem_H,
         WriteMem_B => WriteMem_B, data_out => data_out_ecriture);
    data_out <= read_out when (WE = '1' and OE = '0') else
                (others => 'Z');
    process(clk)
    begin
        if (rising_edge(clk) and init = '0' and WE = '0') then 
            banc_reg(to_integer(unsigned(adress(31 downto 0)))) <= data_out_ecriture;
        end if;

    end process;

end fdd_module_memoire ; -- fdd_port_ecriture