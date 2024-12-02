LIBRARY IEEE;   
USE ieee.std_logic_1164.ALL;  
USE ieee.std_logic_arith.ALL;  
USE ieee.std_logic_unsigned.ALL;  
USE std.textio.all  ;
  
PACKAGE random_generators IS  
  
   constant NTAB : integer := 32;  
   constant PRECISION_MULTIPLIER : real := 100000.0;
   constant  MATH_E :   real := 2.71828_18284_59045_23536;
   constant maxIntLimit : integer := 2147483647;
   type genstatus1 is array (0 to NTAB+1) of integer;  
   type genstatus2 is array (0 to 3) of real;  
   type cof1 is array (0 to 5) of real;
--   constant PI : real := 3.141592654;  
   constant PI : real :=   3.14159265358979323846264;
-- Mathematical functions needed to perform the random number generation  
    FUNCTION sqrt   ( val : REAL ) RETURN  real;  
    FUNCTION isqrt  ( val : REAL ) RETURN  real;  
    FUNCTION exp    ( val : REAL ) RETURN  real;  
    FUNCTION log    ( val : REAL ) RETURN  real;  
    FUNCTION ilog   ( val : REAL ) RETURN  real;  
    FUNCTION floor  ( val : REAL ) RETURN  real;  
    FUNCTION ceil   ( val : REAL ) RETURN  real;  
    FUNCTION myceil ( val : REAL; width : INTEGER)   RETURN  real;
    FUNCTION pow    ( val : REAL ; p : REAL) RETURN real;  
    FUNCTION pow    ( val : REAL ; p : integer) RETURN real;  
    FUNCTION pow    ( val : integer ; p : integer) RETURN real;  
    FUNCTION pow    ( val : integer ; p : REAL) RETURN real;  
    FUNCTION tan    (x : real) RETURN real;
    FUNCTION sin    (x : real) RETURN real;
    FUNCTION cos    (x : real) RETURN real;
    FUNCTION factorial  (x : integer) RETURN real;
    FUNCTION gammln (xx : real) RETURN real;
  
-- Random number generation functions  
    PROCEDURE random ( variable seed : inout INTEGER; variable rndval : out REAL; variable iv : inout genstatus1);  
  
    PROCEDURE dist_normal (variable seed : inout INTEGER; variable rndval : out REAL; mean : REAL; stddev : REAL; variable iv : inout genstatus1; variable iy : inout genstatus2 );  

  
    PROCEDURE dist_normal (variable seed : inout INTEGER; variable rndval : out INTEGER; mean : REAL; stddev : REAL; variable iv : inout genstatus1; variable iy : inout genstatus2 );  
  
    PROCEDURE dist_uniform (variable seed : inout INTEGER; variable rndval : out INTEGER; startpoint : REAL; endpoint : REAL; variable iv : inout genstatus1 );  

	PROCEDURE dist_exponential (variable seed : inout INTEGER; variable rndval : out REAL; endpoint : REAL; variable iv : inout genstatus1);

	PROCEDURE dist_poisson (variable seed : inout INTEGER; variable rndval : out REAL; max_rand : REAL; variable iv : inout genstatus1);
  
END random_generators;  
  
  
LIBRARY ieee;  
USE ieee.std_logic_1164.ALL;  
  
PACKAGE BODY random_generators IS  
  
