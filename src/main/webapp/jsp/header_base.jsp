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
<!DOCTYPE html>
<html>

<head>
    <title>Code Defenders<%= pageTitle != null ? " - " + pageTitle : "" %></title>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

    <!-- App context -->
    <base href="${pageContext.request.contextPath}/">

    <!-- jQuery -->
    <script src="js/jquery.js" type="text/javascript" ></script>

    <!-- Slick -->
    <link href="css/slick_1.5.9.css" rel="stylesheet" type="text/css" />
    <script src="js/slick_1.5.9.min.js" type="text/javascript" ></script>

	<!-- Favicon.ico -->
	<link rel="icon" href="favicon.ico" type="image/x-icon">

    <!-- File Input -->
    <!--
    <script src="js/fileinput.min.js" type="text/javascript"></script>
    -->
    <!--
    <link href="css/fileinput.min.css" rel="stylesheet" type="text/css" />
    -->

    <!-- Bootstrap -->
    <script src="js/bootstrap.min.js" type="text/javascript" ></script>
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />

    <!-- JQuery UI -->
    <script src="js/jquery-ui.min.js" type="text/javascript" ></script>
    <link href="css/jquery-ui.min.css" rel="stylesheet" type="text/css" />

    <link href="css/bootstrap-toggle_2.2.0.min.css" rel="stylesheet" type="text/css" />
    <script src="js/bootstrap-toggle_2.2.0.min.js" type="text/javascript" ></script>
    <!-- select -->
    <link href="css/bootstrap-select_1.9.3.min.css" rel="stylesheet" type="text/css" />
    <script src="js/bootstrap-select_1.9.3.min.js" type="text/javascript" ></script>


    <!-- Leaf -->
    <link href="css/base.css" rel="stylesheet">
    <script type="text/javascript" src="js/script.js"></script>

    <!-- Codemirror -->
    <script src="codemirror/lib/codemirror.js" type="text/javascript" ></script>
    <script src="codemirror/mode/clike/clike.js" type="text/javascript" ></script>
    <script src="codemirror/mode/diff/diff.js" type="text/javascript" ></script>
    <script src="codemirror/addon/dialog/dialog.js" type="text/javascript" ></script>
    <script src="codemirror/addon/search/searchcursor.js" type="text/javascript" ></script>
    <script src="codemirror/addon/search/search.js" type="text/javascript" ></script>
    <script src="codemirror/addon/scroll/annotatescrollbar.js" type="text/javascript" ></script>
    <script src="codemirror/addon/search/matchesonscrollbar.js" type="text/javascript" ></script>
    <script src="codemirror/addon/search/jump-to-line.js" type="text/javascript" ></script>
    <script src="codemirror/addon/selection/active-line.js" type="text/javascript" ></script>
    <script src="codemirror/addon/edit/matchbrackets.js" type="text/javascript" ></script>
    <script src="codemirror/addon/edit/closebrackets.js" type="text/javascript" ></script>
    <script src="codemirror/addon/hint/show-hint.js" type="text/javascript" ></script>
    <script src="codemirror/addon/hint/anyword-hint.js" type="text/javascript" ></script>

    <link href="codemirror/lib/codemirror.css" rel="stylesheet" type="text/css" />
    <!-- <link href="codemirror/lib/codemirror.css" rel="stylesheet" type="text/css" > -->
    <link href="codemirror/addon/dialog/dialog.css" rel="stylesheet" type="text/css" >
    <link href="codemirror/addon/search/matchesonscrollbar.css" rel="stylesheet" type="text/css" >
    <link href="codemirror/addon/hint/show-hint.css" rel="stylesheet" type="text/css" >

    <!-- Table sorter -->
    <script type="text/javascript" src="js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" src="js/moment.min.js"></script> <!-- must come before datetime-moment -->
    <script type="text/javascript" src="js/datetime-moment.js"></script> <!-- must come after moment -->
    <link href="css/jquery.dataTables.min.css" rel="stylesheet" type="text/css" />
    <link href="css/datatables-override.css" rel="stylesheet" type="text/css" />


    <!-- MultiplayerGame -->
    <link href="css/gamestyle.css" rel="stylesheet" type="text/css" />
    <link href="css/notification-style.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="js/messaging.js"></script>

    <!-- Upload page -->
    <link href="css/uploadcut.css" rel="stylesheet" type="text/css" />

    <link href="css/game_highlighting.css" rel="stylesheet" type="text/css" />

    <script>
        $(document).ready(function() {
            $('.single-item').slick({
                arrows: true,
                infinite: true,
                speed: 300,
                draggable: false
            });
        });
    </script>

    <script>
        $(document).ready(function() {
            try {
                $('table.mutant-table').DataTable( {
                    "pagingType": "full_numbers",
                    "searching": true,
                    "lengthChange": false,
                    "ordering": false,
                    "pageLength": 4,
                    language: {
                        search: "_INPUT_",
                        searchPlaceholder: "Search...",
                        info: "",
                        sInfoEmpty: "",
                        sInfoFiltered: ""
                    }
                } );
            } catch (e) {
                // statements to handle TypeError exceptions
            }
        } );
    </script>

</head>

<body class="page-grid">
<%@ page import="java.util.*" %>
<%@ page import="org.codedefenders.game.Test" %>
<%@ page import="org.codedefenders.model.User" %>
<%@ page import="org.codedefenders.game.Mutant" %>
<%@ page import="org.codedefenders.game.duel.DuelGame" %>
<%@ page import="org.codedefenders.util.Constants" %>
<%@ page import="org.codedefenders.database.DatabaseAccess" %>
<%@ page import="org.codedefenders.game.Role" %>
<%@ page import="static org.codedefenders.game.GameState.ACTIVE" %>
<%@ page import="org.codedefenders.game.GameClass" %>
<%@ page import="org.codedefenders.game.multiplayer.MultiplayerGame" %>
<%@ page import="java.util.ArrayList" %>
<div class="menu-top bg-grey bg-plus-4 text-white" style="padding-bottom:0px;">
    <div class="full-width">
        <div class="nest">
            <div class="crow fly nogutter">
                <div>
                    <div>
                        <div class="tabs-blue-grey">
                            <a href="${pageContext.request.contextPath}/" class="main-title" id="site-logo">
                                <div class="crow">
                                    <div id="home" class="ws-12" style="font-size: 36px; text-align: center;">
                                        <span><img class="logo" href="${pageContext.request.contextPath}/" src="images/logo.png"/></span>
                                        Code Defenders
                                    </div>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="bg-plus-3" style="padding:2px 0; margin-bottom: 0px; margin-top: 5px;"></div>
    </div>
</div>
<div  style="background-color: #fafafa; min-height: 90%; padding-bottom: 20px;"/>
