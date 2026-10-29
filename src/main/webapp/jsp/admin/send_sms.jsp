<jsp:include page="/jsp/common/header.jsp" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="row justify-content-center">
    <div class="col-lg-10">
        
        <!-- Breadcrumb / Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold m-0 text-transparent bg-clip-text" style="background-image: linear-gradient(135deg, #4f46e5, #7c3aed); -webkit-background-clip: text; color: transparent;">
                    <i class="bi bi-chat-left-text-fill text-primary me-2"></i> SMS Broadcast Portal
                </h2>
                <p class="text-muted m-0">Send a critical update or voting reminder to all participants</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left me-1"></i> Back to Elections
            </a>
        </div>

        <!-- Election Info Card -->
        <div class="card mb-4 border-0 shadow-sm rounded-4 overflow-hidden" style="background: linear-gradient(135deg, rgba(79, 70, 229, 0.03) 0%, rgba(124, 58, 237, 0.03) 100%); border: 1px solid rgba(79, 70, 229, 0.1) !important;">
            <div class="card-body p-4">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <span class="badge ${election.isPrivate() ? 'bg-dark text-warning border border-warning' : 'bg-primary bg-opacity-10 text-primary'} mb-2">
                            <i class="bi ${election.isPrivate() ? 'bi-star-fill' : 'bi-globe'} me-1"></i> ${election.isPrivate() ? 'Invite-Only (Private)' : 'Public Election'}
                        </span>
                        <h4 class="fw-bold m-0">${election.title}</h4>
                        <p class="text-muted m-0 mt-1 small">${election.description}</p>
                    </div>
                    <div class="col-md-4 text-md-end mt-3 mt-md-0">
                        <div class="p-3 bg-body rounded-3 border d-inline-block text-center shadow-sm">
                            <h3 class="fw-bold text-primary m-0">${voters.size()}</h3>
                            <small class="text-muted fw-semibold">Target Voters</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Composer Form -->
            <div class="col-md-7 mb-4">
                <div class="card border-0 shadow-sm rounded-4 p-4 h-100 bg-body">
                    <h5 class="fw-bold mb-3"><i class="bi bi-pencil-square text-primary me-2"></i>Draft SMS Message</h5>
                    
                    <form action="${pageContext.request.contextPath}/admin/elections" method="post" id="smsForm">
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="action" value="sendSMS">
                        <input type="hidden" name="electionId" value="${election.id}">

                        <div class="mb-3">
                            <label for="message" class="form-label fw-semibold text-muted">Message Content</label>
                            <textarea class="form-control rounded-3" id="message" name="message" rows="6" placeholder="Type your broadcast message here... e.g., 'Hello! Secure Voting is now LIVE for the Student Council Election. Make sure to cast your vote before 5 PM!'" required style="resize: none; font-size: 15px; border-color: rgba(79, 70, 229, 0.15);"></textarea>
                            <div class="d-flex justify-content-between mt-2 px-1">
                                <small class="text-muted" id="charCount">0 / 160 characters</small>
                                <small class="text-muted" id="segments">1 segment (Standard SMS)</small>
                            </div>
                        </div>

                        <!-- Info Alerts -->
                        <div class="alert alert-info rounded-3 border-0 bg-info bg-opacity-10 text-dark small mb-4">
                            <i class="bi bi-info-circle-fill text-info me-2"></i>
                            <strong>Note:</strong> Messages are sent as a simulated high-priority mobile SMS alert. Each broadcast is securely logged for tracking.
                        </div>

                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary btn-lg fw-bold rounded-3 shadow" id="sendBtn">
                                <i class="bi bi-send-fill me-2"></i> Broadcast SMS Message
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Recipients Preview -->
            <div class="col-md-5 mb-4">
                <div class="card border-0 shadow-sm rounded-4 p-4 h-100 bg-body">
                    <h5 class="fw-bold mb-3"><i class="bi bi-people-fill text-primary me-2"></i>Recipient List (${voters.size()})</h5>
                    
                    <div class="overflow-auto" style="max-height: 380px;">
                        <ul class="list-group list-group-flush">
                            <c:forEach items="${voters}" var="voter">
                                <li class="list-group-item px-0 py-3 bg-transparent border-bottom">
                                    <div class="d-flex align-items-center justify-content-between">
                                        <div>
                                            <h6 class="fw-bold m-0 text-truncate" style="max-width: 180px;">${voter.name}</h6>
                                            <small class="text-muted">${voter.email}</small>
                                        </div>
                                        <div class="text-end">
                                            <span class="badge bg-success bg-opacity-10 text-success rounded-pill fw-normal">+1 (555) 018-00${voter.id}</span>
                                            <br>
                                            <small class="text-muted small">Simulated Phone</small>
                                        </div>
                                    </div>
                                </li>
                            </c:forEach>
                            <c:if test="${empty voters}">
                                <li class="list-group-item text-center text-muted py-4 bg-transparent border-0">
                                    <i class="bi bi-people display-4 d-block mb-2 opacity-50"></i>
                                    No eligible voters configured for this election.
                                </li>
                            </c:if>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        const textarea = document.getElementById('message');
        const charCount = document.getElementById('charCount');
        const segments = document.getElementById('segments');
        const form = document.getElementById('smsForm');
        const sendBtn = document.getElementById('sendBtn');

        textarea.addEventListener('input', () => {
            const length = textarea.value.length;
            charCount.textContent = `${length} / 160 characters`;
            
            // Calculate segment counts (standard SMS is 160 characters)
            const segs = Math.ceil(length / 160) || 1;
            segments.textContent = `${segs} segment${segs > 1 ? 's' : ''} (Standard SMS)`;
            
            if (length > 160) {
                charCount.classList.add('text-warning');
            } else {
                charCount.classList.remove('text-warning');
            }
        });

        form.addEventListener('submit', (e) => {
            sendBtn.disabled = true;
            sendBtn.innerHTML = `<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Broadcasting...`;
        });
    });
</script>

<jsp:include page="/jsp/common/footer.jsp" />
