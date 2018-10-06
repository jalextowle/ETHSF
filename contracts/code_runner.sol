pragma solidity ^0.4.24;

contract Runner {

  constructor() public {
    // FIXME - Set free memory pointer to allow jump table to be placed in memory
  }

  function run(bytes memory _code, bytes memory _data) public payable {
    assembly {
      // FIXME - Place jump table in memory
      place_table()

      // Instantiate the opcode and label variables
      let opcode
      let label
      // Set the code_ptr to point after _code's length slot
      let code_ptr := add(_code, 0x1f) 
      // Set the code_end value to point after the bytecode
      let code_end := add(code_ptr, mload(_code)) 
      // Set the start of the stack to the current free memory pointer
      let stack_start := mload(0x40)
      // Set the stack pointer to the start of the stack
      let stack_ptr := stack_start 
      // Create space in memory for the stack
      let mem_ptr := add(stack_ptr, mul(1024, 0x20))
      // Set up the pseudo free memory pointer
      mstore(add(mem_ptr, 0x40), 0x80)

      // Main Loop
      LOOP:
        code_ptr := add(code_ptr, 0x1) 
        if gt(code_ptr, code_end) {
          stop()
        }
        opcode := byte(mload(code_ptr), 0x0) 
        // Load the jumpdest for the given opcode from the jump table
        label := div(mload(add(mul(opcode, 0x2), 0x80)), exp(2, 240))
        jump(label) 

      $STOP: 
        stop()
      $ADD:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, add(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $MUL:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, mul(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $SUB:  
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, sub(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $DIV:  
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, div(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $SDIV:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, sdiv(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $MOD: 
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, mod(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $SMOD: 
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, smod(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $ADDMOD: 
        stack_ptr := safe_sub(stack_ptr, 0x60, stack_start)
        mstore(stack_ptr, addmod(mload(add(stack_ptr, 0x40)), mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)


      function safe_sub(_ptr, _dif, _ref) -> ptr {
        ptr := sub(_ptr, _dif)
        if or(lt(_ptr, _dif), lt(ptr, _ref)) {
          revert(0x0, 0x0)
        }
      }

      function safe_add(_ptr, _dif, _ref) -> ptr {
        ptr := add(_ptr, _dif)
        if gt(ptr, _ref) {
          revert(0x0, 0x0)
        }
      }

      function place_table() {
        mstore(0x80, $STOP)
        mstore(0x82, $ADD)
        mstore(0x84, $MUL)
        mstore(0x86, $SUB)
        mstore(0x88, $DIV)
        mstore(0x90, $SDIV)
        mstore(0x92, $MOD)
      }
    }
  }

}
