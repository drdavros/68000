-- 6502, Monitor ROM, external SRAM interface and two 16450 UARTs
-- that can be synthesized and used with
-- the NoICE debugger that can be found at
-- http://www.noicedebugger.com/

library IEEE;
use IEEE.std_logic_1164.all;
library mini_uart;

entity DebugSystemXR is
    port(
        Reset_n		: in std_logic;
        Clk			: in std_logic;
        NMI_n		: in std_logic;
        --OE_n		: out std_logic;
        --WE_n		: out std_logic;
        --RAMCS_n		: out std_logic;
        --ROMCS_n		: out std_logic;
        --PGM_n		: out std_logic;
        --A			: out std_logic_vector(16 downto 0);
        --D			: inout std_logic_vector(7 downto 0);
        -- serial port 0
        RXD0		: in std_logic;
        TXD0		: out std_logic;
        -- serial port 1
        RXD1		: in std_logic;
        TXD1		: out std_logic
        );
end entity DebugSystemXR;

architecture struct of DebugSystemXR is
    
    -- xilinx rom for simulation
    component rams_21a is
        port (clk : in std_logic;
            en : in std_logic;
            addr : in std_logic_vector(7 downto 0);
            data : out std_logic_vector(7 downto 0));
    end component;
    
    -- rom from dasm and rom2vhdl
    component test_rom is
        port (addr	:in std_logic_vector (11 downto 0);
            data  :out std_logic_vector (7 downto 0)
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
    
    
    signal Res_n_s		: std_logic;
    signal Rd_n			: std_logic;
    signal Wr_n			: std_logic;
    signal R_W_n		: std_logic;
    signal A_i			: std_logic_vector(23 downto 0);
    signal Dwrite		: std_logic_vector(7 downto 0);
    --signal ROM_D		: std_logic_vector(7 downto 0);
    signal UART0_D		: std_logic_vector(7 downto 0);
    signal UART1_D		: std_logic_vector(7 downto 0);
    signal CPU_D		: std_logic_vector(7 downto 0);
    
    signal Rdy			: std_logic;
    
    signal RAMCS_n_i	: std_logic;
    signal UART0CS_n	: std_logic;
    signal UART1CS_n	: std_logic;
    
    signal Sram_Dout    : std_logic_vector(7 downto 0);
    
    signal Rom_Dout     : std_logic_vector(7 downto 0);
    signal ROMCS        : std_logic;
    
    -- uart signals
    signal IntTx_N      : std_logic; -- interrupt
    signal IntRx_N      : std_logic;
    
begin
    
    Rd_n <= not R_W_n or not Rdy;
    Wr_n <= R_W_n or not Rdy;
    --OE_n <= not R_W_n;
    --WE_n <= Wr_n;
    --RAMCS_n <= RAMCS_n_i;
    --ROMCS_n <= '1';
    --PGM_n <= '1';
    --A(14 downto 0) <= A_i(14 downto 0);
    --A(16 downto 15) <= "00";
    --D <= D_i when R_W_n = '0' else "ZZZZZZZZ";
    
    process (Reset_n, Clk)
    begin
        if Reset_n = '0' then
            Res_n_s <= '0';
            Rdy <= '0';
        elsif Clk'event and Clk = '1' then
            Res_n_s <= '1';
            Rdy <= not Rdy;
        end if;
    end process;
    
    -- memory address map
    -- ram is lower half of memory
    -- 32K x 8
    RAMCS_n_i <= A_i(15);
    -- uart 0 is at 8000 hex through 8007
    UART0CS_n <= '0' when A_i(15 downto 3) = "1000000000000" else '1';
    -- uart 1 is at 8010 hex through 8017
    UART1CS_n <= '0' when A_i(15 downto 3) = "1000000010000" else '1';
    -- rom chip select F000 hex through FFFF
    ROMCS <= '0' when A_i(15 downto 12) = "1111" else '1';
    
    -- multiplexer for data coming into cpu
    CPU_D <=
    Sram_Dout when RAMCS_n_i = '0' else
    UART0_D when UART0CS_n = '0' else
    UART1_D when UART1CS_n = '0' else
    Rom_Dout;
    
    -- CPU
    u0 : entity work.T65
    port map(
        Mode => "00", -- select 6502
        Res_n => Res_n_s,
        Clk => Clk,
        Rdy => Rdy,
        Abort_n => '1',
        IRQ_n => '1',
        NMI_n => NMI_n,
        SO_n => '1',
        R_W_n => R_W_n,
        Sync => open,
        EF => open,
        MF => open,
        XF => open,
        ML_n => open,
        VP_n => open,
        VDA => open,
        VPA => open,
        A => A_i,
        DI => CPU_D, --6502 input
        DO => Dwrite);
    
    -- rom monitor that was not included?
    --    u1 : entity work.Mon65XR
    --    port map(
    --        Clk => Clk,
    --        A => A_i(9 downto 0),
    --        D => ROM_D);
    
    
    -- uart 0 (new, no documents on the old one)
    -- write 8000 send data
    -- read 8000 to read data
    -- read 8001 for status
    -----------------------------------------------------------------------------
    --             CSReg detailed 
    -----------+--------+--------+--------+--------+--------+--------+--------+
    -- CSReg(7)|CSReg(6)|CSReg(5)|CSReg(4)|CSReg(3)|CSReg(2)|CSReg(1)|CSReg(0)|
    --   Res   |  Res   |  Res   |  Res   | UndRun | OvrRun |  FErr  |  OErr  |
    -----------+--------+--------+--------+--------+--------+--------+--------+
    -----------------------------------------------------------------------------
    
    u3 : miniUART
    port map (
        SysClk      => Clk,
        Reset       => Res_n_s,
        CS_N        => UART0CS_n,
        RD_N        => Rd_n,
        WR_N        => Wr_n,
        RxD         => RXD0,
        TxD         => TXD0,
        IntRx_N     => IntRx_N,  -- Receive interrupt
        IntTx_N     => IntTx_N,  -- Transmit interrupt
        Addr        => A_i(1 downto 0), 
        DataIn      => Dwrite, 
        DataOut     => UART0_D); -- 
    
    
    
    
    -- uart 0
    --    u3 : entity work.T16450
    --    port map(
    --        MR_n => Res_n_s,
    --        XIn => Clk,
    --        RClk => BaudOut0,
    --        CS_n => UART0CS_n,
    --        Rd_n => Rd_n,
    --        Wr_n => Wr_n,
    --        A => A_i(2 downto 0),
    --        D_In => Dwrite,
    --        D_Out => UART0_D,
    --        SIn => RXD0,
    --        CTS_n => CTS0,
    --        DSR_n => DSR0,
    --        RI_n => RI0,
    --        DCD_n => DCD0,
    --        SOut => TXD0,
    --        RTS_n => RTS0,
    --        DTR_n => DTR0,
    --        OUT1_n => open,
    --        OUT2_n => open,
    --        BaudOut => BaudOut0,
    --        Intr => open);
    
    -- uart 1
    --    u4 : entity work.T16450
    --    port map(
    --        MR_n => Res_n_s,
    --        XIn => Clk,
    --        RClk => BaudOut1,
    --        CS_n => UART1CS_n,
    --        Rd_n => Rd_n,
    --        Wr_n => Wr_n,
    --        A => A_i(2 downto 0),
    --        D_In => Dwrite,
    --        D_Out => UART1_D,
    --        SIn => RXD1,
    --        CTS_n => CTS1,
    --        DSR_n => DSR1,
    --        RI_n => RI1,
    --        DCD_n => DCD1,
    --        SOut => TXD1,
    --        RTS_n => RTS1,
    --        DTR_n => DTR1,
    --        OUT1_n => open,
    --        OUT2_n => open,
    --        BaudOut => BaudOut1,
    --        Intr => open);
    
    -- sram memory
    u5 : entity SSRAM
    port map(
        Clk     => Clk,
        CE_n    => RAMCS_n_i,
        WE_n    => R_W_n,
        A       => A_i(14 downto 0),
        DIn     => Dwrite,
        DOut    => Sram_Dout
        );
    
    -- rom memory
    --    u6 : entity single_port_rom
    --    port map
    --        (
    --        addr	=> A_i(7 downto 0),
    --        clk		=> Clk,
    --        q		=> Rom_Dout
    --        );
    
    -- xilinx rom memory
    -- sometimes we use this one
    --        u6 : rams_21a
    --        port map
    --            (
    --            clk => Clk,
    --            en  => '1',
    --            addr => A_i(7 downto 0),
    --            data => Rom_Dout
    --            );
    
    -- rom memory
    -- from dasm and rom2vhdl
    -- sometimes we use this one
    u6 : test_rom
    port map (
        addr    => A_i(11 downto 0),
        data => Rom_Dout
        );
    
    
    
    
end;
