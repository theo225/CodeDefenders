<%@ page import="org.codedefenders.*" %>
<% String pageTitle="Game History"; %>
<%@ include file="/jsp/header.jsp" %>
<div>
<h3> Duels </h3>
<table class="table table-hover table-responsive table-paragraphs games-table">
	<tr>
		<th>Game ID</th>
		<th>Class</th>
		<th>Attacker</th>
		<th>Defender</th>
		<th>Level</th>
		<th></th>
	</tr>


	<%
		boolean isGames = false;
		String atkName;
		String defName;
		int uid = (Integer)request.getSession().getAttribute("uid");
		int atkId;
		int defId;
		for (Game g : DatabaseAccess.getHistoryForUser(uid)) {
			atkId = g.getAttackerId();
			defId = g.getDefenderId();
			User attacker = DatabaseAccess.getUserForKey("User_ID", atkId);
			User defender = DatabaseAccess.getUserForKey("User_ID", defId);
			atkName = attacker == null ? "-" : attacker.username;
			defName = defender == null ? "-" : defender.username;
	%>

	<tr>
		<td class="col-sm-2"><%= g.getId() %></td>
		<td class="col-sm-2"><%= g.getCUT().getAlias() %></td>
		<td class="col-sm-2"><%= atkName %></td>
		<td class="col-sm-2"><%= defName %></td>
		<td class="col-sm-2"><%= g.getLevel().name() %></td>
		<td class="col-sm-2">
			<form id="view" action="games" method="post">
				<input type="hidden" name="formType" value="enterGame">
				<input type="hidden" name="game" value=<%=g.getId()%>>
				<input type="submit" class="btn btn-default" value="View Scores">
			</form>
		</td>
	</tr>

	<%
		}
		if (!isGames) {%>
	<tr><td colspan="100%"> Empty duels history. </td></tr>
	<%}
	%>
</table>
	<hr />
	<h3>Battlegrounds</h3>
	<table class="table table-hover table-responsive table-paragraphs games-table">
		<tr>
			<th>Game ID</th>
			<th>Class</th>
			<th>Owner</th>
			<th>Prize</th>
			<th>Level</th>
			<th>Actions</th>
		</tr>
		<%
			ArrayList<MultiplayerGame> mgames = DatabaseAccess.getFinishedMultiplayerGamesForUser(uid);
			if (mgames.isEmpty()) {
		%>
		<tr><td colspan="100%"> Empty multi-player games history. </td></tr>
		<%
		} else {
		%>
		<%
			for (MultiplayerGame g : mgames) {
				Role role = g.getRole(uid);
		%>
		<tr>
			<td class="col-sm-2"><%= g.getId() %></td>
			<td class="col-sm-2"><%= g.getCUT().getAlias() %></td>
			<td class="col-sm-2"><%= DatabaseAccess.getUserForKey("User_ID", g.getCreatorId()).username %></td>
			<td class="col-sm-2"><%= g.getPrize() %></td>
			<td class="col-sm-2"><%= g.getLevel().name() %></td>
			<td class="col-sm-2"><%
				switch(role){
					case ATTACKER:
			%>
				<a href="multiplayer/games?id=<%= g.getId() %>">Attack</a>
				<%
						break;
					case CREATOR:
				%>
				<a href="multiplayer/games?id=<%= g.getId() %>">Observe</a>
				<%

						break;
					case DEFENDER:
				%>
				<a href="multiplayer/games?id=<%= g.getId() %>">Defend</a>
				<%

							break;
						default:

							break;
					}

				%></td>
		</tr>
		<%
				} // for (MultiplayerGame g : games)
			} // if (games.isEmpty())
		%>
	</table>

</div>
</div>

<%@ include file="/jsp/footer.jsp" %>
