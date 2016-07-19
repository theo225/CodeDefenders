<% String pageTitle="Upload Class"; %>
<%@ include file="/jsp/header.jsp" %>

<div id="divUpload" class="container">
	<form id="formUpload" action="upload" class="form-upload" method="post" enctype="multipart/form-data">
		<input id="classAlias" name="classAlias" type="text" class="form-control" placeholder="Optional class alias" >
		<input type="checkbox" name="prepareForSingle" value="prepare" style="margin-right:5px;">Generate mutants and tests for single-player mode? (It may take a while...)</input>
		<span id="file-select">
			<input id="fileUpload" name="fileUpload" type="file" class="file-loading" accept=".java" />
		</span>
		<span id="submit-button">
			<input type="submit" text="Upload" class="fileinput-upload-button" value="Upload" />
		</span>
	</form>
	</div>
<%@ include file="/jsp/footer.jsp" %>
