package org.codedefenders;

import org.codedefenders.singleplayer.PrepareAI;
import org.codedefenders.singleplayer.SinglePlayerGame;
import org.codedefenders.singleplayer.automated.attacker.AiAttacker;
import org.codedefenders.singleplayer.automated.defender.AiDefender;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;

public class GameSelectionManager extends HttpServlet {

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

		response.sendRedirect("games/user");
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

		HttpSession session = request.getSession();
		// Get their user id from the session.
		int uid = (Integer) session.getAttribute("uid");
		int gameId;

		ArrayList<String> messages = new ArrayList<String>();
		session.setAttribute("messages", messages);

		switch (request.getParameter("formType")) {

			case "createGame":

				// Get the identifying information required to create a game from the submitted form.

				int classId = 0;
				try {
					classId = Integer.parseInt(request.getParameter("class"));
				} catch (NumberFormatException e) {
					response.sendRedirect("games/create");
					//TODO: Make an error message appear.
				}

				int rounds = Integer.parseInt(request.getParameter("rounds"));
				String modeName = request.getParameter("mode");
				Role role = request.getParameter("role") == null ? Role.DEFENDER : Role.ATTACKER;
				Game.Level level = request.getParameter("level") == null ? Game.Level.HARD : Game.Level.EASY;
				Game.Mode mode = null;

				switch (modeName) {
					case "sing": mode = Game.Mode.SINGLE; break;
					case "duel": mode = Game.Mode.DUEL; break;
					case "prty": mode = Game.Mode.PARTY; break;
					case "utst": mode = Game.Mode.UTESTING; break;
					default: mode = Game.Mode.SINGLE;
				}

				if (classId != 0) {
					//Valid class selected.

					if(mode.equals(Game.Mode.SINGLE)) {
						//Create singleplayer game.

						//Need to check if a dummy game has been created - ie if the generated files exist.
						//If this is not the case, run prepareAI on the class.
						if(!DatabaseAccess.gameWithUserExistsForClass(1, classId)) {
							PrepareAI.createTestsAndMutants(classId);
						}

						SinglePlayerGame nGame = new SinglePlayerGame(classId, uid, rounds, role, level);
						nGame.insert();
						if (role.equals(Role.ATTACKER)) {
							nGame.addPlayer(uid, Role.ATTACKER);
							nGame.addPlayer(AiDefender.ID, Role.DEFENDER);
						} else {
							nGame.addPlayer(uid, Role.DEFENDER);
							nGame.addPlayer(AiAttacker.ID, Role.ATTACKER);
						}
						nGame.tryFirstTurn();
					} else {
						// Create the game with supplied parameters and insert it in the database.
						Game nGame = new Game(classId, uid, rounds, role, level);
						nGame.insert();
						if (nGame.getAttackerId() != 0)
							nGame.addPlayer(uid, Role.ATTACKER);
						else
							nGame.addPlayer(uid, Role.DEFENDER);
					}


					// Redirect to the game selection menu.
					response.sendRedirect("games");
				}

				break;

			case "joinGame":

				// Get the identifying information required to create a game from the submitted form.
				gameId = Integer.parseInt(request.getParameter("game"));

				Game jGame = DatabaseAccess.getGameForKey("ID", gameId);

				if ((jGame.getAttackerId() == uid) || (jGame.getDefenderId() == uid)) {
					// uid is already in the game
					if (jGame.getDefenderId() == uid)
						messages.add("Already a defender in this game!");
					else
						messages.add("Already an attacker in this game!");
					// either way, reload list of open games
					response.sendRedirect(request.getHeader("referer"));
					break;
				} else {
					if (jGame.getAttackerId() == 0) {
						jGame.addPlayer(uid, Role.ATTACKER);
						messages.add("Joined game as an attacker.");
					} else if (jGame.getDefenderId() == 0) {
						messages.add("Joined game as a defender.");
						jGame.addPlayer(uid, Role.DEFENDER);
					} else {
						messages.add("Game is no longer open.");
						response.sendRedirect(request.getHeader("referer"));
						break;
					}
					// user joined, update game
					jGame.setState(Game.State.ACTIVE);
					jGame.setActiveRole(Role.ATTACKER);
					jGame.update();
					// go to play view
					session.setAttribute("gid", gameId);
					response.sendRedirect("play");
					break;
				}

			case "enterGame":

				gameId = Integer.parseInt(request.getParameter("game"));
				Game eGame = DatabaseAccess.getGameForKey("ID", gameId);

				if (eGame.isUserInGame(uid)) {
					session.setAttribute("gid", gameId);
					if (eGame.getMode().equals(Game.Mode.UTESTING))
						response.sendRedirect("utesting");
					else
						response.sendRedirect("play");
				} else {
					response.sendRedirect(request.getHeader("referer"));
				}
				break;
			default:
				System.err.println("Action not recognised");
				response.sendRedirect(request.getHeader("referer"));
				break;
		}
	}
}