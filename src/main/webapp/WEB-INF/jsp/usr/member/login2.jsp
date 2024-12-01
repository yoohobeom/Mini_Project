<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 레이아웃</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdn.jsdelivr.net/npm/daisyui@latest/dist/full.css" rel="stylesheet">
</head>
<body class="flex items-center justify-center h-screen bg-gray-100">
    <div class="p-6 bg-white rounded-lg shadow-lg w-96">
        <h2 class="text-2xl font-bold text-center mb-6">로그인</h2>
        <form class="space-y-4">
            <div class="form-control">
                <label class="label">
                    <span class="label-text">아이디</span>
                </label>
                <input type="text" placeholder="아이디를 입력하세요" class="input input-bordered w-full">
            </div>
            <div class="form-control">
                <label class="label">
                    <span class="label-text">비밀번호</span>
                </label>
                <input type="password" placeholder="비밀번호를 입력하세요" class="input input-bordered w-full">
            </div>
            <button class="btn btn-success w-full">로그인</button>
        </form>
        <div class="divider">또는</div>
        <button class="btn btn-error w-full">로그아웃</button>
    </div>
</body>
</html>
