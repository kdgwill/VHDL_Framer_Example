LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;

ENTITY tb_FramerTop IS
--port (
--);
END;

ARCHITECTURE structure of tb_FramerTop IS
Signal bits: integer:= 32;
Signal	clk	   : STD_LOGIC;
Signal	resetb	: STD_LOGIC;
Signal sin	   : STD_LOGIC;
Signal	sout	  : STD_ULOGIC;
Signal clk_div_8 : std_ulogic;
Signal decode_F628_out : std_ulogic;
Signal ram_wren : STD_LOGIC ;
Signal ram_address : STD_LOGIC_VECTOR (4 DOWNTO 0);
Signal ram_data : STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
Signal ram_q : STD_LOGIC_VECTOR (bits-1 DOWNTO 0);

Signal add_data0x		: STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
Signal add_data1x		: STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
Signal add_result		: STD_LOGIC_VECTOR (bits-1 DOWNTO 0);

Signal divide_denom		: STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
Signal divide_numer		: STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
Signal divide_quotient		: STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
Signal divide_remain		: STD_LOGIC_VECTOR (bits-1 DOWNTO 0);

COMPONENT tb_Framer_generator
   PORT (
          clk		  : OUT STD_LOGIC;
	        ser_in 	: OUT STD_LOGIC;
	       resetb	: OUT STD_LOGIC
	     );  
END COMPONENT;

COMPONENT Framer
	PORT (
		   clk		  : in  std_ulogic;
	     sin		  : in  std_ulogic;
	     resetb	: in  std_ulogic;

       SOUT            : out std_ulogic;
       clk_div_8       : out std_ulogic;
	     decode_F628_out : out std_ulogic
		);
END COMPONENT;



Component Average 
generic (
  	bits: integer
);
 PORT (clk             : in   std_logic;
       resetb          : in   std_logic;
       data_sig_in     : in    std_ulogic;
       clk_div_8       : in std_ulogic;
	     decode_F628_out : in std_ulogic;
	     ram_wren        : out STD_LOGIC ;
       ram_address		   : out STD_LOGIC_VECTOR (4 DOWNTO 0);
       ram_data        : out STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
       ram_q           : in STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
       add_value0x     : Out STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
       add_value1x     : Out STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
		   add_sum	       	: In STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
		   div_denom	     	: Out STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
		   div_numer		     : Out STD_LOGIC_VECTOR (bits-1 DOWNTO 0)
	     );           
end Component; 

Component Ram IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (bits-1 DOWNTO 0)
	);
END Component;

Component Add IS
	PORT
	(
		data0x		: IN STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
		data1x		: IN STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (bits-1 DOWNTO 0)
	);
END Component;

Component Divider IS
	PORT
	(
		denom		: IN STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
		numer		: IN STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
		quotient		: OUT STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
		remain		: OUT STD_LOGIC_VECTOR (bits-1 DOWNTO 0)
	);
END Component;
------------------PORT MAP
BEGIN
  Gen: tb_Framer_generator
PORT Map (
		   clk	   => clk,
		    ser_in 	=> sin,
		   resetb	=> resetb
		  );
		  
UUT: Framer
PORT Map (
		     clk	   => clk,
		     sin	   => sin,
		     resetb	=> resetb,
		     sout	   => sout,
		     clk_div_8 => clk_div_8,
	       decode_F628_out => decode_F628_out
		  );

Avg: Average
generic map (
  	bits => bits
)
Port Map(
       clk  => clk,
       resetb => resetb,
       data_sig_in    => sout,
       clk_div_8 => clk_div_8,
	     decode_F628_out => decode_F628_out,
	     ram_wren => ram_wren,
       ram_address => ram_address,
       ram_data => ram_data,
       ram_q => ram_q,
       add_value0x => add_data0x,
       add_value1x => add_data1x,
		   add_sum	  => add_result,
		   div_denom	  => divide_denom,
		   div_numer		 => divide_numer
); 

RAM1: RAM 
PORT map
	(
		address => ram_address,
		clock	=> clk,
		data => ram_data,
		wren => ram_wren,
		q => ram_q
	);

Add1: Add 
	PORT map
	(
		data0x => add_data0x,
		data1x	=> add_data1x,
		result	=> add_result
	);

Div1: Divider 
	PORT map
	(
		denom		=>divide_denom,
		numer		=> divide_numer,
		quotient		=> divide_quotient,
		remain		=> divide_remain
	);


END ;