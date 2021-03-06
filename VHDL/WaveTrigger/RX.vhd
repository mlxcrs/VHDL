LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

Entity RX is
port(
	d: out STD_LOGIC_VECTOR(0 to 7); --10 bits de saida dos leds
	i: in STD_LOGIC; --bit de entrada do RX
	clk: in STD_LOGIC; --bit de entrada do pulso de clock
	clk2: buffer STD_LOGIC
);
end entity;
Architecture N of RX is
	signal count2: integer range 0 to 1000;
	signal count3: integer range 0 to 1000000; --Variavel para controle dos estados do processo de recebimento
	signal flag2: integer range 0 to 1;
	signal clock2: bit; --Bit que terá seu estado alternado para servir de clock do RX
	begin
	process(clk) --Processo de controle da velocidade do clock do TX e do clock do RX
	begin
		if clk'event and clk = '0' then
			if count2 = 625 then --Contagem que fará com que clock2 seja 1000x mais lento que clk
				clock2 <= not clock2;
				count2 <=0;
			else
				count2 <= count2 + 1;
			end if;
		end if;
	end process;
	process(clock2)							--Recebe
	begin
		if clock2'event and clock2 = '0' then
			if i = '1' then					--O processo inicia após a entrada estar 
				flag2 <= 1;				--conectada (recebendo nivel lógico alto)
			end if;
			if i = '0' and count3 = 0 and flag2 = 1 then	--Se receber bit ‘1’ (start bit) em ‘i’, 
				count3 <= 1;				--estiver no estado inicial (count3 = 0)
			elsif count3 = 6 then
				d(0) <= i;clk2 <= not clk2;				--Se for estado 6, led0 recebe primeiro bit
				count3 <= count3 + 1;
			elsif count3 = 10 then
				d(1) <= i;clk2 <= not clk2;		--Se for estado 10, led1 recebe segundo bit
				count3 <= count3 + 1;			
			elsif count3 = 14 then
				d(2) <= i;clk2 <= not clk2;				--Se for estado 14, led2 recebe terceiro bit
				count3 <= count3 + 1;
			elsif count3 = 18 then
				d(3) <= i;clk2 <= not clk2;				--Se for estado 18, led3 recebe quarto bit
				count3 <= count3 + 1;
			elsif count3 = 22 then
				d(4) <= i;clk2 <= not clk2;				--Se for estado 22, led4 recebe quinto bit
				count3 <= count3 + 1;
			elsif count3 = 26 then
				d(5) <= i;clk2 <= not clk2;				--Se for estado 26, led5 recebe sexto bit
				count3 <= count3 + 1;
			elsif count3 = 30 then
				d(6) <= i;clk2 <= not clk2;				--Se for estado 30, led6 recebe setimo bit
				count3 <= count3 + 1;
			elsif count3 = 34 then
				d(7) <= i;clk2 <= not clk2;				--Se for estado 34, led7 recebe oitavo bit
				count3 <= count3 + 1;
			elsif count3 = 40 then
				count3 <= 0;				--Se for estado 48, count3 volta ao estado 0
			elsif count3 >= 1 then
				count3 <= count3 + 1;			--Se não entrar em nenhuma das alternativas
			end if;						--count3 será incrementado.
		end if;							--As leituras acontecem de 4 em 4 clocks
	end process;
end architecture;
