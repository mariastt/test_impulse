`timescale 1ns / 1ps

module stream_upsize_tb #(
    parameter T_DATA_WIDTH = 4,
    parameter T_DATA_RATIO = 2,
    parameter fifo_depth = 32
)();
     logic [3:0] num_pkts = 0;

	 logic                    clk;
	 logic                    rst_n;
	 
     logic [T_DATA_WIDTH-1:0] s_data_i;
     logic                    s_last_i;
     logic                    s_valid_i;
     logic                    s_ready_o;
     logic [T_DATA_WIDTH-1:0] m_data_o [T_DATA_RATIO-1:0];
     logic [T_DATA_RATIO-1:0] m_keep_o;
     logic                    m_last_o;
     logic                    m_valid_o;
     logic                    m_ready_i;
	 
	 stream_upsize dut (
	 .clk       (clk),
	 .rst_n     (rst_n),
	 
	 .s_data_i  (s_data_i),
	 .s_last_i  (s_last_i),
	 .s_valid_i (s_valid_i),
	 .s_ready_o (s_ready_o),
	 .m_data_o  (m_data_o),
	 .m_keep_o  (m_keep_o),
	 .m_last_o  (m_last_o),
	 .m_valid_o (m_valid_o),
	 .m_ready_i (m_ready_i)
	 );
	 
	initial clk = 0;
    always #10 clk = ~clk;
	 
    initial begin

        s_valid_i = 0;
        m_ready_i = 1;
        s_last_i = 0;
        s_data_i = '0;
		  
	    rst_n = 0; #500;
        @(posedge clk); #1;
        rst_n = 1;
		  
        repeat(20) begin
            transaction();
        end    
        #40; s_valid_i = 0;
        m_ready_i = 0;
        $finish;     
	 end
	
	 task transaction;
         @(posedge clk);
         num_pkts = $urandom_range(1,6);
         s_valid_i = 1;
         s_data_i = $urandom;
           
         if (num_pkts != 1) begin
             s_last_i = 0; 
             while (num_pkts > 1) begin
             @(posedge clk);
                 if (s_ready_o) begin  
                     s_data_i = $urandom;
                     num_pkts -= 1;
                 end else if (s_ready_o == 0) begin
                     while (s_ready_o == 0) begin
                         @(posedge s_ready_o);
                     end
                 end
                 
             end
             s_last_i = 1;
         end
         else begin 
             #1; s_last_i = 1; 
             if (s_ready_o == 0) begin 
                 while (s_ready_o == 0) begin
                 @(posedge s_ready_o);
                 end
//                 s_last_i = 0;
             end
         end
	 endtask

endmodule