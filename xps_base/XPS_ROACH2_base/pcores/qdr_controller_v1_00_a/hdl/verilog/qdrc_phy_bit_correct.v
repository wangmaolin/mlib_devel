module qdrc_phy_bit_correct(
    clk0,
    clk270,
    reset,

    aligned,

    qdr_q_rise, //180 clock domain
    qdr_q_fall,
    qdr_q_rise_cal,
    qdr_q_fall_cal
  );
  input  clk0, clk270, reset;
  input  aligned;
  input  qdr_q_rise, qdr_q_fall;
  output qdr_q_rise_cal, qdr_q_fall_cal;

  (* shreg_extract = "NO" *) reg [1:0] data_buffer2;
  (* shreg_extract = "NO" *) reg [1:0] data_buffer1;
  (* shreg_extract = "NO" *) reg [1:0] data_buffer0;
  reg [1:0] data_reg;

  always @(posedge clk0) begin
    data_reg    <= {qdr_q_rise, qdr_q_fall};
    data_buffer0 <= data_reg;
    data_buffer1 <= data_buffer0;
    data_buffer2 <= data_buffer1;
  end

  assign qdr_q_rise_cal = aligned ? data_buffer2[1] : data_buffer2[0];
  assign qdr_q_fall_cal = aligned ? data_buffer2[0] : data_buffer1[1];

endmodule
