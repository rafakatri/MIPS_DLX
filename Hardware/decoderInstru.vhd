library ieee;
use ieee.std_logic_1164.all;

entity decoderInstru is
  port ( opcode : in std_logic_vector(5 downto 0);
			funct : in std_logic_vector(5 downto 0);
         saida : out std_logic_vector(11 downto 0)
  );
end entity;

architecture comportamento of decoderInstru is

  constant LW  : std_logic_vector(5 downto 0) := "100011";
  constant SW  : std_logic_vector(5 downto 0) := "101011";
  constant BEQ : std_logic_vector(5 downto 0) := "000100";
  constant JMP : std_logic_vector(5 downto 0) := "000010";
  constant OP_FUNCT : std_logic_vector(5 downto 0) := "000000"; 

  begin
saida <= "001100011010" when opcode = LW else
         "000100011001" when opcode = SW else
         "000100001100" when opcode = BEQ else
			"100000000000" when opcode = JMP else
			"011000010000" when ((opcode = OP_FUNCT) and (funct = "100000")) else
			"011000000000" when ((opcode = OP_FUNCT) and (funct = "100010")) else
         "000000000000";  -- NOP para os opcodes Indefinidos
end architecture;