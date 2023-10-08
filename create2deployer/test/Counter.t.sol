// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {Counter} from "../src/Counter.sol";
import {compile, Vm} from "./Deploy.sol";

contract CounterTest is Test {
    using {compile} for Vm;

    Counter public counter;

    function setUp() public {
    }

    function deployFromBytecode(bytes memory bytecode) internal returns (address) {
        address child;

        assembly{
            child := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        return child;
   }

    function test_huffcreate2factory() public {
        bytes memory newCreate2Bytecode = vm.compile("src/CREATE2DEPLOYER.huff");

        /// @notice deploy the bytecode with the create instruction
        address CREATE2HUFF = deployFromBytecode(newCreate2Bytecode);
        bytes32 salt = keccak256("salt");
        // this will use CREATE2_FACTORY
        address preComputedAddress = computeCreate2Address(salt, keccak256(abi.encodePacked(type(Counter).creationCode)), CREATE2HUFF);
        (bool success, bytes memory response) = CREATE2HUFF.call(abi.encodePacked(salt, type(Counter).creationCode));
        require(success, "should be successful");  
        CREATE2HUFF.call(abi.encodePacked(salt, type(Counter).creationCode));
        // a bit messy but works
        (,,uint256 _counter) = abi.decode(abi.encode(response), (bytes32, uint256, uint256));
        assertEq(address(uint160(_counter>>96)), preComputedAddress, "should be the same address");

        Counter create2Counter = Counter(address(uint160(_counter>>96))) ;   
    
        create2Counter.increment();
        assertEq(create2Counter.number(), 1);
        
    }

    // This is the current behaviour of CREATE2_FACTORY
    function test_create2factory() public {
        bytes32 salt = keccak256("salt");
        // this will use CREATE2_FACTORY
        address preComputedAddress = computeCreate2Address(salt, keccak256(abi.encodePacked(type(Counter).creationCode)));

        /*
        // this will use CREATE2, this is similar to the script version
        vm.prank(CREATE2_FACTORY);
        counter = new Counter{salt: salt}();
        */
        // this will use CREATE2  in a real situation (like script does under the hood)
        (bool success, bytes memory response) = CREATE2_FACTORY.call(abi.encodePacked(salt, type(Counter).creationCode));
        require(success, "should be successful");   
        
        // a bit messy but works
        (,,uint256 _counter) = abi.decode(abi.encode(response), (bytes32, uint256, uint256));
        assertEq(address(uint160(_counter>>96)), preComputedAddress, "should be the same address");

        Counter create2Counter = Counter(address(uint160(_counter>>96))) ;   
    
        //console2.logBytes(CREATE2_FACTORY.code);
        create2Counter.increment();
        assertEq(create2Counter.number(), 1);
    }



}