-- Mathematical functions needed to perform the random number generation  

    -- expects 'x' in the range -PI/2 to PI/2
	FUNCTION factorial (x : integer) RETURN real IS
        variable realx : real := real(x);
		variable op: real := 1.0;
	BEGIN
        
		if (realx = 0.0) then
			return 1.0;
		end if;
		while (realx > 1.0) loop
			op := op*realx;
			realx := realx - 1.0;
		end loop;
		return op;
	END;


	FUNCTION sin (x : real) RETURN real IS
		variable op: real;
		variable minusFlag : integer := 0;
		variable x2 : real := x;
		variable plusMinusOne : real := 1.0;
		variable termNo : integer;
		variable oneTerm : real;
	BEGIN
		-- bring 'x' between 0 and PI
		while (x2 < 0.0) loop
			x2 := x2 + 2.0*PI;
		end loop;
		if (x2 > PI) then
			x2 := x2 - PI;
			minusFlag := 1;
		end if;
		-- 'x' is now between 0 and PI.

		-- handle special values like 0, PI/2 and PI
		if (x2 = 0.0 or x2 = PI) then
			return 0.0;
		end if;
		if (x2 = PI/2.0) then
			if (minusFlag = 1) then 
				return -1.0;
			else 
				return 1.0;
			end if;
		end if;

      -- series is :-
      -- sin (x) = x - x^3/3! + x^5/5! ...
		op := x2;
		oneTerm := x2;
		termNo := 1;
		plusMinusOne := -1.0;
		while (oneTerm > 0.00000001) loop
		   oneTerm := x2;
		   termNo := termNo + 2;
		   for i in 2 to termNo loop
		      oneTerm := oneTerm*x2/real(i);
   		   end loop;
   		   op := op + plusMinusOne*oneTerm;
   		   plusMinusOne := -1.0*plusMinusOne;
	   end loop;
	 
		if (minusFlag = 1) then
			op := -1.0*op;
		end if;
		return op;
	END;


	FUNCTION cos (x : real) RETURN real IS
		variable op: real;
		variable sinx: real;
		variable minusFlag : integer := 0;
		variable x2 : real := x;
	BEGIN
		-- bring 'x' between -PI/2 and PI/2
		while (x2 < (-1.0*PI/2.0)) loop
			x2 := x2 + 2.0*PI;
		end loop;
		if (x2 > (PI/2.0)) then
			x2 := x2 - PI;
			minusFlag := 1;
		end if;
		-- 'x' is now between -PI/2 and PI/2
	
		-- handle special values like -PI/2, 0 and PI/2
		if (x2 = 0.0) then
			if (minusFlag = 1) then 
				return -1.0;
			else 
				return 1.0;
			end if;
		end if;
		if (x2 = PI/2.0 or x2 = (-1.0*PI/2.0)) then 
			return 0.0;
		end if;

		-- main algo for cos(x).
		-- use cos = sqrt(1 - sin*sin)
		sinx := sin(x2);
		op := sqrt(1.0 - sinx*sinx);
		if (minusFlag = 1) then
			op := -1.0*op;
		end if;
		return op;
	END;


	FUNCTION tan (x : real) RETURN real IS
		variable op: real;
		variable bigop: real;
		variable sinx : real;
		variable cosx : real;
	BEGIN
		sinx := sin(x);
		cosx := cos(x);
		assert (cosx /= 0.0) report "tan(PI/2) is infinity" severity FAILURE;
		op := sin(x)/cos(x);
		bigOp := PRECISION_MULTIPLIER*op;
		bigOp := real(integer(bigOp)); 
		op := bigOp/PRECISION_MULTIPLIER;
		return op;
	END;

    FUNCTION pow ( val : REAL ; p : integer) RETURN real is  
    BEGIN 
		return pow(val, real(p)); 
	END;
    FUNCTION pow ( val : integer ; p : REAL) RETURN real is  
    BEGIN  
		return pow(real(val), p); 
	END;
    FUNCTION pow ( val : integer ; p : integer) RETURN real is  
    BEGIN  
		return pow(real(val), real(p)); 
	END;

    --pow - claulates powers for real numbers  
    FUNCTION pow ( val : REAL ; p : REAL) RETURN real is  
    BEGIN  
         if  not( p = real(integer(p)) ) then  
            assert (val>0.0) report "Output for function pow is complex " severity FAILURE;   
         elsif ( (p/2.0) = real(integer(p/2.0)) ) then  
            assert (val>0.0) report "Output for function pow is imaginary " severity FAILURE;  
         end if;      
    RETURN (exp( p * log(val) ) );    
    END;  
  
    -- isqrt - Calculates the square root of a real number in the range 0 to 2  
    FUNCTION isqrt ( val : REAL ) RETURN  real IS  
       variable sum, term, valpower, correction, coeff, inrangeval, factorial, i: real;  
    BEGIN  
        assert (val>=0.0) report "Function sqrt called on a negative value" severity FAILURE;   
        inrangeval := val;  
        correction := 1.0;  
        while ( inrangeval >= 1.0) loop  
             inrangeval := inrangeval / 4.0;  
             correction := correction * 2.0;  
        end loop;         
        i := 0.0;  
        coeff := 1.0;  
        factorial := 1.0;  
        sum := 0.0;  
        term := 1.0;  
        valpower := 1.0;  
        while ((sum /= sum+term)) loop  
             sum := sum + term;  
             coeff := coeff * (0.5-i);  
             valpower := valpower * (inrangeval-1.0);  
             factorial := factorial * (i+1.0);  
             term := coeff * valpower / factorial;  
             i := i + 1.0;  
         end loop;  
         RETURN (sum* correction);  
    END isqrt;  
      
    --sqrt - calculates the square root of any   
    FUNCTION sqrt ( val : REAL ) RETURN real is  
       variable ival: real;  
             
    BEGIN  
       if val=0.0 then  
    RETURN 0.0;  
        elsif (val <1.0) then  
        ival :=1.0/val;  
    RETURN (1.0/isqrt(ival));  
        else  
        RETURN (isqrt(val));  
        end if;  
   END sqrt;  

    function exp  (val : real ) return real is
    	-- returns e**val; where e = MATH_E
  	--
  	-- This function computes the exponential using the following series:
  	--    exp(val) = 1 + val + val**2/2! + val**3/3! + ... ; val > 0
  	--
	constant eps : real := 0.000001;	-- precision criteria

    	variable reciprocal: boolean := val < 0.0;-- check sign of argument
    	variable xlocal : real := abs(val);       -- use positive value
    	variable oldval: real ;			-- following variables are
    	variable num: real ;			-- used for series evaluation
    	variable count: integer ;
    	variable denom: real ;
    	variable newval: real ;

     begin
    	-- compute value for special cases
	if val = 0.0 then
		return 1.0;
	else
		if  val = 1.0  then
			return MATH_E;
		end if;
	end if;

    	-- compute value for general cases
    	oldval := 1.0;
    	num := xlocal;
    	count := 1;
    	denom := 1.0;
    	newval:= oldval + num/denom;

    	while ( abs(newval - oldval) > eps ) loop
		oldval := newval;
		num := num*xlocal;
        	count := count +1;
		denom := denom*(real(count));
        	newval := oldval + num/denom;
    	end loop;

    	if reciprocal then
        	newval := 1.0/newval;
    	end if;

    	return newval;
     end exp;

  
    -- ilog - Calculates the natural logarithm of a real number larger than 0.001   
    FUNCTION ilog ( val : REAL )   RETURN  real IS  
       variable sum, term, valpower, correction, coeff, inrangeval, i: real;  
       constant e : real := 2.718281828459045;  
    BEGIN  
       assert (val>0.0) report "Function log called on negative or zero value" severity FAILURE;   
       inrangeval := val;  
       correction := 0.0;  
       while ( inrangeval >= 2.0 ) loop  
            inrangeval := inrangeval / e;  
            correction := correction + 1.0;  
       end loop;  
       i := 2.0;  
       coeff := 1.0;  
       sum := 0.0;  
       valpower := inrangeval-1.0;  
       term := (inrangeval-1.0);  
       while ( sum /= sum+term ) loop  
            sum := sum + term;  
            coeff := coeff * (-1.0);  
            valpower := valpower * (inrangeval-1.0);  
            term := coeff * valpower / i;  
            i := i + 1.0;  
       end loop;  
       RETURN (sum+correction);  
    END ilog;  
     
    --log - calculates the natural logarithm for any real number  
      
    FUNCTION log ( val : REAL )   RETURN  real IS  
       variable v : real;         
    BEGIN  
       if (val < 0.001 ) then   
           v := val * 1.0e6;  
    RETURN (ilog(v) - ilog(1.0e6));  
       else  
    RETURN ilog(val);  
       end if;  
    END log;  
  
    -- floor - Calculates the largest integral value less than or equal to a real number  
    FUNCTION floor ( val : REAL )   RETURN  real IS  
        variable y : integer;
		variable realVal : real := val;
		variable count : real := 0.0;
    BEGIN
		count := val/real(maxIntLimit); 
		count := real(integer(count));
		realVal := val - count*real(maxIntLimit);
		y := integer(realVal);
        if real(y)>realVal then  
            realVal := real(y-1);  
        else  
            realVal :=  real(y);  
        end if;
		return count*real(maxIntLimit) + realVal;
    END floor;  
  
    -- ceil - Calculates the smallest integral value greater than or equal to a real number  
    FUNCTION ceil ( val : REAL )   RETURN  real IS  
       variable y : integer;  
    BEGIN  
        y := integer(val);  
        if real(y)=val then  
            RETURN real(y);  
        elsif real(y)<val then  
            RETURN real(y+1);  
        else  
            RETURN real(y);  
        end if;  
    END ceil;  

    -- myceil - Calculates the smallest integral value greater than or equal to a real number  
    FUNCTION myceil ( val : REAL; width : INTEGER)   RETURN  real IS  
       variable max_rand : integer;  
       variable ceil_val : real;  
    BEGIN  
	if width > 31 then	
		max_rand := maxIntLimit;
	else 
       	max_rand := integer(pow(2.0, real(width)) - 1.0);
	end if;

	ceil_val := ceil(val);
	if width < 30 then
		RETURN ceil_val;
	elsif abs(ceil_val) >= real(max_rand) then
		RETURN real(max_rand);
	else
		 RETURN ceil_val;

