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
      $MULMOD:
        stack_ptr := safe_sub(stack_ptr, 0x60, stack_start)
        mstore(stack_ptr, mulmod(mload(add(stack_ptr, 0x40)), mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $EXP:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, exp(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $SIGNEXTEND:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, signextend(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $LT:
      $GT:
      $SLT:
      $SGT:
      $EQ:
      $ISZERO:
      $AND:
      $OR:
      $XOR:
      $NOT:
      $BYTE:
      $SHA3:
      $ADDRESS:
      $BALANCE:
      $ORIGIN:
      $CALLER:
      $CALLVALUE:
      $CALLDATALOAD:
      $CALLDATASIZE:
      $CALLDATACOPY:
      $CODESIZE:
      $CODECOPY:
      $GASPRICE:
      $EXTCODESIZE:
      $EXTCODECOPY:
      $RETURNDATASIZE:
      $RETURNDATACOPY:
      $BLOCKHASH:
      $COINBASE:
      $TIMESTAMP:
      $NUMBER:
      $DIFFICULTY:
      $GASLIMIT:
      $POP:
      $MLOAD:
      $MSTORE:
      $MSTORE8:
      $SLOAD:
      $SSTORE:
      $JUMP:
      $JUMPI:
      $PC:
      $MSIZE:
      $GAS:
      $JUMPDEST:
      $PUSH:
      $DUP:
      $SWAP:
      $LOG0:
      $LOG1:
      $LOG2:
      $LOG3:
      $LOG4:
      $CREATE:
      $CALL:
      $CALLCODE:
      $RETURN:
      $DELEGATECALL:
      $STATICCALL:
      $REVERT:
      $INVALID:
      $SELFDESTRUCT:

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
        mstore(0x62, $STOP)
        mstore(0x64, $ADD)
        mstore(0x66, $MUL)
        mstore(0x68, $SUB)
        mstore(0x6a, $DIV)
        mstore(0x6c, $SDIV)
        mstore(0x6e, $MOD)
        mstore(0x70, $SMOD)
        mstore(0x72, $ADDMOD)
        mstore(0x74, $MULMOD)
        mstore(0x76, $EXP)
        mstore(0x78, $SIGNEXTEND)
        mstore(0x82, $LT)
        mstore(0x84, $GT)
        mstore(0x86, $SLT)
        mstore(0x88, $SGT)
        mstore(0x8a, $EQ)
        mstore(0x8c, $ISZERO)
        mstore(0x8e, $AND)
        mstore(0x90, $OR)
        mstore(0x92, $XOR)
        mstore(0x94, $NOT)
        mstore(0x96, $BYTE)
        mstore(0xa2, $SHA3)
        mstore(0xc2, $ADDRESS)
        mstore(0xc4, $BALANCE)
        mstore(0xc6, $ORIGIN)
        mstore(0xc8, $CALLER)
        mstore(0xca, $CALLVALUE)
        mstore(0xcc, $CALLDATALOAD)
        mstore(0xce, $CALLDATASIZE)
        mstore(0xd0, $CALLDATACOPY)
        mstore(0xd2, $CODESIZE)
        mstore(0xd4, $CODECOPY)
        mstore(0xd6, $GASPRICE)
        mstore(0xd8, $EXTCODESIZE)
        mstore(0xda, $EXTCODECOPY)
        mstore(0xdc, $RETURNDATASIZE)
        mstore(0xde, $RETURNDATACOPY)
        mstore(0xe2, $BLOCKHASH)
        mstore(0xe4, $COINBASE)
        mstore(0xe6, $TIMESTAMP)
        mstore(0xe8, $NUMBER)
        mstore(0xea, $DIFFICULTY)
        mstore(0xec, $GASLIMIT)
        mstore(0x102, $POP)
        mstore(0x104, $MLOAD)
        mstore(0x106, $MSTORE)
        mstore(0x108, $MSTORE8)
        mstore(0x10a, $SLOAD)
        mstore(0x10c, $SSTORE)
        mstore(0x10e, $JUMP)
        mstore(0x110, $JUMPI)
        mstore(0x112, $PC)
        mstore(0x114, $MSIZE)
        mstore(0x116, $GAS)
        mstore(0x118, $JUMPDEST)
        for { let i := 0x122 } lt(i, 0x15c) { i := add(0x2) }
        {
          mstore(i, $PUSH)
        }
        for { let i := 0x162 } lt(i, 0x17c) { i := add(0x2) } 
        {
          mstore(i, $DUP)
        }
        for { let i := 0x182 } lt(i, 0x19c) { i := add(0x2) } 
        {
          mstore(i, $SWAP)
        }
        mstore(0x1a2, $LOG0)
        mstore(0x1a4, $LOG1)
        mstore(0x1a6, $LOG2)
        mstore(0x1a8, $LOG3)
        mstore(0x1aa, $LOG4)

        mstore(0x242, $CREATE)
        mstore(0x244, $CALL)
        mstore(0x246, $CALLCODE)
        mstore(0x248, $RETURN)
        mstore(0x24a, $DELEGATECALL)
        mstore(0x256, $STATICCALL)
        mstore(0x25c, $REVERT)
        mstore(0x25e, $INVALID)
        mstore(0x260, $SELFDESTRUCT)

      }
    }
  }
}
