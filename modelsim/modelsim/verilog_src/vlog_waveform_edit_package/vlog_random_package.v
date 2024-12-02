task random (inout integer seed, output real rndval);
	localparam NTAB  = 32;
	localparam IA = 16807;  
	localparam IM = 2147483647;  
	real AM;  
	localparam IQ = 127773;  
	localparam IR = 2836;  
	real NDIV;  
	localparam EPS  = 1.2e-7;  
	localparam RNMX = (1.0-EPS);  
	real temp;  
	integer j, k;  
	
	begin
	AM = (1.0/$itor(IM)); 
	NDIV = (1.0+($itor(IM)-1.0)/$itor(NTAB)); 
	if (seed <= 0 || global_iv[NTAB] == 0)
	begin 
		if (seed == 0)
			seed = 1;  
		else if (seed < 0)
			seed = -1 * seed;  

		j = NTAB+7;	
		while (j >= 0)
		begin
			k = seed/IQ;  
			seed = IA*(seed-k*IQ)-IR*k;  
			if (seed < 0)
				seed = seed + IM;  
			if (j < NTAB)
				global_iv[j] = seed;  
			j = j - 1;  
		end
		global_iv[NTAB] = global_iv[0];        
	end  

	k = seed/IQ;  
	seed = IA*(seed-k*IQ)-IR*k;  
	if (seed < 0)
		seed = seed + IM;  

	j = $rtoi(floor($itor(global_iv[NTAB])/$itor(NDIV)));  
	global_iv[NTAB] = global_iv[j];    
	global_iv[j] = seed;  

	temp = AM*$itor(global_iv[NTAB]);  
	if (temp > RNMX) 
		rndval = RNMX;  
	else   
		rndval = temp;  
	end
endtask    
 
task dist_poisson (inout integer seed, output real rndval, input real stddev);
	real g, em, t, mainRand;
	real sqrtOfTwo;
	real sq;
	real alxm;
	real y, temp;
	localparam PI = 3.14159265358979323846264;
	localparam PRECISION_MULTIPLIER = 100000;
	begin
		sqrtOfTwo = sqrt(2.0);
		sq = sqrtOfTwo*sqrt(stddev);
		alxm = log (stddev);
		if (stddev < 12.0) begin
			g = exp (-1.0*stddev);
			em = 0.0;
			random(seed, mainRand);
			t = mainRand;
			while (t > g)
			begin
				em = em + 1.0;
				random (seed, mainRand);
				t = t * mainRand;
			end
		end
		else begin
			g = stddev*alxm - gammln(stddev+1.0);
			t = -1.0;
			mainRand = 0.0;
			while (mainRand > t) begin
				random (seed, mainRand);
				y = tan (PI*mainRand);
				y = round (y * PRECISION_MULTIPLIER);
				y = y/PRECISION_MULTIPLIER;
				em = sq*y + stddev;
				while (em < 0.0) begin
					random (seed, mainRand);
					y = tan (PI*mainRand);
					em = sq*y + stddev;
				end
				temp = floor (em*alxm - gammln(em+1.0) - g);
				if (temp < -100.0)
					t = 0.0;
				else
					t = 0.9*(1.0 + y*y) * exp(temp);
				random (seed, mainRand);
			end
		end
	rndval = em - 2147483647.0*floor(em/2147483647.0);
	end
endtask

task dist_exponential (inout integer seed, output real rndval, input real stddev);
	real rndval01, temp, modulus;
		begin
			random (seed, rndval01);
			while (rndval01 == 0.0)
				random (seed, rndval01);
			temp = -1.0*(stddev*log(rndval01));
			modulus = -1.0*(temp - 2147483647.0*negFloor(temp/2147483647.0));
			rndval = -1.0*ceil(modulus);
		end
endtask

task dist_normal (inout integer seed, output real rndval, input real mean, input real stddev);
	localparam NTAB = 32;
	real fac, rsq, v1, v2;	
    	begin
    		if (stddev < 0.0) 
			$display ("Standurd deviation  negative or zero");
		else
		begin
			// global_iy[0] represents variable "gset"  
			// global_iv[NTAB+1] represents variable "iset" should be initialized to 0 before the procedure is called  
			if ( seed < 0 )   
				global_iv[NTAB+1] = 0;  
			if (global_iv[NTAB+1] == 0)   
			begin
				random(seed, v1);  
				random(seed, v2);  
				v1=2.0*v1 - 1.0;  
				v2=2.0*v2 - 1.0;  
				rsq = v1*v1 + v2*v2 ;  
				while ( rsq >= 1.0 || rsq == 0.0 )   
				begin
					random(seed, v1);  
					random(seed, v2);  
					v1 = 2.0*v1-1.0;  
					v2 = 2.0*v2-1.0;  
					rsq = v1*v1+v2*v2;  
				end  
				fac = sqrt(-2.0* log(rsq)/rsq);  
				global_iy[0] = v1 * fac;  
				global_iv[NTAB+1] = 1;  
				rndval = (stddev * (v2 * fac)) + mean;  
			end
			else
			begin
				global_iv[NTAB+1] = 0;  
				rndval = global_iy[0] * stddev + mean; 
			end
		end
	end
