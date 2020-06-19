LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

PACKAGE fifo_pkg IS
   FUNCTION log2 (x : natural) RETURN natural;
   FUNCTION ceil_log2 (t : natural) RETURN natural;
   FUNCTION ceil_log2t (t : natural) RETURN natural;
   FUNCTION SYNC_MODE_SEL (FAMILY: INTEGER) return INTEGER;
   FUNCTION t_fwft (FWFT: INTEGER; PREFETCH : INTEGER) return INTEGER;
END;

PACKAGE BODY fifo_pkg IS
    FUNCTION log2 (x : natural) RETURN natural is 
    BEGIN
	IF x <= 1 THEN   --[SAR#46322] Below change to accomodate value of DEPTH = 1, so that ceil log function returns 1 and MEMWADDDR is [0:0] for WDEPTH = 1
        --IF x < 1 THEN   
            RETURN 0;
        ELSE
            RETURN log2 (x / 2) + 1;
        END IF;
    END FUNCTION log2;

    FUNCTION ceil_log2 (t : natural) RETURN natural is
        VARIABLE RetVal:    natural;
    BEGIN
        RetVal := log2(t);
        IF (t > (2**RetVal)) THEN
            RETURN(RetVal + 1); -- RetVal is too small, so bump it up by 1 and return
        ELSE
            RETURN(RetVal); -- Just right
        END IF;
    END FUNCTION ceil_log2;

    FUNCTION ceil_log2t (t : natural) RETURN natural is
        VARIABLE RetVal:    natural;
    BEGIN
        IF (t = 1) THEN
          RetVal := 1;
          RETURN(RetVal); -- Just right
	ELSE
          RetVal := log2(t);
          IF (t > (2**RetVal)) THEN
            RETURN(RetVal + 1); -- RetVal is too small, so bump it up by 1 and return
          ELSE
            RETURN(RetVal); -- Just right
          END IF;
        END IF;
    END FUNCTION ceil_log2t;

    FUNCTION t_fwft (FWFT : INTEGER ; PREFETCH : INTEGER) RETURN INTEGER IS
      VARIABLE ret_val : INTEGER := 0;
      BEGIN
	 IF (FWFT = 1 OR PREFETCH = 1) THEN
	   ret_val := 0;
         ELSE 
	   ret_val := 1;
	 END IF;
	 RETURN ret_val;     
    END FUNCTION t_fwft;
      
    FUNCTION SYNC_MODE_SEL (FAMILY: INTEGER) RETURN INTEGER IS
       VARIABLE return_val: INTEGER := 0;
       BEGIN
          IF (FAMILY = 25) THEN
             return_val := 1;
          ELSE 
             return_val := 0;
          END IF;
          RETURN return_val;
    END SYNC_MODE_SEL;

END;



