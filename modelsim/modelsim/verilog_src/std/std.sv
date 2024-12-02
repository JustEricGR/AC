// This is the SystemVerilog builtin "std" package as defined in the
// P1800 Draft 5 LRM
//
//   NOTE: VLOG and VSIM will not work properly if these declarations
//         are modified.
package std;

class semaphore;
	local chandle p1;
	local int keyCount;
	function new(int keyCount = 0);
	this.keyCount = keyCount;
	endfunction
	extern function void put(int keyCount = 1);
	extern task get(int keyCount = 1);
	extern function int try_get(int keyCount = 1);
endclass

class mailbox #(type T = integer /*FINISH: dynamic_singular_type*/);
	local T items[$];
	local semaphore read_semaphore;
	local semaphore write_semaphore;

	function new(int maxItems = 0);
	  read_semaphore = new(0);
	  if (maxItems > 0)
		write_semaphore = new(maxItems);
      else if (maxItems < 0)
        $display("** Warning: Ignoring illegal negative size in mailbox construction; using default");
	endfunction

	function int num();
	  return items.size();
	endfunction

	task put(T message);
	  if (write_semaphore!=null)
		write_semaphore.get(1);
	  items.push_back(message);
	  read_semaphore.put(1);
	endtask

	function int try_put(T message);
	  if (write_semaphore==null || write_semaphore.try_get(1) > 0) begin
		items.push_back(message);
		read_semaphore.put(1);
		return 1;
	  end
	  return 0;
	endfunction

	task get(output /*ref*/ T message);
	  read_semaphore.get(1);
	  message = items.pop_front();
	  if (write_semaphore!=null)
		write_semaphore.put(1);
	endtask

	function int try_get(output /*ref*/ T message);
	  if (read_semaphore.try_get(1) > 0) begin
		message = items.pop_front();
		if (write_semaphore!=null)
		  write_semaphore.put(1);
		return 1;
	  end
	  return 0;
	endfunction

	task peek(output /*ref*/ T message);
	  read_semaphore.get(1);
	  message = items[0];
	  read_semaphore.put(1);
	endtask

	function int try_peek(output /*ref*/ T message);
	  if (read_semaphore.try_get(1) > 0) begin
		message = items[0];
		read_semaphore.put(1);
		return 1;
	  end
	  return 0;
	endfunction
endclass

class process;
	typedef enum { FINISHED, RUNNING, WAITING, SUSPENDED, KILLED } state;
	extern local function new();	// illegal to call
	extern static function process self();
	extern function state status();
	extern function void kill();
	extern task await();
	extern function void suspend();
	extern function void resume();
endclass

function automatic int randomize(input int i);
endfunction

endpackage
