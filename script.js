const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

// Example: Draw a moving rectangle
let x = 50;
let y = 50;
let dx = 2;
let dy = 2;

function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Draw rectangle
    ctx.fillStyle = 'blue';
    ctx.fillRect(x, y, 50, 50);

    // Update position
    x += dx;
    y += dy;

    // Bounce off walls
    if (x + 50 > canvas.width || x < 0) dx *= -1;
    if (y + 50 > canvas.height || y < 0) dy *= -1;

    requestAnimationFrame(draw);
}

draw();
