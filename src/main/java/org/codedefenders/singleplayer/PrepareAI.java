package org.codedefenders.singleplayer;

import org.codedefenders.AntRunner;
import org.codedefenders.Game;
import org.codedefenders.Mutant;
import org.codedefenders.Test;

import java.util.ArrayList;

public class PrepareAI {

	public PrepareAI() {

	}

	public static void createTestsAndMutants(int classId) {
		Game dummyGame = new Game(classId, 1, 3, Game.Role.ATTACKER, Game.Level.EASY);
		dummyGame.insert();
		dummyGame.setDefenderId(1);
		dummyGame.setState(Game.State.ACTIVE);
		dummyGame.update();


		EvoSuiteMaker esMake = new EvoSuiteMaker(classId, dummyGame);
		esMake.makeSuite();

		MajorMaker mMake = new MajorMaker(classId, dummyGame);
		mMake.createMutants();

		ArrayList<Test> tests = dummyGame.getTests();
		ArrayList<Mutant> mutants = dummyGame.getMutants();

		for (Test t : tests) {
			for (Mutant m : mutants) {
				//Find if mutant killed by test.
				if(AntRunner.testKillsMutant(m, t)) {
					m.incrementTimesKilledAi();
					t.incrementAiMutantsKilled();
				}
			}
		}

		//Store kill counts to SQL.
		for (Test t : tests) {
			t.update();
		}
		for (Mutant m: mutants) {
			m.update();
		}

		//Create XML files.
		esMake.createTestIndex();
		mMake.createMutantIndex();

		//TODO: Find how many tests "kill" mutants.
		//Don't actually kill mutants to run all tests.
		//Perhaps rank mutants in how many tests kill them.
	}
}
