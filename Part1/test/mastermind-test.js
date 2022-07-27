//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected
const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
const wasm_tester = require("circom_tester").wasm;
const { buildPoseidon } = require('circomlibjs');
const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);


describe("MastermindVariation", function (){
    this.timeout(100000000);

    before(async () => {
      poseidon = await buildPoseidon();
    });


    it("guess is true", async function() {
        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        const privSalt = 42

        const pubSolnHash = ethers.BigNumber.from(poseidon.F.toObject(poseidon([privSalt, 1, 2, 3, 4, 5])))

        const INPUT = {
            "pubGuessA": 1,
            "pubGuessB": 2,
            "pubGuessC": 3,
            "pubGuessD": 4,
            "pubGuessE": 5,
            "pubNumHit": 5,
            "pubNumBlow": 0,
            "privSalt": 42,
            "pubSolnHash": pubSolnHash,
            "privSolnA": 1,
            "privSolnB": 2,
            "privSolnC": 3,
            "privSolnD": 4,
            "privSolnE": 5,
        }

        const witness = await circuit.calculateWitness(INPUT, true);
        assert(Fr.eq(Fr.e(witness[0]),Fr.e(1)));
        assert(Fr.eq(Fr.e(witness[1]),Fr.e(INPUT.pubSolnHash)));
    })

    it("guess is 4/5 correct", async function() {
      const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
      const privSalt = 42

      const pubSolnHash = ethers.BigNumber.from(poseidon.F.toObject(poseidon([privSalt, 1, 2, 3, 4, 5])))

      const INPUT = {
          "pubGuessA": 0,
          "pubGuessB": 2,
          "pubGuessC": 3,
          "pubGuessD": 4,
          "pubGuessE": 5,
          "pubNumHit": 4,
          "pubNumBlow": 0,
          "privSalt": 42,
          "pubSolnHash": pubSolnHash,
          "privSolnA": 1,
          "privSolnB": 2,
          "privSolnC": 3,
          "privSolnD": 4,
          "privSolnE": 5,
      }

      const witness = await circuit.calculateWitness(INPUT, true);
      assert(Fr.eq(Fr.e(witness[0]),Fr.e(1)));
      assert(Fr.eq(Fr.e(witness[1]),Fr.e(INPUT.pubSolnHash)));
  })

  it("guess is fully false", async function() {
    const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
    const privSalt = 42

    const pubSolnHash = ethers.BigNumber.from(poseidon.F.toObject(poseidon([privSalt, 1, 2, 3, 4, 5])))

    const INPUT = {
        "pubGuessA": 0,
        "pubGuessB": 1,
        "pubGuessC": 4,
        "pubGuessD": 5,
        "pubGuessE": 3,
        "pubNumHit": 0,
        "pubNumBlow": 4,
        "privSalt": 42,
        "pubSolnHash": pubSolnHash,
        "privSolnA": 1,
        "privSolnB": 2,
        "privSolnC": 3,
        "privSolnD": 4,
        "privSolnE": 5,
    }

    const witness = await circuit.calculateWitness(INPUT, true);
    assert(Fr.eq(Fr.e(witness[0]),Fr.e(1)));
    assert(Fr.eq(Fr.e(witness[1]),Fr.e(INPUT.pubSolnHash)));
})
})
