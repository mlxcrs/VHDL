LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
ENTITY part1 IS
   PORT ( CLOCK_50, AUD_DACLRCK   				: IN    	STD_LOGIC;
          AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT  : IN    	STD_LOGIC;
			 key0, key1, key2, key3					: IN    	BIT; 
			 LED0, LED1, LED2, LED3					: OUT 	BIT;
          KEY                                : IN    	STD_LOGIC_VECTOR(3 DOWNTO 0);
          I2C_SDAT                      		: INOUT 	STD_LOGIC;
          I2C_SCLK, AUD_DACDAT, AUD_XCK 		: OUT   	STD_LOGIC;
			 LED_RED										: OUT		STD_LOGIC_VECTOR(0 TO 7);
--			 SW											: IN 		STD_LOGIC_VECTOR(0 TO 7);
--			 SW9											: IN 		BIT;
			 DEBUG_RX									: OUT 	STD_LOGIC;
			 BLUE_IN										: IN 		STD_LOGIC
			 );
END part1;

ARCHITECTURE Behavior OF part1 IS
   COMPONENT DISTORT
		PORT(	clock_50M	: IN  STD_LOGIC;
				buffer_in	: IN  STD_LOGIC_VECTOR(23 DOWNTO 0);
				buffer_out	: OUT STD_LOGIC_VECTOR(23 DOWNTO 0));
   END COMPONENT;
	COMPONENT RX
		PORT(	d: out STD_LOGIC_VECTOR(0 to 7); --10 bits de saida dos leds
				i: in STD_LOGIC; --bit de entrada do RX
				clk: in STD_LOGIC; --bit de entrada do pulso de clock
				clk2: buffer STD_LOGIC);
   END COMPONENT;
   COMPONENT clock_generator
      PORT( CLOCK_27 : IN STD_LOGIC;
            reset    : IN STD_LOGIC;
            AUD_XCK  : OUT STD_LOGIC);
   END COMPONENT;
   COMPONENT audio_and_video_config
      PORT( CLOCK_50, reset : IN    STD_LOGIC;
            I2C_SDAT        : INOUT STD_LOGIC;
            I2C_SCLK        : OUT   STD_LOGIC);
   END COMPONENT;   
   COMPONENT audio_codec
      PORT( CLOCK_50, reset, read_s, write_s               : IN  STD_LOGIC;
            writedata_left, writedata_right                : IN  STD_LOGIC_VECTOR(23 DOWNTO 0);
            AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK : IN  STD_LOGIC;
            read_ready, write_ready                        : OUT STD_LOGIC;
            readdata_left, readdata_right                  : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
            AUD_DACDAT                                     : OUT STD_LOGIC);
   END COMPONENT;

   SIGNAL CLOCK2_50, read_ready, write_ready, read_s, write_s : STD_LOGIC;
	SIGNAL clock_00000010									: STD_LOGIC;
   SIGNAL readdata_left, readdata_right            : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL readdata_buffer,readdata_buffer_2			: STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL buffer_T1, buffer_T2							: STD_LOGIC_VECTOR(23 DOWNTO 0);
   SIGNAL writedata_left, writedata_right          : STD_LOGIC_VECTOR(23 DOWNTO 0);   
   SIGNAL reset                                    : STD_LOGIC;
	SIGNAL flag1												: STD_LOGIC;
	SIGNAL sum 													: integer range 0 to 1500000;
	SIGNAL corte												: integer range 0 to 15;
	SIGNAL BLUE_VALUE_RECEIVE								: STD_LOGIC_VECTOR(0 to 7);
	SIGNAL BLUE_COMUNIC										: BIT;
	SIGNAL read_from_Distort, write_on_Distort		: STD_LOGIC_VECTOR(23 DOWNTO 0); 
BEGIN
	my_clock_gen: clock_generator PORT MAP (CLOCK2_50, reset, AUD_XCK);
   cfg: audio_and_video_config PORT MAP (CLOCK_50, reset, I2C_SDAT, I2C_SCLK);
   codec: audio_codec PORT MAP (CLOCK_50, reset, read_s, write_s, writedata_left, 
	                             writedata_right, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK,
										  AUD_DACLRCK, read_ready, write_ready, readdata_left, 
										  readdata_right, AUD_DACDAT);
	rcv:	RX PORT MAP (BLUE_VALUE_RECEIVE, BLUE_IN, CLOCK_50, DEBUG_RX);
	LED_RED <= BLUE_VALUE_RECEIVE;
	
	
	
	CLOCK2_50<= CLOCK_50;
	read_s 	<= read_ready;
   write_s 	<= write_ready AND read_ready;
	reset <= NOT(KEY(0));

	LED0 <= key0;
	LED1 <= key1;
	LED2 <= key2;
	LED3 <= key3;
	

	PROCESS(clock_00000010)
	BEGIN
		IF clock_00000010'EVENT and clock_00000010='0' THEN
			IF corte = 6 THEN
				flag1 <= '1';
			ELSIF corte = 1 THEN
				flag1 <= '0';
			END IF;
			IF flag1 = '0' THEN
				corte <= corte + 1;
			ELSE
				corte <= corte - 1;
			END IF;
		END IF;
	END PROCESS;
	Process(CLOCK_50)
	begin
		if CLOCK_50'event and CLOCK_50='0' then
			if sum = 250000 then
				clock_00000010 <= not clock_00000010;
				sum <= 0;
			else
				sum <= sum + 1;
			end if;
			
			if 	BLUE_VALUE_RECEIVE = "10001100" then
				writedata_left <= writedata_right;
				writedata_right <= readdata_right;
				
			elsif BLUE_VALUE_RECEIVE = "11001100" then
				if 	(readdata_right >= "000010011001100110011000" and readdata_right <= "011111111111111111111111") then
					readdata_buffer <= "000010011001100110011000";
				elsif (readdata_right >= "100000000000000000000000" and readdata_right <= "111101100110011001100101") then
					readdata_buffer <= "111101100110011001100101";
				else
					readdata_buffer <= readdata_right;
				end if;
				writedata_right <= std_logic_vector(to_unsigned(to_integer(signed(readdata_buffer)), writedata_right'length));
				writedata_left <= writedata_right;
				
			elsif BLUE_VALUE_RECEIVE = "01001100" then
				buffer_T2 <= readdata_right;
				writedata_right <= std_logic_vector(to_unsigned(to_integer(signed(buffer_T2))*(corte+1)/4, writedata_right'length));
				writedata_left <= writedata_right;

			else
				writedata_left <= writedata_right;
				writedata_right <= readdata_right;
				
			end if;
		end if;	
	end process;
	
END Behavior;