--	if width = 1 then
--		RETURN  ceil (val);
--	elsif abs(ceil_val) >= real(max_rand) then
--		RETURN real(max_rand);
--	else
--		RETURN ceil_val;
	end if;
    END myceil;  
  
-- Random number generation functions  
  
    -- random - Returns a uniform number value between 0.0 and 1.0  
    -- VHDL implementation of Park and Miller with Pays-Durham shuffle and added safeguards  
    -- Reference Numerical Recipes In C book, Chapter 7, page 280  
  
    PROCEDURE random ( variable seed : inout INTEGER; variable rndval : out REAL; variable iv : inout genstatus1) IS  
       constant IA : integer := 16807;  
       constant IM : integer := maxIntLimit;  
       constant AM : real := (1.0/real(IM));  
       constant IQ : integer := 127773;  
       constant IR : integer := 2836;  
       constant NTAB : integer := 32;  
       constant NDIV : real := (1.0+(real(IM)-1.0)/real(NTAB));  
       constant EPS  : real := 1.2e-7;  
       constant RNMX : real := (1.0-EPS);  
       variable temp : real;  
       variable j, k : integer;  
    BEGIN  
       if (seed <= 0 or iv(NTAB) = 0) then  
  
          if (seed = 0) then  
               seed := 1;  
          elsif (seed < 0) then  
               seed := -1 * seed;  
          end if;  
  
          j := NTAB+7;        
          while (j >= 0) loop  
              k := seed/IQ;  
              seed := IA*(seed-k*IQ)-IR*k;  
              if (seed < 0) then   
                  seed := seed + IM;  
              end if;        
              if (j < NTAB) then   
                  iv(j) := seed;  
              end if;  
          j := j - 1;  
          end loop;  
          iv(NTAB) := iv(0);        
       end if;  
  
       k := seed/IQ;  
       seed := IA*(seed-k*IQ)-IR*k;  
       if (seed < 0) then  
           seed := seed + IM;  
       end if;  
       j := integer(floor(real(iv(NTAB))/real(NDIV)));  
       iv(NTAB) := iv(j);    
       iv(j) := seed;  
       temp := AM*real(iv(NTAB));  
       if (temp > RNMX) then   
           rndval := RNMX;  
       else   
           rndval := temp;  
       end if;        
  
    END random;  
  
    -- dist_uniform - Returns a uniform number value between start and end  
  
    PROCEDURE dist_uniform (variable seed : inout INTEGER; variable rndval : out INTEGER; startpoint : REAL; endpoint : REAL; variable iv : inout genstatus1 ) IS  
       variable rndval01 : real;        
    BEGIN  
  
       random(seed, rndval01, iv);  
       rndval := integer(startpoint + (endpoint-startpoint)*rndval01);  
  
    END dist_uniform;  
  
     -- dist_normal - Returns a random number with normal (Gaussian) distribution  
     -- Reference Numerical Recipes In C  book, Chapter 7, page 289  
  
    PROCEDURE dist_normal (variable seed : inout INTEGER; variable rndval : out INTEGER; mean : REAL; stddev : REAL; variable iv : inout genstatus1; variable iy : inout genstatus2 ) IS  
       variable rand : real;        
    BEGIN  
         assert (stddev>0.0) report "Standurd deviation is negative or zero" severity FAILURE;  
         dist_normal ( seed , rand , mean , stddev , iv , iy );  
         rndval := integer(rand);      
  
    END dist_normal;  
  
  
    PROCEDURE dist_normal (variable seed : inout INTEGER; variable rndval : out REAL; mean : REAL; stddev : REAL; variable iv : inout genstatus1; variable iy : inout genstatus2 ) IS  
       variable fac, rsq, v1, v2 : real;        
    BEGIN  
    assert (stddev>0.0) report "Standurd deviation is negative or zero" severity FAILURE;  
  
