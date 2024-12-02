
`ifndef AVM_MACROS_HEADER
`define AVM_MACROS_HEADER

// some macros to manage cloning

`define AVM_CLONE_METHOD( T ) function avm_transaction clone; T t = new; t.copy( this ); assert( $cast( clone , t ) ); endfunction
`define AVM_CLONE( to , from ) if( !$cast( to , from.clone() ) ) avm_report_error("Clone Error" , "Type mismatch" );

`endif
