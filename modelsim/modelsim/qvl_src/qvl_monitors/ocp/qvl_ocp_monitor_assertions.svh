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

  parameter QVL_ERROR = 1;          // 1 = `OVL_ERROR;
  parameter QVL_INFO = 3;           // 3 = `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = Constraints_Mode;  // 0 = `OVL_ASSERT
                                    // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; // 0 = `COVER_NONE;
  parameter QVL_MSG = "QVL_OCP_VIOLATION : ";
  //--------------------------------------------------------------------------
  // Parameter / Known driven checks
  //--------------------------------------------------------------------------

`ifdef QVL_XCHECK_OFF
`else // QVL_XCHECK_OFF

// Master side

generate
  case (ZI_CONSTRAINT_MASTER_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN_MASTER_SIDE 
        A_OCP_SCMDACCEPT_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (scmdaccept),
                          .qualifier (pcmdaccept == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SCMDACCEPT_UNKN"}),
                          .msg            ("SCmdAccept signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SDATAACCEPT_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sdataaccept),
                          .qualifier (pdataaccept == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SDATAACCEPT_UNKN"}),
                          .msg            ("SDataAccept signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SRESP_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sresp),
                          .qualifier (presp == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SRESP_UNKN"}),
                          .msg            ("SResp signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SDATA_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sdata),
                          .qualifier (psdata == 1'b1 && isresp !== null_res)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SDATA_UNKN"}),
                          .msg            ("SData signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SDATAINFO_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sdatainfo),
                          .qualifier (psdatainfo == 1'b1 && isresp !== null_res)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SDATAINFO_UNKN"}),
                          .msg            ("SDataInfo signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SRESPINFO_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (srespinfo),
                          .qualifier (prespinfo == 1'b1 && isresp !== null_res)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SRESPINFO_UNKN"}),
                          .msg            ("SRespInfo signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SRESPLAST_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sresplast),
                          .qualifier (presplast == 1'b1 && isresp !== null_res)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SRESPLAST_UNKN"}),
                          .msg            ("SRespLast signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_STHREADID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sthreadid),
                          .qualifier (THREADS > 1 && isresp !== null_res)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STHREADID_UNKN"}),
                          .msg            ("SThreadID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_STAGID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .qualifier(TAGS > 1 && istaginorder === 1'b0 && 
                          isresp !== null_res),
                          .test_expr (stagid)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STAGID_UNKN"}),
                          .msg            ("STagID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_STAGINORDER_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (staginorder),
                          .qualifier (TAGS > 1 && ptaginorder && isresp !== null_res)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STAGINORDER_UNKN"}),
                          .msg            ("STagInOrder signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
//OCP 2.2 check
        A_OCP_SRESPROWLAST_UNKN:
          assert property ( ASSERT_NEVER_UNKNOWN_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sresprowlast),
                          .qualifier (pblockstride && pburstseq_blck_enable && isresp !== null_res)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SRESPROWLAST_UNKN"}),
                          .msg            ("SRespRowLast signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN_MASTER_SIDE 
        M_OCP_SCMDACCEPT_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (scmdaccept),
                          .qualifier (pcmdaccept == 1'b1)));
        M_OCP_SDATAACCEPT_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sdataaccept),
                          .qualifier (pdataaccept == 1'b1)));
        M_OCP_SRESP_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sresp),
                          .qualifier (presp == 1'b1)));
        M_OCP_SDATA_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sdata),
                          .qualifier (psdata == 1'b1 && isresp !== null_res)));
        M_OCP_SDATAINFO_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sdatainfo),
                          .qualifier (psdatainfo == 1'b1 && isresp !== null_res)));
        M_OCP_SRESPINFO_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (srespinfo),
                          .qualifier (prespinfo == 1'b1 && isresp !== null_res)));
        M_OCP_SRESPLAST_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sresplast),
                          .qualifier (presplast == 1'b1 && isresp !== null_res)));
        M_OCP_STHREADID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sthreadid),
                          .qualifier (THREADS > 1 && isresp !== null_res)));
        M_OCP_STAGID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (stagid),
                          .qualifier(TAGS > 1 && istaginorder === 1'b0 && 
                          isresp !== null_res)));

        M_OCP_STAGINORDER_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (staginorder),
                          .qualifier (TAGS > 1 && ptaginorder && isresp !== null_res)));
//OCP 2.2 constraint
        M_OCP_SRESPROWLAST_UNKN:
          assume property ( ASSERT_NEVER_UNKNOWN_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (sresprowlast),
                          .qualifier (presprowlast && pburstseq_blck_enable &&
                                      isresp !== null_res)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_UNKNOWN_MASTER_SIDE 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

// Slave side

generate
  case (ZI_CONSTRAINT_SLAVE_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN_SLAVE_SIDE 
        A_OCP_MCMD_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mcmd),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MCMD_UNKN"}),
                          .msg            ("MCmd signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATAVALID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatavalid),
                          .qualifier (pdatahandshake == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATAVALID_UNKN"}),
                          .msg            ("MDataValid signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MRESPACCEPT_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mrespaccept),
                          .qualifier (prespaccept == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MRESPACCEPT_UNKN"}),
                          .msg            ("MRespAccept signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MADDR_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (maddr),
                          .qualifier (paddr == 1'b1 && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MADDR_UNKN"}),
                          .msg            ("MAddr signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATA_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdata),
                           .qualifier(pmdata == 1'b1 &&
                          ((imdatavalid === 1'b1 && pdatahandshake == 1'b1)||
                           (imcmd !== idle && pdatahandshake == 1'b0))) ))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATA_UNKN"}),
                          .msg            ("MData signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MADDRSPACE_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (maddrspace),
                          .qualifier (paddrspace == 1'b1 && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MADDRSPACE_UNKN"}),
                          .msg            ("MAddrSpace signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBYTEEN_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mbyteen),
                          .qualifier (pbyteen == 1'b1 && imcmd !== idle &&
                                      (write_type_cmd ? pmdatabyteen != 1'b1 : 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBYTEEN_UNKN"}),
                          .msg            ("MByteEn signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATABYTEEN_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatabyteen),
                          .qualifier (pmdatabyteen == 1'b1 && imdatavalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATABYTEEN_UNKN"}),
                          .msg            ("MDataByteEn signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATAINFO_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatainfo),

                          .qualifier(pmdatainfo == 1'b1 &&
                          ((imdatavalid === 1'b1 && pdatahandshake == 1'b1) ||
                           (imcmd !== idle && pdatahandshake == 1'b0))) ))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATAINFO_UNKN"}),
                          .msg            ("MDataInfo signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MREQINFO_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mreqinfo),
                          .qualifier (preqinfo == 1'b1 && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MREQINFO_UNKN"}),
                          .msg            ("MReqInfo signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MATOMICLENGTH_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (matomiclength),
                          .qualifier (patomiclength == 1'b1 && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MATOMICLENGTH_UNKN"}),
                          .msg            ("MAtomicLength signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTLENGTH_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mburstlength),
                          .qualifier (pburstlength == 1'b1 && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTLENGTH_UNKN"}),
                          .msg            ("MBurstLength signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTPRECISE_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mburstprecise),
                          .qualifier (pburstprecise == 1'b1 && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTPRECISE_UNKN"}),
                          .msg            ("MBurstPrecise signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTSEQ_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mburstseq),
                          .qualifier (pburstseq == 1'b1 && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTSEQ_UNKN"}),
                          .msg            ("MBurstSeq signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTSINGLEREQ_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mburstsinglereq),
                          .qualifier (pburstsinglereq == 1'b1 && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTSINGLEREQ_UNKN"}),
                          .msg            ("MBurstSingleReq signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATALAST_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatalast),
                          .qualifier (pdatalast == 1'b1 && imdatavalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATALAST_UNKN"}),
                          .msg            ("MDataLast signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MREQLAST_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mreqlast),
                          .qualifier (preqlast == 1'b1 && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MREQLAST_UNKN"}),
                          .msg            ("MReqLast signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MCONNID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mconnid),
                          .qualifier (pconnid == 1'b1 && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MCONNID_UNKN"}),
                          .msg            ("MConnID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATATHREADID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatathreadid),
                          .qualifier (THREADS > 1 && imdatavalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATATHREADID_UNKN"}),
                          .msg            ("MDataThreadID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MTHREADID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mthreadid),
                          .qualifier (THREADS > 1 && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTHREADID_UNKN"}),
                          .msg            ("MThreadID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATATAGID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatatagid),
                          .qualifier (TAGS > 1 && imdatavalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATATAGID_UNKN"}),
                          .msg            ("MDataTagID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MTAGID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mtagid),
                          .qualifier (TAGS > 1 && imtaginorder === 1'b0 && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTAGID_UNKN"}),
                          .msg            ("MTagID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MTAGINORDER_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mtaginorder),
                          .qualifier (TAGS > 1 && ptaginorder && imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTAGINORDER_UNKN"}),
                          .msg            ("MTagInOrder signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
//OCP 2.2 checks
        A_OCP_MBLOCKHEIGHT_UNKN:
          assert property ( ASSERT_NEVER_UNKNOWN_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mblockheight),
                          .qualifier (pblockheight && pburstseq_blck_enable &&
                                      imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBLOCKHEIGTH_UNKN"}),
                          .msg            ("MBlockHeight signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBLOCKSTRIDE_UNKN:
          assert property ( ASSERT_NEVER_UNKNOWN_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mblockstride),
                          .qualifier (pblockstride && pburstseq_blck_enable && 
                                      imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBLOCKSTRIDE_UNKN"}),
                          .msg            ("MBlockStride signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MREQROWLAST_UNKN:
          assert property ( ASSERT_NEVER_UNKNOWN_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mreqrowlast),
                          .qualifier (preqrowlast && pburstseq_blck_enable && 
                                      imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MREQROWLAST_UNKN"}),
                          .msg            ("MReqRrowLast signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATAROWLAST_UNKN:
          assert property ( ASSERT_NEVER_UNKNOWN_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatarowlast),
                          .qualifier (pdatarowlast && pburstseq_blck_enable && 
                                      imcmd !== idle)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATAROWLAST_UNKN"}),
                          .msg            ("MDataRowLast signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN_SLAVE_SIDE 
        M_OCP_MCMD_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mcmd),
                          .qualifier (1'b1)));
        M_OCP_MDATAVALID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatavalid),
                          .qualifier (pdatahandshake == 1'b1)));
        M_OCP_MRESPACCEPT_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mrespaccept),
                          .qualifier (prespaccept == 1'b1)));
        M_OCP_MADDR_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (maddr),
                          .qualifier (paddr == 1'b1 && imcmd !== idle)));
        M_OCP_MDATA_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdata),
                          .qualifier(pmdata == 1'b1 &&
                          ((imdatavalid === 1'b1 && pdatahandshake == 1'b1)||
                           (imcmd !== idle && pdatahandshake == 1'b0))) ));
        M_OCP_MADDRSPACE_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (maddrspace),
                          .qualifier (paddrspace == 1'b1 && imcmd !== idle)));
        M_OCP_MBYTEEN_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mbyteen),
                          .qualifier (pbyteen == 1'b1 && imcmd !== idle &&
                                      (write_type_cmd ? pmdatabyteen != 1'b1 : 1'b1))));
        M_OCP_MDATABYTEEN_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatabyteen),
                          .qualifier (pmdatabyteen == 1'b1 && imdatavalid === 1'b1)));
        M_OCP_MDATAINFO_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatainfo),
                          .qualifier(pmdatainfo == 1'b1 &&
                          ((imdatavalid === 1'b1 && pdatahandshake == 1'b1) ||
                           (imcmd !== idle && pdatahandshake == 1'b0))) ));
        M_OCP_MREQINFO_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mreqinfo),
                          .qualifier (preqinfo == 1'b1 && imcmd !== idle)));
        M_OCP_MATOMICLENGTH_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (matomiclength),
                          .qualifier (patomiclength == 1'b1 && imcmd !== idle)));
        M_OCP_MBURSTLENGTH_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mburstlength),
                          .qualifier (pburstlength == 1'b1 && imcmd !== idle)));
        M_OCP_MBURSTPRECISE_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mburstprecise),
                          .qualifier (pburstprecise == 1'b1 && imcmd !== idle)));
        M_OCP_MBURSTSEQ_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mburstseq),
                          .qualifier (pburstseq == 1'b1 && imcmd !== idle)));
        M_OCP_MBURSTSINGLEREQ_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mburstsinglereq),
                          .qualifier (pburstsinglereq == 1'b1 && imcmd !== idle)));
        M_OCP_MDATALAST_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatalast),
                          .qualifier (pdatalast == 1'b1 && imdatavalid === 1'b1)));
        M_OCP_MREQLAST_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mreqlast),
                          .qualifier (preqlast == 1'b1 && imcmd !== idle)));
        M_OCP_MCONNID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mconnid),
                          .qualifier (pconnid == 1'b1 && imcmd !== idle)));
        M_OCP_MDATATHREADID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatathreadid),
                          .qualifier (THREADS > 1 && imdatavalid === 1'b1)));
        M_OCP_MTHREADID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mthreadid),
                          .qualifier (THREADS > 1 && imcmd !== idle)));
        M_OCP_MDATATAGID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatatagid),
                          .qualifier (TAGS > 1 && imdatavalid === 1'b1)));
        M_OCP_MTAGID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mtagid),
                          .qualifier (TAGS > 1 && imtaginorder === 1'b0 && imcmd !== idle)));
        M_OCP_MTAGINORDER_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mtaginorder),
                          .qualifier (TAGS > 1 && ptaginorder && imcmd !== idle)));
 //OCP 2.2 constraints
        M_OCP_MBLOCKHEIGHT_UNKN:
          assume property ( ASSERT_NEVER_UNKNOWN_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mblockheight),
                          .qualifier (pblockheight && pburstseq_blck_enable &&
                                      imcmd !== idle)));
        M_OCP_MBLOCKSTRIDE_UNKN:
          assume property ( ASSERT_NEVER_UNKNOWN_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mblockstride),
                          .qualifier (pblockstride && pburstseq_blck_enable &&
                                      imcmd !== idle)));
        M_OCP_MREQROWLAST_UNKN:
          assume property ( ASSERT_NEVER_UNKNOWN_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mreqrowlast),
                          .qualifier (preqrowlast && pburstseq_blck_enable && 
                                      imcmd !== idle)));
        M_OCP_MDATAROWLAST_UNKN:
          assume property ( ASSERT_NEVER_UNKNOWN_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (mdatarowlast),
                          .qualifier (pdatarowlast && pburstseq_blck_enable &&
                                      imcmd !== idle)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_UNKNOWN_SLAVE_SIDE 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

// Core side

generate
  case (ZI_CONSTRAINT_CORE_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN_CORE_SIDE 
        A_OCP_CONTROL_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (control),
                          .qualifier (pcontrol == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROL_UNKN"}),
                          .msg            ("Control signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_CORE_SIDE));
        A_OCP_CONTROLWR_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (controlwr),
                          .qualifier (pcontrolwr == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROLWR_UNKN"}),
                          .msg            ("ControlWr signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_CORE_SIDE));
        A_OCP_STATUSRD_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (statusrd),
                          .qualifier (pstatusrd == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STATUSRD_UNKN"}),
                          .msg            ("StatusRd signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_CORE_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN_CORE_SIDE 
        M_OCP_CONTROL_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (control),
                          .qualifier (pcontrol == 1'b1)));
        M_OCP_CONTROLWR_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (controlwr),
                          .qualifier (pcontrolwr == 1'b1)));
        M_OCP_STATUSRD_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (statusrd),
                          .qualifier (pstatusrd == 1'b1)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_UNKNOWN_CORE_SIDE 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

// System side

generate
  case (ZI_CONSTRAINT_SYSTEM_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN_SYSTEM_SIDE 
        A_OCP_CONTROLBUSY_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (controlbusy),
                          .qualifier (pcontrolbusy == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROLBUSY_UNKN"}),
                          .msg            ("ControlBusy signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SYSTEM_SIDE));
        A_OCP_STATUS_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (status),
                          .qualifier (pstatus == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STATUS_UNKN"}),
                          .msg            ("Status signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SYSTEM_SIDE));
        A_OCP_STATUSBUSY_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (statusbusy),
                          .qualifier (pstatusbusy == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STATUSBUSY_UNKN"}),
                          .msg            ("StatusBusy signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SYSTEM_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN_SYSTEM_SIDE 
        M_OCP_CONTROLBUSY_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (controlbusy),
                          .qualifier (pcontrolbusy == 1'b1)));
        M_OCP_STATUS_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (status),
                          .qualifier (pstatus == 1'b1)));
        M_OCP_STATUSBUSY_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .test_expr (statusbusy),
                          .qualifier (pstatusbusy == 1'b1)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_UNKNOWN_SYSTEM_SIDE 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

`endif // QVL_XCHECK_OFF

  //--------------------------------------------------------------------------
  // Protocol checks
  //--------------------------------------------------------------------------

// Property type

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_OCP_IMPROPER_BYTEEN_ENABLING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (improper_byteen_enabling == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_IMPROPER_BYTEEN_ENABLING"}),
                          .msg            ("BYTEEN should be enabled only if MDATA or SDATA is enabled and DATA_WDTH is an integer multiple of 8."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_IMPROPER_MDATABYTEEN_ENABLING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (improper_mdatabyteen_enabling == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_IMPROPER_MDATABYTEEN_ENABLING"}),
                          .msg            ("MDATABYTEEN should be enabled only if MDATA is enabled , DATAHANDSHAKE is enabled and DATA_WDTH is an integer multiple of 8."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_RESPACCEPT_ENABLED_WITHOUT_RESP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (respaccept_enabled_without_resp == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPACCEPT_ENABLED_WITHOUT_RESP"}),
                          .msg            ("RESPACCEPT should not be enabled if RESP is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_SDATA_ENABLED_WITHOUT_RESP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sdata_enabled_without_resp == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SDATA_ENABLED_WITHOUT_RESP"}),
                          .msg            ("SDATA should not be enabled if RESP is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_SDATAINFO_ENABLED_WITHOUT_RESP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sdatainfo_enabled_without_resp == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SDATAINFO_ENABLED_WITHOUT_RESP"}),
                          .msg            ("SDATAINFO should not be enabled if RESP is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_RESPINFO_ENABLED_WITHOUT_RESP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (respinfo_enabled_without_resp == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPINFO_ENABLED_WITHOUT_RESP"}),
                          .msg            ("RESPINFO should not be enabled if RESP is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_RESPLAST_ENABLED_WITHOUT_RESP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resplast_enabled_without_resp == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPLAST_ENABLED_WITHOUT_RESP"}),
                          .msg            ("RESPLAST should not be enabled if RESP is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_DATAACCEPT_ENABLED_WITHOUT_DATAHANDSHAKE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (dataaccept_enabled_without_datahandshake == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DATAACCEPT_ENABLED_WITHOUT_DATAHANDSHAKE"}),
                          .msg            ("DATAACCEPT should not be enabled if DATAHANDSHAKE is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_IMPROPER_MDATAINFO_ENABLING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (improper_mdatainfo_enabling == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_IMPROPER_MDATAINFO_ENABLING"}),
                          .msg            ("MDATAINFO should not be enabled if DATA_WDTH is not an integer multiple of 8."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_INCORRECT_MDATAINFO_WDTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (incorrect_mdatainfo_wdth == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_INCORRECT_MDATAINFO_WDTH"}),
                          .msg            ("MDATAINFO_WDTH should be greater than or equal to MDATAINFOBYTE_WDTH*DATA_WDTH/8."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_IMPROPER_SDATAINFO_ENABLING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (improper_sdatainfo_enabling == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_IMPROPER_SDATAINFO_ENABLING"}),
                          .msg            ("SDATAINFO should not be enabled if DATA_WDTH is not an integer multiple of 8."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_INCORRECT_SDATAINFO_WDTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (incorrect_sdatainfo_wdth == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_INCORRECT_SDATAINFO_WDTH"}),
                          .msg            ("SDATAINFO_WDTH should be greater than or equal to SDATAINFOBYTE_WDTH*DATA_WDTH/8."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_BURSTSINGLEREQ_ENABLED_WITHOUT_DATAHANDSHAKE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burstsinglereq_enabled_without_datahandshake == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BURSTSINGLEREQ_ENABLED_WITHOUT_DATAHANDSHAKE"}),
                          .msg            ("If any write-type commands are enabled, BURSTSINGLEREQ should not be enabled if DATAHANDSHAKE is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_DATALAST_ENABLED_WITHOUT_DATAHANDSHAKE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (datalast_enabled_without_datahandshake == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DATALAST_ENABLED_WITHOUT_DATAHANDSHAKE"}),
                          .msg            ("DATALAST should not be enabled if DATAHANDSHAKE is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_CONTROLBUSY_ENABLED_WITHOUT_CONTROLWR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (controlbusy_enabled_without_controlwr == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROLBUSY_ENABLED_WITHOUT_CONTROLWR"}),
                          .msg            ("CONTROLBUSY should be enabled only if CONTROLWR is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_CONTROLWR_ENABLED_WITHOUT_CONTROL: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (controlwr_enabled_without_control == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROLWR_ENABLED_WITHOUT_CONTROL"}),
                          .msg            ("CONTROLWR should not be enabled if CONTROL is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_STATUSBUSY_ENABLED_WITHOUT_STATUS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (statusbusy_enabled_without_status == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STATUSBUSY_ENABLED_WITHOUT_STATUS"}),
                          .msg            ("STATUSBUSY should not be enabled if STATUS is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_STATUSRD_ENABLED_WITHOUT_STATUS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (statusrd_enabled_without_status == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STATUSRD_ENABLED_WITHOUT_STATUS"}),
                          .msg            ("STATUSRD should not be enabled if STATUS is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_NONE_OF_THE_COMMANDS_ENABLED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (none_of_the_commands_enabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_NONE_OF_THE_COMMANDS_ENABLED"}),
                          .msg            ("At least one of the COMMAND_ENABLEs should be set to 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_WRITENONPOST_ENABLE_SET_WITHOUT_WRITERESP_ENABLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (writenonpost_enable_set_without_writeresp_enable == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_WRITENONPOST_ENABLE_SET_WITHOUT_WRITERESP_ENABLE"}),
                          .msg            ("WRITENONPOST_ENABLE should be set to 1 only if WRITERESP_ENABLE is set to 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_RDLWRC_ENABLE_SET_WITHOUT_WRITERESP_ENABLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rdlwrc_enable_set_without_writeresp_enable == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RDLWRC_ENABLE_SET_WITHOUT_WRITERESP_ENABLE"}),
                          .msg            ("RDLWRC_ENABLE should be set to 1 only if WRITERESP_ENABLE is set to 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_RESP_NOT_ENABLED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resp_not_enabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESP_NOT_ENABLED"}),
                          .msg            ("RESP should be enabled if any read-type command is enabled or WRITERESP_ENABLE is set to 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_READEX_ENABLE_SET_WITHOUT_WRITE_ENABLE_OR_WRITENONPOST_ENABLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (readex_enable_set_without_write_enable_or_writenonpost_enable
                                                                        == 1'b1)
               ) )

          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_READEX_ENABLE_SET_WITHOUT_WRITE_ENABLE_OR_WRITENONPOST_ENABLE"}),
                          .msg            ("READEX_ENABLE should not be enabled if WRITE_ENABLE or WRITENONPOST_ENABLE is not set to 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_NONE_OF_THE_BURST_SEQUENCE_ENABLED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (none_of_the_burst_sequence_enabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_NONE_OF_THE_BURST_SEQUENCE_ENABLED"}),
                          .msg            ("If BURSTSEQ is enabled, at least one of the burst sequence parameters should be enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_FORCE_ALIGNED_ENABLED_WHEN_DATA_WDTH_IS_NON_POWER_OF_TWO: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                  (force_aligned_enabled_when_data_wdth_is_non_power_of_two == 
                                                                          1'b1)
               ) )
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_FORCE_ALIGNED_ENABLED_WHEN_DATA_WDTH_IS_NON_POWER_OF_TWO"}),
                          .msg            ("FORCE_ALIGNED should be enabled only when DATA_WDTH is set to a power-of-two value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_BURSTSINGLEREQ_ENABLED_WITHOUT_BURSTPRECISE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burstsinglereq_enabled_without_burstprecise == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BURSTSINGLEREQ_ENABLED_WITHOUT_BURSTPRECISE"}),
                          .msg            ("BURSTSINGLEREQ should not be enabled if BURSTPRECISE is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_DATAHANDSHAKE_WITHOUT_WRITE_TYPE_CMD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (improper_datahandshake_enabling == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DATAHANDSHAKE_WITHOUT_WRITE_TYPE_CMD"}),
                          .msg            ("DATAHANDSHAKE should be enabled only if at least one of the write-type command is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_MTHREADBUSY_ENABLED_WITHOUT_RESP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_enabled_without_resp == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTHREADBUSY_ENABLED_WITHOUT_RESP"}),
                          .msg            ("MTHREADBUSY should not be enabled if RESP is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_WRAP_SEQUENCE_NON_POWER_OF_TWO_DATA_WDTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrap_sequence_non_power_of_two_data_wdth == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_WRAP_SEQUENCE_NON_POWER_OF_TWO_DATA_WDTH"}),
                          .msg            ("Burst address sequence WRAP should be enabled only if DATA_WDTH is a power-of-two number of bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_XOR_SEQUENCE_NON_POWER_OF_TWO_DATA_WDTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (xor_sequence_non_power_of_two_data_wdth == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_XOR_SEQUENCE_NON_POWER_OF_TWO_DATA_WDTH"}),
                          .msg            ("Burst address sequence XOR should be enabled only if DATA_WDTH is a power-of-two number of bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_BURSTSINGLEREQ_ENABLED_WHILE_ONLY_UNKN_ADDR_SEQ_ENABLED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                  (burstsinglereq_enabled_while_only_unkn_addr_seq_enabled == 
                                                                           1'b1)
               )  )
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BURSTSINGLEREQ_ENABLED_WHILE_ONLY_UNKN_ADDR_SEQ_ENABLED"}),
                          .msg            ("BURSTSINGLEREQ should not be enabled if the only enabled burst address sequence is UNKN."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_MTHREADBUSY_EXACT_ENABLED_WITHOUT_MTHREADBUSY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_exact_enabled_without_mthreadbusy == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTHREADBUSY_EXACT_ENABLED_WITHOUT_MTHREADBUSY"}),
                          .msg            ("MTHREADBUSY_EXACT should be enabled only if MTHREADBUSY is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_SDATATHREADBUSY_EXACT_ENABLED_WITHOUT_SDATATHREADBUSY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (sdatathreadbusy_exact_enabled_without_sdatathreadbusy == 1'b1)
               ) )

          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SDATATHREADBUSY_EXACT_ENABLED_WITHOUT_SDATATHREADBUSY"}),
                          .msg            ("SDATATHREADBUSY_EXACT should be enabled only if SDATATHREADBUSY is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_STHREADBUSY_EXACT_ENABLED_WITHOUT_STHREADBUSY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadbusy_exact_enabled_without_sthreadbusy == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STHREADBUSY_EXACT_ENABLED_WITHOUT_STHREADBUSY"}),
                          .msg            ("STHREADBUSY_EXACT should be enabled only if STHREADBUSY is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_ATOMICLENGTH_WITHOUT_BURSTLENGTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (atomiclength_without_burstlength == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_ATOMICLENGTH_WITHOUT_BURSTLENGTH"}),
                          .msg            ("ATOMICLENGTH should be enabled only if BURSTLENGTH is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_BURSTPRECISE_WITHOUT_BURSTLENGTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burstprecise_without_burstlength == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BURSTPRECISE_WITHOUT_BURSTLENGTH"}),
                          .msg            ("BURSTPRECISE should be enabled only if BURSTLENGTH is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_BURSTSEQ_WITHOUT_BURSTLENGTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burstseq_without_burstlength == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BURSTSEQ_WITHOUT_BURSTLENGTH"}),
                          .msg            ("BURSTSEQ should be enabled only if BURSTLENGTH is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_BURSTSINGLEREQ_WITHOUT_BURSTLENGTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burstsinglereq_without_burstlength == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BURSTSINGLEREQ_WITHOUT_BURSTLENGTH"}),
                          .msg            ("BURSTSINGLEREQ should be enabled only if BURSTLENGTH is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_STHREADBUSY_WITHOUT_CMDACCEPT_AND_STHREADBUSY_EXACT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
.test_expr
                  (sthreadbusy_without_cmdaccept_and_sthreadbusy_exact == 1'b1)
               ))


          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STHREADBUSY_WITHOUT_CMDACCEPT_AND_STHREADBUSY_EXACT"}),
                          .msg            ("STHREADBUSY should not be enabled when CMDACCEPT and STHREADBUSY_EXACT are not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_CMDACCEPT_WHILE_STHREADBUSY_AND_STHREADBUSY_EXACT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (cmdaccept_while_sthreadbusy_and_sthreadbusy_exact == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CMDACCEPT_WHILE_STHREADBUSY_AND_STHREADBUSY_EXACT"}),
                          .msg            ("CMDACCEPT should not be enabled when both STHREADBUSY and STHREADBUSY_EXACT are enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_SDATATHREADBUSY_WITHOUT_DATAACCEPT_AND_SDATATHREADBUSY_EXACT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                  (sdatathreadbusy_without_dataaccept_and_sdatathreadbusy_exact 
                                                                       == 1'b1)
               ) )

          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SDATATHREADBUSY_WITHOUT_DATAACCEPT_AND_SDATATHREADBUSY_EXACT"}),
                          .msg            ("SDATATHREADBUSY should not be enabled when DATAACCEPT and SDATATHREADBUSY_EXACT are not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_DATAACCEPT_WHILE_SDATATHREADBUSY_AND_SDATATHREADBUSY_EXACT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (dataaccept_while_sdatathreadbusy_and_sdatathreadbusy_exact == 
                                                                          1'b1)
               ) )


          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DATAACCEPT_WHILE_SDATATHREADBUSY_AND_SDATATHREADBUSY_EXACT"}),
                          .msg            ("DATAACCEPT should not be enabled when both SDATATHREADBUSY and SDATATHREADBUSY_EXACT are enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_MTHREADBUSY_WITHOUT_RESPACCEPT_AND_MTHREADBUSY_EXACT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                  (mthreadbusy_without_respaccept_and_mthreadbusy_exact == 1'b1)
               ) )
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTHREADBUSY_WITHOUT_RESPACCEPT_AND_MTHREADBUSY_EXACT"}),
                          .msg            ("MTHREADBUSY should not be enabled when RESPACCEPT and MTHREADBUSY_EXACT are not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_RESPACCEPT_WHILE_MTHREADBUSY_AND_MTHREADBUSY_EXACT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (respaccept_while_mthreadbusy_and_mthreadbusy_exact == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPACCEPT_WHILE_MTHREADBUSY_AND_MTHREADBUSY_EXACT"}),
                          .msg            ("RESPACCEPT should not be enabled when both MTHREADBUSY and MTHREADBUSY_EXACT are enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_REQ_BLOCKING_WHILE_DATAHANDSHAKE_NON_BLOCKING_FLOW_CONTROL: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (req_blocking_while_datahandshake_non_blocking_flow_control == 
                                                                          1'b1)
               ) )
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_REQ_BLOCKING_WHILE_DATAHANDSHAKE_NON_BLOCKING_FLOW_CONTROL"}),
                          .msg            ("When datahandshake phase is configured for non-blocking flow control, request phase should not be configured for blocking flow control."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_DATAHANDSHAKE_BLOCKING_WHILE_REQ_NON_BLOCKING_FLOW_CONTROL: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (datahandshake_blocking_while_req_non_blocking_flow_control == 
                                                                          1'b1)
               ) )

          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DATAHANDSHAKE_BLOCKING_WHILE_REQ_NON_BLOCKING_FLOW_CONTROL"}),
                          .msg            ("When request phase is configured for non-blocking flow control, datahandshake phase should not be configured for blocking flow control."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_BURSTLENGTH_WDTH_VALUE_OF_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burstlength_wdth_value_of_1 == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BURSTLENGTH_WDTH_VALUE_OF_1"}),
                          .msg            ("BURSTLENGTH_WDTH value should not be set to 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_THREADID_WDTH_NOT_LOG2_OF_THREADS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (threadid_wdth_not_log2_of_threads == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_THREADID_WDTH_NOT_LOG2_OF_THREADS"}),
                          .msg            ("Value of THREADID_WDTH parameter should be equal to the next whole integer of log2 of THREADS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_MDATALAST_WITHOUT_BURSTLENGTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatalast_without_burstlength == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATALAST_WITHOUT_BURSTLENGTH"}),
                          .msg            ("MDATALAST should be enabled only if BURSTLENGTH is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_MREQLAST_WITHOUT_BURSTLENGTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mreqlast_without_burstlength == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MREQLAST_WITHOUT_BURSTLENGTH"}),
                          .msg            ("MREQLAST should be enabled only if BURSTLENGTH is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_MRESPLAST_WITHOUT_BURSTLENGTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mresplast_without_burstlength == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MRESPLAST_WITHOUT_BURSTLENGTH"}),
                          .msg            ("MRESPLAST should be enabled only if BURSTLENGTH is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_TAGINORDER_WHEN_TAGS_NOT_GREATER_THAN_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (taginorder_when_tags_not_greater_than_1 == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_TAGINORDER_WHEN_TAGS_NOT_GREATER_THAN_1"}),
                          .msg            ("TAGINORDER should not be set when tagged transactions are not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_TAGID_WDTH_NOT_LOG2_OF_TAGS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (tagid_wdth_not_log2_of_tags == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_TAGID_WDTH_NOT_LOG2_OF_TAGS"}),
                          .msg            ("Value of TAGID_WDTH parameter should be equal to the next whole integer of log2 of TAGS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
//OCP 2.2 configuration checks
        A_OCP_REQROWLAST_WITHOUT_BURSTLENGTH:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reqrowlast_without_burstlength == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_REQROWLAST_WITHOUT_BURSTLENGTH"}),
                          .msg            ("reqrowlast can only be enabled if burstlength is also enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_REQROWLAST_WITHOUT_REQLAST_AND_BURSTSEQ_BLCK_ENABLE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reqrowlast_without_reqlast_and_burstseq_blck_enable == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_REQROWLAST_WITHOUT_REQLAST_AND_BURSTSEQ_BLCK_ENABLE"}),
                          .msg            ("reqlowlast can only be enabled if both reqlast and burstseq_blck_enable are enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_BLOCKHEIGHT_WITHOUT_BURSTSEQ_BLCK_ENABLE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (blockheight_without_burstseq_blck_enable == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BLOCKHEIGHT_WITHOUT_BURSTSEQ_BLCK_ENABLE"}),
                          .msg            ("blockheight can only be enabled if burstseq_blck_enable is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_BLOCKSTRIDE_WITHOUT_BURSTSEQ_BLCK_ENABLE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (blockstride_without_burstseq_blck_enable == 1'b1)))
          else qvl_error_t( 
                          .err_msg        ({QVL_MSG,"A_OCP_BLOCKSTRIDE_WITHOUT_BURSTSEQ_BLCK_ENABLE"}),
                          .msg            ("blockstride can only be enabled if burstseq_blck_enable is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_ILLEGAL_BLOCKHEIGHT_WIDTH:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (illegal_blockheight_width == 1'b1)))
          else qvl_error_t( 
                          .err_msg        ({QVL_MSG,"A_OCP_ILLEGAL_BLOCKHEIGHT_WIDTH"}),
                          .msg            ("BLOCKHEIGHT_WIDTH must be greater than 1 if blockheight is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_DATAROWLAST_WITHOUT_DATAHANDSHAKE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (datarowlast_without_datahandshake == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DATAROWLAST_WITHOUT_DATAHANDSHAKE"}),
                          .msg            ("datarowlast can only be enabled if datahandshake is also enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_DATAROWLAST_WITHOUT_BURSTLENGTH:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (datarowlast_without_burstlength == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DATAROWLAST_WITHOUT_BURSTLENGTH"}),
                          .msg            ("datarowlast can only be enabled if burstlength is also enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_DATAROWLAST_WITHOUT_DATALAST_AND_BURSTSEQ_BLCK_ENABLE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (datarowlast_without_datalast_and_burstseq_blck_enable == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DATAROWLAST_WITHOUT_BURSTLENGTH"}),
                          .msg            ("datarowlast can only be enabled if both datalast and burstseq_blck_enable are enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_RESPROWLAST_WITHOUT_RESP:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resprowlast_without_resp == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPROWLAST_WITHOUT_RESP"}),
                          .msg            ("resprowlast can only be enabled if response is also enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_RESPROWLAST_WITHOUT_BURSTLENGTH:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resprowlast_without_burstlength == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPROWLAST_WITHOUT_BURSTLENGTH"}),
                          .msg            ("resprowlast can only be enabled if burstlength is also enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_RESPROWLAST_WITHOUT_RESPLAST_AND_BURSTSEQ_BLCK_ENABLE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resprowlast_without_resplast_and_burstseq_blck_enable == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPROWLAST_WITHOUT_DATALAST_AND_BURSTSEQ_BLCK_ENABLE"}),
                          .msg            ("resprowlast can only be enabled if both resplast and burstseq_blck_enable are enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_ILLEGAL_SETTING_OF_MTHREADBUSY_PIPELINED:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_pipelined_enabled_without_mthreadbusy_exact == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_ILLEGAL_SETTING_OF_MTHREADBUSY_PIPELINED"}),
                          .msg            ("mthreadbusy_pipelined can only be enabled if mthreadbusy_exact is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_ILLEGAL_SETTING_OF_SDATATHREADBUSY_PIPELINED:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sdatathreadbusy_pipelined_enabled_without_sdatathreadbusy_exact == 1'b1)))
          else qvl_error_t( 
                          .err_msg        ({QVL_MSG,"A_OCP_ILLEGAL_SETTING_OF_SDATATHREADBUSY_PIPELINED"}),
                          .msg            ("sdatathreadbusy_pipelined can only be enabled if sdatathreadbusy_exact is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_ILLEGAL_SETTING_OF_STHREADBUSY_PIPELINED:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadbusy_pipelined_enabled_without_sthreadbusy_exact == 1'b1)))
          else qvl_error_t( 
                          .err_msg        ({QVL_MSG,"A_OCP_ILLEGAL_SETTING_OF_STHREADBUSY_PIPELINED"}),
                          .msg            ("sthreadbusy_pipelined can only be enabled if sthreadbusy_exact is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_RESPACCEPT_WITH_MTHREADBUSY_EXACT_ENABLED:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (respaccept_enabled_with_mthreadbusy_exact == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPACCEPT_WITH_MTHREADBUSY_EXACT_ENABLED"}),
                          .msg            ("respaccept can only be enabled when mthreadbusy_exact is not enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_MTHREADBUSY_WITHOUT_EXACTLY_ONE_OF_MTHREADBUSY_EXACT_AND_RESPACCEPT:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_without_exactly_one_of_mthreadbusy_exact_and_respaccept == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTHREADBUSY_WITHOUT_EXACTLY_ONE_OF_MTHREADBUSY_EXACT_AND_RESPACCEPT"}),
                          .msg            ("mthreadbusy can only be enabled if exactly one of mthreadbusy_exact and respaccept is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));

// OCP 3.0 configuration check
        A_OCP_NONPOSTED_WRITE_CONFIGURED_WITHOUT_WRITERESP_ENABLED:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (nonposted_write_without_writeresp_enabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_NONPOSTED_WRITE_CONFIGURED_WITHOUT_WRITERESP_ENABLED"}),
                          .msg            ("Nonposted write can only be enabled if write response is also enabled"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));

// OCP disconnect configuration check
	A_OCP_CONNECTCAP_NOT_TIED_OFF_TO_ZERO_WHILE_CONNECTION_PARAMETER_CONFIGURED_ZERO:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (connectcap_not_tied_off_to_zero_while_connection_parameter_configured_zero == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONNECTCAP_NOT_TIED_OFF_TO_ZERO_WHILE_CONNECTION_PARAMETER_CONFIGURED_ZERO"}),
                          .msg            ("Connectcap must be configured as zero while parameter CONNECTION is set to zero"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_OCP_IMPROPER_BYTEEN_ENABLING: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (improper_byteen_enabling == 1'b1)));
        M_OCP_IMPROPER_MDATABYTEEN_ENABLING: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (improper_mdatabyteen_enabling == 1'b1)));
        M_OCP_RESPACCEPT_ENABLED_WITHOUT_RESP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (respaccept_enabled_without_resp == 1'b1)));
        M_OCP_SDATA_ENABLED_WITHOUT_RESP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sdata_enabled_without_resp == 1'b1)));
        M_OCP_SDATAINFO_ENABLED_WITHOUT_RESP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sdatainfo_enabled_without_resp == 1'b1)));
        M_OCP_RESPINFO_ENABLED_WITHOUT_RESP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (respinfo_enabled_without_resp == 1'b1)));
        M_OCP_RESPLAST_ENABLED_WITHOUT_RESP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resplast_enabled_without_resp == 1'b1)));
        M_OCP_DATAACCEPT_ENABLED_WITHOUT_DATAHANDSHAKE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (dataaccept_enabled_without_datahandshake == 1'b1)));
        M_OCP_IMPROPER_MDATAINFO_ENABLING: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (improper_mdatainfo_enabling == 1'b1)));
        M_OCP_INCORRECT_MDATAINFO_WDTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (incorrect_mdatainfo_wdth == 1'b1)));
        M_OCP_IMPROPER_SDATAINFO_ENABLING: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (improper_sdatainfo_enabling == 1'b1)));
        M_OCP_INCORRECT_SDATAINFO_WDTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (incorrect_sdatainfo_wdth == 1'b1)));
        M_OCP_BURSTSINGLEREQ_ENABLED_WITHOUT_DATAHANDSHAKE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burstsinglereq_enabled_without_datahandshake == 1'b1)));
        M_OCP_DATALAST_ENABLED_WITHOUT_DATAHANDSHAKE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (datalast_enabled_without_datahandshake == 1'b1)));
        M_OCP_CONTROLBUSY_ENABLED_WITHOUT_CONTROLWR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (controlbusy_enabled_without_controlwr == 1'b1)));
        M_OCP_CONTROLWR_ENABLED_WITHOUT_CONTROL: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (controlwr_enabled_without_control == 1'b1)));
        M_OCP_STATUSBUSY_ENABLED_WITHOUT_STATUS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (statusbusy_enabled_without_status == 1'b1)));
        M_OCP_STATUSRD_ENABLED_WITHOUT_STATUS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (statusrd_enabled_without_status == 1'b1)));
        M_OCP_NONE_OF_THE_COMMANDS_ENABLED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (none_of_the_commands_enabled == 1'b1)));
        M_OCP_WRITENONPOST_ENABLE_SET_WITHOUT_WRITERESP_ENABLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (writenonpost_enable_set_without_writeresp_enable == 
                           1'b1)));
        M_OCP_RDLWRC_ENABLE_SET_WITHOUT_WRITERESP_ENABLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rdlwrc_enable_set_without_writeresp_enable == 1'b1)));
        M_OCP_RESP_NOT_ENABLED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resp_not_enabled == 1'b1)));
        M_OCP_READEX_ENABLE_SET_WITHOUT_WRITE_ENABLE_OR_WRITENONPOST_ENABLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (readex_enable_set_without_write_enable_or_writenonpost_enable
                                                                        == 1'b1)
               ) );
        M_OCP_NONE_OF_THE_BURST_SEQUENCE_ENABLED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (none_of_the_burst_sequence_enabled == 1'b1)));
        M_OCP_FORCE_ALIGNED_ENABLED_WHEN_DATA_WDTH_IS_NON_POWER_OF_TWO: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                  (force_aligned_enabled_when_data_wdth_is_non_power_of_two == 
                                                                          1'b1)) );
        M_OCP_BURSTSINGLEREQ_ENABLED_WITHOUT_BURSTPRECISE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burstsinglereq_enabled_without_burstprecise == 1'b1)));
        M_OCP_DATAHANDSHAKE_WITHOUT_WRITE_TYPE_CMD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (improper_datahandshake_enabling == 1'b1)));
        M_OCP_MTHREADBUSY_ENABLED_WITHOUT_RESP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_enabled_without_resp == 1'b1)));
        M_OCP_WRAP_SEQUENCE_NON_POWER_OF_TWO_DATA_WDTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrap_sequence_non_power_of_two_data_wdth == 1'b1)));
        M_OCP_XOR_SEQUENCE_NON_POWER_OF_TWO_DATA_WDTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (xor_sequence_non_power_of_two_data_wdth == 1'b1)));
        M_OCP_BURSTSINGLEREQ_ENABLED_WHILE_ONLY_UNKN_ADDR_SEQ_ENABLED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                  (burstsinglereq_enabled_while_only_unkn_addr_seq_enabled == 
                                                                           1'b1)
               ) );

        M_OCP_MTHREADBUSY_EXACT_ENABLED_WITHOUT_MTHREADBUSY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_exact_enabled_without_mthreadbusy == 1'b1)));
        M_OCP_SDATATHREADBUSY_EXACT_ENABLED_WITHOUT_SDATATHREADBUSY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (sdatathreadbusy_exact_enabled_without_sdatathreadbusy == 1'b1)
               ) );

        M_OCP_STHREADBUSY_EXACT_ENABLED_WITHOUT_STHREADBUSY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadbusy_exact_enabled_without_sthreadbusy == 1'b1)));
        M_OCP_ATOMICLENGTH_WITHOUT_BURSTLENGTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (atomiclength_without_burstlength == 1'b1)));
        M_OCP_BURSTPRECISE_WITHOUT_BURSTLENGTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burstprecise_without_burstlength == 1'b1)));
        M_OCP_BURSTSEQ_WITHOUT_BURSTLENGTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burstseq_without_burstlength == 1'b1)));
        M_OCP_BURSTSINGLEREQ_WITHOUT_BURSTLENGTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burstsinglereq_without_burstlength == 1'b1)));
        M_OCP_STHREADBUSY_WITHOUT_CMDACCEPT_AND_STHREADBUSY_EXACT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                  (sthreadbusy_without_cmdaccept_and_sthreadbusy_exact == 1'b1)
               )  );


        M_OCP_CMDACCEPT_WHILE_STHREADBUSY_AND_STHREADBUSY_EXACT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (cmdaccept_while_sthreadbusy_and_sthreadbusy_exact == 
                           1'b1)));
        M_OCP_SDATATHREADBUSY_WITHOUT_DATAACCEPT_AND_SDATATHREADBUSY_EXACT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                  (sdatathreadbusy_without_dataaccept_and_sdatathreadbusy_exact 
                                                                       == 1'b1)
               )  );

        M_OCP_DATAACCEPT_WHILE_SDATATHREADBUSY_AND_SDATATHREADBUSY_EXACT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (dataaccept_while_sdatathreadbusy_and_sdatathreadbusy_exact == 
                                                                          1'b1)
               ) );
        M_OCP_MTHREADBUSY_WITHOUT_RESPACCEPT_AND_MTHREADBUSY_EXACT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                  (mthreadbusy_without_respaccept_and_mthreadbusy_exact == 1'b1)
               ) );
        M_OCP_RESPACCEPT_WHILE_MTHREADBUSY_AND_MTHREADBUSY_EXACT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (respaccept_while_mthreadbusy_and_mthreadbusy_exact == 
                           1'b1)));
        M_OCP_REQ_BLOCKING_WHILE_DATAHANDSHAKE_NON_BLOCKING_FLOW_CONTROL: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (req_blocking_while_datahandshake_non_blocking_flow_control == 
                                                                          1'b1)
               ) );
        M_OCP_DATAHANDSHAKE_BLOCKING_WHILE_REQ_NON_BLOCKING_FLOW_CONTROL: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (datahandshake_blocking_while_req_non_blocking_flow_control == 
                                                                          1'b1)
               ) );
        M_OCP_BURSTLENGTH_WDTH_VALUE_OF_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burstlength_wdth_value_of_1 == 1'b1)));
        M_OCP_THREADID_WDTH_NOT_LOG2_OF_THREADS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (threadid_wdth_not_log2_of_threads == 1'b1)));
        M_OCP_MDATALAST_WITHOUT_BURSTLENGTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatalast_without_burstlength == 1'b1)));
        M_OCP_MREQLAST_WITHOUT_BURSTLENGTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mreqlast_without_burstlength == 1'b1)));
        M_OCP_MRESPLAST_WITHOUT_BURSTLENGTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mresplast_without_burstlength == 1'b1)));
        M_OCP_TAGINORDER_WHEN_TAGS_NOT_GREATER_THAN_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (taginorder_when_tags_not_greater_than_1 == 1'b1)));
        M_OCP_TAGID_WDTH_NOT_LOG2_OF_TAGS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (tagid_wdth_not_log2_of_tags == 1'b1)));
//OCP 2.2 constraints
        M_OCP_REQROWLAST_WITHOUT_BURSTLENGTH:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reqrowlast_without_burstlength == 1'b1)));
        M_OCP_REQROWLAST_WITHOUT_REQLAST_AND_BURSTSEQ_BLCK_ENABLE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reqrowlast_without_reqlast_and_burstseq_blck_enable == 1'b1)));
        M_OCP_BLOCKHEIGHT_WITHOUT_BURSTSEQ_BLCK_ENABLE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (blockheight_without_burstseq_blck_enable == 1'b1)));
        M_OCP_BLOCKSTRIDE_WITHOUT_BURSTSEQ_BLCK_ENABLE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (blockstride_without_burstseq_blck_enable == 1'b1)));
        M_OCP_ILLEGAL_MBLOCKHEIGHT_WIDTH:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (illegal_blockheight_width == 1'b1)));
        M_OCP_DATAROWLAST_WITHOUT_DATAHANDSHAKE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (datarowlast_without_datahandshake == 1'b1)));
        M_OCP_DATAROWLAST_WITHOUT_BURSTLENGTH:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (datarowlast_without_burstlength == 1'b1)));
        M_OCP_DATAROWLAST_WITHOUT_DATALAST_AND_BURSTSEQ_BLCK_ENABLE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (datarowlast_without_datalast_and_burstseq_blck_enable == 1'b1)));
        M_OCP_RESPROWLAST_WITHOUT_RESP:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resprowlast_without_resp == 1'b1)));
        M_OCP_RESPROWLAST_WITHOUT_BURSTLENGTH:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resprowlast_without_burstlength == 1'b1)));
        M_OCP_RESPROWLAST_WITHOUT_RESPLAST_AND_BURSTSEQ_BLCK_ENABLE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resprowlast_without_resplast_and_burstseq_blck_enable == 1'b1)));
        M_OCP_ILLEGAL_SETTING_OF_MTHREADBUSY_PIPELINED:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_pipelined_enabled_without_mthreadbusy_exact == 1'b1)));
        M_OCP_ILLEGAL_SETTING_OF_SDATATHREADBUSY_PIPELINED:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sdatathreadbusy_pipelined_enabled_without_sdatathreadbusy_exact == 1'b1)));
        M_OCP_ILLEGAL_SETTING_OF_STHREADBUSY_PIPELINED:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadbusy_pipelined_enabled_without_sthreadbusy_exact == 1'b1)));
        M_OCP_RESPACCEPT_WITH_MTHREADBUSY_EXACT_ENABLED:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (respaccept_enabled_with_mthreadbusy_exact == 1'b1)));
        M_OCP_MTHREADBUSY_WITHOUT_EXACTLY_ONE_OF_MTHREADBUSY_EXACT_AND_RESPACCEPT:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_without_exactly_one_of_mthreadbusy_exact_and_respaccept == 1'b1)));

// OCP 3.0 configuration constraint
        M_OCP_NONPOSTED_WRITE_CONFIGURED_WITHOUT_WRITERESP_ENABLED:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (nonposted_write_without_writeresp_enabled == 1'b1)));

// OCP disconnect configuration constraint 
        M_OCP_CONNECTCAP_NOT_TIED_OFF_TO_ZERO_WHILE_CONNECTION_PARAMETER_CONFIGURED_ZERO:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (connectcap_not_tied_off_to_zero_while_connection_parameter_configured_zero == 1'b1)));

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

// Master side

generate
  case (ZI_CONSTRAINT_MASTER_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_MASTER_SIDE 
        A_OCP_SDATA_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sdata_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SDATA_NOT_STEADY"}),
                          .msg            ("SData should be steady from the beginning of the response phase until the end of the response phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SDATAINFO_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sdatainfo_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SDATAINFO_NOT_STEADY"}),
                          .msg            ("SDataInfo should be steady from the beginning of the response phase until the end of the response phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SRESPINFO_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (srespinfo_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SRESPINFO_NOT_STEADY"}),
                          .msg            ("SRespInfo should be steady from the beginning of the response phase until the end of the response phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SRESPLAST_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sresplast_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SRESPLAST_NOT_STEADY"}),
                          .msg            ("SRespLast should be steady from the beginning of the response phase until the end of the response phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_STHREADID_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadid_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STHREADID_NOT_STEADY"}),
                          .msg            ("SThreadID should be steady from the beginning of the response phase until the end of the response phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SRESP_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sresp_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SRESP_NOT_STEADY"}),
                          .msg            ("SResp should be steady from the beginning of the response phase until the end of the response phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_MTHREADBUSY_EXACT_RESPONSE_PRESENTATION_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_exact_response_presentation_violation 
                           == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTHREADBUSY_EXACT_RESPONSE_PRESENTATION_VIOLATION"}),
                          .msg            ("Slave should not present a response on a thread for which the corresponding MThreadBusy bit is asserted in that cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
//OCP 2.2 check
        A_OCP_MTHREADBUSY_PIPELINED_RESPONSE_PRESENTATION_VIOLATION:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_pipelined_response_presentation_violation
                           == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTHREADBUSY_PIPELINED_RESPONSE_PRESENTATION_VIOLATION"}),
                          .msg            ("If MTHREADBUSY_PIPELINED is enabled, slave should not present a response on a thread for which the corresponding MThreadBusy bit is asserted in the previous cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SDATATHREADBUSY_EXACT_DATAHANDSHAKE_ACCEPTANCE_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (sdatathreadbusy_exact_datahandshake_acceptance_violation == 
                                                                         1'b1)
               ) )

          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SDATATHREADBUSY_EXACT_DATAHANDSHAKE_ACCEPTANCE_VIOLATION"}),
                          .msg            ("Datahandshake phase presented on a thread for which SDataThreadBusy is deasserted in the current cycle should be accepted by the slave in that cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_STHREADBUSY_EXACT_COMMAND_ACCEPTANCE_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadbusy_exact_command_acceptance_violation == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STHREADBUSY_EXACT_COMMAND_ACCEPTANCE_VIOLATION"}),
                          .msg            ("Command presented on a thread for which SThreadBusy is deasserted in the current cycle should be accepted by that slave in that cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_REQDATA_TOGETHER_MULTI_REQ_ACCEPTANCE_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reqdata_together_multi_req_acceptance_violation == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_REQDATA_TOGETHER_MULTI_REQ_ACCEPTANCE_VIOLATION"}),
                          .msg            ("Slave with both REQDATA_TOGETHER and BURSTSINGLEREQ enabled should accept the request and the associated datahandshake phase together for each transfer in any multiple request/ multiple data write-type burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_STAGINORDER_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (staginorder_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STAGINORDER_NOT_STEADY"}),
                          .msg            ("STagInOrder should be steady from the beginning of the response phase until the end of the response phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_STAGID_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (stagid_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STAGID_NOT_STEADY"}),
                          .msg            ("For tagged transactions, STagID should be steady from the beginning of the response phase until the end of the response phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_STAGID_VALUE_NOT_LESS_THAN_TAGS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (stagid_value_not_less_than_tags == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STAGID_VALUE_NOT_LESS_THAN_TAGS"}),
                          .msg            ("For tagged transactions, value of STagID field should be less than the number of tags."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_STHREADID_VALUE_NOT_LESS_THAN_THREADS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadid_value_not_less_than_threads == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STHREADID_VALUE_NOT_LESS_THAN_THREADS"}),
                          .msg            ("Value of SThreadID field should be less than the number of threads."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SRESPLAST_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b0),
                          .test_expr (last_resp_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SRESPLAST_VIOLATION"}),
                          .msg            ("SRespLast should be asserted only for last response phase of the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_FAIL_RESPONSE_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (fail_response_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_FAIL_RESPONSE_VIOLATION"}),
                          .msg            ("The FAIL response should be preseneted only for WriteConditional commands."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SRESPINFO_NOT_CONSTANT_DURING_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (srespinfo_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SRESPINFO_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("SRespInfo should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_RESPONSE_BEGINNING_BEFORE_REQUEST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resp_beginning_before_request == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPONSE_BEGINNING_BEFORE_REQUEST"}),
                          .msg            ("A response phase should not begin before the associated request phase begins."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_RESPONSE_ENDING_BEFORE_REQUEST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resp_ending_before_request == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPONSE_ENDING_BEFORE_REQUEST"}),
                          .msg            ("A response phase should not end before the associated request phase ends."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_RESPONSE_BEGINNING_BEFORE_DATAHANDSHAKE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resp_beginning_before_data == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPONSE_BEGINNING_BEFORE_DATAHANDSHAKE"}),
                          .msg            ("A response phase should not begin before the associated datahandshake phase begins."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_RESPONSE_ENDING_BEFORE_DATAHANDSHAKE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resp_ending_before_data == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPONSE_ENDING_BEFORE_DATAHANDSHAKE"}),
                          .msg            ("A response phase should not end before the associated datahandshake phase ends."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SRMD_WR_RESP_BEGINNING_BEFORE_LAST_WR_DATA: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (srmd_wr_resp_beginning_before_last_wr_data == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SRMD_WR_RESP_BEGINNING_BEFORE_LAST_WR_DATA"}),
                          .msg            ("For SRMD writes, a response phase should not begin before the associated last datahandshake phase begins."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SRMD_WR_RESP_ENDING_BEFORE_LAST_WR_DATA: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (srmd_wr_resp_ending_before_last_wr_data == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SRMD_WR_RESP_ENDING_BEFORE_LAST_WR_DATA"}),
                          .msg            ("For SRMD writes, a response phase should not end before the associated last datahandshake phase ends."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_OCP_SRESPROWLAST_NOT_STEADY:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sresprowlast_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SRESPROWLAST_NOT_STEADY"}),
                          .msg            ("SRespRowLast should be steady from the beginning of the response phase until the end of the response phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_MASTER_SIDE 
        M_OCP_SDATA_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sdata_not_steady == 1'b1)));
        M_OCP_SDATAINFO_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sdatainfo_not_steady == 1'b1)));
        M_OCP_SRESPINFO_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (srespinfo_not_steady == 1'b1)));
        M_OCP_SRESPLAST_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sresplast_not_steady == 1'b1)));
        M_OCP_STHREADID_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadid_not_steady == 1'b1)));
        M_OCP_SRESP_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sresp_not_steady == 1'b1)));
        M_OCP_MTHREADBUSY_EXACT_RESPONSE_PRESENTATION_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_exact_response_presentation_violation 
                           == 1'b1)));
//OCP 2.2 constraint
        M_OCP_MTHREADBUSY_PIPELINED_RESPONSE_PRESENTATION_VIOLATION:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_pipelined_response_presentation_violation
                           == 1'b1)));
        M_OCP_SDATATHREADBUSY_EXACT_DATAHANDSHAKE_ACCEPTANCE_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (sdatathreadbusy_exact_datahandshake_acceptance_violation == 
                                                                         1'b1)
               ) );
        M_OCP_STHREADBUSY_EXACT_COMMAND_ACCEPTANCE_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadbusy_exact_command_acceptance_violation == 
                           1'b1)));
        M_OCP_REQDATA_TOGETHER_MULTI_REQ_ACCEPTANCE_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reqdata_together_multi_req_acceptance_violation == 
                           1'b1)));
        M_OCP_STAGINORDER_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (staginorder_not_steady == 1'b1)));
        M_OCP_STAGID_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (stagid_not_steady == 1'b1)));
	M_OCP_STAGID_VALUE_NOT_LESS_THAN_TAGS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (stagid_value_not_less_than_tags == 1'b1)));
	M_OCP_STHREADID_VALUE_NOT_LESS_THAN_THREADS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadid_value_not_less_than_threads == 1'b1)));
        M_OCP_SRESPLAST_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (last_resp_violation == 1'b1)));
	M_OCP_FAIL_RESPONSE_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (fail_response_violation == 1'b1)));
	M_OCP_SRESPINFO_NOT_CONSTANT_DURING_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (srespinfo_not_constant_during_burst == 1'b1)));	
	M_OCP_RESPONSE_BEGINNING_BEFORE_REQUEST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resp_beginning_before_request == 1'b1)));
	M_OCP_RESPONSE_ENDING_BEFORE_REQUEST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resp_ending_before_request == 1'b1)));
        M_OCP_RESPONSE_BEGINNING_BEFORE_DATAHANDSHAKE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (resp_beginning_before_data == 1'b1)));
        M_OCP_RESPONSE_ENDING_BEFORE_DATAHANDSHAKE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),

                          .enable    (1'b1),
                          .test_expr (resp_ending_before_data == 1'b1)));
	M_OCP_SRMD_WR_RESP_BEGINNING_BEFORE_LAST_WR_DATA: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (srmd_wr_resp_beginning_before_last_wr_data == 1'b1)));
        M_OCP_SRMD_WR_RESP_ENDING_BEFORE_LAST_WR_DATA: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (srmd_wr_resp_ending_before_last_wr_data == 1'b1)));
//OCP 2.2 compliance constraint
        M_OCP_SRESPROWLAST_NOT_STEADY:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sresprowlast_not_steady == 1'b1)));
      end 

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_MASTER_SIDE 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

// Slave side

generate
  case (ZI_CONSTRAINT_SLAVE_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_SLAVE_SIDE 
        A_OCP_SINGLE_REQ_MULTIPLE_DATA_REQ_WITH_UNKN_ADDR_SEQ: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (single_req_multiple_data_req_with_unkn_addr_seq == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SINGLE_REQ_MULTIPLE_DATA_REQ_WITH_UNKN_ADDR_SEQ"}),
                          .msg            ("Single request /  multiple data bursts should not be issued with the address sequence UNKN."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MADDR_UNALIGNED_TO_OCP_WORD_SIZE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (unaligned_maddr == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MADDR_UNALIGNED_TO_OCP_WORD_SIZE"}),
                          .msg            ("MAddr should be aligned to OCP word size"),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTLENGTH_NOT_CONSTANT_DURING_PRECISE_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstlength_not_constant_during_precise_burst == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTLENGTH_NOT_CONSTANT_DURING_PRECISE_BURST"}),
                          .msg            ("For precise bursts, the value of MBurstLength should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_ILLEGAL_MATOMICLENGTH_ENCODING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (illegal_encoding_for_matomiclength == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_ILLEGAL_MATOMICLENGTH_ENCODING"}),
                          .msg            ("MAtomicLength should not have a encoding of 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_ILLEGAL_MBURSTLENGTH_ENCODING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (illegal_encoding_for_mburstlength == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_ILLEGAL_MBURSTLENGTH_ENCODING"}),
                          .msg            ("MBurstLength should not have a encoding of 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
/* Check removed as there is no reserved encoding of mburstseq signal in OCP 2.2
        A_OCP_RESERVED_MBURSTSEQ_ENCODING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reserved_encoding_for_mburstseq == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESERVED_MBURSTSEQ_ENCODING"}),
                          .msg            ("MBurstSeq should not have a reserved encoding of 3'b111."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
*/
        A_OCP_MADDR_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (maddr_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MADDR_NOT_STEADY"}),
                          .msg            ("MAddr should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MADDRSPACE_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (maddrspace_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MADDRSPACE_NOT_STEADY"}),
                          .msg            ("MAddrSpace should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MATOMICLENGTH_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (matomiclength_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MATOMICLENGTH_NOT_STEADY"}),
                          .msg            ("MAtomicLength should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTLENGTH_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstlength_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTLENGTH_NOT_STEADY"}),
                          .msg            ("MBurstLength should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTPRECISE_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstprecise_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTPRECISE_NOT_STEADY"}),
                          .msg            ("MBurstPrecise should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTSEQ_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstseq_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTSEQ_NOT_STEADY"}),
                          .msg            ("MBurstSeq should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTSINGLEREQ_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstsinglereq_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTSINGLEREQ_NOT_STEADY"}),
                          .msg            ("MBurstSingleReq should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBYTEEN_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mbyteen_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBYTEEN_NOT_STEADY"}),
                          .msg            ("MByteEn should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MCONNID_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mconnid_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MCONNID_NOT_STEADY"}),
                          .msg            ("MConnID should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MREQINFO_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mreqinfo_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MREQINFO_NOT_STEADY"}),
                          .msg            ("MReqInfo should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MREQLAST_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mreqlast_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MREQLAST_NOT_STEADY"}),
                          .msg            ("MReqLast should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MTHREADID_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadid_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTHREADID_NOT_STEADY"}),
                          .msg            ("MThreadID should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MCMD_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mcmd_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MCMD_NOT_STEADY"}),
                          .msg            ("MCmd should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATA_NOT_STEADY_FOR_REQ_PHASE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (pdatahandshake == 1'b0 && mdata_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATA_NOT_STEADY_FOR_REQ_PHASE"}),
                          .msg            ("MData should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATA_NOT_STEADY_FOR_DATAHANDSHAKE_PHASE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (pdatahandshake == 1'b1 && mdata_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATA_NOT_STEADY_FOR_DATAHANDSHAKE_PHASE"}),
                          .msg            ("MData should be steady from the beginning of the datahandshake phase until the end of the datahandshake phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATABYTEEN_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatabyteen_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATABYTEEN_NOT_STEADY"}),
                          .msg            ("MDataByteEn should be steady from the beginning of the datahandshake phase until the end of the datahandshake phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATAINFO_NOT_STEADY_FOR_REQ_PHASE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (pdatahandshake == 1'b0 && 
                           mdatainfo_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATAINFO_NOT_STEADY_FOR_REQ_PHASE"}),
                          .msg            ("MDataInfo should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATAINFO_NOT_STEADY_FOR_DATAHANDSHAKE_PHASE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (pdatahandshake == 1'b1 && 
                           mdatainfo_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATAINFO_NOT_STEADY_FOR_DATAHANDSHAKE_PHASE"}),
                          .msg            ("MDataInfo should be steady from the beginning of the datahandshake phase until the end of the datahandshake phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATALAST_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatalast_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATALAST_NOT_STEADY"}),
                          .msg            ("MDataLast should be steady from the beginning of the datahandshake phase until the end of the datahandshake phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATATHREADID_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatathreadid_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATATHREADID_NOT_STEADY"}),
                          .msg            ("MDataThreadID should be steady from the beginning of the datahandshake phase until the end of the datahandshake phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATAVALID_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatavalid_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATAVALID_NOT_STEADY"}),
                          .msg            ("MDataValid should be steady from the beginning of the datahandshake phase until the end of the datahandshake phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MTHREADBUSY_EXACT_RESPONSE_ACCEPTANCE_VIOLATION:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_exact_response_acceptance_violation 
                           == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTHREADBUSY_EXACT_RESPONSE_ACCEPTANCE_VIOLATION"}),
                          .msg            ("Response presented on a thread for which MThreadBusy is deasserted in the current cycle should be accepted by the master in that cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_SDATATHREADBUSY_EXACT_DATAHANDSHAKE_PRESENTATION_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (sdatathreadbusy_exact_datahandshake_presentation_violation == 
                                                                           1'b1)
               ) )

          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SDATATHREADBUSY_EXACT_DATAHANDSHAKE_PRESENTATION_VIOLATION"}),
                          .msg            ("Master should not present a datahandshake phase on a thread for which the corresponding SDataThreadBusy bit is asserted in that cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_STHREADBUSY_EXACT_COMMAND_PRESENTATION_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadbusy_exact_command_presentation_violation == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STHREADBUSY_EXACT_COMMAND_PRESENTATION_VIOLATION"}),
                          .msg            ("If STHREADBUSY_EXACT is enabled, a command should not be presented on a thread for which the corresponding SThreadBusy bit asserted in this cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
//New 2.1 missing checks
        A_OCP_RESPONSE_REORDERED_FOR_OVERLAPPING_ADDRESSES_VIOLATION:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b0),
                          .test_expr ( response_reordered_for_overlapping_addresses_for_tagged_transaction ==
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPONSE_REORDERED_FOR_OVERLAPPING_ADDRESSES_VIOLATION"}),
                          .msg            ("For tagged requests with overlapping addresses, response may not be reordered."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_RESPONSE_REORDERED_BEYOND_INTERLEAVE_SIZE_VIOLATION:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b0),
                          .test_expr ( response_reordered_beyond_tag_interleave_size_for_tagged_transaction ==
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RESPONSE_REORDERED_BEYOND_INTERLEAVE_SIZE_VIOLATION"}),
                          .msg            ("For tagged requests, responses for burst sequences must stay together up to tag interleave size"),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
//OCP 2.2 checks (next two)
        A_OCP_SDATATHREADBUSY_PIPELINED_DATAHANDSHAKE_PRESENTATION_VIOLATION:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (sdatathreadbusy_pipelined_datahandshake_presentation_violation ==
                                                                           1'b1)
               ) )

          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_SDATATHREADBUSY_EXACT_DATAHANDSHAKE_PRESENTATION_VIOLATION"}),
                          .msg            ("If SDATATHREADBUSY_PIPELINED is enabled, a datahandshake phase should not be presented on a thread for which the corresponding SDataThreadBusy bit is asserted in the previous cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_STHREADBUSY_PIPELINED_COMMAND_PRESENTATION_VIOLATION:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadbusy_pipelined_command_presentation_violation ==
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STHREADBUSY_EXACT_COMMAND_PRESENTATION_VIOLATION"}),
                          .msg            ("If STHREADBUSY_PIPELINED is enabled, a command should not be presented on a thread for which the corresponding SThreadBusy bit asserted in the previous cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_READEX_CMD_NOT_FOLLOWED_BY_WR_WRNP_CMD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (readex_cmd_not_followed_by_wr_wrnp_cmd == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_READEX_CMD_NOT_FOLLOWED_BY_WR_WRNP_CMD"}),
                          .msg            ("When ReadEx command is issued, the next request on the thread that issued a ReadEx should be a Write or WriteNonPost."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_UNLOCKING_WR_WRNP_CMD_NOT_SAME_ADDR_AS_RDEX: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (unlocking_wr_wrnp_cmd_not_same_addr_as_rdex == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_UNLOCKING_WR_WRNP_CMD_NOT_SAME_ADDR_AS_RDEX"}),
                          .msg            ("The unlocking command following a ReadEx command should have the same address and address space values as the ReadEx command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_UNLOCKING_WR_WRNP_CMD_NOT_SAME_MBYTEEN_AS_RDEX: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (unlocking_wr_wrnp_cmd_not_same_mbyteen_as_rdex == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_UNLOCKING_WR_WRNP_CMD_NOT_SAME_MBYTEEN_AS_RDEX"}),
                          .msg            ("The unlocking command following a ReadEx command should have the same mbyteen values as the ReadEx command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_RDEX_CMD_AS_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rdex_cmd_as_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RDEX_CMD_AS_BURST"}),
                          .msg            ("The ReadEx command should not be used as part of burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_RDL_CMD_AS_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rdl_cmd_as_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RDL_CMD_AS_BURST"}),
                          .msg            ("The ReadLinked command should not be used as part of burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_WRC_CMD_AS_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrc_cmd_as_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_WRC_CMD_AS_BURST"}),
                          .msg            ("The WriteConditional command should not be used as part of burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_UNLOCKING_WR_WRNP_CMD_AS_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (unlocking_wr_wrnp_cmd_as_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_UNLOCKING_WR_WRNP_CMD_AS_BURST"}),
                          .msg            ("The unlocking Write or WriteNonPost command associated with a ReadEx command should not be used as part of a burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_WRAP_SEQUENCE_FOR_IMPRECISE_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrap_sequence_for_imprecise_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_WRAP_SEQUENCE_FOR_IMPRECISE_BURST"}),
                          .msg            ("Burst address sequence WRAP should be used only for precise bursts."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_XOR_SEQUENCE_FOR_IMPRECISE_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (xor_sequence_for_imprecise_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_XOR_SEQUENCE_FOR_IMPRECISE_BURST"}),
                          .msg            ("Burst address sequence XOR should be used only for precise bursts."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_WRAP_SEQUENCE_NON_POWER_OF_TWO_BURST_LENGTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrap_sequence_non_power_of_two_burst_length == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_WRAP_SEQUENCE_NON_POWER_OF_TWO_BURST_LENGTH"}),
                          .msg            ("Burst length of WRAP address sequence should be power-of-two value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_XOR_SEQUENCE_NON_POWER_OF_TWO_BURST_LENGTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (xor_sequence_non_power_of_two_burst_length == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_XOR_SEQUENCE_NON_POWER_OF_TWO_BURST_LENGTH"}),
                          .msg            ("Burst length of XOR address sequence should be power-of-two value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_STRM_SEQUENCE_WITHOUT_ANY_BYTE_ENABLE_ASSERTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (strm_sequence_without_any_byte_enable == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STRM_SEQUENCE_WITHOUT_ANY_BYTE_ENABLE_ASSERTED"}),
                          .msg            ("Burst address sequence STRM should have at least one byte enable asserted for each transfer in the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_DFLT2_SEQUENCE_WITHOUT_ANY_BYTE_ENABLE_ASSERTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (dflt2_sequence_without_any_byte_enable == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DFLT2_SEQUENCE_WITHOUT_ANY_BYTE_ENABLE_ASSERTED"}),
                          .msg            ("Burst address sequence DFLT2 should have at least one byte enable asserted for each transfer in the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_STRM_SEQUENCE_NOT_HAVING_SAME_BYTE_ENABLES: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (strm_sequence_not_having_same_byte_enables == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STRM_SEQUENCE_NOT_HAVING_SAME_BYTE_ENABLES"}),
                          .msg            ("Bursts with the STRM address sequence should have the same byte enable pattern for each transfer in the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MCMD_NOT_CONSTANT_DURING_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mcmd_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MCMD_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("MCmd should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MADDRSPACE_NOT_CONSTANT_DURING_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (maddrspace_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MADDRSPACE_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("MAddrSpace should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MCONNID_NOT_CONSTANT_DURING_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mconnid_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MCONNID_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("MConnID should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTPRECISE_NOT_CONSTANT_DURING_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstprecise_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTPRECISE_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("MBurstPrecise should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTSINGLEREQ_NOT_CONSTANT_DURING_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstsinglereq_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTSINGLEREQ_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("MBurstSingleReq should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTSEQ_NOT_CONSTANT_DURING_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstseq_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTSEQ_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("MBurstSeq should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MATOMICLENGTH_NOT_CONSTANT_DURING_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (matomiclength_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MATOMICLENGTH_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("MAtomicLength should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MREQINFO_NOT_CONSTANT_DURING_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mreqinfo_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MREQINFO_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("MReqInfo should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MREQLAST_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (imreqlast), //Checking for illegal mreqlast assertion only
                          .test_expr (mreqlast_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MREQLAST_VIOLATION"}),
                          .msg            ("MReqLast should be asserted only for last request phase of the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MBURSTSINGLEREQ_ASSERTED_WHEN_MBURSTPRECISE_DEASSERTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstsinglereq_without_mburstprecise == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBURSTSINGLEREQ_ASSERTED_WHEN_MBURSTPRECISE_DEASSERTED"}),
                          .msg            ("MBurstSingleReq should not be asserted when MBurstPrecise is not asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_WR_CMD_WHILE_WRITE_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wr_cmd_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_WR_CMD_WHILE_WRITE_ENABLE_0"}),
                          .msg            ("A master with WRITE_ENABLE set to 0 should not generate Write command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_RD_CMD_WHILE_READ_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rd_cmd_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RD_CMD_WHILE_READ_ENABLE_0"}),
                          .msg            ("A master with READ_ENABLE set to 0 should not generate Read command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_RDEX_CMD_WHILE_READEX_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rdex_cmd_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RDEX_CMD_WHILE_READEX_ENABLE_0"}),
                          .msg            ("A master with READEX_ENABLE set to 0 should not generate ReadEx command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_RDL_CMD_WHILE_RDLWRC_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rdl_cmd_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RDL_CMD_WHILE_RDLWRC_ENABLE_0"}),
                          .msg            ("A master with RDLWRC_ENABLE set to 0 should not generate ReadLinked command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_WRC_CMD_WHILE_RDLWRC_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrc_cmd_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_WRC_CMD_WHILE_RDLWRC_ENABLE_0"}),
                          .msg            ("A master with RDLWRC_ENABLE set to 0 should not generate WriteConditional command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_WRNP_CMD_WHILE_WRITENONPOST_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrnp_cmd_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_WRNP_CMD_WHILE_WRITENONPOST_ENABLE_0"}),
                          .msg            ("A master with WRITENONPOST_ENABLE set to 0 should not generate WriteNonPost command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_BCST_CMD_WHILE_BROADCAST_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (bcst_cmd_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BCST_CMD_WHILE_BROADCAST_ENABLE_0"}),
                          .msg            ("A master with BROADCAST_ENABLE set to 0 should not generate Broadcast command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_BYTE_ENABLES_NOT_FORCE_ALIGNED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (byte_enables_not_force_aligned == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BYTE_ENABLES_NOT_FORCE_ALIGNED"}),
                          .msg            ("A master with FORCE_ALIGNED option enabled should not generate any byte enable patterns that are not force aligned."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_BURST_ALIGNED_INCR_BURST_SIZE_NOT_POWER_OF_TWO: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burst_aligned_incr_burst_size_not_power_of_two == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BURST_ALIGNED_INCR_BURST_SIZE_NOT_POWER_OF_TWO"}),
                          .msg            ("When BURST_ALIGNED is enabled, the total burst size of INCR bursts should be power of two."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_BURST_ALIGNED_INCR_BURST_UNALIGNED_START_ADDR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burst_aligned_incr_burst_unaligned_start_addr == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BURST_ALIGNED_INCR_BURST_UNALIGNED_START_ADDR"}),
                          .msg            ("When BURST_ALIGNED is enabled, INCR bursts should have their starting address aligned to total burst size."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_BURST_ALIGNED_INCR_BURST_NOT_PRECISE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burst_aligned_incr_burst_not_precise == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BURST_ALIGNED_INCR_BURST_NOT_PRECISE"}),
                          .msg            ("When BURST_ALIGNED is enabled, INCR bursts should be issued as precise bursts."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_REQDATA_TOGETHER_SINGLE_REQ_PRESENTATION_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reqdata_together_single_req_presentation_violation == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_REQDATA_TOGETHER_SINGLE_REQ_PRESENTATION_VIOLATION"}),
                          .msg            ("In a single request / multiple data write-type burst, master should present request and datahandshake phases of the first transfer in the same cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_REQDATA_TOGETHER_SINGLE_REQ_ACCEPTANCE_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reqdata_together_single_req_acceptance_violation == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_REQDATA_TOGETHER_SINGLE_REQ_ACCEPTANCE_VIOLATION"}),
                          .msg            ("In a single request / multiple data write-type burst,  slave should accept request and datahandshake phases of the first transfer in the same cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_WRNP_CMD_WHILE_WRITERESP_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrnp_cmd_while_resp_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_WRNP_CMD_WHILE_WRITERESP_ENABLE_0"}),
                          .msg            ("A master with WRITERESP_ENABLE is set to 0 should not generate WriteNonPost command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_WRC_CMD_WHILE_WRITERESP_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrc_cmd_while_resp_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_WRC_CMD_WHILE_WRITERESP_ENABLE_0"}),
                          .msg            ("A master with WRITERESP_ENABLE is set to 0 should not generate WriteConditional command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_RDL_CMD_WHILE_WRITERESP_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rdl_cmd_while_resp_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_RDL_CMD_WHILE_WRITERESP_ENABLE_0"}),
                          .msg            ("A master with WRITERESP_ENABLE is set to 0 should not generate ReadLinked command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_DFLT1_BURST_WHILE_BURSTSEQ_DFLT1_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (dflt1_burst_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DFLT1_BURST_WHILE_BURSTSEQ_DFLT1_ENABLE_0"}),
                          .msg            ("A master with BURSTSEQ_DFLT1_ENABLE set to 0 should not issue DFLT1 burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_DFLT2_BURST_WHILE_BURSTSEQ_DFLT2_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (dflt2_burst_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DFLT2_BURST_WHILE_BURSTSEQ_DFLT2_ENABLE_0"}),
                          .msg            ("A master with BURSTSEQ_DFLT2_ENABLE set to 0 should not issue DFLT2 burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_INCR_BURST_WHILE_BURSTSEQ_INCR_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (incr_burst_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_INCR_BURST_WHILE_BURSTSEQ_INCR_ENABLE_0"}),
                          .msg            ("A master with BURSTSEQ_INCR_ENABLE set to 0 should not issue INCR burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_STRM_BURST_WHILE_BURSTSEQ_STRM_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (strm_burst_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STRM_BURST_WHILE_BURSTSEQ_STRM_ENABLE_0"}),
                          .msg            ("A master with BURSTSEQ_STRM_ENABLE set to 0 should not issue STRM burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_UNKN_BURST_WHILE_BURSTSEQ_UNKN_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (unkn_burst_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_UNKN_BURST_WHILE_BURSTSEQ_UNKN_ENABLE_0"}),
                          .msg            ("A master with BURSTSEQ_UNKN_ENABLE set to 0 should not issue UNKN burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_WRAP_BURST_WHILE_BURSTSEQ_WRAP_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrap_burst_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_WRAP_BURST_WHILE_BURSTSEQ_WRAP_ENABLE_0"}),
                          .msg            ("A master with BURSTSEQ_WRAP_ENABLE set to 0 should not issue WRAP burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_XOR_BURST_WHILE_BURSTSEQ_XOR_ENABLE_0: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (xor_burst_while_disabled == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_XOR_BURST_WHILE_BURSTSEQ_XOR_ENABLE_0"}),
                          .msg            ("A master with BURSTSEQ_XOR_ENABLE set to 0 should not issue XOR burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_XOR_BURST_INCORRECT_ADDRESS_SEQUENCE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b0),
                          .test_expr (xor_burst_incorrect_address_sequence == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_XOR_BURST_INCORRECT_ADDRESS_SEQUENCE"}),
                          .msg            ("For XOR bursts, MAddr sequence should be as defined by the specification."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_INCR_BURST_INCORRECT_ADDRESS_SEQUENCE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (incr_burst_incorrect_address_sequence == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_INCR_BURST_INCORRECT_ADDRESS_SEQUENCE"}),
                          .msg            ("Each transfer of an INCR burst should increment MAddr by the OCP word size."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_STRM_BURST_MADDR_NOT_CONSTANT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (strm_burst_maddr_not_constant == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STRM_BURST_MADDR_NOT_CONSTANT"}),
                          .msg            ("STRM bursts should have the same MAddr across all transfers of the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_WRAP_BURST_INCORRECT_ADDRESS_SEQUENCE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrap_burst_incorrect_address_sequence == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_WRAP_BURST_INCORRECT_ADDRESS_SEQUENCE"}),
                          .msg            ("For WRAP bursts, MAddr sequence should be as defined by the specification."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_REQDATA_TOGETHER_MULTI_REQ_PRESENTATION_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reqdata_together_multi_req_presentation_violation == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_REQDATA_TOGETHER_MULTI_REQ_PRESENTATION_VIOLATION"}),
                          .msg            ("Master with both REQDATA_TOGETHER and BURSTSINGLEREQ enabled should present the request and the associated datahandshake phase together for each transfer in any multiple request/ multiple data write-type burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MTAGINORDER_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mtaginorder_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTAGINORDER_NOT_STEADY"}),
                          .msg            ("MTagInOrder should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MTAGID_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mtagid_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTAGID_NOT_STEADY"}),
                          .msg            ("For tagged transactions, MTagID should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATATAGID_NOT_STEADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatatagid_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATATAGID_NOT_STEADY"}),
                          .msg            ("For tagged transactions, MDataTagID should be steady from the beginning of the datahandshake phase until the end of the datahandshake phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MTAGID_VALUE_NOT_LESS_THAN_TAGS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mtagid_value_not_less_than_tags == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTAGID_VALUE_NOT_LESS_THAN_TAGS"}),
                          .msg            ("For tagged transactions, value of MTagID field should be less than the number of tags."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATATAGID_VALUE_NOT_LESS_THAN_TAGS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatatagid_value_not_less_than_tags == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATATAGID_VALUE_NOT_LESS_THAN_TAGS"}),
                          .msg            ("For tagged transactions, value of MDataTagID field should be less than the number of tags."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MTAGID_NOT_CONSTANT_DURING_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mtagid_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTAGID_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("MTagID should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MTAGINORDER_NOT_CONSTANT_DURING_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mtaginorder_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTAGINORDER_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("MTagInOrder should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MTHREADID_VALUE_NOT_LESS_THAN_THREADS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadid_value_not_less_than_threads == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MTHREADID_VALUE_NOT_LESS_THAN_THREADS"}),
                          .msg            ("Value of MThreadID field should be less than the number of threads."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATATHREADID_VALUE_NOT_LESS_THAN_THREADS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatathreadid_value_not_less_than_threads == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATATHREADID_VALUE_NOT_LESS_THAN_THREADS"}),
                          .msg            ("Value of MDataThreadID field should be less than the number of threads."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_STRM_SEQUENCE_WITHOUT_ANY_MDATABYTE_ENABLE_ASSERTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (strm_sequence_without_any_mdatabyte_enable == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STRM_SEQUENCE_WITHOUT_ANY_MDATABYTE_ENABLE_ASSERTED"}),
                          .msg            ("Burst address sequence STRM should have at least one mdatabyte enable asserted for each transfer in the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_DFLT2_SEQUENCE_WITHOUT_ANY_MDATABYTE_ENABLE_ASSERTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (dflt2_sequence_without_any_mdatabyte_enable == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DFLT2_SEQUENCE_WITHOUT_ANY_MDATABYTE_ENABLE_ASSERTED"}),
                          .msg            ("Burst address sequence DFLT2 should have at least one mdatabyte enable asserted for each transfer in the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_STRM_SEQUENCE_NOT_HAVING_SAME_MDATABYTE_ENABLES: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (strm_sequence_not_having_same_mdatabyte_enables == 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STRM_SEQUENCE_NOT_HAVING_SAME_MDATABYTE_ENABLES"}),
                          .msg            ("Bursts with the STRM address sequence should have the same mdatabyte enable pattern for each transfer in the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATABYTE_ENABLES_NOT_FORCE_ALIGNED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatabyte_enables_not_force_aligned == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATABYTE_ENABLES_NOT_FORCE_ALIGNED"}),
                          .msg            ("A master with FORCE_ALIGNED option enabled should not generate any mdatabyte enable patterns that are not force aligned."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_MDATALAST_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (last_data_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATALAST_VIOLATION"}),
                          .msg            ("MDataLast should be asserted only for last data phase of the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_DATAHANDSHAKE_BEGINNING_BEFORE_REQUEST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (data_beginning_before_request == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DATAHANDSHAKE_BEGINNING_BEFORE_REQUEST"}),
                          .msg            ("A datahandshake phase should not begin before the associated request phase begins."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_DATAHANDSHAKE_ENDING_BEFORE_REQUEST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (data_ending_before_request == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_DATAHANDSHAKE_ENDING_BEFORE_REQUEST"}),
                          .msg            ("A datahandshake phase should not end before the associated request phase ends."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_OCP_TAGGED_WRITE_DATA_OUT_OF_ORDER: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b0),
                          .test_expr (tagged_write_data_out_of_order == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_TAGGED_WRITE_DATA_OUT_OF_ORDER"}),
                          .msg            ("For tagged write transactions, the datahandshake phase must observe the same order as the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
//OCP 2.2 protocol compliance checks
        A_OCP_MBLOCKHEIGHT_NOT_STEADY:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mblockheight_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBLOCKHEIGHT_NOT_STEADY"}),
                          .msg            ("MBlockHeight should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_MBLOCKSTRIDE_NOT_STEADY:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr ( mblockstride_not_steady== 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBLOCKSTRIDE_NOT_STEADY"}),
                          .msg            ("MBlockStride should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_MREQROWLAST_NOT_STEADY:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mreqrowlast_not_steady== 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MREQROWLAST_NOT_STEADY"}),
                          .msg            ("MReqRowLast should be steady from the beginning of the request phase until the end of the request phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_MDATAROWLAST_NOT_STEADY:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatarowlast_not_steady == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MDATAROWLAST_NOT_STEADY"}),
                          .msg            ("MDataRowLast should be steady from the beginning of the datahandshake phase until the end of the datahandshake phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_ILLEGAL_MBLOCKHEIGHT_ENCODING:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr ( illegal_mblockheight_encoding== 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_ILLEGAL_MBLOCKHEIGHT_ENCODING"}),
                          .msg            ("MblockHeight must be greater than 0 for BLCK burst sequence."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_ILLEGAL_MBLOCKSTRIDE_ENCODING:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (illegal_mblockstride_encoding == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_ILLEGAL_MBLOCKSTRIDE_ENCODING"}),
                          .msg            ("MblockStride must be greater than 0 for BLCK burst sequence with MblockHeight > 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_BLCK_BURST_WHILE_BURSTSEQ_BLCK_ENABLE_0:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (blck_burst_while_burstseq_blck_enable_0 == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BLCK_BURST_WHILE_BURSTSEQ_BLCK_ENABLE_0"}),
                          .msg            ("A master with BURSTSEQ_BLCK_ENABLE set to 0 should not issue BLCK burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_MBLOCKHEIGHT_NOT_CONSTANT_DURING_BURST:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mblockheight_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBLOCKHEIGHT_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("The value of MBlockHeight should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_MBLOCKSTRIDE_NOT_CONSTANT_DURING_BURST:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mblockstride_not_constant_during_burst == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBLOCKSTRIDE_NOT_CONSTANT_DURING_BURST"}),
                          .msg            ("The value of MBlockStride should be constant throughout the burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));

        A_OCP_MBLOCKSTRIDE_UNALIGNED_TO_OCP_WORD_SIZE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mblockstride_unaligned_to_ocp_word_size == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MBLOCKSTRIDE_UNALIGNED_TO_OCP_WORD_SIZE"}),
                          .msg            ("MBlockStride should be aligned to OCP word size."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_BLCK_BURST_INCORRECT_ADDRESS_SEQUENCE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (blck_burst_incorrect_address_sequence == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BLCK_BURST_INCORRECT_ADDRESS_SEQUENCE"}),
                          .msg            ("Starting address  of each subsequence of   BLCK burst should be starting address of the prior subsequence plus MBlockStride."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_BLCK_ADDRSPACE_BOUNDARY_CROSS:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (blck_addrspace_boundary_cross == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_BLCK_ADDRSPACE_BOUNDARY_CROSS"}),
                          .msg            ("An BLCK  burst can never cross the address space boundary."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));

// OCP disconnect checks

        A_OCP_MCMD_NOT_IDLE_WHILE_OCP_NOT_CONNECTED:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mcmd_not_idle_while_ocp_not_connected == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_MCMD_NOT_IDLE_WHILE_OCP_NOT_CONNECTED"}),
                          .msg            ("Master must drive idle commands when OCP is not connected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_LEAVING_CONNECTED_STATE_DURING_ONGOING_TRANSACTION:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (ocp_leaving_connected_state_during_ongoing_transaction == 1'b1)))
          else qvl_error_t( 
                          .err_msg        ({QVL_MSG,"A_OCP_LEAVING_CONNECTED_STATE_DURING_ONGOING_TRANSACTION"}),
                          .msg            ("Master must not initiate disconnect before reaching current transaction boundary."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_TRANSITS2MWAIT_WITHOUT_SLAVE_REQUEST:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (ocp_transits2mwait_without_slave_request == 1'b1)))
          else qvl_error_t( 
                          .err_msg        ({QVL_MSG,"A_OCP_TRANSITS2MWAIT_WITHOUT_SLAVE_REQUEST"}),
                          .msg            ("Master must not change state to M_WAIT before slave requests to wait."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_OCP_TRANSITS2MCON_WITHOUT_SLAVE_GRANT:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (ocp_transits2mcon_without_slave_grant == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_TRANSITS2MCON_WITHOUT_SLAVE_GRANT"}),
                          .msg            ("Master must not change state to M_CON before slave allows to connect."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
	A_OCP_TRANSITS2MDISC_WITHOUT_SLAVE_REQUEST:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (ocp_transits2mdisc_without_slave_request == 1'b1)))
          else qvl_error_t( 
                          .err_msg        ({QVL_MSG,"A_OCP_TRANSITS2MDISC_WITHOUT_SLAVE_REQUEST"}),
                          .msg            ("Master must not change state to M_DISC before slave requests to disconnect."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
	A_OCP_TRANSITS2MOFF_WITHOUT_SLAVE_GRANT:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (ocp_transits2moff_without_slave_grant == 1'b1)))
          else qvl_error_t( 
                          .err_msg        ({QVL_MSG,"A_OCP_TRANSITS2MOFF_WITHOUT_SLAVE_GRANT"}),
                          .msg            ("Master must not change state to M_OFF before slave allows this transition."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE)); 

      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_SLAVE_SIDE
	M_OCP_SINGLE_REQ_MULTIPLE_DATA_REQ_WITH_UNKN_ADDR_SEQ: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (single_req_multiple_data_req_with_unkn_addr_seq == 
                           1'b1)));
        M_OCP_MADDR_UNALIGNED_TO_OCP_WORD_SIZE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (unaligned_maddr == 1'b1)));
        M_OCP_MBURSTLENGTH_NOT_CONSTANT_DURING_PRECISE_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstlength_not_constant_during_precise_burst == 
                           1'b1)));
        M_OCP_ILLEGAL_MATOMICLENGTH_ENCODING: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (illegal_encoding_for_matomiclength == 1'b1)));
        M_OCP_ILLEGAL_MBURSTLENGTH_ENCODING: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (illegal_encoding_for_mburstlength == 1'b1)));
/* Constraint removed as there is no reserved encoding of mburstseq signal in OCP 2.2
        M_OCP_RESERVED_MBURSTSEQ_ENCODING: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reserved_encoding_for_mburstseq == 1'b1)));
*/
        M_OCP_MADDR_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (maddr_not_steady == 1'b1)));
        M_OCP_MADDRSPACE_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (maddrspace_not_steady == 1'b1)));
        M_OCP_MATOMICLENGTH_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (matomiclength_not_steady == 1'b1)));
        M_OCP_MBURSTLENGTH_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstlength_not_steady == 1'b1)));
        M_OCP_MBURSTPRECISE_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstprecise_not_steady == 1'b1)));
        M_OCP_MBURSTSEQ_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstseq_not_steady == 1'b1)));
        M_OCP_MBURSTSINGLEREQ_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstsinglereq_not_steady == 1'b1)));
        M_OCP_MBYTEEN_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mbyteen_not_steady == 1'b1)));
        M_OCP_MCONNID_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mconnid_not_steady == 1'b1)));
        M_OCP_MREQINFO_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mreqinfo_not_steady == 1'b1)));
        M_OCP_MREQLAST_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mreqlast_not_steady == 1'b1)));
        M_OCP_MTHREADID_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadid_not_steady == 1'b1)));
        M_OCP_MCMD_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mcmd_not_steady == 1'b1)));
        M_OCP_MDATA_NOT_STEADY_FOR_REQ_PHASE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (pdatahandshake == 1'b0 && mdata_not_steady == 1'b1)));
        M_OCP_MDATA_NOT_STEADY_FOR_DATAHANDSHAKE_PHASE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (pdatahandshake == 1'b1 && mdata_not_steady == 1'b1)));
        M_OCP_MDATABYTEEN_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatabyteen_not_steady == 1'b1)));
        M_OCP_MDATAINFO_NOT_STEADY_FOR_REQ_PHASE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (pdatahandshake == 1'b0 && 
                           mdatainfo_not_steady == 1'b1)));
        M_OCP_MDATAINFO_NOT_STEADY_FOR_DATAHANDSHAKE_PHASE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (pdatahandshake == 1'b1 && 
                           mdatainfo_not_steady == 1'b1)));
        M_OCP_MDATALAST_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatalast_not_steady == 1'b1)));
        M_OCP_MDATATHREADID_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatathreadid_not_steady == 1'b1)));
        M_OCP_MDATAVALID_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatavalid_not_steady == 1'b1)));
        M_OCP_MTHREADBUSY_EXACT_RESPONSE_ACCEPTANCE_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadbusy_exact_response_acceptance_violation 
                           == 1'b1)));
        M_OCP_SDATATHREADBUSY_EXACT_DATAHANDSHAKE_PRESENTATION_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (sdatathreadbusy_exact_datahandshake_presentation_violation == 
                                                                           1'b1)
               ) );
        M_OCP_STHREADBUSY_EXACT_COMMAND_PRESENTATION_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadbusy_exact_command_presentation_violation == 
                           1'b1)));
//New 2.1 missing constraints
        M_OCP_RESPONSE_REORDERED_FOR_OVERLAPPING_ADDRESSES_VIOLATION:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b0),
                          .test_expr ( response_reordered_for_overlapping_addresses_for_tagged_transaction ==
                           1'b1)));
        M_OCP_RESPONSE_REORDERED_BEYOND_INTERLEAVE_SIZE_VIOLATION:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b0),
                          .test_expr ( response_reordered_beyond_tag_interleave_size_for_tagged_transaction ==
                           1'b1)));
//OCP 2.2 constraints (next two)
        M_OCP_SDATATHREADBUSY_PIPELINED_DATAHANDSHAKE_PRESENTATION_VIOLATION:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (sdatathreadbusy_pipelined_datahandshake_presentation_violation ==
                                                                           1'b1)
               ) );
        M_OCP_STHREADBUSY_PIPELINED_COMMAND_PRESENTATION_VIOLATION:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (sthreadbusy_pipelined_command_presentation_violation ==
                           1'b1)));
        M_OCP_READEX_CMD_NOT_FOLLOWED_BY_WR_WRNP_CMD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (readex_cmd_not_followed_by_wr_wrnp_cmd == 1'b1)));
        M_OCP_UNLOCKING_WR_WRNP_CMD_NOT_SAME_ADDR_AS_RDEX: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (unlocking_wr_wrnp_cmd_not_same_addr_as_rdex == 1'b1)));
        M_OCP_UNLOCKING_WR_WRNP_CMD_NOT_SAME_MBYTEEN_AS_RDEX: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (unlocking_wr_wrnp_cmd_not_same_mbyteen_as_rdex == 
                           1'b1)));
        M_OCP_RDEX_CMD_AS_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rdex_cmd_as_burst == 1'b1)));
        M_OCP_RDL_CMD_AS_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rdl_cmd_as_burst == 1'b1)));
        M_OCP_WRC_CMD_AS_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrc_cmd_as_burst == 1'b1)));
        M_OCP_UNLOCKING_WR_WRNP_CMD_AS_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (unlocking_wr_wrnp_cmd_as_burst == 1'b1)));
        M_OCP_WRAP_SEQUENCE_FOR_IMPRECISE_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrap_sequence_for_imprecise_burst == 1'b1)));
        M_OCP_XOR_SEQUENCE_FOR_IMPRECISE_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (xor_sequence_for_imprecise_burst == 1'b1)));
        M_OCP_WRAP_SEQUENCE_NON_POWER_OF_TWO_BURST_LENGTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrap_sequence_non_power_of_two_burst_length == 1'b1)));
        M_OCP_XOR_SEQUENCE_NON_POWER_OF_TWO_BURST_LENGTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (xor_sequence_non_power_of_two_burst_length == 1'b1)));
        M_OCP_STRM_SEQUENCE_WITHOUT_ANY_BYTE_ENABLE_ASSERTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (strm_sequence_without_any_byte_enable == 1'b1)));
        M_OCP_DFLT2_SEQUENCE_WITHOUT_ANY_BYTE_ENABLE_ASSERTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (dflt2_sequence_without_any_byte_enable == 1'b1)));
        M_OCP_STRM_SEQUENCE_NOT_HAVING_SAME_BYTE_ENABLES: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (strm_sequence_not_having_same_byte_enables == 1'b1)));
        M_OCP_MCMD_NOT_CONSTANT_DURING_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mcmd_not_constant_during_burst == 1'b1)));
        M_OCP_MADDRSPACE_NOT_CONSTANT_DURING_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (maddrspace_not_constant_during_burst == 1'b1)));
        M_OCP_MCONNID_NOT_CONSTANT_DURING_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mconnid_not_constant_during_burst == 1'b1)));
        M_OCP_MBURSTPRECISE_NOT_CONSTANT_DURING_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstprecise_not_constant_during_burst == 1'b1)));
        M_OCP_MBURSTSINGLEREQ_NOT_CONSTANT_DURING_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstsinglereq_not_constant_during_burst == 1'b1)));
        M_OCP_MBURSTSEQ_NOT_CONSTANT_DURING_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstseq_not_constant_during_burst == 1'b1)));
        M_OCP_MATOMICLENGTH_NOT_CONSTANT_DURING_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (matomiclength_not_constant_during_burst == 1'b1)));
        M_OCP_MREQINFO_NOT_CONSTANT_DURING_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mreqinfo_not_constant_during_burst == 1'b1)));
        M_OCP_MREQLAST_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mreqlast_violation == 1'b1)));
        M_OCP_MBURSTSINGLEREQ_ASSERTED_WHEN_MBURSTPRECISE_DEASSERTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mburstsinglereq_without_mburstprecise == 1'b1)));
        M_OCP_WR_CMD_WHILE_WRITE_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wr_cmd_while_disabled == 1'b1)));
        M_OCP_RD_CMD_WHILE_READ_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rd_cmd_while_disabled == 1'b1)));
        M_OCP_RDEX_CMD_WHILE_READEX_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rdex_cmd_while_disabled == 1'b1)));
        M_OCP_RDL_CMD_WHILE_RDLWRC_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rdl_cmd_while_disabled == 1'b1)));
        M_OCP_WRC_CMD_WHILE_RDLWRC_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrc_cmd_while_disabled == 1'b1)));
        M_OCP_WRNP_CMD_WHILE_WRITENONPOST_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrnp_cmd_while_disabled == 1'b1)));
        M_OCP_BCST_CMD_WHILE_BROADCAST_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (bcst_cmd_while_disabled == 1'b1)));
        M_OCP_BYTE_ENABLES_NOT_FORCE_ALIGNED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (byte_enables_not_force_aligned == 1'b1)));
        M_OCP_BURST_ALIGNED_INCR_BURST_SIZE_NOT_POWER_OF_TWO: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burst_aligned_incr_burst_size_not_power_of_two == 
                           1'b1)));
        M_OCP_BURST_ALIGNED_INCR_BURST_UNALIGNED_START_ADDR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burst_aligned_incr_burst_unaligned_start_addr == 1'b1)));
        M_OCP_BURST_ALIGNED_INCR_BURST_NOT_PRECISE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (burst_aligned_incr_burst_not_precise == 1'b1)));
        M_OCP_REQDATA_TOGETHER_SINGLE_REQ_PRESENTATION_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reqdata_together_single_req_presentation_violation == 
                           1'b1)));
        M_OCP_REQDATA_TOGETHER_SINGLE_REQ_ACCEPTANCE_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reqdata_together_single_req_acceptance_violation == 
                           1'b1)));
        M_OCP_WRNP_CMD_WHILE_WRITERESP_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrnp_cmd_while_resp_disabled == 1'b1)));
        M_OCP_WRC_CMD_WHILE_WRITERESP_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrc_cmd_while_resp_disabled == 1'b1)));
        M_OCP_RDL_CMD_WHILE_WRITERESP_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (rdl_cmd_while_resp_disabled == 1'b1)));
        M_OCP_DFLT1_BURST_WHILE_BURSTSEQ_DFLT1_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (dflt1_burst_while_disabled == 1'b1)));
        M_OCP_DFLT2_BURST_WHILE_BURSTSEQ_DFLT2_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (dflt2_burst_while_disabled == 1'b1)));
        M_OCP_INCR_BURST_WHILE_BURSTSEQ_INCR_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (incr_burst_while_disabled == 1'b1)));
        M_OCP_STRM_BURST_WHILE_BURSTSEQ_STRM_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (strm_burst_while_disabled == 1'b1)));
        M_OCP_UNKN_BURST_WHILE_BURSTSEQ_UNKN_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (unkn_burst_while_disabled == 1'b1)));
        M_OCP_WRAP_BURST_WHILE_BURSTSEQ_WRAP_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrap_burst_while_disabled == 1'b1)));
        M_OCP_XOR_BURST_WHILE_BURSTSEQ_XOR_ENABLE_0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (xor_burst_while_disabled == 1'b1)));
        M_OCP_XOR_BURST_INCORRECT_ADDRESS_SEQUENCE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (xor_burst_incorrect_address_sequence == 1'b1)));
        M_OCP_INCR_BURST_INCORRECT_ADDRESS_SEQUENCE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (incr_burst_incorrect_address_sequence == 1'b1)));
        M_OCP_STRM_BURST_MADDR_NOT_CONSTANT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (strm_burst_maddr_not_constant == 1'b1)));
        M_OCP_WRAP_BURST_INCORRECT_ADDRESS_SEQUENCE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (wrap_burst_incorrect_address_sequence == 1'b1)));
        M_OCP_REQDATA_TOGETHER_MULTI_REQ_PRESENTATION_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (reqdata_together_multi_req_presentation_violation == 
                           1'b1)));
        M_OCP_MTAGINORDER_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mtaginorder_not_steady == 1'b1)));
        M_OCP_MTAGID_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mtagid_not_steady == 1'b1)));
        M_OCP_MDATATAGID_NOT_STEADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatatagid_not_steady == 1'b1)));
        M_OCP_MTAGID_VALUE_NOT_LESS_THAN_TAGS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mtagid_value_not_less_than_tags == 1'b1)));
        M_OCP_MDATATAGID_VALUE_NOT_LESS_THAN_TAGS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatatagid_value_not_less_than_tags == 1'b1)));
        M_OCP_MTAGID_NOT_CONSTANT_DURING_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mtagid_not_constant_during_burst == 1'b1)));
        M_OCP_MTAGINORDER_NOT_CONSTANT_DURING_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mtaginorder_not_constant_during_burst == 1'b1)));
        M_OCP_MTHREADID_VALUE_NOT_LESS_THAN_THREADS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mthreadid_value_not_less_than_threads == 1'b1)));
        M_OCP_MDATATHREADID_VALUE_NOT_LESS_THAN_THREADS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatathreadid_value_not_less_than_threads == 1'b1)));
        M_OCP_STRM_SEQUENCE_WITHOUT_ANY_MDATABYTE_ENABLE_ASSERTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (strm_sequence_without_any_mdatabyte_enable == 1'b1)));
        M_OCP_DFLT2_SEQUENCE_WITHOUT_ANY_MDATABYTE_ENABLE_ASSERTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (dflt2_sequence_without_any_mdatabyte_enable == 1'b1)));
        M_OCP_STRM_SEQUENCE_NOT_HAVING_SAME_MDATABYTE_ENABLES: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (strm_sequence_not_having_same_mdatabyte_enables == 
                           1'b1)));
        M_OCP_MDATABYTE_ENABLES_NOT_FORCE_ALIGNED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatabyte_enables_not_force_aligned == 1'b1)));
        M_OCP_MDATALAST_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (last_data_violation == 1'b1)));
        M_OCP_DATAHANDSHAKE_BEGINNING_BEFORE_REQUEST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (data_beginning_before_request == 1'b1))); 
        M_OCP_DATAHANDSHAKE_ENDING_BEFORE_REQUEST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (data_ending_before_request == 1'b1)));
        M_OCP_TAGGED_WRITE_DATA_OUT_OF_ORDER: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (tagged_write_data_out_of_order == 1'b1)));
//OCP 2.2 Protocol complince constraints
        M_OCP_MBLOCKHEIGHT_NOT_STEADY:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mblockheight_not_steady == 1'b1)));
        M_OCP_MBLOCKSTRIDE_NOT_STEADY:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr ( mblockstride_not_steady== 1'b1)));
        M_OCP_MREQROWLAST_NOT_STEADY:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mreqrowlast_not_steady== 1'b1)));
        M_OCP_MDATAROWLAST_NOT_STEADY:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mdatarowlast_not_steady == 1'b1)));
        M_OCP_ILLEGAL_MBLOCKHEIGHT_ENCODING:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr ( illegal_mblockheight_encoding== 1'b1)));
        M_OCP_ILLEGAL_MBLOCKSTRIDE_ENCODING:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (illegal_mblockstride_encoding == 1'b1)));
        M_OCP_BLCK_BURST_WHILE_BURSTSEQ_BLCK_ENABLE_0:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (blck_burst_while_burstseq_blck_enable_0 == 1'b1)));
        M_OCP_MBLOCKHEIGHT_NOT_CONSTANT_DURING_BURST:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mblockheight_not_constant_during_burst == 1'b1)));
        M_OCP_MBLOCKSTRIDE_NOT_CONSTANT_DURING_BURST:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mblockstride_not_constant_during_burst == 1'b1)));
        M_OCP_MBLOCKSTRIDE_UNALIGNED_TO_OCP_WORD_SIZE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mblockstride_unaligned_to_ocp_word_size == 1'b1)));
        M_OCP_BLCK_BURST_INCORRECT_ADDRESS_SEQUENCE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (blck_burst_incorrect_address_sequence == 1'b1)));
        M_OCP_BLCK_ADDRSPACE_BOUNDARY_CROSS:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (blck_addrspace_boundary_cross == 1'b1)));
        M_OCP_MCMD_NOT_IDLE_WHILE_OCP_NOT_CONNECTED:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (mcmd_not_idle_while_ocp_not_connected == 1'b1)));
        M_OCP_LEAVING_CONNECTED_STATE_DURING_ONGOING_TRANSACTION:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (ocp_leaving_connected_state_during_ongoing_transaction == 1'b1)));
        M_OCP_TRANSITS2MWAIT_WITHOUT_SLAVE_REQUEST:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (ocp_transits2mwait_without_slave_request == 1'b1)));
        M_OCP_TRANSITS2MCON_WITHOUT_SLAVE_GRANT:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (ocp_transits2mcon_without_slave_grant == 1'b1)));
        M_OCP_TRANSITS2MDISC_WITHOUT_SLAVE_REQUEST:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (ocp_transits2mdisc_without_slave_request == 1'b1)));
        M_OCP_TRANSITS2MOFF_WITHOUT_SLAVE_GRANT:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (ocp_transits2moff_without_slave_grant == 1'b1)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_SLAVE_SIDE 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

// Core side

generate
  case (ZI_CONSTRAINT_CORE_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_CORE_SIDE 
        A_OCP_CONTROL_CHANGED_MORE_THAN_ONCE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (control_changed_more_than_once == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROL_CHANGED_MORE_THAN_ONCE"}),
                          .msg            ("Control signal should not change more than once every other cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_CORE_SIDE));
        A_OCP_CONTROL_CHANGED_WHILE_CONTROLBUSY_ACTIVE_IN_PREVIOUS_CYCLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (control_changed_while_controlbusy_active_in_previous_cycle == 
                                                                          1'b1)
               ))


          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROL_CHANGED_WHILE_CONTROLBUSY_ACTIVE_IN_PREVIOUS_CYCLE"}),
                          .msg            ("If ControlBusy is sampled asserted in the the previous cycle, Control should not transition in the current cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_CORE_SIDE));
        A_OCP_CONTROL_NOT_STEADY_AFTER_RESET: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (control_not_steady_after_reset == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROL_NOT_STEADY_AFTER_RESET"}),
                          .msg            ("Control should be held steady for the first two cycles after reset is deasserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_CORE_SIDE));
        A_OCP_CONTROLWR_DEASSERTED_WHILE_CONTROL_CHANGED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (controlwr_deasserted_while_control_changed == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROLWR_DEASSERTED_WHILE_CONTROL_CHANGED"}),
                          .msg            ("Control signal can toggle only when ControlWr is sampled asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_CORE_SIDE));
        A_OCP_CONTROLWR_ASSERTED_FOR_MORE_THAN_ONE_CYCLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (contolwr_asserted_for_more_than_one_cycle == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROLWR_ASSERTED_FOR_MORE_THAN_ONE_CYCLE"}),
                          .msg            ("ControlWr should not be active for more than one clock cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_CORE_SIDE));
        A_OCP_STATUSRD_ASSERTED_FOR_MORE_THAN_ONE_CYCLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (statusrd_asserted_for_more_than_one_cycle == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STATUSRD_ASSERTED_FOR_MORE_THAN_ONE_CYCLE"}),
                          .msg            ("StatusRd should  be asserted for only one clock cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_CORE_SIDE));
        A_OCP_CONTROLWR_ASSERTED_WHILE_CONTROLBUSY_ACTIVE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (controlwr_asserted_while_controlbusy_active == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROLWR_ASSERTED_WHILE_CONTROLBUSY_ACTIVE"}),
                          .msg            ("ControlWr signal should not be asserted if ControlBusy is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_CORE_SIDE));
        A_OCP_STATUSRD_ASSERTED_WHILE_STATUSBUSY_ACTIVE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (statusrd_asserted_while_statusbusy_active == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_STATUSRD_ASSERTED_WHILE_STATUSBUSY_ACTIVE"}),
                          .msg            ("StatusRd signal should not be asserted if StatusBusy is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_CORE_SIDE));
        A_OCP_CONTROLWR_ASSERTED_IN_FIRST_CYCLE_AFTER_RESET: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (controlwr_asserted_in_first_cycle_after_reset == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROLWR_ASSERTED_IN_FIRST_CYCLE_AFTER_RESET"}),
                          .msg            ("ControlWr signal should not be asserted in the cycle following a reset."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_CORE_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_CORE_SIDE 
        M_OCP_CONTROL_CHANGED_MORE_THAN_ONCE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (control_changed_more_than_once == 1'b1)));
        M_OCP_CONTROL_CHANGED_WHILE_CONTROLBUSY_ACTIVE_IN_PREVIOUS_CYCLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr
                 (control_changed_while_controlbusy_active_in_previous_cycle == 
                                                                          1'b1)
               ) );
        M_OCP_CONTROL_NOT_STEADY_AFTER_RESET: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (control_not_steady_after_reset == 1'b1)));
        M_OCP_CONTROLWR_DEASSERTED_WHILE_CONTROL_CHANGED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (controlwr_deasserted_while_control_changed == 1'b1)));
        M_OCP_CONTROLWR_ASSERTED_FOR_MORE_THAN_ONE_CYCLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (contolwr_asserted_for_more_than_one_cycle == 1'b1)));
        M_OCP_STATUSRD_ASSERTED_FOR_MORE_THAN_ONE_CYCLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (statusrd_asserted_for_more_than_one_cycle == 1'b1)));
        M_OCP_CONTROLWR_ASSERTED_WHILE_CONTROLBUSY_ACTIVE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (controlwr_asserted_while_controlbusy_active == 1'b1)));
        M_OCP_STATUSRD_ASSERTED_WHILE_STATUSBUSY_ACTIVE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (statusrd_asserted_while_statusbusy_active == 1'b1)));
        M_OCP_CONTROLWR_ASSERTED_IN_FIRST_CYCLE_AFTER_RESET: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (controlwr_asserted_in_first_cycle_after_reset == 1'b1)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_CORE_SIDE 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

// System side

generate
  case (ZI_CONSTRAINT_SYSTEM_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_SYSTEM_SIDE 
        A_OCP_CONTROLBUSY_ASSERTED_INCORRECTLY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (controlbusy_asserted_incorrectly == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_OCP_CONTROLBUSY_ASSERTED_INCORRECTLY"}),
                          .msg            ("ControlBusy should only be asserted immediately after reset is deasserted, or in the cycle after ControlWr is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SYSTEM_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_SYSTEM_SIDE 
        M_OCP_CONTROLBUSY_ASSERTED_INCORRECTLY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ocpclk ),
                          .reset_n   (areset_n & oreset_n),
                          .enable    (1'b1),
                          .test_expr (controlbusy_asserted_incorrectly == 1'b1)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_SYSTEM_SIDE 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

`endif //QVL_ASSRT_ON

