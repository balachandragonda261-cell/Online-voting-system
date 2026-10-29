<jsp:include page="/jsp/common/header.jsp" />

<style>
    /* Custom landing page styles */
    .hero-section {
        padding: 6rem 0;
        background: linear-gradient(135deg, rgba(79, 70, 229, 0.05) 0%, rgba(124, 58, 237, 0.05) 100%);
        border-radius: 1.5rem;
        margin-top: -1.5rem;
        margin-bottom: 4rem;
        position: relative;
        overflow: hidden;
    }
    
    .hero-section::before {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: radial-gradient(circle, rgba(79, 70, 229, 0.1) 0%, transparent 50%);
        z-index: 0;
        animation: rotate 30s linear infinite;
    }
    
    @keyframes rotate {
        100% { transform: rotate(360deg); }
    }

    .hero-content {
        position: relative;
        z-index: 1;
    }

    .feature-card {
        border: none;
        border-radius: 1rem;
        transition: all 0.3s ease;
        background: var(--bs-body-bg);
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        height: 100%;
    }

    .feature-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        border-color: var(--bs-primary);
    }
    
    .feature-icon-wrapper {
        width: 64px;
        height: 64px;
        border-radius: 1rem;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 2rem;
        margin-bottom: 1.5rem;
    }

    .cta-section {
        background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
        border-radius: 1.5rem;
        padding: 4rem 2rem;
        color: white;
        text-align: center;
        margin-bottom: 2rem;
        box-shadow: 0 20px 25px -5px rgba(79, 70, 229, 0.3);
    }
</style>

<!-- Hero Section -->
<div class="hero-section text-center text-lg-start px-4 px-md-5">
    <div class="row align-items-center hero-content">
        <div class="col-lg-6 mb-5 mb-lg-0">
            <span class="badge bg-primary bg-opacity-10 text-primary mb-3 px-3 py-2 rounded-pill fw-bold border border-primary border-opacity-25">
                <i class="bi bi-stars me-1"></i> The Future of Voting
            </span>
            <h1 class="display-3 fw-bold mb-4" style="line-height: 1.2;">
                Enterprise-Grade <br>
                <span class="text-transparent bg-clip-text" style="background-image: linear-gradient(135deg, #4f46e5, #7c3aed); -webkit-background-clip: text; color: transparent;">Elections</span>
            </h1>
            <p class="lead mb-4 text-muted fw-medium fs-4">
                Secure, verifiable, and effortless hybrid voting for organizations, colleges, and enterprises.
            </p>
            <div class="d-flex flex-column flex-sm-row gap-3 justify-content-center justify-content-lg-start">
                <a href="${pageContext.request.contextPath}/auth?action=register" class="btn btn-primary btn-lg px-5 py-3 fw-bold shadow-lg shadow-primary">
                    Create an Account
                </a>
                <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-outline-dark btn-lg px-5 py-3 fw-bold bg-body">
                    Sign In
                </a>
            </div>
        </div>
        <div class="col-lg-6 position-relative text-center d-none d-lg-block">
            <i class="bi bi-shield-check" style="font-size: 20rem; color: #4f46e5; opacity: 0.1; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);"></i>
            <div class="row g-4 position-relative z-1">
                <div class="col-6">
                    <div class="card border-0 shadow-sm rounded-4 mb-4 p-4 text-center bg-body">
                        <i class="bi bi-box-arrow-in-down text-primary fs-1 mb-2"></i>
                        <h5 class="fw-bold m-0">Hybrid Mode</h5>
                    </div>
                    <div class="card border-0 shadow-sm rounded-4 p-4 text-center bg-body">
                        <i class="bi bi-lock-fill text-success fs-1 mb-2"></i>
                        <h5 class="fw-bold m-0">SHA-256 Secured</h5>
                    </div>
                </div>
                <div class="col-6 mt-4">
                    <div class="card border-0 shadow-sm rounded-4 mb-4 p-4 text-center bg-body">
                        <i class="bi bi-bar-chart-fill text-warning fs-1 mb-2"></i>
                        <h5 class="fw-bold m-0">Live Analytics</h5>
                    </div>
                    <div class="card border-0 shadow-sm rounded-4 p-4 text-center bg-body">
                        <i class="bi bi-person-fill-lock text-danger fs-1 mb-2"></i>
                        <h5 class="fw-bold m-0">Invite-Only</h5>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Features Section -->
