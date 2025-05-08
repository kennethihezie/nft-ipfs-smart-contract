// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Script, console2} from "forge-std/Script.sol";
import { LW3Punks } from "../contracts/LW3Punks.sol";

contract LW3PunksScript is Script {
    string constant PRIVATE_KEY = "PRIVATE_KEY";

    function setUp() public {}

    function run() public {
       // Get the environment variable "PRIVATE_KEY"
       uint256 deployer = vm.envUint(PRIVATE_KEY);

       vm.startBroadcast(deployer);

       new LW3Punks("https://gateway.pinata.cloud/ipfs/","Qmbygo38DWF1V8GttM1zy89KzyZTPU2FLUzQtiDvB7q6i5", 0.01 ether, 10);

       vm.stopBroadcast();
    }
}
