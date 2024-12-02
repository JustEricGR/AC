-- ----------------------------------------------------------------------------
--
--  Copyright (c) Mentor Graphics Corporation, 1982-1996, All Rights Reserved.
--                       UNPUBLISHED, LICENSED SOFTWARE.
--            CONFIDENTIAL AND PROPRIETARY INFORMATION WHICH IS THE
--          PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS.
--
--
-- PackageName :  Std_SimFlags
-- Title       :  Standard Simulation Flags
-- Purpose     :  This package defines a set of standard flags
--             :  used to set the operating conditions of a given
--             :  design.
--             :
-- Comments    :  Tightly integrated with Std_Timing.
--             :
-- Assumptions : none
-- Limitations : none
-- Known Errors: none
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- Mentor Graphics Corporation owns the sole copyright to this software.
-- Under International Copyright laws you (1) may not make a copy of this
-- software except for the purposes of maintaining a single archive copy, 
-- (2) may not derive works herefrom, (3) may not distribute this work to
-- others. These rights are provided for information clarification, 
-- other restrictions of rights may apply as well.
--
-- This is an "Unpublished" work.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> License   NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- This software is further protected by specific source code and/or
-- object code licenses provided by Mentor Graphics Corporation. Use of this
-- software other than as provided in the licensing agreement constitues
-- an infringement. No modification or waiver of any right(s) shall be 
-- given other than by the written authorization of an officer of The 
-- Mentor Graphics Corporation.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> Proprietary Information <<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- This source code contains proprietary information of Mentor Graphics 
-- Corporation and shall not be disclosed other than as provided in the software
-- licensing agreement.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>> Warrantee <<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- Mentor Graphics Corporation MAKES NO WARRANTY OF ANY KIND WITH REGARD TO 
-- THE USE OF THIS SOFTWARE, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
-- FOR A PARTICULAR PURPOSE.
-- ----------------------------------------------------------------------------
-- Modification History :
-- ----------------------------------------------------------------------------
--   Version No:| Author:|  Mod. Date:| Changes Made:
--     v1.000   |  ****  |  09/16/91  | Production release
--     v1.010   |  wdb   |  10/24/91  | Production release update
--     v1.110   |  mkd   |  03/06/92  | Production release update
--     v1.200   |  mkd   |  04/21/92  | depends std_timing
--     v1.210   |  mkd   |  06/25/92  | to match with std_timing version v1.21
--     v1.300   |  mkd   |  08/03/92  | production release
--     v1.400   |  mkd   |  11/06/92  | production release update
--     v1.500   |  mkd   |  11/17/92  | production release update
--     v1.600   |  mkd   |  02/11/93  | production release update
--     v1.610   |  wrm   |  03/30/93  | replace all 0 fs with 0 ns in body
--     v1.700 B |  wrm   |  05/03/93  | Beta release - no change from 1.61
--     v1.700   |  wrm   |  05/03/93  | production release - no changes
--     v1.800   |  wrm   |  07/28/93  | production release - no changes
--     v2.000   |  wrm   |  07/21/94  | production release - no changes
--     v2.100   |  wrm   |  01/10/96  | production release - no changes
--     v2.2     |  bmc   |  07/25/96  | Updated for Mentor Graphics Release
-- ----------------------------------------------------------------------------

LIBRARY IEEE;
USE     IEEE.Std_Logic_1164.ALL; -- Reference the STD_Logic system

LIBRARY Std_DevelopersKit;
USE     Std_DevelopersKit.Std_Timing.ALL;     -- Reference the Std Timing system

