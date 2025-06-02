module Semaphore #(
    parameter CLK_FREQ = 100_000_000
) (
    input wire clk,
    input wire rst_n,

    input wire pedestrian,

    output wire green,
    output wire yellow,
    output wire red
);

    // definindo os estados
    localparam [2:0] RED    = 3'b100,
       				 YELLOW = 3'b010,
        		     GREEN  = 3'b001;

    // definindo o tempo para cada sinal
    localparam integer RED_TIME     = CLK_FREQ * 5, // tempo sinal vermelho = 5 s
                       GREEN_TIME   = CLK_FREQ * 7, // tempo sinal verde = 7 s
                       YELLOW_TIME  = CLK_FREQ / 2; // tempo sinal amarelo = 0.5 s

    // definindo os registradores internos
    reg [2:0] estado, proximo_estado;
    reg [31:0] contador;

	// definindo a máquina de estados sequencial    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            estado <= RED;
            contador <= 32'd0;
        end else begin
			estado <= proximo_estado;
			contador <= (estado != proximo_estado) ? 32'd0 : contador + 1;
        end
    end

    // definindo a lógica da transição de estados
    always @(*) begin
        case (estado)
            RED    : proximo_estado = (contador >= RED_TIME - 1) ? GREEN : RED;
            GREEN  : proximo_estado = (pedestrian ^ (contador >= GREEN_TIME - 1)) ? YELLOW : GREEN;
			YELLOW : proximo_estado = (contador >= YELLOW_TIME - 1) ? RED : YELLOW;
            default: proximo_estado = RED;
        endcase
    end

    // definindo as saídas de sinal
    assign red    = (estado == RED);
    assign green  = (estado == GREEN);
    assign yellow = (estado == YELLOW);

endmodule
