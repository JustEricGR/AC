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


`include "std_qvl_task.h"
`include "std_qvl_property.svh"

`ifdef QVL_ASSERT_ON

  //---------------------------------------------------------------------

  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ASSERT
                                   // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`COVER_NONE;
  parameter QVL_MSG = "QVL_SATA_VIOLATION : ";

  wire not_clk = ~clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate
  case (ZI_RECEIVE_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_SATA_NON_ALIGN_DWORD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (non_align_dword_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NON_ALIGN_DWORD_VIOLATION_P"}),
                          .msg            ("A pair of ALIGNp primitives must be detected once every 254 non-ALIGNp dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NON_ALIGN_DWORD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (non_align_dword_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NON_ALIGN_DWORD_VIOLATION_N"}),
                          .msg            ("A pair of ALIGNp primitives must be detected once every 254 non-ALIGNp dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_RD_000111_SUB_BLK_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rd_000111_sub_blk_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RD_000111_SUB_BLK_VIOLATION_P"}),
                          .msg            ("Sub-block containing 000111 was generated when the running disparity at the beginning of the sub-block was negative."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_RD_000111_SUB_BLK_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rd_000111_sub_blk_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RD_000111_SUB_BLK_VIOLATION_N"}),
                          .msg            ("Sub-block containing 000111 was generated when the running disparity at the beginning of the sub-block was negative."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_RD_111000_SUB_BLK_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rd_111000_sub_blk_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RD_111000_SUB_BLK_VIOLATION_P"}),
                          .msg            ("Sub-block containing 111000 was generated when the running disparity at the beginning of the sub-block was positive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_RD_111000_SUB_BLK_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rd_111000_sub_blk_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RD_111000_SUB_BLK_VIOLATION_N"}),
                          .msg            ("Sub-block containing 111000 was generated when the running disparity at the beginning of the sub-block was positive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_RD_0011_SUB_BLK_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rd_0011_sub_blk_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RD_0011_SUB_BLK_VIOLATION_P"}),
                          .msg            ("Sub-block containing 0011 was generated when the running disparity at the beginning of the sub-block was negative."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_RD_0011_SUB_BLK_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rd_0011_sub_blk_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RD_0011_SUB_BLK_VIOLATION_N"}),
                          .msg            ("Sub-block containing 0011 was generated when the running disparity at the beginning of the sub-block was negative."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_RD_1100_SUB_BLK_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rd_1100_sub_blk_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RD_1100_SUB_BLK_VIOLATION_P"}),
                          .msg            ("Sub-block containing 1100 was generated when the running disparity at the beginning of the sub-block was positive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_RD_1100_SUB_BLK_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rd_1100_sub_blk_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RD_1100_SUB_BLK_VIOLATION_N"}),
                          .msg            ("Sub-block containing 1100 was generated when the running disparity at the beginning of the sub-block was positive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PMACK_P_LESS_THAN_4_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (pmack_p_less_than_4_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PMACK_P_LESS_THAN_4_VIOLATION_P"}),
                          .msg            ("PMACK primitive must be transmitted at least four times as an acknowledgement to PMREQ."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PMACK_P_LESS_THAN_4_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (pmack_p_less_than_4_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PMACK_P_LESS_THAN_4_VIOLATION_N"}),
                          .msg            ("PMACK primitive must be transmitted four at least times as an acknowledgement to PMREQ."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PMACK_P_MORE_THAN_16_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (pmack_p_more_than_16_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PMACK_P_MORE_THAN_16_VIOLATION_P"}),
                          .msg            ("PMACK primitive must be transmitted not more than sixteen times as an acknowledgement to PMREQ."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PMACK_P_MORE_THAN_16_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (pmack_p_more_than_16_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PMACK_P_MORE_THAN_16_VIOLATION_N"}),
                          .msg            ("PMACK primitive must be transmitted not more than sixteen times as an acknowledgement to PMREQ."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_INVALID_K_CODE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (invalid_K_code_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_INVALID_K_CODE_VIOLATION_P"}),
                          .msg            ("Control characters other than K28.5 and K28.3 are invalid K-codes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_INVALID_K_CODE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (invalid_K_code_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_INVALID_K_CODE_VIOLATION_N"}),
                          .msg            ("Control characters other than K28.5 and K28.3 are invalid K-codes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_K_CODE_NOT_BYTE0_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (K_code_not_byte0_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_K_CODE_NOT_BYTE0_VIOLATION_P"}),
                          .msg            ("K28.5 or K28.3 character must be the first byte of any primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_K_CODE_NOT_BYTE0_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (K_code_not_byte0_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_K_CODE_NOT_BYTE0_VIOLATION_N"}),
                          .msg            ("K28.5 or K28.3 character must be the first byte of any primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_INVALID_PRIMITIVE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (invalid_primitive == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_INVALID_PRIMITIVE_P"}),
                          .msg            ("Invalid primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_INVALID_PRIMITIVE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (invalid_primitive == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_INVALID_PRIMITIVE_N"}),
                          .msg            ("Invalid primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_ALIGN_P_PAIR_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (alignp_pair_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_ALIGN_P_PAIR_VIOLATION_P"}),
                          .msg            ("ALIGNp primitive  must be detected in pairs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_ALIGN_P_PAIR_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (alignp_pair_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_ALIGN_P_PAIR_VIOLATION_N"}),
                          .msg            ("ALIGNp primitive  must be detected in pairs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_REPEAT_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (repeat_primitive_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_REPEAT_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("CONTp primitive must not be detected until the primitive to be repeated is detected atleast twice."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_REPEAT_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (repeat_primitive_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_REPEAT_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("CONTp primitive must not be detected until the primitive to be repeated is detected atleast twice."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_CONT_P_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (contp_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_CONT_P_VIOLATION_P"}),
                          .msg            ("Primitives other than HOLDp, HOLDAp, PMREQ_Pp, PMREQ_Sp, R_ERRp, R_OKp, R_RDYp, SYNCp, WTRMp and X_RDYp must not be followed by CONTp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_CONT_P_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (contp_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_CONT_P_VIOLATION_N"}),
                          .msg            ("Primitives other than HOLDp, HOLDAp, PMREQ_Pp, PMREQ_Sp, R_ERRp, R_OKp, R_RDYp, SYNCp, WTRMp and X_RDYp must not be followed by CONTp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SYNC_P_BEFORE_PMREQP_P_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sync_p_before_pmreqp_p_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SYNC_P_BEFORE_PMREQP_P_VIOLATION_P"}),
                          .msg            ("PMREQ_Pp primitives must always be preceded by SYNCp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SYNC_P_BEFORE_PMREQP_P_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (sync_p_before_pmreqp_p_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SYNC_P_BEFORE_PMREQP_P_VIOLATION_N"}),
                          .msg            ("PMREQ_Pp primitives must always be preceded by SYNCp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SYNC_P_BEFORE_PMREQS_P_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sync_p_before_pmreqs_p_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SYNC_P_BEFORE_PMREQS_P_VIOLATION_P"}),
                          .msg            ("PMREQ_Sp primitives must always be preceded by SYNCp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SYNC_P_BEFORE_PMREQS_P_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (sync_p_before_pmreqs_p_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SYNC_P_BEFORE_PMREQS_P_VIOLATION_N"}),
                          .msg            ("PMREQ_Sp primitives must always be preceded by SYNCp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SOF_P_MORE_THAN_ONCE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sof_p_more_than_once_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SOF_P_MORE_THAN_ONCE_VIOLATION_P"}),
                          .msg            ("SOFp primitive must not be transmitted more than once in a frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SOF_P_MORE_THAN_ONCE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (sof_p_more_than_once_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SOF_P_MORE_THAN_ONCE_VIOLATION_N"}),
                          .msg            ("SOFp primitive must not be transmitted more than once in a frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_EOF_P_MORE_THAN_ONCE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (eof_p_more_than_once_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_EOF_P_MORE_THAN_ONCE_VIOLATION_P"}),
                          .msg            ("EOFp primitive must not be transmitted more than once in a frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_EOF_P_MORE_THAN_ONCE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (eof_p_more_than_once_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_EOF_P_MORE_THAN_ONCE_VIOLATION_N"}),
                          .msg            ("EOFp primitive must not be transmitted more than once in a frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DATA_OUTSIDE_SOF_EOF_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (data_outside_sof_eof_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DATA_OUTSIDE_SOF_EOF_VIOLATION_P"}),
                          .msg            ("The data dword must be transmitted within the SOFp and EOFp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DATA_OUTSIDE_SOF_EOF_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (data_outside_sof_eof_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DATA_OUTSIDE_SOF_EOF_VIOLATION_N"}),
                          .msg            ("The data dword must be transmitted within the SOFp and EOFp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMAT_BY_TRANSMITTER_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dmat_by_transmitter_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMAT_BY_TRANSMITTER_VIOLATION_P"}),
                          .msg            ("DMATp primitive must not be transmitted by the data FIS transmitter."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMAT_BY_TRANSMITTER_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dmat_by_transmitter_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMAT_BY_TRANSMITTER_VIOLATION_N"}),
                          .msg            ("DMATp primitive must not be transmitted by the data FIS transmitter."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_EOF_P_WTRM_P_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (eof_p_wtrm_p_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_EOF_P_WTRM_P_VIOLATION_P"}),
                          .msg            ("EOFp must always be followed by WTRMp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_EOF_P_WTRM_P_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (eof_p_wtrm_p_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_EOF_P_WTRM_P_VIOLATION_N"}),
                          .msg            ("EOFp must always be followed by WTRMp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMAT_P_RIP_P_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dmat_p_r_ip_p_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMAT_P_RIP_P_VIOLATION_P"}),
                          .msg            ("DMATp must always be followed by R_IPp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMAT_P_RIP_P_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dmat_p_r_ip_p_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMAT_P_RIP_P_VIOLATION_N"}),
                          .msg            ("DMATp must always be followed by R_IPp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_R_OK_P_WHEN_CRC_ERR_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (r_ok_p_when_crc_err_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_R_OK_P_WHEN_CRC_ERR_VIOLATION_P"}),
                          .msg            ("R_OKp primitive must not be transmitted when CRC error is encountered."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_R_OK_P_WHEN_CRC_ERR_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (r_ok_p_when_crc_err_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_R_OK_P_WHEN_CRC_ERR_VIOLATION_N"}),
                          .msg            ("R_OKp primitive must not be transmitted when CRC error is encountered."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_REG_H2D_FIS_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reg_h2d_fis_count_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_REG_H2D_FIS_COUNT_VIOLATION_P"}),
                          .msg            ("REG host to device FIS must have 5 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_REG_H2D_FIS_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (reg_h2d_fis_count_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_REG_H2D_FIS_COUNT_VIOLATION_N"}),
                          .msg            ("REG host to device FIS must have 5 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_REG_D2H_FIS_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reg_d2h_fis_count_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_REG_D2H_FIS_COUNT_VIOLATION_P"}),
                          .msg            ("REG device to host FIS must have 5 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_REG_D2H_FIS_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (reg_d2h_fis_count_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_REG_D2H_FIS_COUNT_VIOLATION_N"}),
                          .msg            ("REG device to host FIS must have 5 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SERV_IN_REG_D2H_FIS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (serv_in_reg_d2h_fis_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SERV_IN_REG_D2H_FIS_VIOLATION_P"}),
                          .msg            ("REG device to host FIS must not be transmitted with SERV bit set to '1' in the status register."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SERV_IN_REG_D2H_FIS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (serv_in_reg_d2h_fis_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SERV_IN_REG_D2H_FIS_VIOLATION_N"}),
                          .msg            ("REG device to host FIS must not be transmitted with SERV bit set to '1' in the status register."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SET_DEV_FIS_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (set_dev_fis_count_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SET_DEV_FIS_COUNT_VIOLATION_P"}),
                          .msg            ("Set device bits FIS must have 2 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SET_DEV_FIS_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (set_dev_fis_count_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SET_DEV_FIS_COUNT_VIOLATION_N"}),
                          .msg            ("Set device bits FIS must have 2 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_ACT_FIS_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_act_fis_count_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_ACT_FIS_COUNT_VIOLATION_P"}),
                          .msg            ("DMA activate FIS must have 1 dword."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_ACT_FIS_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_act_fis_count_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_ACT_FIS_COUNT_VIOLATION_N"}),
                          .msg            ("DMA activate FIS must have 1 dword."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_SETUP_FIS_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_setup_fis_count_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_SETUP_FIS_COUNT_VIOLATION_P"}),
                          .msg            ("DMA setup FIS must have 7 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_SETUP_FIS_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_setup_fis_count_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_SETUP_FIS_COUNT_VIOLATION_N"}),
                          .msg            ("DMA setup FIS must have 7 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_BIST_ACT_FIS_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (bist_act_fis_count_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_BIST_ACT_FIS_COUNT_VIOLATION_P"}),
                          .msg            ("BIST activate FIS must have 3 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_BIST_ACT_FIS_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bist_act_fis_count_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_BIST_ACT_FIS_COUNT_VIOLATION_N"}),
                          .msg            ("BIST activate FIS must have 3 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PIO_TRANSFER_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (pio_transfer_count_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PIO_TRANSFER_COUNT_VIOLATION_P"}),
                          .msg            ("In PIO setup FIS the transfer count register must not be set zero except for bit0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PIO_TRANSFER_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (pio_transfer_count_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PIO_TRANSFER_COUNT_VIOLATION_N"}),
                          .msg            ("In PIO setup FIS the transfer count register must not be set zero except for bit0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PIO_SETUP_FIS_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (pio_setup_fis_count_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PIO_SETUP_FIS_COUNT_VIOLATION_P"}),
                          .msg            ("PIO setup FIS must have 5 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PIO_SETUP_FIS_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (pio_setup_fis_count_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PIO_SETUP_FIS_COUNT_VIOLATION_N"}),
                          .msg            ("PIO setup FIS must have 5 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DATA_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (data_count_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DATA_COUNT_VIOLATION_P"}),
                          .msg            ("The number of dwords in a data FIS must not exceed 2048."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DATA_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (data_count_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DATA_COUNT_VIOLATION_N"}),
                          .msg            ("The number of dwords in a data FIS must not exceed 2048."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DATA_NOT_DWORD_ALIGNED_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (data_not_dword_aligned_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DATA_NOT_DWORD_ALIGNED_VIOLATION_P"}),
                          .msg            ("The data is not dowrd aligned."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DATA_NOT_DWORD_ALIGNED_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (data_not_dword_aligned_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DATA_NOT_DWORD_ALIGNED_VIOLATION_N"}),
                          .msg            ("The data is not dowrd aligned."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_FIS_WHEN_SRST_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (fis_when_srst_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_FIS_WHEN_SRST_VIOLATION_P"}),
                          .msg            ("Device must not perform any operation when SRST bit is set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_FIS_WHEN_SRST_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (fis_when_srst_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_FIS_WHEN_SRST_VIOLATION_N"}),
                          .msg            ("Device must not perform any operation when SRST bit is set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SRST_GS_NP_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (srst_gs_np_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SRST_GS_NP_VIOLATION_P"}),
                          .msg            ("Good status format violation for Soft reset protocol of non-packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SRST_GS_NP_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (srst_gs_np_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SRST_GS_NP_VIOLATION_N"}),
                          .msg            ("Good status format violation for Soft reset protocol of non-packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SRST_GS_P_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (srst_gs_p_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SRST_GS_P_VIOLATION_P"}),
                          .msg            ("Good status format violation for Soft reset protocol of packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SRST_GS_P_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (srst_gs_p_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SRST_GS_P_VIOLATION_N"}),
                          .msg            ("Good status format violation for Soft reset protocol of packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SRST_BS_NP_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (srst_bs_np_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SRST_BS_NP_VIOLATION_P"}),
                          .msg            ("Bad status format violation for Soft reset protocol of non-packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SRST_BS_NP_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (srst_bs_np_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SRST_BS_NP_VIOLATION_N"}),
                          .msg            ("Bad status format violation for Soft reset protocol of non-packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SRST_BS_P_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (srst_bs_p_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SRST_BS_P_VIOLATION_P"}),
                          .msg            ("Bad status format violation for Soft reset protocol of packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SRST_BS_P_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (srst_bs_p_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SRST_BS_P_VIOLATION_N"}),
                          .msg            ("Bad status format violation for Soft reset protocol of packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_EX_DIAG_GS_NP_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ex_diag_gs_np_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_EX_DIAG_GS_NP_VIOLATION_P"}),
                          .msg            ("Good status format violation for Execute device diagnostics command of non-packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_EX_DIAG_GS_NP_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ex_diag_gs_np_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_EX_DIAG_GS_NP_VIOLATION_N"}),
                          .msg            ("Good status format violation for Execute device diagnostics command of non-packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_EX_DIAG_GS_P_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ex_diag_gs_p_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_EX_DIAG_GS_P_VIOLATION_P"}),
                          .msg            ("Good status format violation for Execute device diagnostics command of packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_EX_DIAG_GS_P_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ex_diag_gs_p_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_EX_DIAG_GS_P_VIOLATION_N"}),
                          .msg            ("Good status format violation for Execute device diagnostics command of packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_EX_DIAG_BS_NP_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ex_diag_bs_np_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_EX_DIAG_BS_NP_VIOLATION_P"}),
                          .msg            ("Bad status format violation for Execute device diagnostics command of non-packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_EX_DIAG_BS_NP_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ex_diag_bs_np_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_EX_DIAG_BS_NP_VIOLATION_N"}),
                          .msg            ("Bad status format violation for Execute device diagnostics command of non-packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_EX_DIAG_BS_P_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ex_diag_bs_p_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_EX_DIAG_BS_P_VIOLATION_P"}),
                          .msg            ("Bad status format violation for Execute device diagnostics command of packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_EX_DIAG_BS_P_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ex_diag_bs_p_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_EX_DIAG_BS_P_VIOLATION_N"}),
                          .msg            ("Bad status format violation for Execute device diagnostics command of packet feature set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DEV_RST_GS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dev_rst_gs_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DEV_RST_GS_VIOLATION_P"}),
                          .msg            ("Good status format violation for Device Reset command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DEV_RST_GS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dev_rst_gs_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DEV_RST_GS_VIOLATION_N"}),
                          .msg            ("Good status format violation for Device Reset command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_OTHER_CMD_GS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (other_cmd_gs_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_OTHER_CMD_GS_VIOLATION_P"}),
                          .msg            ("Good status format violation for commands other than Device Reset, Execute device diagnostics and soft reset commands."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_OTHER_CMD_GS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (other_cmd_gs_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_OTHER_CMD_GS_VIOLATION_N"}),
                          .msg            ("Good status format violation for commands other than Device Reset, Execute device diagnostics and soft reset commands."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_OTHER_CMD_BS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (other_cmd_bs_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_OTHER_CMD_BS_VIOLATION_P"}),
                          .msg            ("Bad status format violation for commands other than Device Reset, Execute device diagnostics and soft reset commands."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_OTHER_CMD_BS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (other_cmd_bs_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_OTHER_CMD_BS_VIOLATION_N"}),
                          .msg            ("Bad status format violation for commands other than Device Reset, Execute device diagnostics and soft reset commands."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PIO_SETUP_STS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (pio_setup_sts_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PIO_SETUP_STS_VIOLATION_P"}),
                          .msg            ("The PIO setup FIS transmitted during PIO-IN or PIO-OUT command must have I bit cleared to '0' for first DRQ data block and set to '1' for other DRQ data blocks, also ERR bit should be cleared to '0'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PIO_SETUP_STS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (pio_setup_sts_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PIO_SETUP_STS_VIOLATION_N"}),
                          .msg            ("The PIO setup FIS transmitted during PIO-IN or PIO-OUT command must have I bit cleared to '0' for first DRQ data block and set to '1' for other DRQ data blocks, also ERR bit should be cleared to '0'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_REG_D2H_STS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reg_d2h_sts_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_REG_D2H_STS_VIOLATION_P"}),
                          .msg            ("The Reg FIS transmitted in response PIO-IN command must have I bit set to '1' and ERR bit set to '1'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_REG_D2H_STS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (reg_d2h_sts_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_REG_D2H_STS_VIOLATION_N"}),
                          .msg            ("The Reg FIS transmitted in response PIO-IN command must have I bit set to '1' and ERR bit set to '1'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NO_DATA_AFTER_PIO_SETUP_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (no_data_after_pio_setup_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NO_DATA_AFTER_PIO_SETUP_VIOLATION_P"}),
                          .msg            ("PIO setup FIS must always be followed by one data FIS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NO_DATA_AFTER_PIO_SETUP_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (no_data_after_pio_setup_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NO_DATA_AFTER_PIO_SETUP_VIOLATION_N"}),
                          .msg            ("PIO setup FIS must always be followed by one data FIS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DATA_FIS_IN_PIO_CMD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (data_fis_in_pio_cmd_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DATA_FIS_IN_PIO_CMD_VIOLATION_P"}),
                          .msg            ("Data FIS must not be followed by another data FIS during PIO commands."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DATA_FIS_IN_PIO_CMD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (data_fis_in_pio_cmd_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DATA_FIS_IN_PIO_CMD_VIOLATION_N"}),
                          .msg            ("Data FIS must not be followed by another data FIS during PIO commands."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_IN_CMD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_in_cmd_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_IN_CMD_VIOLATION_P"}),
                          .msg            ("On receipt of DMA-IN command from the host, the device shall transmit either reg device to host FIS or data FIS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_IN_CMD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_in_cmd_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_IN_CMD_VIOLATION_N"}),
                          .msg            ("On receipt of DMA-IN command from the host, the device shall transmit either reg device to host FIS or data FIS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_ACT_CMD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_act_cmd_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_ACT_CMD_VIOLATION_P"}),
                          .msg            ("DMA activate FIS must always be followed by one data FIS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_ACT_CMD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_act_cmd_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_ACT_CMD_VIOLATION_N"}),
                          .msg            ("DMA activate FIS must always be followed by one data FIS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_OUT_CMD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_out_cmd_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_OUT_CMD_VIOLATION_P"}),
                          .msg            ("On receipt of DMA-OUT command from the host, the device must not transmit any other FIS other than DMA activate FIS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_OUT_CMD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_out_cmd_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_OUT_CMD_VIOLATION_N"}),
                          .msg            ("On receipt of DMA-OUT command from the host, the device must not transmit any other FIS other than DMA activate FIS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PKT_CMD_PIO_SETUP_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (pkt_cmd_pio_setup_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PKT_CMD_PIO_SETUP_VIOLATION_P"}),
                          .msg            ("On receipt of packet command from the host, the device must transmit PIO setup FIS with  I bit set to '1'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PKT_CMD_PIO_SETUP_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (pkt_cmd_pio_setup_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PKT_CMD_PIO_SETUP_VIOLATION_N"}),
                          .msg            ("On receipt of packet command from the host, the device must transmit PIO setup FIS with  I bit set to '1'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_REL_BIT_IN_CMD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rel_bit_in_cmd_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_REL_BIT_IN_CMD_VIOLATION_P"}),
                          .msg            ("Reg FIS with REL bit set to '1' must be sent to the host immediately after the receipt of legacy queued command or packet command and not inbetween data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_REL_BIT_IN_CMD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rel_bit_in_cmd_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_REL_BIT_IN_CMD_VIOLATION_N"}),
                          .msg            ("Reg FIS with REL bit set to '1' must be sent to the host immediately after the receipt of legacy queued command or packet command and not inbetween data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_ROK_FOR_10B_DISPERR_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rok_for_10B_disperr_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_ROK_FOR_10B_DISPERR_VIOLATION_P"}),
                          .msg            ("On detection of 10B or disparity error during a frame reception, the frame must be negatively acknowledged with R_ERRp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_ROK_FOR_10B_DISPERR_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rok_for_10B_disperr_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_ROK_FOR_10B_DISPERR_VIOLATION_N"}),
                          .msg            ("On detection of 10B or disparity error during a frame reception, the frame must be negatively acknowledged with R_ERRp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_ROK_FOR_INVALID_FIS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rok_for_invalid_fis_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_ROK_FOR_INVALID_FIS_VIOLATION_P"}),
                          .msg            ("On detection of unrecognised FIS type during a frame reception, the frame must be negatively acknowledged with R_ERRp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_ROK_FOR_INVALID_FIS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rok_for_invalid_fis_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_ROK_FOR_INVALID_FIS_VIOLATION_N"}),
                          .msg            ("On detection of unrecognised FIS type during a frame reception, the frame must be negatively acknowledged with R_ERRp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_ROK_FOR_MALF_FIS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rok_for_malf_fis_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_ROK_FOR_MALF_FIS_VIOLATION_P"}),
                          .msg            ("On detection of malformed FIS during a frame reception, the frame must be negatively acknowledged with R_ERRp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_ROK_FOR_MALF_FIS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rok_for_malf_fis_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_ROK_FOR_MALF_FIS_VIOLATION_N"}),
                          .msg            ("On detection of malformed FIS during a frame reception, the frame must be negatively acknowledged with R_ERRp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_ACT_WHEN_AUTO_ACT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_act_when_auto_act_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_ACT_WHEN_AUTO_ACT_VIOLATION_P"}),
                          .msg            ("When auto activate bit is set to '1', for a device to host transfer DMA setup FIS must be followed by Data FIS and not DMA activate FIS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_ACT_WHEN_AUTO_ACT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_act_when_auto_act_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_ACT_WHEN_AUTO_ACT_VIOLATION_N"}),
                          .msg            ("When auto activate bit is set to '1', for a device to host transfer DMA setup FIS must be followed by Data FIS and not DMA activate FIS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_AUTO_ACT_IN_RD_TX_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (auto_act_in_rd_tx_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_AUTO_ACT_IN_RD_TX_VIOLATION_P"}),
                          .msg            ("Auto activate bit must be set to '0' in the DMA setup FIS sent for a host to device transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_AUTO_ACT_IN_RD_TX_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (auto_act_in_rd_tx_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_AUTO_ACT_IN_RD_TX_VIOLATION_N"}),
                          .msg            ("Auto activate bit must be set to '0' in the DMA setup FIS sent for a host to device transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_AN_WHEN_NOTF_PEND_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (an_when_notf_pend_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_AN_WHEN_NOTF_PEND_VIOLATION_P"}),
                          .msg            ("Device must not send a Set device bits FIS with asynchronous notification bit set to '1' when the previous notification was pending."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_AN_WHEN_NOTF_PEND_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (an_when_notf_pend_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_AN_WHEN_NOTF_PEND_VIOLATION_N"}),
                          .msg            ("Device must not send a Set device bits FIS with asynchronous notification bit set to '1' when the previous notification was pending."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_AN_IN_SET_DEV_BIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (an_in_set_dev_bit_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_AN_IN_SET_DEV_BIT_VIOLATION_P"}),
                          .msg            ("In a Set device FIS with asynchronous notification bit set to '1', the I bit must be set to '1' and the status and error fields must be set to '0'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_AN_IN_SET_DEV_BIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (an_in_set_dev_bit_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_AN_IN_SET_DEV_BIT_VIOLATION_N"}),
                          .msg            ("In a Set device FIS with asynchronous notification bit set to '1', the I bit must be set to '1' and the status and error fields must be set to '0'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_TRANSFER_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_transfer_count_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_TRANSFER_COUNT_VIOLATION_P"}),
                          .msg            ("In DMA setup FIS, the transfer count register must not be set zero except for bit0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DMA_TRANSFER_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_transfer_count_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DMA_TRANSFER_COUNT_VIOLATION_N"}),
                          .msg            ("In DMA setup FIS, the transfer count register must not be set zero except for bit0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NCQ_RESP_WO_CMD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ncq_resp_wo_cmd_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NCQ_RESP_WO_CMD_VIOLATION_P"}),
                          .msg            ("Response for a NCQ command must not be sent without the NCQ command being outstanding."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NCQ_RESP_WO_CMD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ncq_resp_wo_cmd_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NCQ_RESP_WO_CMD_VIOLATION_N"}),
                          .msg            ("Response for a NCQ command must not be sent without the NCQ command being outstanding."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NCQ_STS_WO_CMD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ncq_sts_wo_cmd_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NCQ_STS_WO_CMD_VIOLATION_P"}),
                          .msg            ("Status for a NCQ command must not be sent without the NCQ command being outstanding."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NCQ_STS_WO_CMD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ncq_sts_wo_cmd_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NCQ_STS_WO_CMD_VIOLATION_N"}),
                          .msg            ("Status for a NCQ command must not be sent without the NCQ command being outstanding."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NCQ_STS_WO_RESP_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ncq_sts_wo_resp_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NCQ_STS_WO_RESP_VIOLATION_P"}),
                          .msg            ("Status for a NCQ command must not be sent without the response for the same."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NCQ_STS_WO_RESP_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ncq_sts_wo_resp_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NCQ_STS_WO_RESP_VIOLATION_N"}),
                          .msg            ("Status for a NCQ command must not be sent without the response for the same."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NON_NCQ_WHEN_NCQ_PENDING_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (non_ncq_when_ncq_pending_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NON_NCQ_WHEN_NCQ_PENDING_VIOLATION_P"}),
                          .msg            ("Legacy command must not be issued when NCQ command is still pending."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NON_NCQ_WHEN_NCQ_PENDING_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (non_ncq_when_ncq_pending_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NON_NCQ_WHEN_NCQ_PENDING_VIOLATION_N"}),
                          .msg            ("Legacy command must not be issued when NCQ command is still pending."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NON_NCQ_CMD_STS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (non_ncq_cmd_sts_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NON_NCQ_CMD_STS_VIOLATION_P"}),
                          .msg            ("On reception of legacy command when NCQ command is pending the reg FIS sent by the device in response must have ERR and ABRT bits set to '1' and BSY bit set to '0'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NON_NCQ_CMD_STS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (non_ncq_cmd_sts_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NON_NCQ_CMD_STS_VIOLATION_N"}),
                          .msg            ("On reception of legacy command when NCQ command is pending the reg FIS sent by the device in response must have ERR and ABRT bits set to '1' and BSY bit set to '0'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NCQ_REG_D2H_STS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ncq_reg_d2h_sts_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NCQ_REG_D2H_STS_VIOLATION_P"}),
                          .msg            ("Reg FIS transmitted in response to the NCQ command from the host must have I bit set to '0'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NCQ_REG_D2H_STS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ncq_reg_d2h_sts_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NCQ_REG_D2H_STS_VIOLATION_N"}),
                          .msg            ("Reg FIS transmitted in response to the NCQ command from the host must have I bit set to '0'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_RD_LOG_CMD_STS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rd_log_cmd_sts_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RD_LOG_CMD_STS_VIOLATION_P"}),
                          .msg            ("On receipt of READ LOG EXT command from the host, the device must send set device FIS with ERR=0, ERROR reg =0, SActive field = 0xffffffff and I=0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_RD_LOG_CMD_STS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rd_log_cmd_sts_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RD_LOG_CMD_STS_VIOLATION_N"}),
                          .msg            ("On receipt of READ LOG EXT command from the host, the device must send Set device FIS with ERR=0, ERROR reg =0, SActive field = 0xffffffff and I=0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DEV_RST_CMD_IN_PM_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dev_rst_cmd_in_pm_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DEV_RST_CMD_IN_PM_VIOLATION_P"}),
                          .msg            ("DEVICE RESET command must not be issued when port multiplier is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DEV_RST_CMD_IN_PM_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dev_rst_cmd_in_pm_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DEV_RST_CMD_IN_PM_VIOLATION_N"}),
                          .msg            ("DEVICE RESET command must not be issued when port multiplier is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_LEGACY_QUEUED_CMD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (legacy_queued_cmd_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_LEGACY_QUEUED_CMD_VIOLATION_P"}),
                          .msg            ("READ or WRITE queued commands must not be issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_LEGACY_QUEUED_CMD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (legacy_queued_cmd_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_LEGACY_QUEUED_CMD_VIOLATION_N"}),
                          .msg            ("READ or WRITE queued commands must not be issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NCQ_CMD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ncq_cmd_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NCQ_CMD_VIOLATION_P"}),
                          .msg            ("NCQ command must not be issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NCQ_CMD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ncq_cmd_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NCQ_CMD_VIOLATION_N"}),
                          .msg            ("NCQ command must not be issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PACKET_CMD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (packet_cmd_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PACKET_CMD_VIOLATION_P"}),
                          .msg            ("Packet queued command must not be issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_PACKET_CMD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (packet_cmd_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PACKET_CMD_VIOLATION_N"}),
                          .msg            ("Packet queued command must not be issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SERVICE_CMD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (service_cmd_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SERVICE_CMD_VIOLATION_P"}),
                          .msg            ("Service command must not be issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_SERVICE_CMD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (service_cmd_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SERVICE_CMD_VIOLATION_N"}),
                          .msg            ("Service command must not be issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_CRC_ERROR_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (crc_error_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_CRC_ERROR_VIOLATION_P"}),
                          .msg            ("Crc error encountered in the fis frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_CRC_ERROR_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (crc_error_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_CRC_ERROR_VIOLATION_N"}),
                          .msg            ("Crc error encountered in the fis frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DISPARITY_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (disparity_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DISPARITY_VIOLATION_P"}),
                          .msg            ("Disparity error encountered while decoding the 10b data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_DISPARITY_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (disparity_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_DISPARITY_VIOLATION_N"}),
                          .msg            ("Disparity error encountered while decoding the 10b data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_CODE_ERR_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (code_err_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_CODE_ERR_VIOLATION_P"}),
                          .msg            ("Invalid 10B code detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_CODE_ERR_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (code_err_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_CODE_ERR_VIOLATION_N"}),
                          .msg            ("Invalid 10B code detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NCQ_QUEUE_DEPTH_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ncq_queue_depth_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NCQ_QUEUE_DEPTH_VIOLATION_P"}),
                          .msg            ("The command tag in the native queued command must not be greater than the maximum queue depth."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_NCQ_QUEUE_DEPTH_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ncq_queue_depth_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_NCQ_QUEUE_DEPTH_VIOLATION_N"}),
                          .msg            ("The command tag in the native queued command must not be greater than the maximum queue depth."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_RESERVED_FIELD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_field_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RESERVED_FIELD_VIOLATION_P"}),
                          .msg            ("The reserved bits in dword of the REG_H2D_FIS must be set to zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_RESERVED_FIELD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (reserved_field_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RESERVED_FIELD_VIOLATION_N"}),
                          .msg            ("The reserved bits in dword  of the REG_H2D_FIS must be set to zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_SATA_NON_ALIGN_DWORD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (non_align_dword_violation == 1'b1)));
        M_SATA_NON_ALIGN_DWORD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (non_align_dword_violation == 1'b1))));
        M_SATA_RD_000111_SUB_BLK_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rd_000111_sub_blk_violation == 1'b1)));
        M_SATA_RD_000111_SUB_BLK_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rd_000111_sub_blk_violation == 1'b1))));
        M_SATA_RD_111000_SUB_BLK_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rd_111000_sub_blk_violation == 1'b1)));
        M_SATA_RD_111000_SUB_BLK_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rd_111000_sub_blk_violation == 1'b1))));
        M_SATA_RD_0011_SUB_BLK_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rd_0011_sub_blk_violation == 1'b1)));
        M_SATA_RD_0011_SUB_BLK_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rd_0011_sub_blk_violation == 1'b1))));
        M_SATA_RD_1100_SUB_BLK_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rd_1100_sub_blk_violation == 1'b1)));
        M_SATA_RD_1100_SUB_BLK_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rd_1100_sub_blk_violation == 1'b1))));
        M_SATA_PMACK_P_LESS_THAN_4_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (pmack_p_less_than_4_violation == 1'b1)));
        M_SATA_PMACK_P_LESS_THAN_4_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (pmack_p_less_than_4_violation == 1'b1))));
        M_SATA_PMACK_P_MORE_THAN_16_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (pmack_p_more_than_16_violation == 1'b1)));
        M_SATA_PMACK_P_MORE_THAN_16_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (pmack_p_more_than_16_violation == 1'b1))));
        M_SATA_INVALID_K_CODE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (invalid_K_code_violation == 1'b1)));
        M_SATA_INVALID_K_CODE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (invalid_K_code_violation == 1'b1))));
        M_SATA_K_CODE_NOT_BYTE0_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (K_code_not_byte0_violation == 1'b1)));
        M_SATA_K_CODE_NOT_BYTE0_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (K_code_not_byte0_violation == 1'b1))));
        M_SATA_INVALID_PRIMITIVE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (invalid_primitive == 1'b1)));
        M_SATA_INVALID_PRIMITIVE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (invalid_primitive == 1'b1))));
        M_SATA_ALIGN_P_PAIR_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (alignp_pair_violation == 1'b1)));
        M_SATA_ALIGN_P_PAIR_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (alignp_pair_violation == 1'b1))));
        M_SATA_REPEAT_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (repeat_primitive_violation == 1'b1)));
        M_SATA_REPEAT_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (repeat_primitive_violation == 1'b1))));
        M_SATA_CONT_P_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (contp_violation == 1'b1)));
        M_SATA_CONT_P_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (contp_violation == 1'b1))));
        M_SATA_SYNC_P_BEFORE_PMREQP_P_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sync_p_before_pmreqp_p_violation == 1'b1)));
        M_SATA_SYNC_P_BEFORE_PMREQP_P_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (sync_p_before_pmreqp_p_violation == 1'b1))));
        M_SATA_SYNC_P_BEFORE_PMREQS_P_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sync_p_before_pmreqs_p_violation == 1'b1)));
        M_SATA_SYNC_P_BEFORE_PMREQS_P_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (sync_p_before_pmreqs_p_violation == 1'b1))));
        M_SATA_SOF_P_MORE_THAN_ONCE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sof_p_more_than_once_violation == 1'b1)));
        M_SATA_SOF_P_MORE_THAN_ONCE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (sof_p_more_than_once_violation == 1'b1))));
        M_SATA_EOF_P_MORE_THAN_ONCE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (eof_p_more_than_once_violation == 1'b1)));
        M_SATA_EOF_P_MORE_THAN_ONCE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (eof_p_more_than_once_violation == 1'b1))));
        M_SATA_DATA_OUTSIDE_SOF_EOF_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (data_outside_sof_eof_violation == 1'b1)));
        M_SATA_DATA_OUTSIDE_SOF_EOF_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (data_outside_sof_eof_violation == 1'b1))));
        M_SATA_DMAT_BY_TRANSMITTER_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dmat_by_transmitter_violation == 1'b1)));
        M_SATA_DMAT_BY_TRANSMITTER_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dmat_by_transmitter_violation == 1'b1))));
        M_SATA_EOF_P_WTRM_P_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (eof_p_wtrm_p_violation == 1'b1)));
        M_SATA_EOF_P_WTRM_P_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (eof_p_wtrm_p_violation == 1'b1))));
        M_SATA_DMAT_P_RIP_P_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dmat_p_r_ip_p_violation == 1'b1)));
        M_SATA_DMAT_P_RIP_P_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dmat_p_r_ip_p_violation == 1'b1))));
        M_SATA_R_OK_P_WHEN_CRC_ERR_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (r_ok_p_when_crc_err_violation == 1'b1)));
        M_SATA_R_OK_P_WHEN_CRC_ERR_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (r_ok_p_when_crc_err_violation == 1'b1))));
        M_SATA_REG_H2D_FIS_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reg_h2d_fis_count_violation == 1'b1)));
        M_SATA_REG_H2D_FIS_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (reg_h2d_fis_count_violation == 1'b1))));
        M_SATA_REG_D2H_FIS_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reg_d2h_fis_count_violation == 1'b1)));
        M_SATA_REG_D2H_FIS_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (reg_d2h_fis_count_violation == 1'b1))));
        M_SATA_SERV_IN_REG_D2H_FIS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (serv_in_reg_d2h_fis_violation == 1'b1)));
        M_SATA_SERV_IN_REG_D2H_FIS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (serv_in_reg_d2h_fis_violation == 1'b1))));
        M_SATA_SET_DEV_FIS_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (set_dev_fis_count_violation == 1'b1)));
        M_SATA_SET_DEV_FIS_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (set_dev_fis_count_violation == 1'b1))));
        M_SATA_DMA_ACT_FIS_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_act_fis_count_violation == 1'b1)));
        M_SATA_DMA_ACT_FIS_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_act_fis_count_violation == 1'b1))));
        M_SATA_DMA_SETUP_FIS_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_setup_fis_count_violation == 1'b1)));
        M_SATA_DMA_SETUP_FIS_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_setup_fis_count_violation == 1'b1))));
        M_SATA_BIST_ACT_FIS_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (bist_act_fis_count_violation == 1'b1)));
        M_SATA_BIST_ACT_FIS_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bist_act_fis_count_violation == 1'b1))));
        M_SATA_PIO_TRANSFER_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (pio_transfer_count_violation == 1'b1)));
        M_SATA_PIO_TRANSFER_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (pio_transfer_count_violation == 1'b1))));
        M_SATA_PIO_SETUP_FIS_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (pio_setup_fis_count_violation == 1'b1)));
        M_SATA_PIO_SETUP_FIS_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (pio_setup_fis_count_violation == 1'b1))));
        M_SATA_DATA_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (data_count_violation == 1'b1)));
        M_SATA_DATA_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (data_count_violation == 1'b1))));
        M_SATA_DATA_NOT_DWORD_ALIGNED_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (data_not_dword_aligned_violation == 1'b1)));
        M_SATA_DATA_NOT_DWORD_ALIGNED_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (data_not_dword_aligned_violation == 1'b1))));
        M_SATA_FIS_WHEN_SRST_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (fis_when_srst_violation == 1'b1)));
        M_SATA_FIS_WHEN_SRST_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (fis_when_srst_violation == 1'b1))));
        M_SATA_SRST_GS_NP_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (srst_gs_np_violation == 1'b1)));
        M_SATA_SRST_GS_NP_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (srst_gs_np_violation == 1'b1))));
        M_SATA_SRST_GS_P_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (srst_gs_p_violation == 1'b1)));
        M_SATA_SRST_GS_P_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (srst_gs_p_violation == 1'b1))));
        M_SATA_SRST_BS_NP_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (srst_bs_np_violation == 1'b1)));
        M_SATA_SRST_BS_NP_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (srst_bs_np_violation == 1'b1))));
        M_SATA_SRST_BS_P_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (srst_bs_p_violation == 1'b1)));
        M_SATA_SRST_BS_P_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (srst_bs_p_violation == 1'b1))));
        M_SATA_EX_DIAG_GS_NP_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ex_diag_gs_np_violation == 1'b1)));
        M_SATA_EX_DIAG_GS_NP_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ex_diag_gs_np_violation == 1'b1))));
        M_SATA_EX_DIAG_GS_P_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ex_diag_gs_p_violation == 1'b1)));
        M_SATA_EX_DIAG_GS_P_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ex_diag_gs_p_violation == 1'b1))));
        M_SATA_EX_DIAG_BS_NP_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ex_diag_bs_np_violation == 1'b1)));
        M_SATA_EX_DIAG_BS_NP_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ex_diag_bs_np_violation == 1'b1))));
        M_SATA_EX_DIAG_BS_P_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ex_diag_bs_p_violation == 1'b1)));
        M_SATA_EX_DIAG_BS_P_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ex_diag_bs_p_violation == 1'b1))));
        M_SATA_DEV_RST_GS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dev_rst_gs_violation == 1'b1)));
        M_SATA_DEV_RST_GS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dev_rst_gs_violation == 1'b1))));
        M_SATA_OTHER_CMD_GS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (other_cmd_gs_violation == 1'b1)));
        M_SATA_OTHER_CMD_GS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (other_cmd_gs_violation == 1'b1))));
        M_SATA_OTHER_CMD_BS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (other_cmd_bs_violation == 1'b1)));
        M_SATA_OTHER_CMD_BS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (other_cmd_bs_violation == 1'b1))));
        M_SATA_PIO_SETUP_STS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (pio_setup_sts_violation == 1'b1)));
        M_SATA_PIO_SETUP_STS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (pio_setup_sts_violation == 1'b1))));
        M_SATA_REG_D2H_STS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reg_d2h_sts_violation == 1'b1)));
        M_SATA_REG_D2H_STS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (reg_d2h_sts_violation == 1'b1))));
        M_SATA_NO_DATA_AFTER_PIO_SETUP_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (no_data_after_pio_setup_violation == 1'b1)));
        M_SATA_NO_DATA_AFTER_PIO_SETUP_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (no_data_after_pio_setup_violation == 1'b1))));
        M_SATA_DATA_FIS_IN_PIO_CMD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (data_fis_in_pio_cmd_violation == 1'b1)));
        M_SATA_DATA_FIS_IN_PIO_CMD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (data_fis_in_pio_cmd_violation == 1'b1))));
        M_SATA_DMA_IN_CMD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_in_cmd_violation == 1'b1)));
        M_SATA_DMA_IN_CMD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_in_cmd_violation == 1'b1))));
        M_SATA_DMA_ACT_CMD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_act_cmd_violation == 1'b1)));
        M_SATA_DMA_ACT_CMD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_act_cmd_violation == 1'b1))));
        M_SATA_DMA_OUT_CMD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_out_cmd_violation == 1'b1)));
        M_SATA_DMA_OUT_CMD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_out_cmd_violation == 1'b1))));
        M_SATA_PKT_CMD_PIO_SETUP_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (pkt_cmd_pio_setup_violation == 1'b1)));
        M_SATA_PKT_CMD_PIO_SETUP_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (pkt_cmd_pio_setup_violation == 1'b1))));
        M_SATA_REL_BIT_IN_CMD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rel_bit_in_cmd_violation == 1'b1)));
        M_SATA_REL_BIT_IN_CMD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rel_bit_in_cmd_violation == 1'b1))));
        M_SATA_ROK_FOR_10B_DISPERR_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rok_for_10B_disperr_violation == 1'b1)));
        M_SATA_ROK_FOR_10B_DISPERR_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rok_for_10B_disperr_violation == 1'b1))));
        M_SATA_ROK_FOR_INVALID_FIS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rok_for_invalid_fis_violation == 1'b1)));
        M_SATA_ROK_FOR_INVALID_FIS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rok_for_invalid_fis_violation == 1'b1))));
        M_SATA_ROK_FOR_MALF_FIS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rok_for_malf_fis_violation == 1'b1)));
        M_SATA_ROK_FOR_MALF_FIS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rok_for_malf_fis_violation == 1'b1))));
        M_SATA_DMA_ACT_WHEN_AUTO_ACT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_act_when_auto_act_violation == 1'b1)));
        M_SATA_DMA_ACT_WHEN_AUTO_ACT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_act_when_auto_act_violation == 1'b1))));
        M_SATA_AUTO_ACT_IN_RD_TX_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (auto_act_in_rd_tx_violation == 1'b1)));
        M_SATA_AUTO_ACT_IN_RD_TX_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (auto_act_in_rd_tx_violation == 1'b1))));
        M_SATA_AN_WHEN_NOTF_PEND_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (an_when_notf_pend_violation == 1'b1)));
        M_SATA_AN_WHEN_NOTF_PEND_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (an_when_notf_pend_violation == 1'b1))));
        M_SATA_AN_IN_SET_DEV_BIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (an_in_set_dev_bit_violation == 1'b1)));
        M_SATA_AN_IN_SET_DEV_BIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (an_in_set_dev_bit_violation == 1'b1))));
        M_SATA_DMA_TRANSFER_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dma_transfer_count_violation == 1'b1)));
        M_SATA_DMA_TRANSFER_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dma_transfer_count_violation == 1'b1))));
        M_SATA_NCQ_RESP_WO_CMD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ncq_resp_wo_cmd_violation == 1'b1)));
        M_SATA_NCQ_RESP_WO_CMD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ncq_resp_wo_cmd_violation == 1'b1))));
        M_SATA_NCQ_STS_WO_CMD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ncq_sts_wo_cmd_violation == 1'b1)));
        M_SATA_NCQ_STS_WO_CMD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ncq_sts_wo_cmd_violation == 1'b1))));
        M_SATA_NCQ_STS_WO_RESP_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ncq_sts_wo_resp_violation == 1'b1)));
        M_SATA_NCQ_STS_WO_RESP_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ncq_sts_wo_resp_violation == 1'b1))));
        M_SATA_NON_NCQ_WHEN_NCQ_PENDING_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (non_ncq_when_ncq_pending_violation == 1'b1)));
        M_SATA_NON_NCQ_WHEN_NCQ_PENDING_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (non_ncq_when_ncq_pending_violation == 1'b1))));
        M_SATA_NON_NCQ_CMD_STS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (non_ncq_cmd_sts_violation == 1'b1)));
        M_SATA_NON_NCQ_CMD_STS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (non_ncq_cmd_sts_violation == 1'b1))));
        M_SATA_NCQ_REG_D2H_STS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ncq_reg_d2h_sts_violation == 1'b1)));
        M_SATA_NCQ_REG_D2H_STS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ncq_reg_d2h_sts_violation == 1'b1))));
        M_SATA_RD_LOG_CMD_STS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rd_log_cmd_sts_violation == 1'b1)));
        M_SATA_RD_LOG_CMD_STS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rd_log_cmd_sts_violation == 1'b1))));
        M_SATA_DEV_RST_CMD_IN_PM_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (dev_rst_cmd_in_pm_violation == 1'b1)));
        M_SATA_DEV_RST_CMD_IN_PM_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (dev_rst_cmd_in_pm_violation == 1'b1))));
        M_SATA_LEGACY_QUEUED_CMD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (legacy_queued_cmd_violation == 1'b1)));
        M_SATA_LEGACY_QUEUED_CMD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (legacy_queued_cmd_violation == 1'b1))));
        M_SATA_NCQ_CMD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ncq_cmd_violation == 1'b1)));
        M_SATA_NCQ_CMD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ncq_cmd_violation == 1'b1))));
        M_SATA_PACKET_CMD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (packet_cmd_violation == 1'b1)));
        M_SATA_PACKET_CMD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (packet_cmd_violation == 1'b1))));
        M_SATA_SERVICE_CMD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (service_cmd_violation == 1'b1)));
        M_SATA_SERVICE_CMD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (service_cmd_violation == 1'b1))));
        M_SATA_CRC_ERROR_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (crc_error_violation == 1'b1)));
        M_SATA_CRC_ERROR_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (crc_error_violation == 1'b1))));
        M_SATA_DISPARITY_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (disparity_violation == 1'b1)));
        M_SATA_DISPARITY_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (disparity_violation == 1'b1))));
        M_SATA_CODE_ERR_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (code_err_violation == 1'b1)));
        M_SATA_CODE_ERR_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (code_err_violation == 1'b1))));
        M_SATA_NCQ_QUEUE_DEPTH_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ncq_queue_depth_violation == 1'b1)));
        M_SATA_NCQ_QUEUE_DEPTH_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (ncq_queue_depth_violation == 1'b1))));
        M_SATA_RESERVED_FIELD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_field_violation == 1'b1)));
        M_SATA_RESERVED_FIELD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (reserved_field_violation == 1'b1))));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

`endif // QVL_ASSERT_ON
