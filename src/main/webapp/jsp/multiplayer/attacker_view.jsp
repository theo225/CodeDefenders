<%--

    Copyright (C) 2016-2018 Code Defenders contributors

    This file is part of Code Defenders.

    Code Defenders is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or (at
    your option) any later version.

    Code Defenders is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Code Defenders. If not, see <http://www.gnu.org/licenses/>.

--%>
<%@ page import="org.codedefenders.util.Constants" %>

<% { %>

<%-- Set request attributes for the components. --%>
<%
    /* mutant_editor */
    String previousMutantCode = (String) request.getSession().getAttribute(Constants.SESSION_ATTRIBUTE_PREVIOUS_MUTANT);
    request.getSession().removeAttribute(Constants.SESSION_ATTRIBUTE_PREVIOUS_MUTANT);
    final GameClass cut = game.getCUT();
    if (previousMutantCode != null) {
        request.setAttribute("mutantCode", previousMutantCode);
    } else {
        request.setAttribute("mutantCode", cut.getAsHTMLEscapedString());
    }
    request.setAttribute("mutantName", cut.getBaseName());
    request.setAttribute("dependencies", cut.getHTMLEscapedDependencyCode());

    /* tests_carousel */
    request.setAttribute("tests", game.getTests());
    request.setAttribute("mutants", game.getMutants());

    /* mutants_list */
    request.setAttribute("mutantsAlive", game.getAliveMutants());
    request.setAttribute("mutantsKilled", game.getKilledMutants());
    request.setAttribute("mutantsEquivalent", game.getMutantsMarkedEquivalent());
    request.setAttribute("markEquivalent", false);
    request.setAttribute("markUncoveredEquivalent", false);
    request.setAttribute("viewDiff", true);
    request.setAttribute("gameType", "PARTY");

    /* game_highlighting */
    request.setAttribute("codeDivSelector", "#newmut-div");
    // request.setAttribute("tests", game.getTests());
    request.setAttribute("mutants", game.getMutants());
    request.setAttribute("showEquivalenceButton", false);
    // request.setAttribute("markUncoveredEquivalent", false);
    // request.setAttribute("gameType", "PARTY");

    /* mutant_explanation */
    request.setAttribute("mutantValidatorLevel", game.getMutantValidatorLevel());

    /* mutant_progressbar */
    request.setAttribute("gameId", game.getId());
%>

<!--<div class="row" style="padding: 0px 15px;"> TODO change to this after changing the header -->
<div class="row">
    <div class="col-md-6">
        <div id="mutants-div">
            <h3>Existing Mutants</h3>
            <%@include file="../game_components/mutants_list.jsp"%>
        </div>

        <% if (game.getLevel().equals(GameLevel.EASY) || game.getState().equals(GameState.FINISHED)) { %>
            <div id="tests-div">
                <h3>JUnit tests </h3>
                <%@include file="../game_components/tests_carousel.jsp"%>
            </div>
        <% } %>
    </div>

    <div class="col-md-6" id="newmut-div">
        <%@include file="../game_components/mutant_progress_bar.jsp"%>
        <h3 style="margin-bottom: 0;">Create a mutant here</h3>

        <form id="reset" action="<%=request.getContextPath() + "/" + game.getClass().getSimpleName().toLowerCase() %>" method="post">
            <input type="hidden" name="formType" value="reset">
            <button class="btn btn-primary btn-warning btn-game btn-right" id="btnReset" style="margin-top: -40px; margin-right: 80px">
                <%--TODO wtf why is this button suddently a little upper. literally 5px--%>
                Reset
            </button>
        </form>

        <form id="atk" action="<%=request.getContextPath() + "/" + game.getClass().getSimpleName().toLowerCase() %>" method="post">
            <% if (game.getState().equals(ACTIVE)) {%>
                <button type="submit" class="btn btn-primary btn-game btn-right" id="submitMutant" form="atk" onClick="progressBar(); this.form.submit(); this.disabled=true; this.value='Attacking...';" style="margin-top: -50px"
                        <% if (game.getState() != GameState.ACTIVE) { %> disabled <% } %>>
                    Attack!
                </button>
            <% } %>

            <input type="hidden" name="formType" value="createMutant">
            <input type="hidden" name="gameID" value="<%= game.getId() %>"/>

            <%@include file="../game_components/mutant_editor.jsp"%>
            <%@include file="../game_components/game_highlighting.jsp" %>
        </form>

        <%@include file="../game_components/mutant_explanation.jsp"%>
    </div>
</div>

<% } %>
