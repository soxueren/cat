<%@ page session="false" language="java" pageEncoding="UTF-8" %>
<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib prefix="a" uri="/WEB-INF/app.tld"%>
<%@ taglib prefix="w" uri="http://www.unidal.org/web/core"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="res" uri="http://www.unidal.org/webres"%>
<jsp:useBean id="ctx"	type="com.dianping.cat.report.page.storage.Context" scope="request" />
<jsp:useBean id="payload"	type="com.dianping.cat.report.page.storage.Payload" scope="request" />
<jsp:useBean id="model"	type="com.dianping.cat.report.page.storage.Model" scope="request" />
<c:set var="report" value="${model.report}" />

<a:storage_report title="Storage Report"
	navUrlPrefix="op=${payload.action.name}&domain=${model.domain}&id=${payload.id}&ip=${model.ipAddress}&operations=${payload.operations}"
	timestamp="${w:format(model.creatTime,'yyyy-MM-dd HH:mm:ss')}">

	<jsp:attribute name="subtitle">${w:format(report.startTime,'yyyy-MM-dd HH:mm:ss')} to ${w:format(report.endTime,'yyyy-MM-dd HH:mm:ss')}</jsp:attribute>

	<jsp:body>
	<res:useJs value="${res.js.local['baseGraph.js']}" target="head-js"/>
<table class="machines">
	<tr style="text-align:left"> 
		<th>&nbsp;[&nbsp; <c:choose>
				<c:when test="${model.ipAddress eq 'All'}">
					<a href="?op=${payload.action.name}&domain=${model.domain}&id=${payload.id}&date=${model.date}&operations=${payload.operations}"
						class="current">All</a>
				</c:when>
				<c:otherwise>
					<a href="?op=${payload.action.name}&domain=${model.domain}&id=${payload.id}&date=${model.date}&operations=${payload.operations}">All</a>
				</c:otherwise>
			</c:choose> &nbsp;]&nbsp; <c:forEach var="ip" items="${model.ips}">
   	  		&nbsp;[&nbsp;
   	  		<c:choose>
					<c:when test="${model.ipAddress eq ip}">
						<a href="?op=${payload.action.name}&domain=${model.domain}&id=${payload.id}&ip=${ip}&date=${model.date}&operations=${payload.operations}"
							class="current">${ip}</a>
					</c:when>
					<c:otherwise>
						<a href="?op=${payload.action.name}&domain=${model.domain}&id=${payload.id}&ip=${ip}&date=${model.date}&operations=${payload.operations}">${ip}</a>
					</c:otherwise>
				</c:choose>
   	 		&nbsp;]&nbsp;
			 </c:forEach>
		</th></tr>
</table>
<table>
	<tr>
	<td>
		<div>
		<label class="btn btn-info btn-sm">
 			<input type="checkbox" id="operation_All" onclick="clickAll()" unchecked>All</label><c:forEach var="item" items="${model.allOperations}"><label class="btn btn-info btn-sm"><input type="checkbox" id="operation_${item}" value="${item}" onclick="clickMe()" unchecked>${item}</label></c:forEach>
 		</div>
	</td>
	<td><input class="btn btn-primary btn-sm "
					value="&nbsp;&nbsp;&nbsp;查询&nbsp;&nbsp;&nbsp;" onclick="query()"
					type="submit" /></td>
	</tr>
