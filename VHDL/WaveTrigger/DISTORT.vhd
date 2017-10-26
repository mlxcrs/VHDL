LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

ENTITY DISTORT IS
PORT(
	clock_50M	: IN  STD_LOGIC;
	buffer_in	: IN  STD_LOGIC_VECTOR(23 DOWNTO 0);
	buffer_out	: OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE N OF DISTORT IS
	SIGNAL clock_10	: STD_LOGIC;
	SIGNAL readdata_buffer: STD_LOGIC_VECTOR(23 DOWNTO 0);
	BEGIN
	PROCESS(clock_50M)
	BEGIN
		IF clock_50M'EVENT AND clock_50M='0' THEN
			IF 	(buffer_in >= "000010011001100110011000" AND buffer_in <= "011111111111111111111111") THEN
				readdata_buffer <= "000010011001100110011000";
			ELSIF (buffer_in >= "100000000000000000000000" AND buffer_in <= "111101100110011001100101") THEN
				readdata_buffer <= "111101100110011001100101";
			ELSE
				readdata_buffer <= buffer_in;
			END IF;
			buffer_out <= std_logic_vector(to_unsigned(to_integer(signed(readdata_buffer)), buffer_out'length));
		END IF;
	END PROCESS;

END ARCHITECTURE;