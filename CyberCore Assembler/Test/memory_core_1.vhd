library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity memory_core_1 is
  port (write       : in  std_logic;
        reset       : in  std_logic;
        clock       : in  std_logic;
        data_in     : in  std_logic_vector (7 downto 0);
        data_out    : out std_logic_vector (7 downto 0);
        address     : in  std_logic_vector (7 downto 0);
        port_in_00  : in  std_logic_vector (7 downto 0);
        port_in_01  : in  std_logic_vector (7 downto 0);
        port_in_02  : in  std_logic_vector (7 downto 0);
        port_in_03  : in  std_logic_vector (7 downto 0);
        port_in_04  : in  std_logic_vector (7 downto 0);
        port_in_05  : in  std_logic_vector (7 downto 0);
        port_in_06  : in  std_logic_vector (7 downto 0);
        port_in_07  : in  std_logic_vector (7 downto 0);
        port_in_08  : in  std_logic_vector (7 downto 0);
        port_in_09  : in  std_logic_vector (7 downto 0);
        port_in_10  : in  std_logic_vector (7 downto 0);
        port_in_11  : in  std_logic_vector (7 downto 0);
        port_in_12  : in  std_logic_vector (7 downto 0);
        port_in_13  : in  std_logic_vector (7 downto 0);
        port_in_14  : in  std_logic_vector (7 downto 0);
        port_in_15  : in  std_logic_vector (7 downto 0);
        port_out_00 : out std_logic_vector (7 downto 0);
        port_out_01 : out std_logic_vector (7 downto 0);
        port_out_02 : out std_logic_vector (7 downto 0);
        port_out_03 : out std_logic_vector (7 downto 0);
        port_out_04 : out std_logic_vector (7 downto 0);
        port_out_05 : out std_logic_vector (7 downto 0);
        port_out_06 : out std_logic_vector (7 downto 0);
        port_out_07 : out std_logic_vector (7 downto 0);
        port_out_08 : out std_logic_vector (7 downto 0);
        port_out_09 : out std_logic_vector (7 downto 0);
        port_out_10 : out std_logic_vector (7 downto 0);
        port_out_11 : out std_logic_vector (7 downto 0);
        port_out_12 : out std_logic_vector (7 downto 0);
        port_out_13 : out std_logic_vector (7 downto 0);
        port_out_14 : out std_logic_vector (7 downto 0);
        port_out_15 : out std_logic_vector (7 downto 0)
        );
end entity;

architecture memory_arch_1 of memory_core_1 is

  component rom_128x8_sync_core_1
    port (address  : in  std_logic_vector (7 downto 0);
          clock    : in  std_logic;
          data_out : out std_logic_vector (7 downto 0));
  end component;

  component rw_96x8_sync_core_1
    port (address  : in  std_logic_vector (7 downto 0);
          clock    : in  std_logic;
          data_out : out std_logic_vector (7 downto 0);
          data_in  : in  std_logic_vector (7 downto 0);
          write    : in  std_logic);
  end component;

  component stack_core_1
    port (address  : in  std_logic_vector (7 downto 0);
          clock    : in  std_logic;
          data_out : out std_logic_vector (7 downto 0);
          data_in  : in  std_logic_vector (7 downto 0);
          write    : in  std_logic);
  end component;

--   component ila_1 is
--     port(
--       clk    : in std_logic;
--       probe0 : in std_logic_vector(7 downto 0);
--       probe1 : in std_logic_vector(7 downto 0);
--       probe2 : in std_logic_vector(7 downto 0);
--       probe3 : in std_logic_vector(7 downto 0)
-- --        probe4 : in std_logic_vector(7 downto 0);
-- --        probe5 : in std_logic_vector(7 downto 0)
--       );
--   end component;

  signal rom_data_out   : std_logic_vector(7 downto 0);
  signal rw_data_out    : std_logic_vector(7 downto 0);
  signal stack_data_out : std_logic_vector(7 downto 0);


begin
  ROM : rom_128x8_sync_core_1
    port map (clock    => clock,
              address  => address,
              data_out => rom_data_out);

  RW : rw_96x8_sync_core_1
    port map (clock    => clock,
              write    => write,
              address  => address,
              data_in  => data_in,
              data_out => rw_data_out);

  STACK : stack_core_1
    port map (clock    => clock,
              write    => write,
              address  => address,
              data_in  => data_in,
              data_out => stack_data_out);

--   debug : ila_1 port map(
--     clk    => clock,
--     probe0 => address,
--     probe1 => data_in,
--     probe2 => port_in_00,
--     probe3 => (others => '1')
-- --        probe4 =>stack_data_out,
-- --        probe5 => rw_data_out
--     );


