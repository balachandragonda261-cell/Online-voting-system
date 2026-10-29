<jsp:include page="/jsp/common/header.jsp" />

<div class="auth-wrapper">
    <div class="card auth-card">
        <h2 class="text-center mb-4">Welcome Back</h2>
        <form action="${pageContext.request.contextPath}/auth" method="post">
            <input type="hidden" name="action" value="login">
            <div class="mb-3">
                <label for="email" class="form-label">Email address</label>
                <input type="email" class="form-control" id="email" name="email" required>
            </div>
            <div class="mb-3">
                <label for="password" class="form-label">Password</label>
                <input type="password" class="form-control" id="password" name="password" required>
            </div>
            <div class="d-grid mb-3">
                <button type="submit" class="btn btn-primary btn-lg">Login</button>
            </div>
            <div class="text-center">
                <span class="text-muted">Don't have an account? </span>
                <a href="${pageContext.request.contextPath}/auth?action=register" class="text-decoration-none text-primary fw-medium">Register here</a>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
