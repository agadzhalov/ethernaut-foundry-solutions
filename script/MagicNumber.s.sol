/**
 * There are some prerequisites we need to know before starting this challange
 * 
 * OPCODES
 * 
 * PUSH0 -> pushes a zero byte onto the stack.
 * PUSH1 -> pushes a single byte value specified onto the stack.
 * MSTORE(p, v) -> used to store data in memory
 * p - memory location in bytes where the data should be stored
 * v - the value to store at the specified memory location
 * 
 * RETURN(p, s)
 * p - starting offset -> This specifies the starting point in memory from where the data should be returned. It's an offset in the memory where the return data starts.
 * s - length -> This specifies the length of the data to return, starting from the given offset p
 * ============================================================================================================
 * 
 * Store number 42 in memory. 
 * Before we call the MSTORE opcode we will need to prepare two inputs onto the stack
 * 
 * PUSH1 0x2a -> arguments v, 42 in hexadecimal format 
 * PUSH1 0 -> argument p, zeroth byte of memory
 * MSTORE -> stores 0x2a in the zeroth byte of memory
 * 
 * Before executing RETURN we need to store p,s in the EVM stack.
 * 
 * We need a sequence that will return 32 bytes from memory starting at memory 0
 * PUSH1 0x20 -> argument p, 0x20 is 32 in hexadecimal format
 * PUSH1 0 -> argument s
 * RETURN -> always to return the number 42. This opcode will end the execution of the code.
 * 
 * transition to bytecode -> 60 2a 60 00 52 60 20 60 00 f3
 * ============================================================================================================
 *
 * Store creation code to memory
 * 
 * PUSH10 602a60005260206000f3 -> runtime code is 10 bytes
 * PUSH1 0 -> store the runtime code at zero
 * MSTORE -> stores the runtime code at memory 0
 * 
 * transition to bytecode -> 69 602a60005260206000f3 60 00 f3
 * 
 * Final part is to return the runtime code.
 * The runtime code is stored as 32 bytes in memory, that's why our runtime code is padded with zero on the left
 * 
 * 0x0000000000000000000000000000000000000000000000000000602a60005260206000f3
 * 
 * PUSH1 0x0a 
 * PUSH1 0x16
 * RETURN -> this will return 10 bytes starting from offset 22
 * 
 * transition to bytecode ->  60 0a 60 16 f3
 * ============================================================================================================
 * 
 * Runtime code
 * 
 * PUSH1 0x2a                       60 2a
 * PUSH1 0                          60 00
 * MSTORE                           f3
 * PUSH1 0x20                       60 2a
 * PUSH1 0                          60 00
 * RETURN                           52
 * 
 * How all of the OPCODES together look like
 * 
 * PUSH10 602a60005260206000f3      69 602a60005260206000f3
 * PUSH1 0                          60 00
 * MSTORE                           52
 * PUSH1 0x0a                       60 0a
 * PUSH1 0x16                       60 16
 * RETURN                           f3
 * 
 * Bytecode -> 69 602a60005260206000f3 60 00 52 60 0a 60 16 f3
 * After we remove the spaces -> 69602a60005260206000f3600052600a6016f3
 * 
 * resource: 
 * 1. https://ethereum.org/en/developers/docs/evm/opcodes/
 * 2. https://www.youtube.com/watch?v=0qQUhsPafJc
 */