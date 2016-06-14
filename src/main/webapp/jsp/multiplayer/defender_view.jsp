
<div class="row-fluid">
	<div class="col-md-6" id="cut-div">
		<h2>Class Under Test</h2>
		<pre class="readonly-pre"><textarea class="readonly-textarea" id="sut" name="cut" cols="80" rows="30">
			<%=mg.getCUT().getAsString()%>
		</textarea></pre>
	</div> <!-- col-md6 left -->
	<div class="col-md-6" id="utest-div">
		<h2> Write a new JUnit test here
			<button type="submit" class="btn btn-primary btn-game btn-right" form="def">Defend!</button>
		</h2>
		<form id="def" action="/multiplayer/move" method="post">
			<%
				String testCode;
				String previousTestCode = (String) request.getSession().getAttribute("previousTest");
				request.getSession().removeAttribute("previousTest");
				if (previousTestCode != null) {
					testCode = previousTestCode;
				} else
					testCode = mg.getCUT().getTestTemplate();
			%>
			<pre><textarea id="code" name="test" cols="80" rows="30"><%= testCode %></textarea></pre>
			<input type="hidden" name="formType" value="createTest">
			<input type="hidden" name="mpGameID" value="<%= mg.getId() %>" />
		</form>
	</div> <!-- col-md6 right top -->
</div> <!-- row-fluid 1 -->

<div class="row-fluid">
	<div class="col-md-6" id="submitted-div">
		<h2> JUnit tests </h2>
		<div class="slider single-item">
			<%
				for (Test t : mg.getExecutableTests()) {
					isTests = true;
					String tc = "";
					for (String l : t.getHTMLReadout()) { tc += l + "\n"; }
			%>
			<div><h4>Test <%= t.getId() %></h4><pre class="readonly-pre"><textarea class="utest" cols="20" rows="10"><%=tc%></textarea></pre></div>
			<%
				}
				if (!isTests) {%>
			<div><h2></h2><p> There are currently no tests </p></div>
			<%}
			%>
		</div> <!-- slider single-item -->
	</div> <!-- col-md-6 left bottom -->
	<div class="col-md-6" id="mutants-div">
		<h2>Mutants</h2>
		<!-- Nav tabs -->
		<ul class="nav nav-tabs" role="tablist">
			<li class="active">
				<a href="#mutalivetab" role="tab" data-toggle="tab">Alive</a>
			</li>
			<li>
				<a href="#mutkilledtab" role="tab" data-toggle="tab">Killed</a>
			</li>
		</ul>
		<div class="tab-content">
			<div class="tab-pane fade active in" id="mutalivetab">
				<table class="table table-hover table-responsive table-paragraphs">
					<%
					if (! mutantsAlive.isEmpty()) {
						for (MultiplayerMutant m : mutantsAlive) {
					%>
					<tr>
						<td>
							<h4>Mutant <%= m.getId() %></h4>
						</td>
						<td>
							<% if (mg.getLevel().equals(Game.Level.EASY)) { %>
							<a href="#" class="btn btn-default btn-diff" id="btnMut<%=m.getId()%>" data-toggle="modal" data-target="#modalMut<%=m.getId()%>">View Diff</a>
							<% } %>
							<div id="modalMut<%=m.getId()%>" class="modal fade" role="dialog">
								<div class="modal-dialog">
									<!-- Modal content-->
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal">&times;</button>
											<h4 class="modal-title">Mutant <%=m.getId()%> - Diff</h4>
										</div>
										<div class="modal-body">
											<pre class="readonly-pre"><textarea class="mutdiff" id="diff<%=m.getId()%>"><%=m.getPatchString()%></textarea></pre>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
						</td>
						<td >
							<form id="equiv" action="play" method="post">
								<input type="hidden" name="formType" value="claimEquivalent">
								<input type="hidden" name="mutantId" value="<%=m.getId()%>">
								<input type="hidden" name="mpGameID" value="<%= mg.getId() %>" />
								<button type="submit" class="btn btn-default btn-right">Claim Equivalent</button>
							</form>
						</td>
					</tr>
					<tr>
						<td colspan="3">
							<% for (String change :	m.getHTMLReadout()) { %>
							<p><%=change%><p>
								<% } %>
						</td>
					</tr>
					<%
						}
					} else {%>
					<tr class="blank_row">
						<td class="row-borderless" colspan="2">No mutants alive.</td>
					</tr>
					<%}
					%>
				</table>
			</div>
			<div class="tab-pane fade" id="mutkilledtab">
				<table class="table table-hover table-responsive table-paragraphs">
					<%
					if (! mutantsKilled.isEmpty()) {
						for (MultiplayerMutant m : mutantsKilled) {
					%>
					<tr>
						<td><h4>Mutant <%= m.getId() %></h4></td>
						<td>
							<a href="#" class="btn btn-default btn-diff" id="btnMut<%=m.getId()%>" data-toggle="modal" data-target="#modalMut<%=m.getId()%>">View Diff</a>
							<div id="modalMut<%=m.getId()%>" class="modal fade" role="dialog">
								<div class="modal-dialog">
									<!-- Modal content-->
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal">&times;</button>
											<h4 class="modal-title">Mutant <%=m.getId()%> - Diff</h4>
										</div>
										<div class="modal-body">
											<pre class="readonly-pre"><textarea class="mutdiff" id="diff<%=m.getId()%>"><%=m.getPatchString()%></textarea></pre>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<% for (String change : m.getHTMLReadout()) { %>
							<p><%=change%><p>
								<% } %>
						</td>
					</tr>
					<%
						}
					} else {%>
					<tr class="blank_row">
						<td class="row-borderless" colspan="2">No mutants killed.</td>
					</tr>
					<%}
					%>
				</table>
			</div>
		</div> <!-- tab-content -->
	</div> <!-- col-md-6 right bottom -->
