//              Copyright 2006-2007 Mentor Graphics Corporation
//                           All Rights Reserved.
//
//              THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
//            INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS
//           CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
//                                  TERMS.
//
//                   Questa Verification Library (QVL)
//

  property ASSERT_NEVER_P (clock, reset_n, enable, test_expr);
    @(posedge clock)
    disable iff (reset_n != 1'b1)
    enable |-> test_expr != 1'b1;
  endproperty

  property ASSERT_NEVER_UNKNOWN_P (clock, reset_n, qualifier, test_expr);
    @(posedge clock)
    disable iff (reset_n != 1'b1)
    qualifier |-> !($isunknown(test_expr));
  endproperty

  property ASSERT_WIN_UNCHANGE_P (clock, reset_n, enable, start_event, end_event, window, test_expr);
  @(posedge clock)
  disable iff (reset_n != 1'b1)
  ( (start_event && !window) ##1 (!(end_event && $stable(test_expr)))[*1:$] ) |-> $stable(test_expr);
  endproperty


