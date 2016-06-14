----------------------------------------------------------------------------------
-- Company: Peralex Electronics
-- Engineer: Gavin Teague
-- 
-- Create Date: 05.09.2014 10:19:29
-- Design Name: 
-- Module Name: wishbone_interconnect - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Connects multiple Wishbone slaves to a single Wishbone master
--
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.parameter.all;

entity wishbone_interconnect is
	port (
        -- WISHBONE CLASSIC SIGNALS - COMMON
		CLK_I : in std_logic;
		RST_I : in std_logic;

		-- WISHBONE CLASSIC SIGNALS - MASTER
		MST_DAT_O : in std_logic_vector(31 downto 0);
		MST_DAT_I : out std_logic_vector(31 downto 0);
		MST_ACK_I : out std_logic;
		MST_ADR_O : in std_logic_vector((C_WB_MST_ADDRESS_BITS - 1) downto 0);
		MST_CYC_O : in std_logic;
		MST_SEL_O : in std_logic_vector(3 downto 0);
		MST_STB_O : in std_logic;
		MST_WE_O  : in std_logic;
		
		-- WISHBONE CLASSIC SIGNALS - SLAVES
		SLV_DAT_O : in T_SLAVE_WB_DATA;
		SLV_DAT_I : out T_SLAVE_WB_DATA;
		SLV_ACK_O : in std_logic_vector(0 to (C_WB_NUM_SLAVES - 1));
		SLV_ADR_I : out T_SLAVE_WB_ADDRESS;
		SLV_CYC_I : out std_logic_vector(0 to (C_WB_NUM_SLAVES - 1));
		SLV_SEL_I : out T_SLAVE_WB_SEL;
		SLV_STB_I : out std_logic_vector(0 to (C_WB_NUM_SLAVES - 1));
		SLV_WE_I  : out std_logic_vector(0 to (C_WB_NUM_SLAVES - 1)));
end wishbone_interconnect;

architecture arch_wishbone_interconnect of wishbone_interconnect is

    signal current_slave : integer range 0 to C_WB_MAX_NUM_SLAVES;
    
begin

    -- TRY DIRECT CONNECTIONS FIRST, RELY ON REGISTERING IN MASTER AND SLAVE
    
    -- DETERMINE CURRENT SLAVE BASED ON UPPER ADDRESS BITS
    current_slave <= to_integer(unsigned(MST_ADR_O((C_WB_MST_ADDRESS_BITS - 1) downto C_WB_SLV_ADDRESS_BITS)));
    
    generate_slave_connections : for a in 0 to (C_WB_NUM_SLAVES - 1) generate
        SLV_DAT_I(a) <= MST_DAT_O;
        SLV_ADR_I(a) <= MST_ADR_O((C_WB_SLV_ADDRESS_BITS - 1) downto 0);
        SLV_CYC_I(a) <= MST_CYC_O;
        SLV_SEL_I(a) <= MST_SEL_O;
        SLV_WE_I(a) <= MST_WE_O;

        -- STB SELECTED SLAVE
        SLV_STB_I(a) <= MST_STB_O when (a = current_slave) else '0';
    end generate generate_slave_connections;

    -- DEMULTIPLEX THE ACK TO THE MASTER
    MST_ACK_I <= SLV_ACK_O(current_slave);
    
    -- DEMULTIPLEX THE DATA TO THE MASTER
    MST_DAT_I <= SLV_DAT_O(current_slave);
 
end arch_wishbone_interconnect;