</div>

<script>
	var editorTest = CodeMirror.fromTextArea(document.getElementById("code"), {
		lineNumbers: true,
		indentUnit: 4,
		indentWithTabs: true,
		matchBrackets: true,
		mode: "text/x-java"
	});
	editorTest.on('beforeChange',function(cm,change) {
		var text = cm.getValue();
		var lines = text.split(/\r|\r\n|\n/);
		var readOnlyLines = [0,1,2,3,4,5,6,7];
		var readOnlyLinesEnd = [lines.length-1,lines.length-2];
		if ( ~readOnlyLines.indexOf(change.from.line) || ~readOnlyLinesEnd.indexOf(change.to.line)) {
			change.cancel();
		}
	});
	editorTest.setSize("100%", 500);
	var editorSUT = CodeMirror.fromTextArea(document.getElementById("sut"), {
		lineNumbers: true,
		matchBrackets: true,
		mode: "text/x-java",
		readOnly: true
	});
	editorSUT.setSize("100%", 500);
	/* Submitted tests */
	var x = document.getElementsByClassName("utest");
	var i;
	for (i = 0; i < x.length; i++) {
		CodeMirror.fromTextArea(x[i], {
			lineNumbers: true,
			matchBrackets: true,
			mode: "text/x-java",
			readOnly: true
		});
	}
	/* Mutants diffs */
	$('.modal').on('shown.bs.modal', function() {
		var codeMirrorContainer = $(this).find(".CodeMirror")[0];
		if (codeMirrorContainer && codeMirrorContainer.CodeMirror) {
			codeMirrorContainer.CodeMirror.refresh();
		} else {
			var editorDiff = CodeMirror.fromTextArea($(this).find('textarea')[0], {
				lineNumbers: false,
				mode: "diff",
				readOnly: true /* onCursorActivity: null */
			});
			editorDiff.setSize("100%", 500);
		}
	});

	$('#finishedModal').modal('show');
</script>