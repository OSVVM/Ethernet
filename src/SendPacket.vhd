      -- Find En = 1 at Rising_Edge(Clk)
--      wait on Clk until Tx_En = '1' and Rising_Edge(iTxClk) ; 
      loop
        GetByte(oData, oEn, oEr) ; 
        case std_logic_vector'(oEn & oEr) is
          when "10" | "11" =>
            -- Data Reception 
            GetPacket ; 
            Last := PACKET ; 
          when "00" => 
            Last := INTER_FRAME ; 
          when "01" => 
            case to_integer(oData) is 
              when 0 =>
                Last := INTER_FRAME ; 
              when 1 => 
                if Last /= LPI_ASSERTED then 
                  StartedLpi ; 
                end if ; 
                Last := LPI_ASSERTED ; 
              when 16#0F# =>
                Last := CARRIER_EXTEND ; 
              when 16#1F# =>
                Last := CARRIER_EXTEND_ERROR ; 
              when others =>
                Last := RESERVED ; 
            end case ; 
        end case ; 
                
        if oEn then
          GetPacket ;
        elsif oEr then 
          case to_integer(oData) is
            when 00 =>
        exit when oEn or oEr ;
      end loop ;
      
      if oEn then
        GetPacket ; 
      else
        case oData is