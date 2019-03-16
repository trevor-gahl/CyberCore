-- modified from:
-- https://www.nandland.com/vhdl/modules/module-uart-serial-port-rs232.html
-- Set Generic clks_per_bit as follows:
-- clks_per_bit = (Frequency of clk)/(Frequency of UART)
-- Example: 100 MHz Clock, 115200 baud UART
-- (100000000)/(115200) = 868
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
  generic(
    clks_per_bit : integer := 868       -- Needs to be set for desired baudrate
    );
  port(
    clk       : in  std_logic;
    tx_dv     : in  std_logic;
    tx_byte   : in  std_logic_vector(7 downto 0);
    tx_active : out std_logic;
    tx_serial : out std_logic;
    tx_done   : out std_logic
    );
end uart_tx;

architecture rtl of uart_tx is

  type state is (S_Idle, S_Tx_Start_Bit, S_Tx_Data_Bits, S_Tx_Stop_Bit, S_Cleanup);

  signal current_state : state := S_Idle;

  signal clk_count   : integer range 0 to clks_per_bit-1 := 0;
  signal bit_index   : integer range 0 to 7              := 0;
  signal tx_data_sig : std_logic_vector(7 downto 0)      := (others => '0');
  signal tx_done_sig : std_logic                         := '0';

begin

  uart_transmit : process(clk)
  begin
    if(rising_edge(clk)) then

      case(current_state) is

        when S_Idle =>
          tx_active   <= '0';
          tx_serial   <= '1';
          tx_done_sig <= '0';
          clk_count   <= 0;
          bit_index   <= 0;

          if(tx_dv = '1') then
            tx_data_sig   <= tx_byte;
            current_state <= S_Tx_Start_Bit;
          else
            current_state <= S_Idle;
          end if;

        when S_Tx_Start_Bit =>
          tx_active <= '1';
          tx_serial <= '0';

          if(clk_count < clks_per_bit-1) then
            clk_count     <= clk_count + 1;
            current_state <= S_Tx_Start_Bit;
          else
            clk_count     <= 0;
            current_state <= S_Tx_Data_Bits;
          end if;

        when S_Tx_Data_Bits =>
          tx_serial <= tx_data_sig(bit_index);

          if(clk_count < clks_per_bit-1) then
            clk_count     <= clk_count + 1;
            current_state <= S_Tx_Data_Bits;
          else
            clk_count <= 0;
            if(bit_index < 7) then
              bit_index     <= bit_index + 1;
              current_state <= S_Tx_Data_Bits;
            else
              bit_index     <= 0;
              current_state <= S_Tx_Stop_Bit;
            end if;
          end if;

        when S_Tx_Stop_Bit =>
          tx_serial <= '1';

          if(clk_count < clks_per_bit-1) then
            clk_count     <= clk_count + 1;
            current_state <= S_Tx_Stop_Bit;
          else
            tx_done_sig   <= '1';
            clk_count     <= 0;
            current_state <= S_Cleanup;
          end if;

        when S_Cleanup =>
          tx_active     <= '0';
          tx_done_sig   <= '1';
          current_state <= S_Idle;

        when others =>
          current_state <= S_Idle;

      end case;
    end if;
  end process;
  tx_done <= tx_done_sig;
end rtl;



