---------------------------------------------------------------------------------
--Generator------------------------------------------------------------
--By Kyle Williams, 04/07/2011--------------------------------------------------
--PROJECT DESCRIPTION------------------------------------------------------------
--1--Input Serial data stream----------------------------------------------------
----------------Define Libraries to be used-------------------------------------- 
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
-----------------ENTITY FOR GENERATOR------------------------------------------ 
ENTITY generator IS
  Generic(N : Integer := 8);
  PORT( 
        clock, reset, load: OUT std_logic;
        D                 : OUT std_logic_vector(n-1 downto 0);
        vec                     : OUT  std_logic_vector(N-1 downto 0);
        sin                     : OUT  STD_Logic
  );
END generator;
-----------------BEHAVIOR OF GENERATOR----------------------------------------- 
ARCHITECTURE behavior OF generator IS
-------------------VARIABLE DECLARATION---------------------------------------- 
signal S_clock: std_logic := '0';
signal S_D: std_logic_vector(n-1 downto 0) := (others =>'0');
signal S_reset: std_logic := '0';
signal S_load: std_logic :='0';


  signal tap: std_logic;
 signal ssr: std_logic_vector(n-1 downto 0);
 -------------------PROCEDUREE------------------------------ 
BEGIN
	S_clock <= not S_clock after 5 ns;
	S_D <= "10101011" after 250 ns;
	S_reset <= '1' after 10 ns;
  
  process 
  begin
    S_load <= '1';
    wait for 10 ns;
    S_load <= '0';
    wait for 10 ns;
  end process;
  
  clock  <= S_clock;
  reset  <= S_reset;
  load   <= S_load;
  D      <= S_D;
  
  
 
  Process(S_Clock,S_Reset,S_Load) 
  Begin
      If(S_reset='0') then
        SSR <= (others => '0');
      elsif rising_edge(S_Clock) Then
        IF S_Load = '1' AND (SSR="00000000" OR SSR="11111111") Then 
          SSR <= S_D;
        ELSE
          SSR<= SSR(6 downTo 0)&tap;
        END If;
      End If;
      tap<=SSR(1) XOR SSR(2) XOR SSR(3) XOR SSR(7);    
      sin<= SSR(7);
      vec<= SSR;
  End Process;  
END behavior; 
