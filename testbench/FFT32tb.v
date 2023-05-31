`include "parameter.vh"
module FFT32tb;
  `FFTsfpw
  reg CLK,RST,START;
  reg [nb-1:0] DR,DI;
  wire [nb-1:0] OR,OI;

  initial begin
    CLK = 0;
    RST = 1;
    START = 0;
    forever #5 CLK = ~CLK;
  end
  initial begin
    #13 RST = 0;
    #23 RST = 1;
  end

//read data from data txt
  integer hand_input;
  reg [`formatSFP-1:0] input_data[0:1000];
  initial begin
    hand_input = $fopen("out.txt" , "r");
    for(integer j=0;j<400;j=j+1) begin
      $fscanf(hand_input , "%0d" , input_data[j]);
    end
    $fclose(hand_input);
    // $readmemh("out.txt" , input_data);
  end


  reg [8:0] count;
  always @(posedge CLK or negedge RST) begin
    if(~RST) begin count <= 9'h1ff; end
    else begin
        if(count == 9'h1ff) begin
            START <= 1;
            count <= 0;
        end else if (0<=count && count <32)begin
            START <= 0;
            count <= count + 1;
            DR <= input_data[count];
            DI <= input_data[count+32];
        end else if (32<=count && count<64) begin
            START <= 0;
            count <= count + 1;
            DR <= input_data[count+32];
            DI <= input_data[count+64];
        end else if (64<=count && count<96) begin
            START <= 0;
            count <= count + 1;
            DR <= input_data[count+64];
            DI <= input_data[count+96];
        end
    end
  end


  FFT32 U_FFT(
    .CLK(CLK),
    .RST(RST),
    .START(START),
    .DR(DR),
    .DI(DI),
    .OR(OR),
    .OI(OI)
  );

  reg start_mdc;
  always@(posedge CLK) begin
    start_mdc <= START;
  end
  reg [nb*4-1:0] DR4,DI4;
  wire [nb*4-1:0] OR4,OI4;
  wire [8:0] count_mdc;
  assign count_mdc = count%24;
  always @(posedge CLK or negedge RST) begin
      if (0<=count_mdc && count_mdc <8) begin
          DR4 <= {input_data[count_mdc] , input_data[count_mdc+8],input_data[count_mdc+16],input_data[count_mdc+24]};
          DI4 <= {input_data[count_mdc+32] , input_data[count_mdc+32+8] , input_data[count_mdc+32+16] , input_data[count_mdc+32+24]};

          dr_i <= {{input_data[count_mdc]}    , {input_data[count_mdc+8]   } , {input_data[count_mdc+16]   } , {input_data[count_mdc+24]   } };
          di_i <= {{input_data[count_mdc+32]} , {input_data[count_mdc+32+8]} , {input_data[count_mdc+32+16]} , {input_data[count_mdc+32+24]} };
      end else if (8<=count_mdc && count_mdc<16) begin
          DR4 <= {input_data[count_mdc+56]    , input_data[count_mdc+56+8]    , input_data[count_mdc+56+16]    , input_data[count_mdc+56+24]    };
          DI4 <= {input_data[count_mdc+56+32] , input_data[count_mdc+56+32+8] , input_data[count_mdc+56+32+16] , input_data[count_mdc+56+32+24] };

          dr_i <= {{input_data[count_mdc+56]   } , {input_data[count_mdc+56+8]   } , {input_data[count_mdc+56+16]   } , {input_data[count_mdc+56+24]    }};
          di_i <= {{input_data[count_mdc+56+32]} , {input_data[count_mdc+56+32+8]} , {input_data[count_mdc+56+32+16]} , {input_data[count_mdc+56+32+24] }};
      end else if (16<=count_mdc && count_mdc<24) begin
          DR4 <= {input_data[count_mdc+112]    , input_data[count_mdc+112+8]    , input_data[count_mdc+112+16]    , input_data[count_mdc+112+24]    };
          DI4 <= {input_data[count_mdc+112+32] , input_data[count_mdc+112+32+8] , input_data[count_mdc+112+32+16] , input_data[count_mdc+112+32+24] };

          dr_i <= {{input_data[count_mdc+112]   } , {input_data[count_mdc+112+8]   } , {input_data[count_mdc+112+16]   } , {input_data[count_mdc+112+24]   } };
          di_i <= {{input_data[count_mdc+112+32]} , {input_data[count_mdc+112+32+8]} , {input_data[count_mdc+112+32+16]} , {input_data[count_mdc+112+32+24]} };
      end
  end
parameter type sfp_t = logic [nb-1:0];
sfp_t [3:0] dr_i ;
sfp_t [3:0] di_i ;
sfp_t [3:0] dr_o ;
sfp_t [3:0] di_o ;
logic rdy_mdc_o;
  R4MDC u_R4MDC(
    .clk_i(CLK),
    .rst_ni(RST),
    .start_mdc_i(START),
    .dr_mdc_i(dr_i),
    .di_mdc_i(di_i),
    .dr_mdc_o(dr_o),
    .di_mdc_o(di_o),
    .rdy_mdc_o
  );


//   reg [2:0] remap_data;
//   wire [nb-1:0] remap_output;
//   reg remap_start;
//   initial begin
//     remap_data = 0;
//     remap_start = 0;
//     #100 remap_start = 1;
//     #10 remap_start = 0; remap_data = 0;
//   end
//   always@(posedge CLK) remap_data <= remap_data + 1;
//   serial_remap u_serial_remap(
//     .clk(CLK),
//     .reset_n(RST),
//     .start(remap_start),
//     .input_data({6'b000000 , remap_data}),
//     .output_data(remap_output)
//   );

endmodule