-- iy(0) represents variable "gset"  
-- iv(NTAB+1) represents variable "iset" should be initialized to 0 before this procedure is called  
  
       if ( seed < 0 ) then  
          iv(NTAB+1) := 0;  
       end if;  
       if ( iv(NTAB+1) = 0 ) then  
            random(seed, v1, iv);  
            random(seed, v2, iv);  
            v1:=2.0*v1 - 1.0;  
            v2:=2.0*v2 - 1.0;  
            rsq := v1*v1 + v2*v2 ;  
            while ( rsq >= 1.0 or rsq = 0.0 ) loop  
                 random(seed, v1, iv);  
                 random(seed, v2, iv);  
                 v1:=2.0*v1-1.0;  
                 v2:=2.0*v2-1.0;  
                 rsq := v1*v1+v2*v2;  
            end loop;  
            fac := sqrt(-2.0*log(rsq)/rsq);  
            iy(0) := v1 * fac;  
            iv(NTAB+1) := 1;  
            rndval := (v2 * fac) * stddev + mean;  
       else  
            iv(NTAB+1) := 0;  
            rndval := iy(0) * stddev + mean;              
       end if;  
         
    END dist_normal;  

    PROCEDURE dist_exponential (variable seed : inout INTEGER; variable rndval : out REAL; endpoint : REAL; variable iv : inout genstatus1 ) IS
       variable rndval01 : real;
       variable temp : real;
       variable modulus : real;
    BEGIN

       random(seed, rndval01, iv);
       while (rndval01 = 0.0) loop
           random(seed, rndval01, iv);
       end loop;
       temp := -1.0*(endpoint * log(rndval01)) ;
       modulus := -1.0*(temp - real(maxIntLimit)*real(integer(floor(temp/real(maxIntLimit)))));
       rndval := (-1.0 *ceil(modulus));

    END dist_exponential;


    PROCEDURE dist_poisson (variable seed : inout INTEGER; variable rndval : out REAL;	max_rand : REAL; variable iv : inout genstatus1 ) IS
	variable g : real ;
	variable em : real ;
	variable t : real ;
	variable mainRand : real;
	-- following are required for max_rand < 12.0
	variable sqrtOfTwo :real := sqrt(2.0);
	variable sq : real := sqrtOfTwo*sqrt(max_rand);
	variable alxm : real := log(max_rand);
	variable y : real;
	variable temp : real;
	Begin
		if (max_rand < 12.0) then
			g := exp(-1.0*max_rand);
			em := 0.0;
			random (seed, mainRand, iv);
			t := mainRand;
			while (t > g) loop
				em := em + 1.0;
				random (seed, mainRand, iv);
				t := t * mainRand;
			end loop;
		else
			g := max_rand*alxm - gammln(max_rand+1.0);

			t := -1.0;
			mainRand := 0.0;
			while (mainRand > t) loop
				random (seed, mainRand, iv);
				y := tan (PI*mainRand);
				em := sq*y + max_rand;
				while (em < 0.0) loop
					random (seed, mainRand, iv);
					y := tan (PI*mainRand);
					em := sq*y + max_rand;
				end loop;
				temp := floor(em*alxm - gammln(em+1.0) - g);
				if (temp < -50.0) then
					t := 0.0;
				else 
					t := 0.9 *(1.0 + y*y) * exp(temp);
				end if;
				random (seed, mainRand, iv);
			end loop;
		end if;
		rndval := em - real(maxIntLimit)*floor(em/real(maxIntLimit));
    END dist_poisson;

FUNCTION gammln (xx : real) RETURN real IS
  variable cof : cof1;
  variable x : real := 0.0;
  variable y : real := 0.0;
  variable tmp : real := 0.0;
  variable ser : real := 0.0;
  BEGIN
     cof := (76.18009172947146, -86.50532032941677, 24.01409824083091, -1.231739572450155, 0.1208650973866179e-2, -0.5395239384953e-5);
     x := xx;
     y := x;
     tmp := x + 5.5;
     tmp := tmp - ((x + 0.5) * log(tmp));

     ser := 1.000000000190015;
     for j in 0 to 5 loop
        y := y + 1.0;
        ser := ser+(cof(j)/y);
     end loop;
     return real(-tmp+log(2.5066282746310005*ser/x));
END;


END random_generators; 