<div class="text-center mb-5">
    <h2 class="fw-bold">Everything you need to run perfect elections</h2>
    <p class="text-muted fs-5">Powerful features designed to ensure integrity and transparency.</p>
</div>

<div class="row g-4 mb-5">
    <div class="col-md-6 col-lg-4">
        <div class="feature-card p-4">
            <div class="feature-icon-wrapper bg-primary bg-opacity-10 text-primary">
                <i class="bi bi-boxes"></i>
            </div>
            <h4 class="fw-bold mb-3">Blockchain Integrity</h4>
            <p class="text-muted m-0">Every vote is cryptographically hashed with SHA-256 and chained to the previous vote. Altering a single vote breaks the entire chain, guaranteeing 100% data integrity.</p>
        </div>
    </div>
    
    <div class="col-md-6 col-lg-4">
        <div class="feature-card p-4">
            <div class="feature-icon-wrapper bg-success bg-opacity-10 text-success">
                <i class="bi bi-people-fill"></i>
            </div>
            <h4 class="fw-bold mb-3">Hybrid Voting</h4>
            <p class="text-muted m-0">Combine the best of both worlds. Run digital online elections while allowing admins to securely input and tally physical paper ballots alongside online votes.</p>
        </div>
    </div>
    
    <div class="col-md-6 col-lg-4">
        <div class="feature-card p-4">
            <div class="feature-icon-wrapper bg-warning bg-opacity-10 text-warning">
                <i class="bi bi-graph-up-arrow"></i>
            </div>
            <h4 class="fw-bold mb-3">Live Analytics & Results</h4>
            <p class="text-muted m-0">Monitor voter turnout in real-time. Once the election concludes, publish the results to reveal interactive leaderboards automatically calculating ties and winners.</p>
        </div>
    </div>

    <div class="col-md-6 col-lg-4">
        <div class="feature-card p-4">
            <div class="feature-icon-wrapper bg-danger bg-opacity-10 text-danger">
                <i class="bi bi-shield-lock-fill"></i>
            </div>
            <h4 class="fw-bold mb-3">Strict Eligibility Control</h4>
            <p class="text-muted m-0">Create Public elections for everyone, or switch to Invite-Only Private elections. Select exactly which voters are allowed to view and cast votes.</p>
        </div>
    </div>

    <div class="col-md-6 col-lg-4">
        <div class="feature-card p-4">
            <div class="feature-icon-wrapper bg-info bg-opacity-10 text-info">
                <i class="bi bi-clock-history"></i>
            </div>
            <h4 class="fw-bold mb-3">Time-Constrained Polling</h4>
            <p class="text-muted m-0">Set exact start and end timestamps. Voters are strictly prevented from voting outside of the designated live window, ensuring fair elections.</p>
        </div>
    </div>

    <div class="col-md-6 col-lg-4">
        <div class="feature-card p-4">
            <div class="feature-icon-wrapper bg-dark bg-opacity-10 text-dark">
                <i class="bi bi-file-earmark-check"></i>
            </div>
            <h4 class="fw-bold mb-3">Voter Receipts</h4>
            <p class="text-muted m-0">Upon voting, users receive a unique cryptographic receipt hash. They can use this to prove their vote was cast and securely recorded without revealing their choice.</p>
        </div>
    </div>
</div>

<!-- CTA Section -->
<div class="cta-section">
    <h2 class="display-5 fw-bold mb-4">Ready to modernize your elections?</h2>
    <p class="fs-5 mb-5 text-white-50 mx-auto" style="max-width: 600px;">
        Join hundreds of organizations trusting VoteSecure for their most critical decisions.
    </p>
    <a href="${pageContext.request.contextPath}/auth?action=register" class="btn btn-light btn-lg px-5 py-3 fw-bold text-primary shadow">
        Get Started Now <i class="bi bi-arrow-right ms-2"></i>
    </a>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