--Multiplexer code
  MUX1 : process (address, rom_data_out, rw_data_out, stack_data_out,
                  port_in_00, port_in_01, port_in_02, port_in_03,
                  port_in_04, port_in_05, port_in_06, port_in_07,
                  port_in_08, port_in_09, port_in_10, port_in_11,
                  port_in_12, port_in_13, port_in_14, port_in_15)

  begin
    if ((to_integer(unsigned(address)) >= 0) and
        (to_integer(unsigned(address)) <= 95)) then
      data_out <= rom_data_out;
    elsif((to_integer(unsigned(address)) >= 128) and
          (to_integer(unsigned(address)) <= 199)) then
      data_out <= rw_data_out;
    elsif((to_integer(unsigned(address)) >= 200) and
          (to_integer(unsigned(address)) <= 255)) then
      data_out <= stack_data_out;

    elsif (address = x"70") then data_out <= port_in_00;
    elsif (address = x"71") then data_out <= port_in_01;
    elsif (address = x"72") then data_out <= port_in_02;
    elsif (address = x"73") then data_out <= port_in_03;
    elsif (address = x"74") then data_out <= port_in_04;
    elsif (address = x"75") then data_out <= port_in_05;
    elsif (address = x"76") then data_out <= port_in_06;
    elsif (address = x"77") then data_out <= port_in_07;
    elsif (address = x"78") then data_out <= port_in_08;
    elsif (address = x"79") then data_out <= port_in_09;
    elsif (address = x"7A") then data_out <= port_in_10;
    elsif (address = x"7B") then data_out <= port_in_11;
    elsif (address = x"7C") then data_out <= port_in_12;
    elsif (address = x"7D") then data_out <= port_in_13;
    elsif (address = x"7E") then data_out <= port_in_14;
    elsif (address = x"7F") then data_out <= port_in_15;

    else data_out <= x"00";

    end if;

  end process;

--port_out_00 description : ADDRESS x "E0"
  U3 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_00 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"60" and write = '1') then
        port_out_00 <= data_in;
      end if;
    end if;
  end process;

--port_out_01 description : ADDRESS x "E1"
  U4 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_01 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"61" and write = '1') then
        port_out_01 <= data_in;
      end if;
    end if;
  end process;

--port_out_02 description : ADDRESS x "E2"
  U5 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_02 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"62" and write = '1') then
        port_out_02 <= data_in;
      end if;
    end if;
  end process;

--port_out_03 description : ADDRESS x "E3"
  U6 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_03 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"63" and write = '1') then
        port_out_03 <= data_in;
      end if;
    end if;
  end process;

--port_out_04 description : ADDRESS x "E4"
  U7 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_04 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"64" and write = '1') then
        port_out_04 <= data_in;
      end if;
    end if;
  end process;

--port_out_05 description : ADDRESS x "E5"
  U8 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_05 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"65" and write = '1') then
        port_out_05 <= data_in;
      end if;
    end if;
  end process;

--port_out_06 description : ADDRESS x "E6"
  U9 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_06 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"66" and write = '1') then
        port_out_06 <= data_in;
      end if;
    end if;
  end process;

--port_out_07 description : ADDRESS x "E7"
  U10 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_07 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"67" and write = '1') then
        port_out_07 <= data_in;
      end if;
    end if;
  end process;

--port_out_08 description : ADDRESS x "E8"
  U11 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_08 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"68" and write = '1') then
        port_out_08 <= data_in;
      end if;
    end if;
  end process;

--port_out_09 description : ADDRESS x "E9"
  U12 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_09 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"69" and write = '1') then
        port_out_09 <= data_in;
      end if;
    end if;
  end process;

--port_out_0A description : ADDRESS x "EA"
  U13 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_10 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"6A" and write = '1') then
        port_out_10 <= data_in;
      end if;
    end if;
  end process;

--port_out_0B description : ADDRESS x "EB"
  U14 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_11 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"6B" and write = '1') then
        port_out_11 <= data_in;
      end if;
    end if;
  end process;

--port_out_0C description : ADDRESS x "EC"
  U15 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_12 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"6C" and write = '1') then
        port_out_12 <= data_in;
      end if;
    end if;
  end process;

--port_out_0D description : ADDRESS x "ED"
  U16 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_13 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"6D" and write = '1') then
        port_out_13 <= data_in;
      end if;
    end if;
  end process;

--port_out_0E description : ADDRESS x "EE"
  U17 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_14 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"6E" and write = '1') then
        port_out_14 <= data_in;
      end if;
    end if;
  end process;

--port_out_0F description : ADDRESS x "EF"
  U18 : process (clock, reset)
  begin
    if (reset = '1') then
      port_out_15 <= x"00";
    elsif (clock'event and clock = '1') then
      if (address = x"6F" and write = '1') then
        port_out_15 <= data_in;
      end if;
    end if;
  end process;



end architecture;
