<jsp:include page="/jsp/common/header.jsp" />

<div class="auth-wrapper">
    <div class="card auth-card">
        <h2 class="text-center mb-4">Create Account</h2>
        <form action="${pageContext.request.contextPath}/auth" method="post">
            <input type="hidden" name="action" value="register">
            <div class="mb-3">
                <label for="name" class="form-label">Full Name</label>
                <input type="text" class="form-control" id="name" name="name" required>
            </div>
            <div class="mb-3">
                <label for="email" class="form-label">Email address</label>
                <input type="email" class="form-control" id="email" name="email" required>
            </div>
            <div class="mb-3">
                <label for="password" class="form-label">Password</label>
                <input type="password" class="form-control" id="password" name="password" required>
            </div>
            <div class="d-grid mb-3">
                <button type="submit" class="btn btn-primary btn-lg">Register</button>
            </div>
            <div class="text-center">
                <span class="text-muted">Already have an account? </span>
                <a href="${pageContext.request.contextPath}/auth?action=login" class="text-decoration-none text-primary fw-medium">Login here</a>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
