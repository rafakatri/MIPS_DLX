library ieee;
use ieee.std_logic_1164.all;

entity decoderInstru is
  port ( opcode : in std_logic_vector(5 downto 0);
			funct : in std_logic_vector(5 downto 0);
         saida : out std_logic_vector(13 downto 0)
  );
end entity;

architecture comportamento of decoderInstru is

  constant LW  : std_logic_vector(5 downto 0) := "100011";
  constant SW  : std_logic_vector(5 downto 0) := "101011";
  constant BEQ : std_logic_vector(5 downto 0) := "000100";
  constant BNE : std_logic_vector(5 downto 0) := "000101";
  constant JMP : std_logic_vector(5 downto 0) := "000010";
  constant JAL : std_logic_vector(5 downto 0) := "000011";
  constant ADDI : std_logic_vector(5 downto 0) := "001000";
  constant LUI : std_logic_vector(5 downto 0) := "001111";
  constant ORI : std_logic_vector(5 downto 0) := "001101";
  constant ANDI : std_logic_vector(5 downto 0) := "001100";
  constant SLTI : std_logic_vector(5 downto 0) := "001010";
  constant OP_FUNCT : std_logic_vector(5 downto 0) := "000000"; 

begin

saida <= "00001101001000" when opcode = LW else
         "00000101000100" when opcode = SW else
         "00000101100000" when opcode = BEQ else
			"00000101010000" when opcode = BNE else
			"01000000000000" when opcode = JMP else
			"01101010000000" when opcode = JAL else
			"10000000000010" when (funct = "001000" and opcode = OP_FUNCT)	else
			"00011000000010" when opcode = OP_FUNCT else
			"00001100000000" when opcode = ADDI else
			"00001011000000" when opcode = LUI else
			"00001100000001" when opcode = ORI else
			"00001100000001" when opcode = ANDI else
			"00001100000000" when opcode = SLTI else
         "00000000000000";  -- NOP para os opcodes Indefinidos
			
end architecture;