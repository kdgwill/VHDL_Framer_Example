---------------------------------------------------------------------------------
--Project Test Bench------------------------------------------------------------
--By Kyle Williams, 04/07/2011--------------------------------------------------
--PROJECT DESCRIPTION------------------------------------------------------------
--1--Input Serial data stream----------------------------------------------------
--2--Detect a start of Frame whose pattern is 10101011----------------------------
--3--After frame detect take every 8 bits and store them in a ram----------------
--4--After 8 bytes have been written in the ram start reading the data from the ram
--5--check that data read from ram matches what was written in the ram-----------
---------------------------------------------------------------------------------
----------------Define Libraries to be used-------------------------------------- 
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;
-----------------ENTITY FOR TEST BENCH------------------------------------------ 
ENTITY tb_ramIntro IS
  GENERIC (    bits   : INTEGER := 8);	 -- # of bits per word
END tb_ramIntro;
-----------------BEHAVIOR OF TEST BENCH----------------------------------------- 
ARCHITECTURE tb_ramIntro of tb_ramIntro IS
-----------------COMPONENT INITIALIZATIONS-------------------------------------- 
COMPONENT generator
  Generic(N : Integer := 8);
  PORT( 
        clock, reset, load: OUT std_logic;
        D                 : OUT std_logic_vector(n-1 downto 0);
        vec                     : OUT  std_logic_vector(N-1 downto 0);
        sin                     : OUT  STD_Logic
  );
END COMPONENT;

COMPONENT receiver   
  PORT ( reset    : IN  STD_Logic;
         clock		  : IN  STD_LOGIC;    
	       rec_in	  : IN  STD_LOGIC;
	       enable	  : OUT  STD_LOGIC; 
	       rec_out  : OUT STD_LOGIC_VECTOR (bits -1 DOWNTO 0)
	       );
End COMPONENT;

COMPONENT ramController 
  PORT ( reset    : IN  STD_Logic;
         clock		  : IN  STD_LOGIC; 
         enable   : IN  STD_LOGIC;
         ctrl_in	 : IN  STD_LOGIC_VECTOR (bits - 1 DOWNTO 0);	 
         addr		   : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
         wr_ena	  : OUT STD_LOGIC; -- write enable      
	       ctrl_out : OUT STD_LOGIC_VECTOR (bits -1 DOWNTO 0)
	);
End COMPONENT;
  
COMPONENT ram   
  PORT ( wr_ena	  : IN  STD_LOGIC; -- write enable
	       clock		  : IN  STD_LOGIC;
	       reset		  : IN  STD_LOGIC;
	       addr		   : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
	       ram_in	 : IN  STD_LOGIC_VECTOR (bits - 1 DOWNTO 0);
	       ram_out : OUT STD_LOGIC_VECTOR (bits -1 DOWNTO 0)
	       );
End COMPONENT;

COMPONENT dataValidation   
  PORT ( 	reset    : IN  STD_Logic;
          clock		  : IN  STD_LOGIC; 
          wr_ena	  : IN  STD_LOGIC; -- write enable
          enable   : IN  STD_LOGIC;
          ctrl_out      : IN  STD_LOGIC_VECTOR (bits -1 DOWNTO 0);
	       	ram_out       : IN  STD_LOGIC_VECTOR (bits -1 DOWNTO 0);
	        data_Valid		  : OUT  STD_LOGIC;
	        validOffset : OUT Integer
	       );
End COMPONENT;
-------------------VARIABLE DECLARATION---------------------------------------- 
Signal clock         : STD_LOGIC;
Signal reset         : STD_LOGIC;
Signal load          : STD_LOGIC;
Signal sin           : STD_LOGIC;
Signal	wr_enable     : STD_LOGIC;
Signal	enable        : STD_LOGIC;
Signal data_Valid		  : STD_LOGIC;
Signal address       : STD_LOGIC_VECTOR(5 DOWNTO 0);--2^6 bit address 64 possible locations
Signal D             : STD_LOGIC_VECTOR(bits-1 Downto 0);
Signal rec_out       : STD_LOGIC_VECTOR(bits-1 DOWNTO 0);
Signal ctrl_out      : STD_LOGIC_VECTOR(bits-1 DOWNTO 0);
Signal ram_out       : STD_LOGIC_VECTOR(bits-1 DOWNTO 0);
Signal validOffset   : Integer;


-------------------BEGINING OF INSTRUCTIONS----------------------------------- 
BEGIN
-------------------VARIABLE DECLARATIONS-------------------------------------- 
Gen: generator
PORT Map (sin=>sin, clock		=> clock, reset	=> reset, load => load); 
 
 recMod:receiver
PORT MAP( reset => reset, clock	=> clock, enable=>enable,rec_in => sin, rec_out => rec_out);

ctrlMod:ramController
PORT MAP( reset=> reset,clock => clock,enable=>enable,ctrl_in	=> rec_out,addr=> address,wr_ena=>wr_enable,ctrl_out => ctrl_out);

SRAM:ram
PORT MAP( wr_ena=>wr_enable,clock=>clock,reset=>reset,addr=>address,ram_in=>ctrl_out,ram_out=>ram_out); 

valid:dataValidation   
PORT MAP(reset=>reset,clock=>clock,wr_ena=>wr_enable,enable=>enable,ctrl_out=>ctrl_out,
                ram_out=>ram_out,data_Valid=>data_Valid,validOffset=>validOffset); 
  
  
-------------------ADDITIONAL INSTRUCTIONS-------------------------------------- 
--look into tb_ram_demo so you can add a check 


END tb_ramIntro;

