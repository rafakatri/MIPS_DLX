library ieee;
use ieee.std_logic_1164.all;

entity decoderInstru is
  port ( opcode : in std_logic_vector(5 downto 0);
         saida : out std_logic_vector(9 downto 0)
  );
end entity;

architecture comportamento of decoderInstru is

  constant LW  : std_logic_vector(5 downto 0) := "100011";
  constant SW  : std_logic_vector(5 downto 0) := "101011";
  constant BEQ : std_logic_vector(5 downto 0) := "000100";
  constant JMP : std_logic_vector(5 downto 0) := "000010";
  constant ADDI : std_logic_vector(5 downto 0) := "001000";
  constant LUI : std_logic_vector(5 downto 0) := "001111";
  constant OP_FUNCT : std_logic_vector(5 downto 0) := "000000"; 

  begin
saida <= "0011010100" when opcode = LW else
         "0001010010" when opcode = SW else
         "0001011000" when opcode = BEQ else
			"1000000000" when opcode = JMP else
			"0110000001" when opcode = OP_FUNCT else
			"0011000000" when opcode = ADDI else
			"0010110000" when opcode = LUI else
         "0000000000";  -- NOP para os opcodes Indefinidos
end architecture;