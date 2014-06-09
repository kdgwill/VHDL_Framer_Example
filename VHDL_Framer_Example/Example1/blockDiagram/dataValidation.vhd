---------------------------------------------------------------------------------
--DataValidation------------------------------------------------------------
--By Kyle Williams, 04/07/2011--------------------------------------------------
--PROJECT DESCRIPTION------------------------------------------------------------
--5--check that data read from ram matches what was written in the ram-----------
----------------Define Libraries to be used-------------------------------------- 
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
-----------------ENTITY FOR DATA VALIDATION------------------------------------------ 
ENTITY dataValidation IS
  GENERIC (    bits   : INTEGER := 8;-- # of bits per word
                words  : INTEGER := 32  );	 -- # of words in the memory);	    
  PORT ( 	
          reset       : IN  STD_Logic;
          clock		     : IN  STD_LOGIC; 
          enable      : IN  STD_LOGIC;
          wr_ena	  : IN  STD_LOGIC; -- write enable
          ctrl_out    : IN  STD_LOGIC_VECTOR (bits -1 DOWNTO 0);
	       	ram_out     : IN  STD_LOGIC_VECTOR (bits -1 DOWNTO 0);
	        data_Valid		: OUT  STD_LOGIC;
	        validOffset : OUT Integer
	       );
END dataValidation;
-----------------BEHAVIOR OF DATA VALIDATION----------------------------------------- 
ARCHITECTURE dataValidation OF dataValidation IS
  TYPE vector_array is ARRAY (0 to words -1) of STD_LOGIC_VECTOR (bits-1 DOWNTO 0);--1Dx1D
  Signal mem   : vector_array;--matrix
  Signal S_data_Valid : STD_Logic;
  

 -------------------PROCEDUREE------------------------------  
  BEGIN    
  PROCESS(clock,reset,wr_ena)    
    Variable temp_addr: Integer; 
    Variable ram_in :  STD_LOGIC_VECTOR (bits -1 DOWNTO 0); 
    Variable S_validOffset:Integer; 
    BEGIN        
    IF(reset='0')THEN
      temp_addr:=0;
      ram_in:="00000000";
      S_validOffset := 0;
    ELSIF(rising_edge(clock) AND wr_ena = '0' AND enable = '1' AND ctrl_out /= ram_in)THEN    
      ram_in:=ctrl_out;        
      mem(temp_addr) <= ram_in;
              
      IF(temp_addr <= words-2)THEN--for some reason compare with 32 instead of 31 look into this
        temp_addr := temp_addr+1;
      ELSE
        temp_addr := 0;
      END IF;  
      
      IF(S_data_valid = '0')THEN
         S_validOffset:=S_validOffset+1; 
      ELSE
        S_validOffset:=0;
      END IF;                           
    END IF; 
    
    validOffset <= S_validOffset; 
  End PROCESS;
  
  PROCESS(clock,reset,wr_ena)
    Variable ram_out2 :  STD_LOGIC_VECTOR (bits -1 DOWNTO 0); 
    Variable temp_addr2 : Integer;  
    BEGIN        
    IF(reset='0')THEN
      temp_addr2:=0;
      ram_out2:=ram_out;
      S_data_Valid <= '0';
    --single problem need to detect when  ram_out is not null
    ELSIF(rising_edge(clock) AND wr_ena = '0' AND enable = '1' AND ram_out /= ram_out2)THEN 
      
      IF(mem(temp_addr2) = ram_out)THEN
        S_data_valid <= '1';  
        --Only Increment when find correct Value
        IF(temp_addr2 <= words-2)THEN
          temp_addr2 := temp_addr2+1;
        ELSE
          temp_addr2 := 0;
        END IF;          
      ELSE
        S_data_valid <= '0'; 
      END IF;     

      ram_out2:=ram_out;
    
      
    END IF;
    data_valid <= S_data_valid;   
    --ASSERT (ram_out = ctrl_out)
    --  REPORT   "DATA READ INTO RAM DOES'T MATCH WHAT WAS WRITTEN INTO RAM"
     -- SEVERITY warning;
  END PROCESS;

    
END dataValidation;
