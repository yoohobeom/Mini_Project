<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<!DOCTYPE html>

<html class= "max-h-full" data-theme="light">

<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${pageTitle }</title>
<!-- 테일윈드CSS -->
<script src="https://cdn.tailwindcss.com"></script>
<!-- 데이지 UI -->
<link href="https://cdn.jsdelivr.net/npm/daisyui@4.12.14/dist/full.min.css" rel="stylesheet" type="text/css" />
<!-- JQuery -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<!-- 폰트어썸 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
<!-- common css -->
<link rel="stylesheet" href="/resource/common.css" />
</head>
<title>Interactive Book Animation</title>
<style>
  body {
    margin: 0;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    background: linear-gradient(to bottom, #87ceeb, #ffffff);
    overflow: hidden;
  }

  .container {
    perspective: 1200px;
  }

  .book {
    position: relative;
    width: 200px;
    height: 300px;
    transform-style: preserve-3d;
    transform-origin: center;
    transition: transform 2s cubic-bezier(0.25, 1, 0.5, 1);
  }

  .book .cover {
    position: absolute;
    width: 100%;
    height: 100%;
    background: linear-gradient(to right, #8b4513, #cd853f);
    border-radius: 5px;
    transform-origin: left;
    transform: rotateY(0deg);
    backface-visibility: hidden;
    transition: transform 2s cubic-bezier(0.25, 1, 0.5, 1);
  }

  .book .page {
    position: absolute;
    width: 100%;
    height: 100%;
    background: white;
    border-radius: 5px;
    box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
    z-index: -1;
    transform: translateZ(-2px);
  }

  .book .inner {
    position: absolute;
    width: 100%;
    height: 100%;
    background: radial-gradient(circle, #f5f5f5, #eaeaea);
    display: flex;
    justify-content: center;
    align-items: center;
    font-family: 'Arial', sans-serif;
    font-size: 18px;
    color: #333;
    opacity: 0;
    transform: scale(0.8);
    transition: opacity 1s ease-in-out, transform 1.5s ease-in-out;
  }

  .zoom-in {
    transform: scale(1.5) translateZ(300px);
  }

  .cover-open {
    transform: rotateY(-160deg);
  }

  .content-visible {
    opacity: 1;
    transform: scale(1);
  }
</style>
</head>
<body>
<div class="container">
  <div class="book">
    <div class="cover"></div>
    <div class="page"></div>
    <div class="inner">Welcome to the Story!</div>
  </div>
</div>

<script>
  const book = document.querySelector('.book');
  const cover = document.querySelector('.cover');
  const inner = document.querySelector('.inner');
  const container = document.querySelector('.container');

  // 애니메이션 트리거
  book.addEventListener('click', () => {
    cover.classList.add('cover-open'); // 커버 열림
    inner.classList.add('content-visible'); // 텍스트 등장
    setTimeout(() => {
      container.classList.add('zoom-in'); // 책 안으로 들어가는 느낌
    }, 2000); // 커버 애니메이션 완료 후 줌 효과 시작
  });
</script>


<%@ include file="/WEB-INF/jsp/common/footer.jsp" %>