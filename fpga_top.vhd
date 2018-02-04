-- TOP level for 68000 computer
-- 
-- 
library IEEE;
use IEEE.STD_LOGIC_1164.all;
-- pragma synthesis_off
library mini_uart;
-- pragma synthesis_on


entity fpga_top is
    port (
        clk_in  : in std_logic;
        reset_n : in std_logic;
        RXD0    : in std_logic;
        TXD0    : out std_logic;
        RXD1    : in std_logic;
        TXD1    : out std_logic;
        reset_out_n : out std_logic;
        led1    : out std_logic;
        led2    : out std_logic
        );
end fpga_top;

-- example:
--entity name is
--    port (
--        input : in  std_logic;
--        output : out  std_logic_vector (7 downto 0)
--    );
--end name; 

architecture rtl of fpga_top is
    
    signal clk              : std_logic := '0';
    signal reset            : std_logic;
    
    signal cpu_clkena_in    : std_logic ;
    signal cpu_rd_bus       : std_logic_vector(15 downto 0);
    signal cpu_ipl          : std_logic_vector(2 downto 0);
    signal cpu_dtack        : std_logic;
    signal cpu_addr         : std_logic_vector(31 downto 0);
    signal cpu_wr_bus       : std_logic_vector(15 downto 0);
    signal cpu_as           : std_logic;
    signal cpu_uds          : std_logic;
    signal cpu_lds          : std_logic;
    signal cpu_rw           : std_logic;
    signal cpu_drive_data   : std_logic;
    
    signal ram_wr           : std_logic;
    signal ram_en           : std_logic;
    signal ram_en_n         : std_logic;
    signal ram_data         : std_logic_vector(15 downto 0);
    
    signal rom_en           : std_logic;
    signal rom_data         : std_logic_vector(15 downto 0);
    
    signal UART0CS_n        : std_logic;
    signal IntRx0_N         : std_logic;
    signal IntTx0_N         : std_logic;
    signal UART0_D          : std_logic_vector(15 downto 0);
    
    signal UART1CS_n        : std_logic;
    signal IntRx1_N         : std_logic;
    signal IntTx1_N         : std_logic;
    signal UART1_D          : std_logic_vector(15 downto 0);
    
    signal cpu_rd_n         : std_logic;
    signal clk1             : std_logic := '0';
    
    signal Bite             : std_logic_vector(1 downto 0);
    
    signal light            : std_logic;
    signal counter          : integer range 0 to 15000000;
    
    component TG68 is
        port(        
            clk           : in std_logic;
            reset         : in std_logic;
            clkena_in     : in std_logic:='1';
            data_in       : in std_logic_vector(15 downto 0);
            IPL           : in std_logic_vector(2 downto 0):="111";
            dtack         : in std_logic;
            addr          : out std_logic_vector(31 downto 0);
            data_out      : out std_logic_vector(15 downto 0);
            as            : out std_logic;
            uds           : out std_logic;
            lds           : out std_logic;
            rw            : out std_logic;
            drive_data    : out std_logic				--enable for data_out driver
            );
    end component;
    
    component SSRAM is
        generic(
            AddrWidth	: integer := 14
            );
        port(
            Clk			: in std_logic;
            CE_n		: in std_logic;
            WE_n		: in std_logic;
            A			: in std_logic_vector(AddrWidth - 1 downto 0);
            DIn			: in std_logic_vector(15 downto 0);
            Bite        : in std_logic_vector(1 downto 0);
            DOut		: out std_logic_vector(15 downto 0)
            );
    end component;
    
    component rom is
        port(
            A	: in std_logic_vector(11 downto 0);
            D	: out std_logic_vector(15 downto 0)
            );
    end component;
    
    component miniUART is
        port (
            SysClk   : in  Std_Logic;  -- System Clock
            Reset    : in  Std_Logic;  -- Reset input
            CS_N     : in  Std_Logic;
            RD_N     : in  Std_Logic;
            WR_N     : in  Std_Logic;
            RxD      : in  Std_Logic;
            TxD      : out Std_Logic;
            IntRx_N  : out Std_Logic;  -- Receive interrupt
            IntTx_N  : out Std_Logic;  -- Transmit interrupt
            Addr     : in  Std_Logic_Vector(1 downto 0); -- 
            DataIn   : in  Std_Logic_Vector(7 downto 0); -- 
            DataOut  : out Std_Logic_Vector(7 downto 0)); -- 
    end component;
    
    -- pragma synthesis_off
    component file_io is  -- test bench
        port (
            clock   : in std_logic;
            reset_n : in std_logic;
            addr    : in std_logic_vector(31 downto 0);
            rw      : in std_logic;
            addr_strobe : in std_logic
            );
    end component;
    -- pragma synthesis_on
    
    
