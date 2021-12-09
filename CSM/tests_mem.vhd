LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity test_lecture is
end test_lecture;

architecture arch_lecture of test_lecture is
    signal s_adress, s_Read_in, s_Read_out : std_logic_vector(31 downto 0);
    signal s_ReadMem_W, s_ReadMem_SH, s_ReadMem_UH, s_ReadMem_SB, s_ReadMem_UB : std_logic := '0';
begin
    pgen0 : entity work.Port_LEcture(fdd_port_lecture)
        port map(adress => s_adress,
                 Read_in => s_Read_in,
                 ReadMem_W => s_ReadMem_W,
                 ReadMem_SH => s_ReadMem_SH,
                 ReadMem_UH => s_ReadMem_UH,
                 ReadMem_SB => s_ReadMem_SB,
                 ReadMem_UB => s_ReadMem_UB,
                 Read_Out => s_Read_out);

    process
    begin
        s_adress <= "11111111111111111111111111111110";
        s_Read_in <= "11111111111111110000000000000000";
        s_ReadMem_W <= '1';
        wait for 5 ns;
        s_ReadMem_W <= '0';
        s_ReadMem_SH <= '1';
        wait for 5 ns;
        s_ReadMem_SH <= '0';
        s_ReadMem_SB <= '1';
        wait for 5 ns;
    wait;
    end process;

end arch_lecture;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity test_ecriture is
end test_ecriture;

architecture arch_ecriture of test_ecriture is
    signal s_adress ,s_data_in, s_current_mem, s_data_out : std_logic_vector(31 downto 0);
    signal s_WriteMem_W, s_WriteMem_H, s_WriteMem_B : std_logic := '0';
begin
    pgen1 : entity work.Port_Ecriture(fdd_port_ecriture)
        port map( adress => s_adress,
                  data_in => s_data_in,
                  current_mem => s_current_mem,
                  WriteMem_W => s_WriteMem_W,
                  WriteMem_H => s_WriteMem_H,
                  WriteMem_B => s_WriteMem_B,
                  data_out => s_data_out );

    process
    begin
        s_adress <= "11111111111111111111111111111100";
        s_data_in <= "11111111111111111111111111111111";
        s_current_mem <= (others => '0');
        s_WriteMem_W <= '1';
        wait for 5 ns;
        s_WriteMem_W <= '0';
        s_WriteMem_H <= '1';
        wait for 5 ns;
        s_WriteMem_H <= '0';
        s_WriteMem_B <= '1';
        wait for 5 ns;
        s_WriteMem_B <= '0';
    wait;
    end process;

end arch_ecriture;



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity test_memoire is
end test_memoire;

architecture arch_memoire of test_memoire is
    signal s_adress ,s_data_in, s_current_mem, s_data_out : std_logic_vector(31 downto 0);
    signal s_WriteMem_W, s_WriteMem_H, s_WriteMem_B,
    s_ReadMem_W, s_ReadMem_SH, s_ReadMem_UH, s_ReadMem_SB,
     s_ReadMem_UB, s_WE, s_OE, s_clk, s_init, s_data_instr : std_logic := '0';
begin
    pgen2 : entity work.Module_Memoire(fdd_module_memoire)
        port map( adress => s_adress,
        data_in => s_data_in,
        WriteMem_W => s_WriteMem_W,
        WriteMem_H => s_WriteMem_H,
        WriteMem_B => s_WriteMem_B,
        data_out => s_data_out,
        ReadMem_W => s_ReadMem_W,
        ReadMem_SH => s_ReadMem_SH,
        ReadMem_UH => s_ReadMem_UH,
        ReadMem_SB => s_ReadMem_SB,
        ReadMem_UB => s_ReadMem_UB,
        WE => s_WE,
        OE => s_OE,
        clk => s_clk,
        init => s_init,
        data_instr => s_data_instr  );

    process
    begin
        s_adress <= "00000000000000000000000111111100";
        s_data_in <= "11111111111111111111111111111111";
        s_WriteMem_W <= '1';
        s_WE <= '0';
        s_OE <= '1';
        wait for 5 ns;
        s_clk <= '1';
        wait for 5 ns;
        s_ReadMem_W <= '1';

        
    wait;
    end process;

end arch_memoire;