</table>
<table class="table table-hover table-striped table-condensed table-bordered"  style="width:100%">

	<tr>
		<th colspan="2" rowspan="2" class="center" style="vertical-align:middle"><a href="?op=${payload.action.name}&domain=${model.domain}&id=${payload.id}&ip=${ip}&date=${model.date}&operations=${payload.operations}&sort=domain">Domain</th>
		<c:forEach var="item" items="${model.operations}">
			<th class="center" colspan="4">${item}</th>
		</c:forEach>
	</tr>
	<tr>
		<c:forEach var="item" items="${model.operations}">
			<th class="right"><a href="?op=${payload.action.name}&domain=${model.domain}&id=${payload.id}&ip=${model.ipAddress}&date=${model.date}&operations=${payload.operations}&sort=${item};count">Count</a></th>
			<th class="right"><a href="?op=${payload.action.name}&domain=${model.domain}&id=${payload.id}&ip=${model.ipAddress}&date=${model.date}&operations=${payload.operations}&sort=${item};long">Long</a></th>
			<th class="right"><a href="?op=${payload.action.name}&domain=${model.domain}&id=${payload.id}&ip=${model.ipAddress}&date=${model.date}&operations=${payload.operations}&sort=${item};avg">Avg</a></th>
			<th class="right"><a href="?op=${payload.action.name}&domain=${model.domain}&id=${payload.id}&ip=${model.ipAddress}&date=${model.date}&operations=${payload.operations}&sort=${item};error">Error</a></th>
		</c:forEach>
	</tr>
	<c:choose>
		<c:when test="${payload.action.name eq 'database' }">
			<c:set var="action" value="hourlyDatabaseGraph" />
		</c:when>
	<c:otherwise>
		<c:set var="action" value="hourlyCacheGraph" />
	</c:otherwise>
	</c:choose>
	<c:forEach var="domain" items="${model.machine.domains}"
		varStatus="index">
		<tr>
		<td><a href="?op=${action}&domain=${model.domain}&date=${model.date}&id=${payload.id}&ip=${model.ipAddress}&project=${domain.key}${model.customDate}&operations=${payload.operations}" class="storage_graph_link" data-status="${domain.key}">[:: show ::]</a>
		</td>
		<td class="left">${domain.key}</td>
		<c:forEach var="item" items="${model.operations}">
			<td class="right">${w:format(domain.value.operations[item].count,'#,###,###,###,##0')}</td>
			<td class="right">${w:format(domain.value.operations[item].longCount,'#,###,###,###,##0')}</td>
			<td class="right">${w:format(domain.value.operations[item].avg,'###,##0.0')}</td>
			<td class="right">${w:format(domain.value.operations[item].error,'#,###,###,###,##0')}</td>
		</c:forEach>
		</tr>
		<tr class="graphs"><td colspan="${w:size(model.operations)*4 + 2}" style="display:none"><div id="${domain.key}" style="display:none"></div></td></tr>
		<tr style="display:none"></tr>
	</c:forEach>
</table>
<res:useJs value="${res.js.local.storage_js}" target="buttom-js" />
</jsp:body>
</a:storage_report>

<script type="text/javascript">
	var fs = "${model.allOperations}";
	fs = fs.replace(/[\[\]]/g,'').split(', ');

	function clickMe() {
		var num = 0;
		for( var i=0; i<fs.length; i++){
		 	var f = "operation_" + fs[i];
			if(document.getElementById(f).checked){
				num ++;
			}else{
				document.getElementById("operation_All").checked = false;
				break;
			} 
		}
		if(num > 0 && num == fs.length) {
			document.getElementById("operation_All").checked = true;
		}
	}
	
	function clickAll(fields) {
		for( var i=0; i<fs.length; i++){
		 	var f = "operation_" + fs[i];
		 	if(document.getElementById(f) != undefined) {
				document.getElementById(f).checked = document.getElementById("operation_All").checked;
		 	}
		}
	}
	
	function query() {
		var url = "";
		if(document.getElementById("operation_All").checked == false && fs.length > 0) {
			for( var i=0; i<fs.length; i++){
			 	var f = "operation_" + fs[i];
				if(document.getElementById(f) != undefined 
						&& document.getElementById(f).checked){
					url += fs[i] + ";";
				} 
			}
			url = url.substring(0, url.length-1);
		}else{
			url = "";
		}
		window.location.href = "?op=${payload.action.name}&domain=${model.domain}&id=${payload.id}&ip=${payload.ipAddress}&step=${payload.step}&date=${model.date}&operations=" + url;
	}
	
	function init(){
		var fields = '${model.operations}';
		var ffs = [];
		if(fields != "[]") {
			ffs = fields.replace(/[\[\]]/g,'').split(', ');
		}
		
		var num = 0;
		for( var i=0; i<ffs.length; i++){
		 	var f = "operation_" + ffs[i];
		 	if(document.getElementById(f) != undefined) { 
				document.getElementById(f).checked = true;
			}
		}
		if(ffs.length == fs.length || ffs.length == 0){
			document.getElementById("operation_All").checked = true;
		}
	}
	
	$(document).ready(function() {
		if('${payload.action.name}' == 'database'){
			$('#Database_report').addClass('active open');
			$('#database_operation').addClass('active');
		}else{
			$('#Cache_report').addClass('active open');
			$('#cache_operation').addClass('active');
		}
		init();
	});
</script>