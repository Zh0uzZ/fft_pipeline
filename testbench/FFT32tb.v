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

endmodule
