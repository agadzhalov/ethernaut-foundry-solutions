// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * 1. We need to get the data[2]. To get the data we have to calculate on which slot is stored
 * 2. We already know it's stored on slot 5, slots start from 0. To get it we can use cast storage 
 * 3. data[3] = 0x44ef0f7aae4c063133e1671b9338606e56c917158e97ae9840804c0977d31233
 * 4. We need to get the first 16 bytes from the data and pass them to the unlock() method.
 */
contract Privacy {
    bool public locked = true; // 1 byte (0 stot)
    uint256 public ID = block.timestamp; // 32 bytes (2st slot)
    uint8 private flattening = 10; // 1 byte (2nd slot)
    uint8 private denomination = 255; // 1 byte (2nd slot)
    uint16 private awkwardness = uint16(block.timestamp); // 2 bytes (2nd slot)
    bytes32[3] private data;    // data[0] -> (3rd slot)
                                // data[1] -> (4th slot)
                                // data[2] -> (5th slot)

    constructor(bytes32[3] memory _data) {
        data = _data;
    }

    function unlock(bytes16 _key) public {
        require(_key == bytes16(data[2]));
        locked = false;
    }
    /*
    A bunch of super advanced solidity algorithms...

      ,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`
      .,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,
      *.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^         ,---/V\
      `*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.    ~|__(o.o)
      ^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'  UU  UU
    */
}