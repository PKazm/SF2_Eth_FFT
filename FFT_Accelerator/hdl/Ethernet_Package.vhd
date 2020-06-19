library IEEE;

use IEEE.std_logic_1164.all;

package ETH_pkg is

    constant ETH_PACKET_MAX : natural := 1522;
    constant ETH_INTERPACKET_GAP : natural := 12;   -- 96 bits, 8 bits per cycle, 12 cycles.

    --type preamble_type is array (0 to 6) of std_logic_vector(7 downto 0);
    --constant ETH_PREAMBLE : preamble_type := (others => X"AA");
    constant ETH_PREAMBLE : std_logic_vector(7*8-1 downto 0) := X"AA" & X"AA" & X"AA" & X"AA" & X"AA" & X"AA" & X"AA";
    constant ETH_SFD : std_logic_vector(7 downto 0) := X"AB";

    --type mac_adr_type is array (0 to 5) of std_logic_vector(7 downto 0);
    --type ip_adr_type is array (0 to 3) of std_logic_vector(7 downto 0);
    --type mac_adr_type is std_logic_vector(47 downto 0);
    --type ip_adr_type is std_logic_vector(31 downto 0);
    --type port_val_type is std_logic_vector(15 downto 0);
    
    

    type my_identity is record
        mac_adr     : std_logic_vector(47 downto 0);
        ip_adr      : std_logic_vector(31 downto 0);
        udp_port    : std_logic_vector(15 downto 0);
    end record my_identity;
    
    --=========================================================================
    -- Ethernet Header stuff
    --=========================================================================

    type eth_header is record
        dest_mac_adr : std_logic_vector(47 downto 0);
        src_mac_adr : std_logic_vector(47 downto 0);
        eth_type : std_logic_vector(7 downto 0);
    end record eth_header;

    constant ETH_TYPE_IPV4  : std_logic_vector(15 downto 0) := X"0800";
    constant ETH_TYPE_ARP   : std_logic_vector(15 downto 0) := X"0806";


    --=========================================================================
    -- IPv4 Header stuff
    --=========================================================================

    type ipv4_header is record
        version     : std_logic_vector(3 downto 0);
        ihl         : std_logic_vector(3 downto 0);
        dscp        : std_logic_vector(5 downto 0);
        ecn         : std_logic_vector(1 downto 0);
        length      : std_logic_vector(15 downto 0);
        ident       : std_logic_vector(15 downto 0);
        flags       : std_logic_vector(2 downto 0);
        frgmt_oset  : std_logic_vector(12 downto 0);
        ttl         : std_logic_vector(7 downto 0);
        protocol    : std_logic_vector(7 downto 0);
        checksum    : std_logic_vector(15 downto 0);
        src_ip      : std_logic_vector(31 downto 0);
        dst_ip      : std_logic_vector(31 downto 0);
    end record ipv4_header;

    constant IPV4_PRTCL_UDP : std_logic_vector(7 downto 0) := X"11";

    --=========================================================================
    -- UDP Header stuff
    --=========================================================================

    type udp_header is record
        src_port    : std_logic_vector(15 downto 0);
        dst_port    : std_logic_vector(15 downto 0);
        length      : std_logic_vector(15 downto 0);
        checksum    : std_logic_vector(15 downto 0);
    end record udp_header;

end package ETH_pkg;

package body ETH_pkg is

end package body ETH_pkg;