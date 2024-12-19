<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>

<c:set var="pageTitle" value="상세보기" />

<%@ include file="/WEB-INF/jsp/common/header.jsp" %>

<script>
	$(document).ready(function() {
		if (${rq.getLoginedMemberId() != -1 }) {
			getLoginId();
		}
		
		getLikePoint();
	})
	
	const getLoginId = function() {
		$.ajax({
			url : '/usr/member/getLoginId',
			type : 'GET',
			dataType : 'text',
			success : function(data) {
				$('#loginedMemberLoginId').html(data);
			},
			error : function(xhr, status, error) {
				console.log(error);
			}
		})
	}
	
	let originalForm = null;
	let originalId = null;
	
	const replyModifyForm = function(i, body) {
		
		if (originalForm != null) {
			replyModifyCancle(originalId);
		}
		
		let replyForm = $('#' + i);
		
		originalForm = replyForm.html();
		originalId = i;
		
		let addHtml = `
			<form action="/usr/reply/doModify" method="post" onsubmit="replyForm_onSubmit(this); return false;">
				<input type="hidden" name="id" value="\${i}" />
				<input type="hidden" name="relId" value="${article.getId() }" />
				<div class="border-2 border-slate-200 rounded-xl px-4 mt-2">
					<div id="loginedMemberLoginId" class="mt-3 mb-2 font-semibold"></div>
					<textarea style="resize:none;" class="textarea textarea-bordered textarea-md w-full" name="body">\${body }</textarea>
					<div class="flex justify-end mb-2">
						<button onclick="replyModifyCancle(\${i});" type="button" class="btn btn-active btn-sm mr-2">취소</button>
						<button class="btn btn-active btn-sm">수정</button>
					</div>
				</div>
			</form>`;
			
		replyForm.html(addHtml);
		getLoginId();
	}
	
	const replyModifyCancle = function(i) {
		let replyForm = $('#' + i);
		
		replyForm.html(originalForm);
		
		originalForm = null;
		originalId = null;
	}
	
	const clickLikePoint = async function() {
		
		let likePointBtn = $('#likePointBtn > i').hasClass('fa-solid');
		
		await $.ajax({
			url : '/usr/likePoint/clickLikePoint',
			type : 'GET',
			data : {
				relTypeCode : 'article',
				relId : ${article.getId() },
				likePointBtn : likePointBtn
			}
		})
		
		await getLikePoint();
	}
	
	const getLikePoint = function() {
		$.ajax({
			url : '/usr/likePoint/getLikePoint',
			type : 'GET',
			data : {
				relTypeCode : 'article',
				relId : ${article.getId() }
			},
			dataType : 'json',
			success : function(data) {
				$('#likeCnt').html(data.data);
				
				if (data.success) {
					$('#likePointBtn').html(`<i class="fa-solid fa-heart"></i>`);
				} else {
					$('#likePointBtn').html(`<i class="fa-regular fa-heart"></i>`);
				}
			},
			error : function(xhr, status, error) {
				console.log(error);
			}
		})
	}
</script>

<section class="mt-8">
	<div class="container mx-auto border-b-2 border-slate-200">
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
					<th>조회수</th>
					<td>${article.getViews() }</td>
				</tr>
				<tr>
					<th>추천수</th>
					<td>
						<c:if test="${rq.getLoginedMemberId() == -1 }">
							  <span id="likeCnt"></span>
						</c:if>
						<c:if test="${rq.getLoginedMemberId() != -1 }">
							<button class="btn btn-sm text-base" onclick="clickLikePoint();">
							  <span id="likeCnt"></span>
							  <span id="likePointBtn"></span>
							</button>
						</c:if>
					</td>
				</tr>
				<tr>
					<th>작성자</th>
					<td>${article.getLoginId() }</td>
				</tr>
				<tr>
					<th>제목</th>
					<td>${article.getTitle() }</td>
				</tr>
				<tr>
					<th>내용</th>
					<td>${article.getBody() }</td>
				</tr>
			</table>
		</div>
		
		<div class="w-9/12 mx-auto my-3 text-sm flex justify-between">
			<div>	
				<button class="btn btn-active btn-sm" onclick="history.back();">뒤로가기</button>
			</div>
			<c:if test="${rq.getLoginedMemberId() == article.getMemberId() }">
				<div>
					<a class="btn btn-active btn-sm" href="modify?id=${article.getId() }">수정</a>
					<a class="btn btn-active btn-sm" onclick="if(confirm('정말 삭제하시겠습니까?') == false) return false;" href="doDelete?id=${article.getId() }">삭제</a>
				</div>
			</c:if>
		</div>
	</div>
</section>

<script>
	const replyForm_onSubmit = function(form) {
		form.body.value = form.body.value.trim();
		
		if (form.body.value.length == 0) {
			alert('내용이 없는 댓글은 작성할 수 없습니다');
			form.body.focus();
			return;
		}
		
		form.submit();
	}
</script>

	<section class="my-5">
		<div class="container mx-auto px-4 text-base">
			<c:if test="${not empty replies }">
				<div>
					<div class="text-lg">댓글</div>
					<c:forEach var="reply" items="${replies }">
						<div id="${reply.getId() }" class="py-2 border-b-2 border-slate-200 pl-20">
							<div class="flex justify-between items-center">
								<div class="font-semibold">${reply.getLoginId() }</div>
							    <c:if test="${rq.getLoginedMemberId() == reply.memberId }">
							    	<div class="dropdown mr-2">
									  <div tabindex="0" role="button" class="btn btn-sm btn-circle btn-ghost m-1">
									  	<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block h-5 w-5 stroke-current">
									      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h.01M12 12h.01M19 12h.01M6 12a1 1 0 11-2 0 1 1 0 012 0zm7 0a1 1 0 11-2 0 1 1 0 012 0zm7 0a1 1 0 11-2 0 1 1 0 012 0z"></path>
									    </svg>
									  </div>
									  <ul tabindex="0" class="dropdown-content menu bg-base-100 rounded-box z-[1] w-24 p-2 shadow">
									    <li><button onclick="replyModifyForm(${reply.getId() }, '${reply.getBody() }');">수정</button></li>
									    <li><a onclick="if(confirm('정말 삭제하시겠습니까?') == false) return false;" href="/usr/reply/doDelete?id=${reply.getId() }&relId=${article.getId() }">삭제</a></li>
									  </ul>
									</div>
							    </c:if>
							</div>
							<div class="text-lg my-1 ml-2">${reply.getForPrintBody() }</div>
							<div class="text-xs text-gray-400">${reply.getRegDate() }</div>
						</div>
					</c:forEach>
				</div>
			</c:if>
			<div>
				<c:if test="${rq.getLoginedMemberId() != -1 }">
					<form action="/usr/reply/doWrite" method="post" onsubmit="replyForm_onSubmit(this); return false;">
						<input type="hidden" name="relTypeCode" value="article" />
						<input type="hidden" name="relId" value="${article.getId() }" />
						<div class="border-2 border-slate-200 rounded-xl px-4 mt-2">
							<div id="loginedMemberLoginId" class="mt-3 mb-2 font-semibold"></div>
							<textarea style="resize:none;" class="textarea textarea-bordered textarea-md w-full" name="body"></textarea>
							<div class="flex justify-end mb-2">
								<button class="btn btn-active btn-sm">작성</button>
							</div>
						</div>
					</form>
				</c:if>
			</div>
		</div>
	</section>
<%@ include file="/WEB-INF/jsp/common/footer.jsp" %>