endtask
 

function real gammln (input real xx);
	real x;
	real y;
	real tmp;
	real ser;
	integer i;
	real switchElement;
	begin
		x = xx;
		y = xx;
		tmp = x + 5.5;
		ser = 1.000000000190015;
		tmp = tmp - ((x + 0.5) * log(tmp));
		for (i=0; i<=5; i=i+1) begin
			case (i)
				0: switchElement = 76.18009172947146;
				1: switchElement = -86.50532032941677;
				2: switchElement = 24.01409824083091;
				3: switchElement = -1.231739572450155;
				4: switchElement = 0.1208650973866179E-2;
				5: switchElement = -0.5395239384953E-5;
			endcase
			y = y + 1.0;
			ser = ser + switchElement/y;
		end
		gammln = (-tmp + log(2.5066282746310005*ser/x));
	end
endfunction

//pow - claulates powers for real numbers  
function real pow ( input real val, input real p);
begin  
	if (p != $itor($rtoi(p)) && val <= 0.0)
		$display ("Output for function pow is complex ");
	else if ( (p/2.0) == $itor($rtoi(p/2.0)) && val <= 0.0)   
		$display ("Output for function pow is imaginary ");  
	pow =  (exp( p * log(val) ) );    
end
endfunction
  
// isqrt - Calculates the square root of a real number in the range 0 to 2  
function real isqrt ( input real val );
	real sum, term, valpower, correction, coeff, inrangeval, factorial, i;
begin  
	if (val < 0.0)
		$display ("function sqrt called on a negative value");   
	inrangeval = val;  
	correction = 1.0;  
	while ( inrangeval >= 1.0)
	begin
		inrangeval = inrangeval / 4.0;  
		correction = correction * 2.0;  
	end
	i = 0.0;
	coeff = 1.0;  
	factorial = 1.0;  
	sum = 0.0;  
	term = 1.0;  
	valpower = 1.0;  
	while ((sum != sum+term))
	begin
		sum = sum + term;  
		coeff = coeff * (0.5-i);  
		valpower = valpower * (inrangeval-1.0);  
		factorial = factorial * (i+1.0);  
		term = coeff * valpower / factorial;  
		i = i + 1.0;  
	end
	isqrt = sum* correction;  
end
endfunction  
      
//sqrt - calculates the square root
function real sqrt ( input real val );
	real ival;
begin  
	if (val == 0.0)
		sqrt = 0.0;  
	else if (val < 1.0)
	begin
		ival = 1.0/val;  
		sqrt = (1.0/isqrt(ival));  
	end
	else  
		sqrt = (isqrt(val));  
end
endfunction  
 


// exp - Calculates the exponential of a real number  
function real exp ( input real val );
	integer intval;
	real fracval, expfracval, expintval;
	real e;  
begin  
	e = 2.718281828459045;
	intval = $rtoi(floor(val));  
	fracval = val - $itor(intval);  
	expintval = e**intval;  
	expfracval = 1.0+fracval*(1.0+0.5*fracval*(1.0+0.333334*fracval*(1.0+0.25*fracval*(1.0+0.2*fracval*(1.0+0.1666667*fracval*(1.0+0.142857*fracval))))));    
	exp = expintval*expfracval;       
end
endfunction 

// ilog - Calculates the natural logarithm of a real number larger than 0.001   
function real ilog ( input real val );
	real sum, term, valpower, correction, coeff, inrangeval, i;
	real e;  
begin  
	e = 2.718281828459045;
	if (val <= 0.0)
		$display ("function log called on negative or zero value");   
	inrangeval = val;  
	correction = 0.0;  
	while ( inrangeval >= 2.0)
	begin 
		inrangeval = inrangeval / e;  
		correction = correction + 1.0;  
	end  
	i = 2.0;  
	coeff = 1.0;  
	sum = 0.0;  
	valpower = inrangeval - 1.0;  
	term = (inrangeval - 1.0);  
	while ( sum != sum+term )
	begin
		sum = sum + term;  
		coeff = coeff * (-1.0);  
		valpower = valpower * (inrangeval-1.0);  
		term = coeff * valpower / i;  
		i = i + 1.0;  
	end  
	ilog = (sum+correction);  
end
endfunction


//log - calculates the natural logarithm for any real number  
function real log ( input real val );
	real v;
begin  
	if (val < 0.001 )
	begin
		v = val * 1.0e6;  
		log =  (ilog(v) - ilog(1.0e6));  
	end
	else  
		log = ilog(val);
end
endfunction

// negFloor - simple floor does not work with negative numbers. This one does.
function real negFloor (input real val);
	integer y;
	real posVal;
	real posFloor;
begin
	if (val >= 0.0)
		negFloor = floor(val);
	else
	begin
		posVal = -1.0*val;
		posFloor = floor (posVal);
		if (posFloor == posVal)
			negFloor = val;
		else
			negFloor = -1.0 *(posFloor - 1);
	end
end
endfunction
  
// floor - Calculates the largest integral value less than or equal to a real number  
function real floor ( input real val );
	integer y;
