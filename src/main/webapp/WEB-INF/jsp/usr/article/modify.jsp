<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>

<c:set var="pageTitle" value="수정" />

<%@ include file="/WEB-INF/jsp/common/header.jsp" %>
<%@ include file="/WEB-INF/jsp/common/toastUiEditorLib.jsp" %>

<section class="mt-8">
	<div class="container mx-auto">
		<form action="doModify" method="post" onsubmit="submitForm(this); return false;">
			<input type="hidden" name="id" value="${article.getId() }"/>
			<div class="w-9/12 mx-auto">
				<table class="table table-lg">
					<tr>
						<th>번호</th>
						<td>${article.getId() }</td>
					</tr>
					<tr>
						<th>작성일</th>
						<td>${article.getRegDate().substring(2, 16) }</td>
					</tr>
					<tr>
						<th>수정일</th>
						<td>${article.getUpdateDate().substring(2, 16) }</td>
					</tr>
					<tr>
						<th>작성자</th>
						<td>${article.getLoginId() }</td>
					</tr>
					<tr>
						<th>제목</th>
						<td><input class="input input-bordered w-full max-w-xs" type="text" name="title" placeholder="제목을 입력해주세요" value="${article.getTitle() }"/></td>
					</tr>
					<tr>
						<th>내용</th>
						<td>
							<input type="hidden" name="body" />
							<div id="toast-ui-editor">
								<script>${article.getBody() }</script>
							</div>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<div class="flex justify-center">
								<button class="btn btn-active btn-wide">수정</button>
							</div>
						</td>
					</tr>
				</table>
			</div>
		</form>
		<div class="w-9/12 mx-auto mt-3 text-sm flex justify-between">
			<div>	
				<button class="btn btn-active btn-sm" onclick="history.back();">뒤로가기</button>
			</div>
		</div>
	</div>
</section>

<%@ include file="/WEB-INF/jsp/common/footer.jsp" %>