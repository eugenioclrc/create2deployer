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

    function test_codesize() public {
        bytes memory newCreate2Bytecode = vm.compile("src/CREATE2DEPLOYER.huff");
        /// @notice deploy the bytecode with the create instruction
        address CREATE2HUFF = deployFromBytecode(newCreate2Bytecode);
        
        console2.log("Create2 default bytecode size", CREATE2_FACTORY.code.length);
        console2.log("Create2 HUFF bytecode size", CREATE2HUFF.code.length);  
    }



    function test_huffcreate2factory() public {
        bytes memory newCreate2Bytecode = vm.compile("src/CREATE2DEPLOYER.huff");
        /// @notice deploy the bytecode with the create instruction
        address CREATE2HUFF = deployFromBytecode(newCreate2Bytecode);
        bytes32 salt = keccak256("salt");
        // this will use CREATE2_FACTORY

        uint256 gasBefore = gasleft();
        (bool success, bytes memory response) = CREATE2HUFF.call(abi.encodePacked(salt, type(Counter).creationCode));
        uint256 gasAfter = gasleft();
        require(success, "should be successful");  

        console2.log("Create2 HUFF gas", gasBefore - gasAfter);
    }

    // This is the current behaviour of CREATE2_FACTORY
    function test_create2factory() public {
        bytes32 salt = keccak256("salt");
        // this will use CREATE2_FACTORY
        
        uint256 gasBefore = gasleft();
        (bool success, bytes memory response) = CREATE2_FACTORY.call(abi.encodePacked(salt, type(Counter).creationCode));
        uint256 gasAfter = gasleft();
        require(success, "should be successful");   
        
        console2.log("Create2 default gas", gasBefore - gasAfter);
    }
}
