pragma circom 2.0.0;

// [assignment] implement a variation of mastermind from https://en.wikipedia.org/wiki/Mastermind_(board_game)#Variation as a circuit
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";

// SUPER MASTERMIND 8 COLORS(NUMBER) and 5 HOLES AKA ADVANCE MASTERMIND
// 0: White 1: Red 2: Black 3: Yellow 4: Blue 5: Green 6: Brown 7: Orange
template MastermindVariation() {
    signal input pubGuessA;
    signal input pubGuessB;
    signal input pubGuessC;
    signal input pubGuessD;
    signal input pubGuessE;
    signal input pubNumHit;
    signal input pubNumBlow;
    signal input pubSolnHash;

    // Private inputs
    signal input privSolnA;
    signal input privSolnB;
    signal input privSolnC;
    signal input privSolnD;
    signal input privSolnE;

    signal input privSalt;

    signal output solnHashOut;

    var guess[5] = [pubGuessA, pubGuessB, pubGuessC, pubGuessD, pubGuessE];
    var soln[5] =  [privSolnA, privSolnB, privSolnC, privSolnD, privSolnE];

    var i = 0;
    var j = 0;
    component lessThan[10];
    component equalGuess[10];
    component equalSoln[10];
    var equalIdx = 0;

    for (i = 0; i < 5; i++) {
        lessThan[i] = LessThan(3);
        lessThan[i].in[0] <== guess[i];
        lessThan[i].in[1] <== 8;
        lessThan[i].out === 1;
        lessThan[i+5] = LessThan(3);
        lessThan[i+5].in[0] <== soln[i];
        lessThan[i+5].in[1] <== 8;
        lessThan[i+5].out === 1;

        for (j = i + 1; j < 5; j++) {
            equalGuess[equalIdx] = IsEqual();
            equalGuess[equalIdx].in[0] <== guess[i];
            equalGuess[equalIdx].in[1] <== guess[j];
            equalGuess[equalIdx].out === 0;
            equalSoln[equalIdx] = IsEqual();
            equalSoln[equalIdx].in[0] <== soln[i];
            equalSoln[equalIdx].in[1] <== soln[j];
            equalSoln[equalIdx].out === 0;
            equalIdx += 1;
        }
    }

    var hit = 0;
    var blow = 0;
    component equalHB[25];

    for (i = 0; i < 5; i++) {
        for (j = 0; j < 5; j++) {
            equalHB[5*i + j] = IsEqual();
            equalHB[5*i + j].in[0] <== soln[i];
            equalHB[5*i + j].in[1] <== guess[j];

            blow += equalHB[5*i + j].out;
            
            if (i == j) {
                hit += equalHB[5*i + j].out;
                blow -= equalHB[5*i + j].out;
            }
        }
    }

    component equalHit = IsEqual();
    equalHit.in[0] <== pubNumHit;
    equalHit.in[1] <== hit;
    equalHit.out === 1;

    component equalBlow = IsEqual();
    equalBlow.in[0] <== pubNumBlow;
    equalBlow.in[1] <== blow;
    equalBlow.out === 1;

    component poseidon = Poseidon(6);
    poseidon.inputs[0] <== privSalt;
    poseidon.inputs[1] <== privSolnA;
    poseidon.inputs[2] <== privSolnB;
    poseidon.inputs[3] <== privSolnC;
    poseidon.inputs[4] <== privSolnD;
    poseidon.inputs[5] <== privSolnE;

    solnHashOut <== poseidon.out;
    pubSolnHash === solnHashOut;

}

component main {public [pubGuessA, pubGuessB, pubGuessC, pubGuessD, pubGuessE, pubNumHit, pubNumBlow, pubSolnHash]} = MastermindVariation();