-------------------------------------------------------------------------------
PACKAGE Std_SimFlags IS
                                                  
    -------------------------------------------------------
    -- DefaultTimeMode                                     
    -------------------------------------------------------
    -- t_minimum == Models will use minimum timing         
    -- t_typical == Models will use typical timing         
    -- t_maximum == Models will use maximum timing         
    -- t_special == Models will use user provided timing   
    -------------------------------------------------------
    CONSTANT DefaultTimeMode          : TimeModeType ;     
                                                           
    -------------------------------------------------------
    -- DefaultFunctionCheck                               
    -------------------------------------------------------
    -- TRUE  == Functional Assertions checking is ON;      
    -- FALSE == Functional Assertions checking is OFF;     
    -------------------------------------------------------
    CONSTANT DefaultFunctionCheck     : BOOLEAN      ;     
                                                           
    -------------------------------------------------------
    -- DefaultTimingCheck
    -------------------------------------------------------
    -- TRUE  == Timing Assertions checking is ON;          
    -- FALSE == Timing Assertions checking is OFF;         
    -------------------------------------------------------
    CONSTANT DefaultTimingCheck       : BOOLEAN      ;     
                                                           
    -------------------------------------------------------
    -- DefaultXAssertion
    -------------------------------------------------------
    -- TRUE  == Assertions are issued upon detecting an X 
    -- FALSE == Assertions are NOT issued upon detecting an X
    -------------------------------------------------------
    CONSTANT DefaultXAssertion        : BOOLEAN      ;     
                                                           
    -------------------------------------------------------
    -- DefaultXPropagation
    -------------------------------------------------------
    -- TRUE  == X's are     generated upon violations      
    -- FALSE == X's are not generated upon violations      
    -------------------------------------------------------
    CONSTANT DefaultXPropagation      : BOOLEAN      ;
                                                           
    -------------------------------------------------------
    -- DefaultWarningsOn
    -------------------------------------------------------
    -- TRUE  == Warning are issued whenever functionality is unusual
    -- FALSE == Warnings are not issued for unusual behavior
    -------------------------------------------------------
    CONSTANT DefaultWarningsOn        : BOOLEAN      ;
                                                           
    -------------------------------------------------------
    -- Timing Defaults
    -------------------------------------------------------
    CONSTANT DefaultDelay             : TIME               ;
    CONSTANT DefaultDelayPair         : DelayPair          ;

    -- Base Incremental Delays
    CONSTANT DefaultBIDelay           : BaseIncrDlyPair    ;
    CONSTANT DefaultBaseIncrDelay     : BaseIncrDelay      ;
    CONSTANT ZeroBIDelay              : BaseIncrDlyPair    ;
    CONSTANT ZeroBaseIncrDelay        : BaseIncrDelay      ;

    -- Straight Forward Propagation Delays
    CONSTANT DefaultMinTypMaxTime     : MinTypMaxTime      ;
    CONSTANT ZeroMinTypMaxTime        : MinTypMaxTime      ;
    
    -- Timing Violations
    CONSTANT DefaultSetupTime         : MinTypMaxTime      ;
    CONSTANT DefaultHoldTime          : MinTypMaxTime      ;
    CONSTANT DefaultReleaseTime       : MinTypMaxTime      ;
    CONSTANT DefaultPulseTime         : MinTypMaxTime      ;

    -------------------------------------------------------
    -- System Parameters
    -------------------------------------------------------
    CONSTANT DefaultVoltage           : Voltage      ;
    CONSTANT DefaultTemperature       : Temperature  ;

    -------------------------------------------------------
    -- Derating Coefficients
    -------------------------------------------------------
    -- Environmental Factors
    CONSTANT DefaultFanoutDrive       : NaturalReal        ;
    CONSTANT DefaultFaninLoad         : NaturalReal        ;

    CONSTANT DefaultCLoad             : Capacitance        ;

    --------------------------------------------------------
    -- Note : Run "polyregress" to obtain these coefficients
    --------------------------------------------------------

    -- Capacitance Derating Polynomial Coefficients
    CONSTANT SysCapDerateCoeff_lh     : PolynomialCoeff ;
    CONSTANT SysCapDerateCoeff_hl     : PolynomialCoeff ;

    -- Temperature Derating Polynomial Coefficients
    CONSTANT SysTempDerateCoeff_lh    : PolynomialCoeff ;
    CONSTANT SysTempDerateCoeff_hl    : PolynomialCoeff ;

    -- Voltage Derating Polynomial Coefficients
    CONSTANT SysVoltageDerateCoeff_lh : PolynomialCoeff ;
    CONSTANT SysVoltageDerateCoeff_hl : PolynomialCoeff ;

    CONSTANT SysDeratingCoeffDefault  : PolynomialCoeff ;
    CONSTANT SysCoeff                 : DerateCoeffArray;

END Std_SimFlags;
