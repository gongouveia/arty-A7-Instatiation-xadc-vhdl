----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Gonçalo Gouevia
--
-- Create Date: 2022 
-- Design Name: 
-- Module Name: AdcModule - Behavioral
-- Project Name: 
-- Target Devices: Arty A7 100t
-- Tool Versions: 
-- Description: 

--XADC in Artix 7, leds up accordingly to the diferencial voltage in pins A11-A10
--A11-A10 diferential voltage must be 0-1V


----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
use ieee.numeric_std.all;      -- going to use to convert std vector to unsigned


entity myADC is
    Port ( led : out STD_LOGIC_VECTOR (3 downto 0);         -- led for see adc value
           ja : in STD_LOGIC_VECTOR (1 downto 0);           -- adc pins                        vai se conectar 
           clk : in STD_LOGIC);                              -- system clock 125 mhz
end myADc;

architecture Behavioral of myADC is

component xadc_wiz_0 is
   port
   (
    daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
    den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
    di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
    dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
    do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
    dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
    vauxp14         : in  STD_LOGIC;                         --A10
    vauxn14         : in  STD_LOGIC;                         --A11
    busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
    channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
    eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
    eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
    alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
    vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
    vn_in           : in  STD_LOGIC
);
end component;

signal ADCValidData : std_logic_vector(7 downto 0);                -- big endian
signal ADCNonValidData : std_logic_vector(7 downto 0);
signal EnableInt : std_logic := '1';                               --ver na datasheet
signal output : integer;

begin

adcImp : xadc_wiz_0
port map
(
    daddr_in        => "0011110",           -- 14th drp port address is 0x1E
    den_in          => EnableInt,           -- set enable drp port
    di_in           => (others => '0'),     -- set input data as 0 
    dwe_in          => '0',                 -- disable write to drp
    do_out(15 downto 8)    => ADCValidData, -- because we use unipolar xadc
    do_out(7 downto 0)    => ADCNonValidData,  -- non valid data with dummy vector
    drdy_out        => open,                    
    dclk_in         => clk,           -- 125 Mhz system clock wires to drp
    vauxp14         => ja(0),               -- xadc positive pin                                      
    vauxn14         => ja(1),               -- xadc negative pin
    busy_out        => open,                   
    channel_out    => open,    
    eoc_out         => EnableInt,          -- enable int                   
    eos_out         => open,                      
    alarm_out       => open,                         
    vp_in           => '0',                        
    vn_in           => '0'
);

-- Convert the bit string to numeric value integer unsigned
output <= to_integer(unsigned(ADCValidData));


---main process is set led depends on adc value



ledProcess : process(output)
begin

if(output <= 5) then

led <= "0000";

elsif(output > 5 and  output < 63) then   
 
led <= "0001";

elsif(output >= 63 and  output < 127) then 

led <= "0011";

elsif(output >= 127 and  output <= 191) then  

led <= "0111";

elsif(output >= 191 and  output <= 255) then 

led <= "1111";

end if;

end process;


end Behavioral;