begin
    -- 
    -- the clock is too fast
    -- design cannot achieve 100 MHz
    --
    -- clk1 should be 50mhz
    process (clk_in)
    begin
        if rising_edge (clk_in) then
            clk1 <= not(clk1);
        end if;
    end process;
    
    -- clock should be 25 mhz
    process (clk1)
    begin
        if rising_edge(clk1) then
            clk <= not(clk);
        end if;
    end process;
    
    -- blinky light please
    process (reset_n, clk)
    begin
        if (reset_n = '0') then
            light <= '0';
            counter <= 0;
        elsif rising_edge(clk) then
            counter <= counter + 1;
            if counter = 0 then
                light <= not (light);
            end if;
        end if;
    end process;
    led1 <= reset_n;
    led2 <= light;
    
    --clk <= clk_in;
    reset <= reset_n; -- this is terrible fix
    reset_out_n <= reset_n;
    cpu_clkena_in <= '1'; -- no work if set to zero
    cpu_IPL <= "111";
    cpu_dtack <= '0'; -- dtack grounded, memory always ready
    cpu_rd_n <= not(cpu_rw) or (cpu_uds and cpu_lds);
    UART0_D(15 downto 8) <= x"00";
    
    U1: entity TG68
    port map(        
        clk           => clk,
        reset         => reset,
        clkena_in     => cpu_clkena_in,
        data_in       => cpu_rd_bus,
        IPL           => cpu_ipl,
        dtack         => cpu_dtack,
        addr          => cpu_addr,
        data_out      => cpu_wr_bus,
        as            => cpu_as,
        uds           => cpu_uds,
        lds           => cpu_lds,
        rw            => cpu_rw,
        drive_data    => cpu_drive_data
        );
    
    --    U2: entity ram
    --    port map(
    --        WE => ram_wr,
    --        CLK => clk,
    --        ADDR => cpu_addr(15 downto 0),
    --        DATA => cpu_wr_bus,
    --        Q => ram_data
    --        );
    
    Bite <= cpu_uds & cpu_lds;
    
    U2: entity SSRAM
    port map(
        Clk			=> clk,
        CE_n		=> ram_en_n,
        WE_n		=> cpu_rw,
        A			=> cpu_addr(14 downto 1),
        DIn			=> cpu_wr_bus,
        Bite        => Bite,
        DOut		=> ram_data
        );
    
    -- rom is 16 bits, so we don't need the lsb
    --    U3:     entity rom
    --    port map(
    --        clk => clk,
    --        en => rom_en,
    --        addr => cpu_addr(8 downto 1),
    --        data => rom_data);
    
    -- rom from assembler
    --    u3: entity first
    --    port map(
    --        A	=> cpu_addr(8 downto 1),
    --        D	=> rom_data);
    
    -- rom tiny basic
    u3: entity rom
    port map(
        A	=> cpu_addr(12 downto 1),
        D	=> rom_data);
    
    u4 : miniUART
    port map (
        SysClk      => Clk,
        Reset       => reset,
        CS_N        => UART0CS_n,
        RD_N        => cpu_rd_n,
        WR_N        => cpu_rw,
        RxD         => RXD0,
        TxD         => TXD0,
        IntRx_N     => IntRx0_N,  -- Receive interrupt
        IntTx_N     => IntTx0_N,  -- Transmit interrupt
        Addr        => cpu_addr(2 downto 1), 
        DataIn      => cpu_wr_bus(7 downto 0), 
        DataOut     => UART0_D(7 downto 0)); 
    
    
    u5 : miniUART
    port map (
        SysClk      => Clk,
        Reset       => reset,
        CS_N        => UART1CS_n,
        RD_N        => cpu_rd_n,
        WR_N        => cpu_rw,
        RxD         => RXD1,
        TxD         => TXD1,
        IntRx_N     => IntRx1_N,  -- Receive interrupt
        IntTx_N     => IntTx1_N,  -- Transmit interrupt
        Addr        => cpu_addr(2 downto 1), 
        DataIn      => cpu_wr_bus(7 downto 0), -- big endian
        DataOut     => UART1_D(7 downto 0)); 
    
    -- memory address map
    -- rom starts at zero, because vectors are at zero
    -- 16K x 16 at 0001_0000 to 0001_3FFF
    ram_en <= '1' when cpu_addr(31 downto 16) = x"0001" else '0';
    ram_en_n <= not(ram_en);
    -- uart 0 is at 0008_0000 hex through 0008_00xx
    UART0CS_n <= '0' when cpu_addr(31 downto 8) = x"000800" else '1';
    -- uart 1 is at 8010 hex through 8017
    UART1CS_n <= '0' when cpu_addr(31 downto 8) = x"000801" else '1';
    -- rom chip select 0000_0000 hex through 0000_FFFF
    rom_en <= '1' when cpu_addr(31 downto 16) = x"0000" else '0';
    
    -- multiplexer for data coming into cpu
    cpu_rd_bus <=
    ram_data when ram_en = '1' else
    UART0_D(7 DOWNTO 0) & UART0_D(7 DOWNTO 0) when UART0CS_n = '0' else
    UART1_D when UART1CS_n = '0' else
    rom_data;
    
    -- pragma synthesis_off
    Udebug : file_io
    port map(
        clock   => Clk,
        reset_n => reset_n,
        addr    => cpu_addr,
        rw      => cpu_rw,
        addr_strobe => cpu_as
        );
    -- pragma synthesis_on
    
end architecture rtl;

