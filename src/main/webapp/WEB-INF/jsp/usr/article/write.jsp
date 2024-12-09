<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>

<c:set var="pageTitle" value="글쓰기" />

<%@ include file="/WEB-INF/jsp/common/header.jsp" %>
<%@ include file="/WEB-INF/jsp/common/toastUiEditorLib.jsp" %>

<section class="mt-8">
	<div class="container mx-auto">
		<form action="doWrite" method="post" onsubmit="submitForm(this); return false;">
			<div class="w-9/12 mx-auto">
				<table class="table table-lg">
					<tr>
						<th>게시판</th>
						<td>
							<div class="flex">
								<div>
									<label class="flex items-center">
										<input class="radio radio-sm" type="radio" name="boardId" value="1" />&nbsp;&nbsp;공지사항
									</label>
								</div>
								<div class="w-16"></div>
								<div>
									<label class="flex items-center">
										<input class="radio radio-sm" type="radio" name="boardId" value="2" checked />&nbsp;&nbsp;자유
									</label>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th>제목</th>
						<td><input class="input input-bordered w-full max-w-xs" type="text" name="title" placeholder="제목을 입력해주세요" /></td>
					</tr>
					<tr>
						<th>내용</th>
						<td>
							<input type="hidden" name="body" />
							<div id="toast-ui-editor"></div>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<div class="flex justify-center">
								<button class="btn btn-active btn-wide">작성</button>
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