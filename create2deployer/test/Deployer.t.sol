// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {Counter} from "../src/Counter.sol";
import {compile, Vm} from "./Deploy.sol";

contract DeployerTest is Test {
    using {compile} for Vm;

    Counter public counter;

    address HUFFCREATE2DEPLOYER;

    function setUp() public {
        bytes memory bytecode = vm.compile("src/CREATE2DEPLOYER.huff");
        address deployed;
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        HUFFCREATE2DEPLOYER = deployed;
    }
/*
    function test_deployOptimized() public {
        bytes memory bytecode = vm.compile("src/CREATE2DEPLOYER.huff");

        bytes32 salt = 0xf09be82ef1e4f3327289ae92ed07f1f546ba47b1c8550a3d05833dcc2d980b1b;

        vm.etch(0x4eEC6b914EeCCF25005b7985D29c42350B6Cbd23, HUFFCREATE2DEPLOYER.code);
        address CREATE2HUFF = 0x4eEC6b914EeCCF25005b7985D29c42350B6Cbd23;

        address expected = 0x0000000d7D0af2f330D3295B047c1c449D1BE51e;
        address preComputedAddress = computeCreate2Address(salt, keccak256(abi.encodePacked(bytecode)), CREATE2HUFF);

        assertEq(preComputedAddress, expected, "should be the same address");

        (bool success, bytes memory response) = CREATE2HUFF.call(abi.encodePacked(salt, bytecode));
        require(success, "should be successful");
        (,, uint256 _optimized) = abi.decode(abi.encode(response), (bytes32, uint256, uint256));
        assertEq(address(uint160(_optimized >> 96)), expected, "should be the expected address");

        // lets try the new optmized deployer:
        (success, response) = expected.call(abi.encodePacked(salt, type(Counter).creationCode));
        require(success, "should be successful");
        // a bit messy but works
        (,, uint256 _counter) = abi.decode(abi.encode(response), (bytes32, uint256, uint256));

        Counter create2Counter = Counter(address(uint160(_counter >> 96)));

        create2Counter.increment();
        assertEq(create2Counter.number(), 1);

    }
    */


    function test_huffcreate2factory() public {
        /// @notice deploy the bytecode with the create instruction
        bytes32 salt = keccak256("salt");
        // this will use CREATE2_FACTORY
        address preComputedAddress =
            computeCreate2Address(salt, keccak256(abi.encodePacked(type(Counter).creationCode)), HUFFCREATE2DEPLOYER);
        (bool success, bytes memory response) =
            HUFFCREATE2DEPLOYER.call{gas: 100000}(abi.encodePacked(salt, type(Counter).creationCode));
        require(success, "should be successful");
        // a bit messy but works
        (,, uint256 _counter) = abi.decode(abi.encode(response), (bytes32, uint256, uint256));
        assertEq(address(uint160(_counter >> 96)), preComputedAddress, "should be the same address");

        Counter create2Counter = Counter(address(uint160(_counter >> 96)));

        create2Counter.increment();
        assertEq(create2Counter.number(), 1);

        // this will revert and consume a lot of gas beacause of the .call, so we use a gasLimit
        ( success,) =
            HUFFCREATE2DEPLOYER.call{gas: 100000}(abi.encodePacked(salt, type(Counter).creationCode));
        assertFalse(success, "should revert, redeploy with same salt");
       
    }

    // This is the current behaviour of CREATE2_FACTORY
    function test_create2factory() public {
        bytes32 salt = keccak256("salt");
        // this will use CREATE2_FACTORY
        address preComputedAddress =
            computeCreate2Address(salt, keccak256(abi.encodePacked(type(Counter).creationCode)));

        /*
        // this will use CREATE2, this is similar to the script version
        vm.prank(CREATE2_FACTORY);
        counter = new Counter{salt: salt}();
        */
        // this will use CREATE2  in a real situation (like script does under the hood)
        (bool success, bytes memory response) = CREATE2_FACTORY.call(abi.encodePacked(salt, type(Counter).creationCode));
        require(success, "should be successful");

        // a bit messy but works
        (,, uint256 _counter) = abi.decode(abi.encode(response), (bytes32, uint256, uint256));
        assertEq(address(uint160(_counter >> 96)), preComputedAddress, "should be the same address");

        Counter create2Counter = Counter(address(uint160(_counter >> 96)));

        //console2.logBytes(CREATE2_FACTORY.code);
        create2Counter.increment();
        assertEq(create2Counter.number(), 1);
    }
}
