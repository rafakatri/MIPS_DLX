library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity Atividade is
  port   ( 
    KEY: in std_logic_vector(3 downto 0);
	 FPGA_RESET_N : in std_logic;
    CLOCK_50 : in std_logic;
	 LEDR : out std_logic_vector(9 downto 0);
	 ula_output : out std_logic_vector(7 downto 0);
	 ram_in : out std_logic_vector(7 downto 0);
	 ram_output : out std_logic_vector(7 downto 0);
	 pc_signal : out std_logic_vector(7 downto 0)
  );
end entity;


architecture mips of Atividade is


signal CLK, RESET : std_logic;

signal proxPC, PC_OUT, pcMaisQuatro, pcMaisImediato, pcImediatoJMP, pcSemJMP : std_logic_vector(31 downto 0);


signal instruction : std_logic_vector(31 downto 0);

alias opcode : std_logic_vector(5 downto 0) is instruction(31 downto 26);

alias funct : std_logic_vector(5 downto 0) is instruction(5 downto 0);

alias Rs : std_logic_vector(4 downto 0) is instruction(25 downto 21);

alias Rt : std_logic_vector(4 downto 0) is instruction(20 downto 16);

alias Rd : std_logic_vector(4 downto 0) is instruction(15 downto 11);

alias imediato : std_logic_vector(15 downto 0) is instruction(15 downto 0);

alias imediato_jmp : std_logic_vector(25 downto 0) is instruction(25 downto 0);


signal Rs_OUT, Rt_OUT, ULA_OUT : std_logic_vector(31 downto 0);

signal RAM_OUT, imediato_estendido, imediato_shift : std_logic_vector(31 downto 0);

signal HAB_RAM, eh_igual, selPC : std_logic;


signal MUX_RtRd_OUT : std_logic_vector(4 downto 0);

signal MUX_RtImed_OUT, MUX_UlaMem_OUT : std_logic_vector(31 downto 0);


signal controle : std_logic_vector(8 downto 0);

alias selJMP : std_logic is controle(8);

alias selRtRd : std_logic is controle(7);

alias HAB_REG : std_logic is controle(6);

alias selRtImed : std_logic is controle(5);

alias selUlaMem : std_logic is controle(4);

alias beq : std_logic is controle(3);

alias rd : std_logic is controle(2);

alias wr : std_logic is controle(1);

alias tipo_r : std_logic is controle(0);


signal op_ctrl, funct_ctrl, ULActrl : std_logic_vector(3 downto 0);  


begin

detectorSub0: work.edgeDetector(bordaSubida) port map (clk => CLOCK_50, entrada => (not KEY(0)), saida => CLK);

detectorSub1: work.edgeDetector(bordaSubida) port map (clk => CLOCK_50, entrada => (not FPGA_RESET_N), saida => RESET);



pc : entity work.registradorGenerico   generic map (larguraDados => 32)
          port map (DIN => proxPC, DOUT => PC_OUT, ENABLE => '1', CLK => CLK, RST => RESET);


			 
aumentapc :  entity work.somaConstante  generic map (larguraDados => 32, constante => 4)
        port map( entrada => PC_OUT, saida => pcMaisQuatro);
		  
		  
shift : entity work.shift2Left port map(entrada => imediato_estendido, saida => imediato_shift);


soma : entity work.somadorGenerico port map(entradaA => pcMaisQuatro, entradaB => imediato_shift, saida => pcMaisImediato);


Mux_PC :  entity work.muxGenerico2x1 generic map (larguraDados => 32)
        port map( entradaA_MUX => pcMaisQuatro,
                 entradaB_MUX =>  pcMaisImediato,
                 seletor_MUX => selPC,
                 saida_MUX => pcSemJMP);
					  
					  
Mux_JMP :  entity work.muxGenerico2x1 generic map (larguraDados => 32)
        port map( entradaA_MUX => pcSemJMP,
                 entradaB_MUX =>  pcImediatoJMP,
                 seletor_MUX => selJMP,
                 saida_MUX => proxPC);
					  				  
					  
					  
Mux_RtRd :  entity work.muxGenerico2x1 generic map (larguraDados => 5)
        port map( entradaA_MUX => Rt,
                 entradaB_MUX =>  Rd,
                 seletor_MUX => selRtRd,
                 saida_MUX => MUX_RtRd_OUT);
					  
					  
					  
Mux_RtImed :  entity work.muxGenerico2x1 generic map (larguraDados => 32)
        port map( entradaA_MUX => Rt_OUT,
                 entradaB_MUX =>  imediato_estendido,
                 seletor_MUX => selRtImed,
                 saida_MUX => MUX_RtImed_OUT);
					  
					  
Mux_UlaMem :  entity work.muxGenerico2x1 generic map (larguraDados => 32)
        port map( entradaA_MUX => ULA_OUT,
                 entradaB_MUX =>  RAM_OUT,
                 seletor_MUX => selUlaMem,
                 saida_MUX => MUX_UlaMem_OUT);
  
  
rom : entity work.ROMMIPS port map(Endereco => PC_OUT, Dado => instruction);


decoder : entity work.decoderInstru port map(opcode => opcode, saida => controle);


decoder_op : entity work.decoderUlaOp port map(opcode => opcode, saida => op_ctrl);


decoder_funct : entity work.decoderUlaFunct port map(funct => funct, saida => funct_ctrl);


Mux_ula :  entity work.muxGenerico2x1 generic map (larguraDados => 4)
        port map( entradaA_MUX => op_ctrl,
                 entradaB_MUX =>  funct_ctrl,
                 seletor_MUX => tipo_r,
                 saida_MUX => ULActrl); 


banco : entity work.bancoReg 
          port map ( clk => CLK,
              enderecoA => Rs,
              enderecoB => Rt,
              enderecoC => MUX_RtRd_OUT,
              dadoEscritaC => MUX_UlaMem_OUT,
              escreveC => HAB_REG,
              saidaA => Rs_OUT,
              saidaB  => Rt_OUT);


ram : entity work.RAMMIPS
          port map (Endereco => ULA_OUT, we => wr, re => rd, habilita  => HAB_RAM, 
			 dado_in => Rt_OUT, dado_out => RAM_OUT, clk => CLK);				  

			 
estendeSinal : entity work.estendeSinalGenerico
          port map (estendeSinal_IN => imediato, estendeSinal_OUT => imediato_estendido);	
			

ULA : entity work.ula
          port map (a => Rs_OUT, b => MUX_RtImed_OUT, resultado => ULA_OUT, ULActrl => ULActrl, zero => eh_igual); 

			 
HAB_RAM <= '1' when ((rd = '1') or (wr = '1')) else
			  '0';
			  
selPC <= '1' when ((eh_igual = '1') and (beq = '1')) else
			'0';
			
pcImediatoJMP(31 downto 28) <= pcMaisQuatro(31 downto 28);
pcImediatoJMP(27 downto 2) <= imediato_jmp;
pcImediatoJMP(1 downto 0) <= "00";
			  
			  
LEDR <= PC_OUT(9 downto 0);


ula_output <= ULA_OUT(7 downto 0);
ram_in <= Rt_OUT(7 downto 0);
ram_output <= RAM_OUT(7 downto 0);	  
pc_signal <= PC_OUT(7 downto 0);
  
end architecture;