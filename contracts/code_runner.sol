pragma solidity ^0.4.24;

contract Runner {

  constructor() public {
    // FIXME - Set free memory pointer to allow jump table to be placed in memory
  }

  function run(bytes memory _code, bytes memory _data) public payable {
    assembly {
      place_table()
      // Instantiate the opcode and label variables
      let opcode
      let label
      // Set the code_ptr to point after _code's length slot
      let code_ptr := add(_code, 0x1f) 
      let code_size := mload(_code)
      // Set the code_end value to point after the bytecode
      let code_end := add(code_ptr, add(code_size, 0x1)) 
      // Set the start of the stack to the current free memory pointer
      let stack_start := mload(0x40)
      // Set the stack pointer to the start of the stack
      let stack_ptr := stack_start 
      // Create space in memory for the stack
      let mem_ptr := add(stack_ptr, mul(1024, 0x20))
      let cd_ptr := add(calldataload(0x24), 0x20)
      // Set up the pseudo free memory pointer
      mstore(add(mem_ptr, 0x40), 0x80)
      // Main LOOP
      LOOP:
        code_ptr := add(code_ptr, 0x1) 
        if gt(code_ptr, code_end) {
          stop()
        }
        opcode := byte(mload(code_ptr), 0x0) 
        // Load the jumpdest for the given opcode from the jump table
        label := div(mload(add(mul(opcode, 0x2), 0x80)), exp(2, 240))
        // If the opcode's label equals zero, revert because the opcode is not in the jump table
        if eq(label, 0x0) {
          revert(0x0, 0x0)
        }
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
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, lt(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $GT:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, gt(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $SLT:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, slt(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $SGT:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, sgt(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $EQ:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, eq(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $ISZERO:
        stack_ptr := safe_sub(stack_ptr, 0x20, stack_start)
        mstore(stack_ptr, iszero(mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $AND:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, and(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $OR:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, or(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $XOR:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, xor(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $NOT:
        stack_ptr := safe(stack_ptr, 0x20, stack_start)
        mstore(stack_ptr, not(mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $BYTE:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, byte(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $SHA3:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(stack_ptr, keccak256(mload(add(stack_ptr, 0x20)), mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $ADDRESS:
        mstore(stack_ptr, address)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $BALANCE:
        mstore(stack_ptr, balance)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $ORIGIN:
        mstore(stack_ptr, origin)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $CALLER:
        mstore(stack_ptr, origin)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $CALLVALUE:
        mstore(stack_ptr, origin)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $CALLDATALOAD:
        stack_ptr := safe_sub(stack_ptr, 0x20, stack_start)
        mstore(
          stack_ptr, 
          calldataload(
            add(mload(stack_ptr), cd_ptr)
          )
        )
        jump(LOOP)
      $CALLDATASIZE:
        mstore(stack_ptr, origin)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $CALLDATACOPY:
        stack_ptr := safe_sub(stack_ptr, 0x60, stack_start)
        calldatacopy(
          add(mload(add(stack_ptr, 0x40)), mem_ptr),
          add(mload(add(stack_ptr, 0x20)), cd_ptr), 
          mload(stack_ptr)
        ) 
        jump(LOOP)
      $CODESIZE:
        mstore(stack_ptr, mload(_code))
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $CODECOPY:
        stack_ptr := safe_sub(stack_ptr, 0x60, stack_start)
        let code_start := add(mload(add(stack_ptr, 0x20)), 0x64)
        let size := mload(stack_ptr)
        if gt(add(code_start, size), code_end) {
          calldatacopy(
            add(mload(add(stack_ptr, 0x40)), mem_ptr),
            code_start,
            sub(code_end, code_start)
          )
          codecopy(
            add(add(mload(add(stack_ptr, 0x40)), mem_ptr), sub(code_end, code_start)), 
            codesize, 
            sub(size, sub(code_end, code_start))
          )         
          jump(LOOP) 
        }
        calldatacopy(
          add(mload(add(stack_ptr, 0x40)), mem_ptr),
          code_start,
          size
        )
        jump(LOOP)
      $GASPRICE:
        mstore(stack_ptr, gasprice)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $EXTCODESIZE:
        mstore(stack_ptr, extcodesize(mload(stack_ptr)))
        stack_ptr := safe_sub(stack_ptr, 0x20, stack_start)
        jump(LOOP)
      $EXTCODECOPY:
        stack_ptr := safe_sub(stack_ptr, 0x80, stack_start)
        extcodecopy( 
          mload(add(stack_ptr, 0x60)), 
          add(mload(add(stack_ptr, 0x40), mem_ptr), 
          mload(add(stack_ptr, 0x20)),
          mload(stack_ptr)
        )
        jump(LOOP)
      $RETURNDATASIZE:
        mstore(stack_ptr, returndatasize)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $RETURNDATACOPY:
        stack_ptr := safe_sub(stack_ptr, 0x60, stack_start)
        returndatacopy(
          add(mload(add(stack_ptr, 0x40)), mem_ptr), 
          mload(add(stack_ptr, 0x20)), 
          mload(stack_ptr)
        ) 
        jump(LOOP)
      $BLOCKHASH:
        stack_ptr := safe_sub(stack_ptr, 0x20, stack_start)
        mstore(stack_ptr, blockhash(mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $COINBASE:
        mstore(stack_ptr, coinbase)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $TIMESTAMP:
        mstore(stack_ptr, timestamp)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $NUMBER:
        mstore(stack_ptr, number)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $DIFFICULTY:
        mstore(stack_ptr, difficulty)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $GASLIMIT:
        mstore(stack_ptr, gaslimit)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $POP:
        stack_ptr := safe_sub(stack_ptr, 0x20, stack_start)
        jump(LOOP)
      $MLOAD:
        stack_ptr := safe_sub(stack_ptr, 0x20, stack_start)
        mstore(stack_ptr, mload(stack_ptr))
        jump(LOOP)
      $MSTORE:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore(add(mload(add(stack_ptr, 0x20)), mem_ptr), mload(stack_ptr))
        jump(LOOP)
      $MSTORE8:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        mstore8(add(mload(add(stack_ptr, 0x20)), mem_ptr), mload(stack_ptr))
        jump(LOOP)
      $SLOAD:
        stack_ptr := safe_sub(stack_ptr, 0x20, stack_start)
        mstore(stack_ptr, sload(mload(stack_ptr)))
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $SSTORE:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        sstore(mload(add(stack_ptr, 0x40)), mload(stack_ptr))
        jump(LOOP)
      $JUMP:
        stack_ptr := safe_sub(stack_ptr, 0x20, stack_start)
        code_ptr := add(_code, add(0x1f, mload(stack_ptr)))
        opcode := byte(mload(add(code_ptr, 0x1)), 0x0)
        if iszero(eq(0x5b, opcode)) {
          revert(0x0, 0x0)
        }
        jump(LOOP)
      $JUMPI:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        if mload(stack_ptr) {
          code_ptr := add(_code, add(0x1f, mload(add(stack_ptr, 0x20))))
          opcode := byte(mload(add(code_ptr, 0x1)), 0x0)
          if iszero(eq(0x5b, opcode)) {
            revert(0x0, 0x0)
          }
        }
        jump(LOOP)
      $PC:
        mstore(stack_ptr, pc)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $MSIZE:
        mstore(stack_ptr, msize)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $GAS:
        mstore(stack_ptr, gas)
        stack_ptr := safe_add(stack_ptr, 0x20, mem_ptr)
        jump(LOOP)
      $JUMPDEST:
        jump(LOOP)
      $PUSH:
        jump(LOOP)
      $DUP:
        jump(LOOP)
      $SWAP:
        jump(LOOP)
      $LOG0:
        stack_ptr := safe_sub(stack_ptr, 0x20, stack_start)
        log0(
           mload(stack_ptr)
        )
        jump(LOOP)
      $LOG1:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        log1(
           mload(add(stack_ptr, 0x20)),
           mload(stack_ptr)
        )
        jump(LOOP)
      $LOG2:
        stack_ptr := safe_sub(stack_ptr, 0x60, stack_start)
        log2(
           mload(add(stack_ptr, 0x40)),
           mload(add(stack_ptr, 0x20)),
           mload(stack_ptr)
        )
        jump(LOOP)
      $LOG3:
        stack_ptr := safe_sub(stack_ptr, 0x80, stack_start)
        log3(
           mload(add(stack_ptr, 0x60)),
           mload(add(stack_ptr, 0x40)),
           mload(add(stack_ptr, 0x20)),
           mload(stack_ptr)
        )
        jump(LOOP)
      $LOG4:
        stack_ptr := safe_sub(stack_ptr, 0xa0, stack_start)
        log4(
           mload(add(stack_ptr, 0x80)),
           mload(add(stack_ptr, 0x60)),
           mload(add(stack_ptr, 0x40)),
           mload(add(stack_ptr, 0x20)),
           mload(stack_ptr)
        )
        jump(LOOP)
      $CREATE:
        stack_ptr := safe_sub(stack_ptr, 0x60, stack_start)
        mstore(stack_ptr, 
               create(
                 mload(add(stack_ptr, 0x40)),
                 mload(add(stack_ptr, 0x20)),
                 mload(stack_ptr)
               )
              )
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $CALL:
        stack_ptr := safe_sub(stack_ptr, 0xe0, stack_start)
        mstore(stack_ptr, 
               call(
                 mload(add(stack_ptr, 0xc0)),
                 mload(add(stack_ptr, 0xa0)), 
                 mload(add(stack_ptr, 0x80)),
                 mload(add(stack_ptr, 0x60)),
                 mload(add(stack_ptr, 0x40)),
                 mload(add(stack_ptr, 0x20)),
                 mload(stack_ptr)
               )
              )
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $CALLCODE:
        stack_ptr := safe_sub(stack_ptr, 0xc0, stack_start)
        mstore(stack_ptr, 
               callcode(
                 mload(add(stack_ptr, 0xa0)), 
                 mload(add(stack_ptr, 0x80)),
                 mload(add(stack_ptr, 0x60)),
                 mload(add(stack_ptr, 0x40)),
                 mload(add(stack_ptr, 0x20)),
                 mload(stack_ptr)
               )
              )
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $RETURN:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        return(mload(add(stack_ptr, 0x20)), mload(stack_ptr))
      $DELEGATECALL:
        stack_ptr := safe_sub(stack_ptr, 0xc0, stack_start)
        mstore(stack_ptr, 
               delegatecall(
                 mload(add(stack_ptr, 0xa0)), 
                 mload(add(stack_ptr, 0x80)),
                 mload(add(stack_ptr, 0x60)),
                 mload(add(stack_ptr, 0x40)),
                 mload(add(stack_ptr, 0x20)),
                 mload(stack_ptr)
               )
              )
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $STATICCALL:
        stack_ptr := safe_sub(stack_ptr, 0xc0, stack_start)
        mstore(stack_ptr, 
               staticcall(
                 mload(add(stack_ptr, 0xa0)), 
                 mload(add(stack_ptr, 0x80)),
                 mload(add(stack_ptr, 0x60)),
                 mload(add(stack_ptr, 0x40)),
                 mload(add(stack_ptr, 0x20)),
                 mload(stack_ptr)
               )
              )
        stack_ptr := add(stack_ptr, 0x20)
        jump(LOOP)
      $REVERT:
        stack_ptr := safe_sub(stack_ptr, 0x40, stack_start)
        revert(add(mload(add(stack_ptr, 0x20)), mem_ptr), mload(stack_ptr))
      $INVALID:
        invalid
      $SELFDESTRUCT:
        stack_ptr := safe_sub(stack_ptr, 0x20, stack_start)
        selfdestruct(mload(stack_ptr))
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
