<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
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
<!-- GSAP CDN -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
    <style>
        .perspective {
            perspective: 1000px;
        }

        .notebook {
            width: 300px;
            height: 400px;
            position: relative;
            transform-origin: center center;
            transition: transform 1s ease-in-out;
        }

        .cover {
            background-color: #8B4513; /* 갈색 */
            background-image: url('https://www.transparenttextures.com/patterns/leather.png');
            background-size: cover;
            position: absolute;
            width: 100%;
            height: 100%;
            transform-origin: left;
            z-index: 2;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 8px 15px rgba(0, 0, 0, 0.5);
            border: 4px solid #654321;
        }

        .pages {
            background-color: #F9F9F9;
            position: absolute;
            width: 100%;
            height: 100%;
            z-index: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 5px 10px rgba(0, 0, 0, 0.3);
            opacity: 0;
        }
    </style>
</head>
<body class="flex items-center justify-center h-screen bg-gray-100">
    <div class="notebook perspective">
        <!-- Notebook Cover -->
        <div class="cover cursor-pointer">
            <h1 class="text-white font-bold text-2xl">My Notebook</h1>
        </div>
        <!-- Notebook Pages -->
        <div class="pages">
            <div class="text-center">
                <h2 class="text-4xl font-bold mb-4">Welcome</h2>
                <p class="text-gray-700">This is the expanded notebook content. Enjoy!</p>
            </div>
        </div>
    </div>

    <script>
        document.querySelector('.cover').addEventListener('click', function () {
            const notebook = document.querySelector('.notebook');
            const pages = document.querySelector('.pages');

            // Step 1: Open the cover
            gsap.to('.cover', {
                rotationY: -180,
                duration: 1,
                transformOrigin: "left center",
                ease: "power2.inOut"
            });

            // Step 2: Expand the notebook to full screen
            gsap.to(notebook, {
                scale: 3,
                x: "-50vw",
                y: "-50vh",
                duration: 1.5,
                delay: 1,
                transformOrigin: "center center",
                ease: "power2.inOut",
                onComplete: function () {
                    // Step 3: Show the pages content
                    gsap.to(pages, {
                        opacity: 1,
                        duration: 0.8
                    });
                }
            });
        });
    </script>
</body>
</html>