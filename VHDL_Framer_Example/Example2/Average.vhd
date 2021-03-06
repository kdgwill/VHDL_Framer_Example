LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.ALL;


entity Average is 
   generic (
  	bits: integer
  );
 port (clk             : in  std_logic;
       resetb          : in  std_logic;
       data_sig_in     : in  std_ulogic;
       clk_div_8       : in  std_ulogic;
	     decode_F628_out : in  std_ulogic;

		   ram_wren        : OUT STD_LOGIC ;
       ram_address		   : out STD_LOGIC_VECTOR (4 DOWNTO 0);
       ram_data        : out STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
       ram_q           : in STD_LOGIC_VECTOR (bits-1 DOWNTO 0);

       add_value0x     : Out STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
       add_value1x     : Out STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
		   add_sum	       	: In STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
		   
		   div_denom	     	: Out STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
		   div_numer		     : Out STD_LOGIC_VECTOR (bits-1 DOWNTO 0)
		   );           
end Average;  

ARCHITECTURE Average of Average IS
  ---Default Variables----
Signal shiftreg :  STD_LOGIC_VECTOR (7 DOWNTO 0);
Signal shiftreg8 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
Signal byte_count:integer:=0;           
Signal enabled : STD_LOGIC := '0';       
begin
  
------Shiftreg----
Process (clk, resetb)
begin
  if (resetb = '0')then
    shiftreg <= (others => '0');
  elsif rising_edge (clk) then
      shiftreg <= shiftreg (6 downto 0) & data_sig_in;
  end if;
end process;
-------Receiving values
Process(clk_div_8,resetb)
Begin
  if(resetb = '0') then
      shiftreg8 <= (others => '0');
  elsif falling_edge (clk_div_8) then
      shiftreg8 <=shiftreg;
  end if;
End Process; 

--bit counter
process (clk_div_8, resetb)
  begin
    if (resetb = '0')  then
        byte_count <= 0;
    elsif falling_edge (clk_div_8) then
        if (decode_F628_out = '1') then
            byte_count <= -1;
            enabled <= '1';
        else
            byte_count <= byte_count + 1;
        end if;
    end if;
end process;
--------------------------------
-----------RAM------------------
--------------------------------
Process(clk_div_8,resetb)
Begin
  if(resetb = '0') then
      ram_wren <= '0';
  elsif falling_edge (clk_div_8) then
      ram_wren <= '1'; 
  elsif rising_edge(clk_div_8) then
      ram_wren <= '0';
  end if;
End Process; 

Process(clk_div_8,resetb)
variable saddr : integer := 10-1;
variable daddr : integer := 0 - 1;
begin
  if (resetb = '0')  then
        saddr := 0;
        daddr := 0;
        ram_address <= (others => '0' );
        ram_data <= (others => '0' );
  elsif falling_edge (clk_div_8) then
    if (decode_F628_out = '1') then
            saddr := 10 - 1;
            daddr := 0 - 1;
    else
      case byte_count is
        when 180 to 182 | 
             450 to 452 | 
             540 to 542 | 
             630 to 632 => saddr := saddr + 1;
             ram_address<= std_logic_vector(to_unsigned  (saddr,5));
             ram_data <= STD_LOGIC_VECTOR(RESIZE(UNSIGNED(shiftreg8), bits));
             daddr := 0 - 1; --reset payload packet counter
        when 3   to 89  |
             93  to 179 |
             183 to 269 |
             273 to 359 |
             363 to 449 | 
             453 to 539 |
             543 to 629 |
             633 to 719 |
             723 to 809=>  daddr := (daddr + 1) mod 10;
             ram_address<= std_logic_vector(to_unsigned  (daddr,5));
             ram_data <= STD_LOGIC_VECTOR(RESIZE(UNSIGNED(shiftreg8), bits));
        when others => null; 
      end case;
    end if;
  end if;
end process;
--------------------------------
--------------ADDER AND DIVIDER-------------
Process(clk_div_8,resetb)
variable saddr : integer := 0;
Begin
  if(resetb = '0') then
      saddr := 0-1;
  elsif falling_edge(clk_div_8) then
    if (decode_F628_out = '1') then
            saddr := 0-1;
    end if; 
  elsif rising_edge(clk_div_8) then
       saddr := (saddr + 1) mod 10;
       add_value1x <= ram_q;
       --ram_address <= std_logic_vector(to_unsigned  (saddr,5));
       if(saddr = 10 - 1) then
          div_numer <= add_sum;  
          add_value0x <= (others => '0');
       else
          add_value0x <= add_sum;    
       end if;
  end if;
  div_denom <= X"0000000A";--always 10
End Process; 
  
END Average;  
           	 	                     	 	
