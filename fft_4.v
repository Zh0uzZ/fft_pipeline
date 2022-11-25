
module fft_4#(parameter expWidth = 3,parameter sigWidth = 3,parameter FormatWidth = 6)(
    input clk,
    input rst,
    input start,
    input [2*FormatWidth:0] x [3:0],
    output [2*FormatWidth:0] y [3:0]
);
    
    reg  [(FormatWidth - 1):0] a;
    reg  [(FormatWidth - 1):0] b;
    wire [(FormatWidth - 1):0] c;
    wire [FormatWidth:0]       rec_a;
    wire [FormatWidth:0]       rec_b;
    wire [FormatWidth:0]       rec_c;
    wire                       out_valid_o;
    wire [4:0]                 excp_flags_o;

    reg [FormatWidth : 0] temp [3:0];



    parameter            IDLE   = 3'd0 ;
    parameter            GET05  = 3'd1 ;
    parameter            GET10  = 3'd2 ;
    parameter            GET15  = 3'd3 ;

    //machine variable
    reg [2:0]            st_next ;
    reg [2:0]            st_cur ;

    //(1) state transfer
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            st_cur      <= 'b0 ;
        end
        else begin
            st_cur      <= st_next ;
        end
    end

    //(2) state switch, using block assignment for combination-logic
    //all case items need to be displayed completely    
    always @(*) begin
        //st_next = st_cur ;//如果条件选项考虑不全，可以赋初值消除latch
        case(st_cur)
            IDLE:
                case (coin)
                    2'b01:     st_next = GET05 ;
                    2'b10:     st_next = GET10 ;
                    default:   st_next = IDLE ;
                endcase
            GET05:
                case (coin)
                    2'b01:     st_next = GET10 ;
                    2'b10:     st_next = GET15 ;
                    default:   st_next = GET05 ;
                endcase

            GET10:
                case (coin)
                    2'b01:     st_next = GET15 ;
                    2'b10:     st_next = IDLE ;
                    default:   st_next = GET10 ;
                endcase
            GET15:
                case (coin)
                    2'b01,2'b10:
                               st_next = IDLE ;
                    default:   st_next = GET15 ;
                endcase
            default:    st_next = IDLE ;
        endcase
    end

    always @(posedge clk or negedge rst) begin
        if(!rst) begin

        end else begin

        end
    end


    addRecFN #(
        .expWidth(ExpWidth),
        .sigWidth(SigWidth)
    ) addRecFN_uut(
        // .control(),
        .subOp(1'b0),
        .a(rec_a),
        .b(rec_b),
        .roundingMode(3'b000),
        .out(rec_c),
        .exceptionFlags(excp_flags_o)
    );

    fNToRecFN #(
        .expWidth(ExpWidth),
        .sigWidth(SigWidth)
    ) a_fNToRecFN_uut (
        .in(a),
        .out(rec_a)
    );

    fNToRecFN #(
        .expWidth(ExpWidth),
        .sigWidth(SigWidth)
    ) b_fNToRecFN_uut (
        .in(b),
        .out(rec_b)
    );

    recFNToFN #(
        .expWidth(ExpWidth),
        .sigWidth(SigWidth)
    ) c_recFNToFN_uut (
        .in(rec_c),
        .out(c)
    );

endmodule
