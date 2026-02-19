module adder(a,b,op,results , compare);

 input op;
 input [31:0]a,b; //[31]Sign ,[30:23] Exponent ,[22:0]mantissa ,
 output reg[31:0]results;

 reg [7:0]a_exp , b_exp , r_exp;
 reg [31:0]a_m, b_m, r_m,prm;
 reg [1:0] mag;
 output reg [1:0] compare;
 integer i;
 reg state;


 always @(*)
 begin
 //Decompose
 a_exp = a[30:23];
 a_m = {9'b000000001 , a[22:0]};
 b_exp = b[30:23];
 b_m = {9'b000000001 , b[22:0]};

 //Sort/Align

 if (a_exp > b_exp) begin
 mag = 0;
 compare = 0;
 b_m = b_m >> (a_exp - b_exp);

 b_exp = b_exp + (a_exp - b_exp);

end
else if (a_exp < b_exp)

begin
mag = 1;
compare = 1;
a_m = a_m >> (b_exp - a_exp);

a_exp = a_exp + (b_exp - a_exp);

end
else begin
mag = 2;
compare = 2;

if (a_m > b_m)
compare = 0;

else if (a_m < b_m)
    compare = 1;
     else
    compare = 2;
end

//Add
if((a[31]==b[31] && !op) || (a[31]!=b[31] && op))
    begin
        results[31] = a[31];
        r_m = a_m + b_m;
end
else if((a[31]!=b[31] && !op) || (a[31]==b[31] && op))
begin
if(mag==0)
begin
r_m = a_m - b_m;
results[31] = op? 1'b0 : a[31];
end
else if (mag==1)
begin
r_m = b_m - a_m;
results[31] = op? (b[31]?1'b0:1'b1) : b[31];
end
else if (mag==2)
begin
if(a_m >= b_m)
begin
r_m = a_m - b_m;
results[31] = op? 1'b0 : a[31];
end
else if (a_m < b_m)

begin
 r_m = b_m - a_m;
 results[31] = op? (b[31]?1'b0:1'b1) : b[31];
 end
 else begin r_m = b_m - a_m; results[31] = 1'b0; end
 end
 else begin r_m = b_m - a_m; results[31] = 1'b0; end
 end
 else begin r_m = b_m - a_m; results[31] = 1'b0; end

 //Normalize
 state = 1;
 i = 31;
 while (state==1)
 begin
 if(r_m[i]==1 || i == 0)
 state = 0;
 i = i-1;
 end

 r_exp = a_exp + i-22;

 if((i-22) > 0)
 prm = r_m >> $unsigned((i-22));
 else if((i-22) < 0)
 prm = r_m << $unsigned((22-i));
 else
 prm = r_m;

 //compose
 results[30:23] = r_exp;
 results[22:0] = prm[22:0];
 end

 endmodule
