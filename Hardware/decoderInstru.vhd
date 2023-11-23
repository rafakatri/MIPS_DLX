library ieee;
use ieee.std_logic_1164.all;

entity decoderInstru is
  port ( opcode : in std_logic_vector(5 downto 0);
			funct : in std_logic_vector(5 downto 0);
         saida : out std_logic_vector(10 downto 0)
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

saida <= "00011010100" when opcode = LW else
         "00001010010" when opcode = SW else
         "00001011000" when opcode = BEQ else
			"01000000000" when opcode = JMP else
			"10000000001" when (funct = "001000" and opcode = OP_FUNCT)	else
			"00110000001" when opcode = OP_FUNCT else
			"00011000000" when opcode = ADDI else
			"00010110000" when opcode = LUI else
         "00000000000";  -- NOP para os opcodes Indefinidos
			
end architecture;