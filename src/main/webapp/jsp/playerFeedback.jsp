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
<%@ page import="org.apache.commons.lang.ArrayUtils" %>
<%@ page import="org.codedefenders.database.AdminDAO" %>
<%@ page import="org.codedefenders.database.DatabaseAccess" %>
<%@ page import="org.codedefenders.database.FeedbackDAO" %>
<%@ page import="org.codedefenders.game.Role" %>
<%@ page import="org.codedefenders.model.User" %>
<%@ page import="org.codedefenders.servlets.FeedbackManager" %>
<%@ page import="org.codedefenders.servlets.admin.AdminSystemSettings" %>
<div id="playerFeedback" class="modal fade" role="dialog" style="z-index: 10000; position: absolute;">

    <style>
        fieldset, label {
            margin: 0;
            padding: 0;
        }

        /****** Style Star Rating Widget *****/
        .rating {
            border: none;
            float: left;
        }

        .rating > input {
            display: none;
        }

        .rating > label:before {
            font-size: 1.25em;
            display: inline-block;
            content: "\e006";
            font-family: 'Glyphicons Halflings';
            font-style: normal;
            font-weight: normal;
        }

        .rating > label {
            font-size: 20px;
            color: #ddd;
            float: right;
        }

        /***** CSS Magic to Highlight Stars on Hover *****/
        .rating > input:checked ~ label, /* show gold star when clicked */
        .rating:not(:checked) > label:hover, /* hover current star */
        .rating:not(:checked) > label:hover ~ label {
            color: #FFD700;
        }

        /* hover previous stars in list */
        .rating > input:checked + label:hover, /* hover current star when changing rating */
        .rating > input:checked ~ label:hover,
        .rating > label:hover ~ input:checked ~ label, /* lighten current selection */
        .rating > input:checked ~ label:hover ~ label {
            color: #FFED85;
        }
    </style>

    <div class="modal-dialog modal-lg">
        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h3 class="modal-title">Feedback for Game <%=gameId%>
                </h3>
            </div>

            <% boolean canSeePlayerFeedback = role.equals(Role.CREATOR) || AdminDAO.getSystemSetting(AdminSystemSettings.SETTING_NAME.SHOW_PLAYER_FEEDBACK).getBoolValue();
            boolean canGiveFeedback = role.equals(Role.DEFENDER) || role.equals(Role.ATTACKER);
                if (canGiveFeedback) {%>
            <ul class="nav nav-tabs">
                <li class="active" id="provideFeedbackLink">
                    <a onClick="switchModal()">
                        Give Feedback
                    </a>
                </li>
                <li id="viewFeedbackLink">
                    <a onClick="switchModal()">
                        View Feedback
                    </a>
                </li>
            </ul>

            <div class="modal-body" id="provide_feedback_modal">
                <h4><b>How much do you agree with the following statements:</b></h4>
                <br>

                <form id="sendFeedback" action="feedback" method="post">
                    <input type="hidden" name="formType" value="sendFeedback">
                    <table class="table-hover table-striped table-responsive ">
                        <tbody>

                        <%
                            Integer[] oldValues = FeedbackDAO.getFeedbackValues(gameId, uid);
                            for (FeedbackManager.FeedbackType f : FeedbackManager.FeedbackType.values()) {
                                int oldValue = oldValues == null ? -1 : oldValues[f.ordinal()];
                                if ((role.equals(Role.DEFENDER) &&
                                        (f.equals(FeedbackManager.FeedbackType.CUT_MUTATION_DIFFICULTY) ||
                                                f.equals(FeedbackManager.FeedbackType.DEFENDER_FAIRNESS)))
                                        ||
                                        (role.equals(Role.ATTACKER) &&
                                                (f.equals(FeedbackManager.FeedbackType.CUT_TEST_DIFFICULTY) ||
                                                        f.equals(FeedbackManager.FeedbackType.ATTACKER_FAIRNESS))))
                                    continue;
                        %>

                        <tr>
                            <td><%=f%>
                            </td>
                            <td>
                                <fieldset class="rating">
                                    <input type="radio" id="star5_<%=f.name()%>" name="rating<%=f.name()%>" value=5
                                        <%=oldValue == 5 ? "checked" : ""%>>
                                    <label class="full" for="star5_<%=f.name()%>" title="very much"></label>
                                    <input type="radio" id="star4_<%=f.name()%>" name="rating<%=f.name()%>" value=4
                                        <%=oldValue == 4 ? "checked" : ""%>>
                                    <label class="full" for="star4_<%=f.name()%>" title="a lot"></label>
                                    <input type="radio" id="star3_<%=f.name()%>" name="rating<%=f.name()%>" value=3
                                        <%=oldValue == 3 ? "checked" : ""%>>
                                    <label class="full" for="star3_<%=f.name()%>" title="somewhat"></label>
                                    <input type="radio" id="star2_<%=f.name()%>" name="rating<%=f.name()%>" value=2
                                        <%=oldValue == 2 ? "checked" : ""%>>
                                    <label class="full" for="star2_<%=f.name()%>" title="a bit"></label>
                                    <input type="radio" id="star1_<%=f.name()%>" name="rating<%=f.name()%>" value=1
                                        <%=oldValue == 1 ? "checked" : ""%>>
                                    <label class="full" for="star1_<%=f.name()%>" title="not at all"></label>
                                </fieldset>
                            </td>
                        </tr>
                        <%}%>
                        </tbody>

                    </table>

                    <br>
                    <p>In providing feedback you help us improve gameplay mechanics, <br>
                        hone match making and select classes that are engaging and fun.</p>
                    <p>You can change your feedback even after the game finishes.</p>
                    <p>Thank you for your time.</p>
                    <br>

                    <button class="btn btn-primary" type="submit"> Save Feedback</button>
                </form>
            </div>
            <%}%>

            <div class="modal-body" id="view_feedback_modal"
                 style="<%=canGiveFeedback ? "display: none;" : ""%>">

                <% if (FeedbackDAO.getNBFeedbacksForGame(gameId) > 0) {%>
                <div class="table-responsive">
                <table class="table-striped table-hover table-bordered table-responsive table-sm">
                    <thead>
                    <tr>
                        <th><%=canSeePlayerFeedback ? "Player" : ""%></th>
                        <% for (FeedbackManager.FeedbackType f : FeedbackManager.FeedbackType.values()) {%>
                        <th title="<%=f.toString()%>"><%=f.name().toUpperCase().replace('_', ' ').replace("CUT ", "")%>
                        </th>
                        <%}%>
                    </tr>
                    </thead>
                    <tbody>

                    <%
                        if (canSeePlayerFeedback) {
                            int[] attackerIDs = game.getAttackerIds();
                            for (int pid : game.getPlayerIds()) {
                                User userFromPlayer = DatabaseAccess.getUserFromPlayer(pid);
                                int userFromPlayerId = userFromPlayer.getId();
                                String userName = userFromPlayer.getUsername();

                                if (FeedbackDAO.hasNotRated(gameId, userFromPlayerId))
                                    continue;

                                String rowColor = ArrayUtils.contains(attackerIDs, pid) ? "#9a002914" : "#0029a01a";
                    %>
                    <tr style="background-color:<%=rowColor%>">
                        <td><%=userName%>
                        </td>
                        <%
                            Integer[] ratingValues = FeedbackDAO.getFeedbackValues(gameId, userFromPlayerId);
                            for (FeedbackManager.FeedbackType f : FeedbackManager.FeedbackType.values()) {
                                int ratingValue = ratingValues == null ? -1 : ratingValues[f.ordinal()];
                                if (ratingValue < 1) {
                        %>
                        <td></td>

                        <%} else {%>

                        <td>
                            <fieldset class="rating">
                                <%for (int i = FeedbackManager.MAX_RATING; i > 0; i--) {%>
                                <label class="full" title="<%=i%>"
                                       style="font-size:9px; color:<%=i <= ratingValue  ? "#FFD700" : "#bdbdbd"%>"></label>
                                <%}%>
                            </fieldset>
                        </td>

                        <%
                                }
                            }
                        %>
                    </tr>

                    <%
                            }
                        }
                    %>
                    <tr></tr>
                    <tr>
                        <td>Average</td>
                        <%
                            double[] avgRatings = FeedbackDAO.getAverageGameRatings(gameId);
                            for (FeedbackManager.FeedbackType f : FeedbackManager.FeedbackType.values()) {
                                double ratingValue = avgRatings == null ? -1 : avgRatings[f.ordinal()];
                                if (ratingValue < 1) {
                        %>
                        <td></td>

                        <%} else {%>

                        <td>
                            <p style="text-align: left;"><%=String.format("%.1f", ratingValue)%></p>
                            <fieldset class="rating">
                                <%for (int i = FeedbackManager.MAX_RATING; i > 0; i--) {%>
                                <label class="full" title="<%=i%>"
                                       style="font-size:9px; color:<%=i <= Math.round(ratingValue)  ? "#FFD700" : "#bdbdbd"%>"></label>
                                <%}%>
                            </fieldset>
                        </td>

                        <%
                                }
                            }
                        %>
                    </tr>
                    </tbody>

                </table>
                </div>
                <% } else {
                %>
                <h4>No player has provided feedback for this game yet.</h4>
                <%
                    }%>
            </div>
        </div>
    </div>
</div>

<script>
    function switchModal() {
        var provideFeedbackModalStyle = document.getElementById('provide_feedback_modal').style.display;
        document.getElementById('view_feedback_modal').style.display = provideFeedbackModalStyle;
        document.getElementById('provide_feedback_modal').style.display = provideFeedbackModalStyle == 'none' ? 'block' : 'none';
        document.getElementById('provideFeedbackLink').classList.toggle('active');
        document.getElementById('viewFeedbackLink').classList.toggle('active');
    }
</script>