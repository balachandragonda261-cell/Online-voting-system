document.addEventListener('DOMContentLoaded', () => {
    // Dark mode toggle logic
    const themeToggle = document.getElementById('theme-toggle');
    const prefersDarkScheme = window.matchMedia("(prefers-color-scheme: dark)");

    // Get theme from localStorage or OS preference
    const currentTheme = localStorage.getItem("theme") || 
                        (prefersDarkScheme.matches ? "dark" : "light");

    if (currentTheme == "dark") {
        document.body.setAttribute("data-theme", "dark");
        if(themeToggle) themeToggle.checked = true;
    } else {
        document.body.setAttribute("data-theme", "light");
    }

    if(themeToggle) {
        themeToggle.addEventListener("change", function () {
            let theme = "light";
            if (this.checked) {
                document.body.setAttribute("data-theme", "dark");
                theme = "dark";
            } else {
                document.body.setAttribute("data-theme", "light");
            }
            localStorage.setItem("theme", theme);
        });
    }

    // Live countdown timer logic
    const timers = document.querySelectorAll('.countdown-timer');
    timers.forEach(timer => {
        const endTimeStr = timer.getAttribute('data-end-time');
        const endTime = new Date(endTimeStr).getTime();

        const x = setInterval(function() {
            const now = new Date().getTime();
            const distance = endTime - now;

            if (distance < 0) {
                clearInterval(x);
                timer.innerHTML = "EXPIRED";
                timer.classList.add('text-danger');
                return;
            }

            const days = Math.floor(distance / (1000 * 60 * 60 * 24));
            const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((distance % (1000 * 60)) / 1000);

            timer.innerHTML = days + "d " + hours + "h " + minutes + "m " + seconds + "s ";
        }, 1000);
    });
});
