</div> <!-- End of container from header.jsp -->

<footer class="mt-auto py-3 text-center border-top" style="border-color: var(--border-color) !important;">
    <div class="container">
        <span class="text-muted">&copy; 2026 VoteSecure. All rights reserved.</span>
    </div>
</footer>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!-- Floating AI Chatbot -->
<c:if test="${empty sessionScope.user || sessionScope.user.role != 'ADMIN'}">
<div id="aiChatWidget" style="position: fixed; bottom: 20px; right: 20px; z-index: 1050;">
    <!-- Chat Button -->
    <button id="chatToggleBtn" class="btn btn-primary rounded-circle shadow-lg" style="width: 60px; height: 60px; font-size: 24px;">
        <i class="bi bi-chat-dots-fill"></i>
    </button>

    <!-- Chat Box -->
    <div id="chatBox" class="card shadow-lg d-none" style="width: 320px; position: absolute; bottom: 70px; right: 0; border-radius: 15px; border: 1px solid var(--border-color);">
        <div class="card-header bg-primary text-white" style="border-top-left-radius: 15px; border-top-right-radius: 15px;">
            <i class="bi bi-robot me-2"></i> AI Voter Assistant
            <button type="button" class="btn-close btn-close-white float-end" id="closeChatBtn" style="font-size: 0.8rem; margin-top: 4px;"></button>
        </div>
        <div class="card-body" id="chatBody" style="height: 300px; overflow-y: auto; background-color: var(--bg-color);">
            <div class="mb-2 text-start">
                <span class="badge bg-secondary rounded-pill p-2" style="font-weight: normal; font-size: 14px;">Hello! I'm your AI Assistant. How can I help you today?</span>
            </div>
        </div>
        <div class="card-footer p-2" style="background-color: var(--card-bg);">
            <div class="input-group">
                <input type="text" id="chatInput" class="form-control" placeholder="Ask a question..." style="font-size: 14px;">
                <button class="btn btn-primary" id="chatSendBtn"><i class="bi bi-send-fill"></i></button>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        const toggleBtn = document.getElementById('chatToggleBtn');
        const closeBtn = document.getElementById('closeChatBtn');
        const chatBox = document.getElementById('chatBox');
        const chatInput = document.getElementById('chatInput');
        const chatSendBtn = document.getElementById('chatSendBtn');
        const chatBody = document.getElementById('chatBody');

        function toggleChat() {
            chatBox.classList.toggle('d-none');
            if (!chatBox.classList.contains('d-none')) {
                chatInput.focus();
            }
        }

        toggleBtn.addEventListener('click', toggleChat);
        closeBtn.addEventListener('click', toggleChat);

        async function sendMessage() {
            const msg = chatInput.value.trim();
            if (!msg) return;

            // Add User Message
            chatBody.innerHTML += `<div class="mb-2 text-end"><span class="badge bg-primary rounded-pill p-2" style="font-weight: normal; font-size: 14px; text-align: left;">${msg}</span></div>`;
            chatInput.value = '';
            chatBody.scrollTop = chatBody.scrollHeight;

            // Add Typing indicator
            const typingId = 'typing-' + Date.now();
            chatBody.innerHTML += `<div id="${typingId}" class="mb-2 text-start"><span class="badge bg-secondary rounded-pill p-2 text-muted" style="font-style: italic;">Typing...</span></div>`;
            chatBody.scrollTop = chatBody.scrollHeight;

            try {
                const response = await fetch('${pageContext.request.contextPath}/api/chatbot', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'message=' + encodeURIComponent(msg)
                });
                
                document.getElementById(typingId).remove();
                
                if (response.ok) {
                    const data = await response.json();
                    chatBody.innerHTML += `<div class="mb-2 text-start"><span class="badge bg-secondary rounded-pill p-2" style="font-weight: normal; font-size: 14px; text-align: left; white-space: normal;">${data.reply}</span></div>`;
                } else {
                    chatBody.innerHTML += `<div class="mb-2 text-start"><span class="badge bg-danger rounded-pill p-2">Error connecting to AI.</span></div>`;
                }
            } catch (e) {
                document.getElementById(typingId).remove();
                chatBody.innerHTML += `<div class="mb-2 text-start"><span class="badge bg-danger rounded-pill p-2">Error connecting to AI.</span></div>`;
            }
            chatBody.scrollTop = chatBody.scrollHeight;
        }

        chatSendBtn.addEventListener('click', sendMessage);
        chatInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') sendMessage();
        });
    });
</script>
</c:if>

<!-- Bootstrap 5 JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<!-- Custom JS -->
<script src="${pageContext.request.contextPath}/js/main.js"></script>

</body>
</html>
