library IEEE;
use iEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity uart_buffer is
    port (
      clock : in std_logic;
      uart_clock : in std_logic;
      interrupt_clr : in std_logic;
      interrupt : out std_logic_vector(3 downto 0);
      buff1 : out std_logic_vector(7 downto 0);
      buff2 : out std_logic_vector(7 downto 0);
      buff3 : out std_logic_vector(7 downto 0);
      buff4 : out std_logic_vector(7 downto 0);
      buff5 : out std_logic_vector(7 downto 0);
      buff6 : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of uart_buffer is

    type state_type is(state_1, state_2, state_3, state_4, state_5, state_6, state_7);

    signal current_state, next_state : state_type;

    -- UART
    signal clks_per_bit                                           : integer := 87;
    signal uart_clk                                               : std_logic;
    signal rx_dv_sig                                              : std_logic;
    signal rx_byte_val                                            : std_logic_vector(7 downto 0);
    signal tx_dv_sig                                              : std_logic;
    signal tx_byte_val                                            : std_logic_vector(7 downto 0);
    signal tx_done_sig                                            : std_logic;

    -- Interrupts
    signal rx_read       : std_logic_vector(7 downto 0);

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

    next_state_logic : process(CLK)
    begin
      if(rising_edge(CLK)) then
        current_state <= next_state;
      end if;
    end process;

    state_logic : process(rx_dv_sig, CLK, interrupt_clr)
    begin
      if(current_state = state_7 and interrupt_clr = '1') then
        next_state <= state_1;
      else
        if(rising_edge(rx_dv_sig)) then

          case(current_state) is
            when state_1 =>
              rx_read    <= rx_byte_val;
              next_state <= state_2;
            when state_2 =>
              rx_read    <= rx_byte_val;
              next_state <= state_3;
            when state_3 =>
              rx_read    <= rx_byte_val;
              next_state <= state_4;
            when state_4 =>
              rx_read    <= rx_byte_val;
              next_state <= state_5;
            when state_5 =>
              rx_read    <= rx_byte_val;
              next_state <= state_6;
            when state_6 =>
              rx_read    <= rx_byte_val;
              next_state <= state_7;
            when others =>
              next_state <= current_state;
          end case;
        end if;
      end if;
    end process;

    state_output : process(current_state)
    begin
      case(current_state) is
        when state_1 =>
          buff1        <= rx_read;
          interrupt    <= "0000";
        when state_2 =>
          buff2        <= rx_read;
          interrupt    <= "0000";
        when state_3 =>
          buff3        <= rx_read;
          interrupt    <= "0000";
        when state_4 =>
          buff4        <= rx_read;
          interrupt    <= "0000";
        when state_5 =>
          buff5        <= rx_read;
          interrupt    <= "0000";
        when state_6 =>
          buff6        <= rx_read;
          interrupt    <= "0000";
        when state_7 =>
          interrupt    <= "0001";
      end case;
    end process;

end Behavioral;
