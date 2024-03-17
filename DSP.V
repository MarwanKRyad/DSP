module DSP (A,B,C,D,clk,CARRYIN,OPMODE,BCIN,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE,PCIN,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);
input [17:0] A,B,D;
input [47:0] C;
input clk,CARRYIN;
input [7:0] OPMODE;
input [17:0] BCIN;
input RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE;
input [47:0]PCIN ;
output [17:0]BCOUT;
output [47:0]PCOUT;
output [47:0]P;
output [35:0]M;
output CARRYOUT;
output CARRYOUTF;
/////////////////////////////////////////////////////////////////////////////////////////
parameter A0REG=0;
parameter A1REG=1;
parameter B0REG=0;
parameter B1REG=1;
parameter CREG=1;
parameter DREG=1;
parameter MREG=1;
parameter PREG=1;
parameter CARRYINREG=1;
parameter CARRYOUTREG=1;
parameter OPMODEREG=1;
parameter B_INPUT="DIRECT";
parameter CARRYINSEL="OPMODE5";
////////////////////////////////////////////////////////////////////////////////////////////
reg [17:0] A0Q,A1Q;
wire [17:0] Wa0,Wa1;
assign Wa0=A0REG?A0Q:A ;
assign Wa1=A1REG?A1Q:Wa0 ;
////////////////////////////////////////
reg [17:0] B0Q,B1Q;
wire [17:0] Wb0,Wb1,Wb;
wire [17:0] pre,w;
reg [17:0] DQ;
wire [17:0] Wd0;

assign Wb=(B_INPUT=="DIRECT")?B:BCIN;
///////////

assign pre=OPMODE[6]?(Wd0-Wb0):(Wb0+Wd0);
assign w=OPMODE[4]?pre:Wb0;
///////////
assign Wb0=B0REG?B0Q:B ; // default Wb0=B just wire 
assign Wb1=B1REG?B1Q:w ; // default Wb1=B1Q 

///////////////////////

assign Wd0=DREG?DQ:D ; // default wd0=DQ registered
/////////////////
reg [17:0] CQ;
wire [17:0] Wc0;
assign Wc0=CREG?CQ:C ; //default wc0=CQQ registered
//////////////////
wire [35:0]Wm2,Wm;
reg [35:0] MQ;
assign Wm=Wa1*Wb1;
assign Wm2=MREG?MQ:Wm ;
assign M=Wm2;
/////////////////////
wire [47:0] X,Z;
assign X=(OPMODE[1:0]==0)?0:(OPMODE[1:0]==1)?Wm2:(OPMODE[1:0]==2)?P:{6'b000000,D[11:0],A,B};
assign Z=(OPMODE[3:2]==0)?0:(OPMODE[3:2]==1)?PCIN:(OPMODE[3:2]==2)?P:Wc0;
////////////////////////////
wire carry_cascade,CIN;
reg CINQ;
assign carry_cascade=(CARRYINSEL=="OPMODE5")?OPMODE[5]:CARRYIN;
assign CIN=CARRYINREG?CINQ:carry_cascade;
////////////////////////////
wire [47:0] post;
assign post=OPMODE[7]?(Z-(X+CIN)):Z+X+CIN;
/////////////
reg [47:0] PQ;
assign P=PREG?PQ:post ;
////////////////
always @(posedge clk ) begin
	if(RSTA==1)
		begin
			A0Q<=0;
			A1Q<=0;
		end
	else if ((CEA==1)) 
		begin
			A0Q<=A;
			A1Q<=Wa0;
		end



	if(RSTD==1)
		begin
			DQ<=0;		
		end
 	else if ((CED==1)) 
		begin
			DQ<=D;
		end
	

	if ((RSTB==1)) 
		begin
			B0Q<=0;
			B1Q<=0;
		end
	else if ((CEB==1)) 
		begin
			B0Q<=Wb;
			B1Q<=w;
		end


	if ((RSTC==1)) 
		begin
			CQ<=0;
		end
	else if ((CEC==1)) 
		begin
			CQ<=C;
		end



	if ((RSTM==1)) 
		begin
			MQ<=0;
		end
	else if ((CEM==1)) 
		begin
			MQ<=Wm;
		end


	if ((RSTCARRYIN==1)) 
		begin
			CINQ<=0;
		end
	else if ((CECARRYIN==1)) 
		begin
			CINQ<=carry_cascade;
		end



	if ((RSTP==1)) 
		begin
			PQ<=0;
		end
	else if ((CEP==1)) 
		begin
			PQ<=post;
		end

end



endmodule