begin  
	y = $rtoi(val);
	if ($itor(y) == val)
		floor = $itor(y);  
	else if ($itor(y) > val)
		floor =  $itor(y-1);  
	else  
		floor =  $itor(y);  
end
endfunction

function real round (input real x);
begin
	if (x < 0.0) begin
		round = -1.0*floor(-1.0*x+0.5);
	end
	else begin
		round = floor(x+0.5);
	end
end
endfunction
  
// ceil - Calculates the smallest integral value greater than or equal to a real number  
function real ceil ( input real val );
	integer y;  
	real q, q_int, q_rem;
	real maxInt;
	real bigValue, smallValue;
begin 
	maxInt = 2147483647.0;
	q = val/maxInt;
	q_int = floor(q);
	q_rem = q - q_int;
	bigValue = q_int*maxInt;
	smallValue = q_rem*maxInt;
	y = $rtoi(smallValue);  
	if ($itor(y) == smallValue)
		ceil = $itor(y) + bigValue;  
	else if ($itor(y) < smallValue)
		ceil = $itor(y+1) + bigValue;  
	else  
		ceil = $itor(y) + bigValue;
end
endfunction

//myceil - Calculates the smallest integral value greater than or equal to a real number
function real myceil ( input real val, input integer width);
	integer max_rand;
	real abs_val;
begin
	if (width > 31)
		max_rand = 2147483647;
	else
		max_rand =  $rtoi(pow(2.0, $itor(width)) - 1.000);
	if (val < 0.0) 
		abs_val = val * -1;
	else 
		abs_val = val;

	if (width < 30) 
		myceil = ceil(val);
	else if (abs_val >= $itor(max_rand))
		myceil = $itor(max_rand);
	else 
		myceil = ceil(val);
end
endfunction

function real sin (input real x);
	real op, termNo, oneTerm;
	integer minusFlag, i;
	real x2;
	real plusMinusOne;
	localparam PI = 3.14159265358979323846264;
begin
	minusFlag = 0;
	x2 = x;
	plusMinusOne = 1.0;
	// bring 'x' between 0 and PI
	while (x2 < 0.0)
		x2 = x2 + 2.0*PI;

	if (x2 > PI) begin
		x2 = x2 - PI;
		minusFlag = 1;
	end

	// 'x' is now between 0 and PI.
	// handle special values like 0, PI/2 and PI
	if (x2 == 0.0 || x2 == PI)
		sin = 0.0;
	else if (x2 == PI/2.0) begin
		if (minusFlag == 1)
			sin = -1.0;
		else 
			sin = 1.0;
	end
	else begin
    	// series is :-
	    // sin (x) = x - x^3/3! + x^5/5! ...
		op = x2;
		oneTerm = x2;
		termNo = 1;
		plusMinusOne = -1.0;
		while (oneTerm > 0.00000001) begin
		   oneTerm = x2;
		   termNo = termNo + 2;
		   for (i=2; i<=termNo; i=i+1)
		      oneTerm = oneTerm*x2/$itor(i);
   		   op = op + plusMinusOne*oneTerm;
   		   plusMinusOne = -1.0*plusMinusOne;
		end
 
		if (minusFlag == 1)
			op = -1.0*op;
		sin = op;
	end
end
endfunction


function real cos (input real x);
	real op;
	real sinx;
	integer minusFlag;
	real x2;
	localparam PI = 3.14159265358979323846264;
begin
	minusFlag = 0;
	x2 = x;
	// bring 'x' between -PI/2 and PI/2
	while (x2 < (-1.0*PI/2.0))
		x2 = x2 + 2.0*PI;
	if (x2 > (PI/2.0)) begin
		x2 = x2 - PI;
		minusFlag = 1;
	end
	// 'x' is now between -PI/2 and PI/2

	// handle special values like -PI/2, 0 and PI/2
	if (x2 == 0.0) begin
		if (minusFlag == 1)  
			cos = -1.0;
		else 
			cos = 1.0;
	end
	else if (x2 == PI/2.0 || x2 == (-1.0*PI/2.0))  
		cos = 0.0;
	else begin
		// main algo for cos(x).
		// use cos = sqrt(1 - sin*sin)
		sinx = sin(x2);
		op = sqrt(1.0 - sinx*sinx);
		if (minusFlag == 1) 
			op = -1.0*op;
		cos = op;
	end
end
endfunction


function real tan (input real x); 
	real op ;
	real bigOp;
	real sinx ;
	real cosx ;
	localparam PRECISION_MULTIPLIER = 100000.0;
	localparam PI = 3.14159265358979323846264;
begin
	sinx = sin(x);
	cosx = cos(x); 
	if (cosx == 0.0) begin
		$display("tan(PI/2) is infinity");
		tan = 2147483647;
	end
	else begin
		op = sin(x)/cos(x);
		/*
		bigOp = PRECISION_MULTIPLIER*op;
		bigOp = $itor($rtoi(bigOp)); 
		op = bigOp/PRECISION_MULTIPLIER;
		*/
		tan = op;
	end
end
endfunction
