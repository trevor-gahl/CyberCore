----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/08/2019 01:37:10 PM
-- Design Name: 
-- Module Name: uart - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart is
  Port (
  clk      : in std_logic;
  uart_clk : in std_logic;
  Rx       : in std_logic;
  Tx       : out std_logic;
  ready_flag : out std_logic;
  received_byte : out std_logic_vector(7 downto 0);
  address_out : out std_logic_vector(2 downto 0);
  output_1 : out std_logic_vector(7 downto 0);
  output_2 : out std_logic_vector(7 downto 0);
  output_3 : out std_logic_vector(7 downto 0);
  output_4 : out std_logic_vector(7 downto 0);
  output_5 : out std_logic_vector(7 downto 0);
  output_6 : out std_logic_vector(7 downto 0);
  output_7 : out std_logic_vector(7 downto 0);
  output_8 : out std_logic_vector(7 downto 0)
   );
end uart;

architecture Behavioral of uart is
  
    component uart_tx is
    generic (
      clks_per_bit : integer := 868     -- Needs to be set correctly
      );
    port (
      clk       : in  std_logic;
      tx_dv     : in  std_logic;
      tx_byte   : in  std_logic_vector(7 downto 0);
      tx_active : out std_logic;
      tx_serial : out std_logic;
      tx_done   : out std_logic
      );
  end component uart_tx;

  component uart_rx is
    generic (
      clks_per_bit : integer := 868     -- Needs to be set correctly
      );
    port (
      clk       : in  std_logic;
      rx_serial : in  std_logic;
      rx_dv     : out std_logic;
      rx_byte   : out std_logic_vector(7 downto 0)
      );
  end component uart_rx;
  
  component uart_buffer is
  Port (address : in std_logic_vector(2 downto 0);
        write   : in std_logic;
        data_in : in std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0)
  );
end component;

--component ila_2 IS
--PORT (
--clk : IN STD_LOGIC;
--probe0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
--    probe1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--    probe2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--    probe3 : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
--);
--END component;
  
  type state_type is(state_1, state_2, state_3, state_4, state_5, state_6, state_7);
  signal current_state, next_state : state_type;
  
  
  signal address : std_logic_vector(2 downto 0):="000";
  signal buffer_read : std_logic_vector(7 downto 0);
  signal buffer_write : std_logic_vector(7 downto 0);
  signal write : std_logic;
  
  
  -- UART
  signal rx_dv_sig                                              : std_logic;
  signal rx_byte_val                                            : std_logic_vector(7 downto 0);
  signal tx_dv_sig                                              : std_logic;
  signal tx_byte_val                                            : std_logic_vector(7 downto 0);
  signal tx_done_sig                                            : std_logic;
  signal ready          : std_logic;
  signal buff1, buff2, buff3, buff4, buff5, buff6, buff7, buff8 : std_logic_vector(7 downto 0);
  
  -- Debugging
  signal probe1 : std_logic_vector(7 downto 0);
begin
  -- Instantiate UART transmitter
  uart_transmit : uart_tx
    generic map (
      clks_per_bit => 87
      )
    port map (
      clk       => uart_clk,
      tx_dv     => tx_dv_sig,
      tx_byte   => tx_byte_val,
      tx_active => open,
      tx_serial => Tx,
      tx_done   => tx_done_sig
      );

  -- Instantiate UART Receiver
  uart_receive : uart_rx
    generic map (
      clks_per_bit => 87
      )
    port map (
      clk       => uart_clk,
      rx_serial => Rx,
      rx_dv     => rx_dv_sig,
      rx_byte   => rx_byte_val
      );

--probe1 <= "00000"&address;

--uart_debug : ila_2 port map (
--  clk => clk,
--  probe0 => address,
--  probe1 => buffer_write,
--  probe2 => buffer_read,
--  probe3 => rx_byte_val
--  );

  buffer1 : uart_buffer port map(
        address => address,
        write => write,
        data_in => buffer_write,
        data_out => buffer_read
        );

--uart_receive_byte : process (rx_dv_sig)
--begin
--if (falling_edge(rx_dv_sig)) then
--  received_byte <= rx_byte_val;
--  buffer_write <= rx_byte_val;
--  if(address >= "111") then
--   address <= "000";
--   ready <= '1';
--  else
--  address <= address +1;
--  ready <= '0';
--  end if;
--end if;
--end process;

state_logic : process(rx_dv_sig)
begin
  if(falling_edge(rx_dv_sig)) then
  received_byte <= rx_byte_val;
    case(address) is
     when "000" =>
       buff1 <= rx_byte_val;
       ready <= '0';
       address <= address + 1;
     when "001" =>
       buff2 <= rx_byte_val;
       ready <= '0';
       address <= address + 1;
     when "010" =>
       buff3 <= rx_byte_val;
       ready <= '0';
       address <= address + 1;
     when "011" =>
       buff4 <= rx_byte_val;
       ready <= '0';
       address <= address + 1;
     when "100" =>
       buff5 <= rx_byte_val;
       ready <= '0';
       address <= address + 1;
     when "101" =>
       buff6 <= rx_byte_val;
       ready <= '0';
       address <= address + 1;
     when "110" =>
       buff7 <= rx_byte_val;
       ready <= '0';
       address <= address + 1;
     when "111" => 
       buff8 <= rx_byte_val;
       ready <= '1';
       address <= "000";
      end case;
  end if;
  end process;

address_out <= address;
ready_flag <= ready;
output_1 <= buff1;
output_2 <= buff2;
output_3 <= buff3;
output_4 <= buff4;
output_5 <= buff5;
output_6 <= buff6;
output_7 <= buff7;
output_8 <= buff8;

end Behavioral;
