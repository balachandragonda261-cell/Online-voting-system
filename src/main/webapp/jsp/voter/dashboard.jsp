<jsp:include page="/jsp/common/header.jsp" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="row mb-4">
    <div class="col-12">
        <h2 class="fw-bold">Voter Dashboard</h2>
        <p class="text-muted">Welcome, ${sessionScope.user.name}. View and participate in active elections.</p>
    </div>
</div>

<div class="row">
    <!-- Active Elections Column -->
    <div class="col-lg-8 mb-4">
        <h4 class="fw-bold mb-4"><i class="bi bi-box-seam text-primary me-2"></i>Available Elections</h4>
        <div class="row">
            <c:set var="activeCount" value="0" />
            <c:forEach items="${elections}" var="election">
                <c:if test="${election.status == 'LIVE' || election.status == 'PUBLISHED'}">
                    <c:set var="activeCount" value="${activeCount + 1}" />
                    <div class="col-md-6 mb-4">
                        <div class="card h-100 ${election.status == 'LIVE' ? 'border-primary' : ''}">
                            <div class="card-header bg-transparent d-flex justify-content-between align-items-center">
                                <span class="badge ${election.status == 'LIVE' ? 'bg-success' : 'bg-info text-dark'}">
                                    ${election.status == 'PUBLISHED' ? 'UPCOMING' : 'LIVE'}
                                </span>
                                <c:if test="${election.status == 'LIVE'}">
                                    <span class="text-danger small fw-bold">
                                        <i class="bi bi-circle-fill me-1" style="font-size: 0.5rem; vertical-align: middle; animation: blinker 1.5s linear infinite;"></i>LIVE
                                    </span>
                                    <style>
                                        @keyframes blinker { 50% { opacity: 0; } }
                                    </style>
                                </c:if>
                                <c:if test="${election.isPrivate()}">
                                    <span class="badge bg-dark text-warning border border-warning ms-2"><i class="bi bi-star-fill me-1"></i>Invite-Only</span>
                                </c:if>
                            </div>
                            <div class="card-body">
                                <h5 class="card-title fw-bold text-truncate">${election.title}</h5>
                                <p class="card-text text-muted small" style="height: 40px; overflow: hidden;">${election.description}</p>
                                
                                <ul class="list-unstyled small mb-4">
                                    <li class="mb-1"><i class="bi bi-calendar-event me-2 text-primary"></i> <strong>Start:</strong> <fmt:formatDate value="${election.startTime}" pattern="MMM dd, yyyy HH:mm"/></li>
                                    <li><i class="bi bi-calendar-x me-2 text-danger"></i> <strong>End:</strong> <fmt:formatDate value="${election.endTime}" pattern="MMM dd, yyyy HH:mm"/></li>
                                </ul>
                                
                                <div class="d-grid gap-2">
                                    <c:choose>
                                        <c:when test="${votedElectionIds.contains(election.id)}">
                                            <button class="btn btn-success fw-bold" disabled><i class="bi bi-check-circle me-1"></i> Vote Submitted</button>
                                        </c:when>
                                        <c:when test="${election.status == 'LIVE'}">
                                            <a href="${pageContext.request.contextPath}/voter/vote?electionId=${election.id}" class="btn btn-primary fw-bold">Cast Vote</a>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn btn-outline-secondary" disabled>Voting Not Open</button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <c:if test="${election.status == 'LIVE'}">
                                <div class="card-footer bg-transparent text-center">
                                    <small class="text-muted fw-bold">Time left: <span class="countdown-timer text-primary" data-end-time="<fmt:formatDate value='${election.endTime}' pattern='yyyy-MM-dd\'T\'HH:mm:ss'/>">Loading...</span></small>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </c:if>
            </c:forEach>
            <c:if test="${activeCount == 0}">
                <div class="col-12">
                    <div class="alert alert-secondary text-center py-4" role="alert">
                        <i class="bi bi-inbox display-4 d-block mb-3 text-muted"></i>
                        No elections available at the moment.
                    </div>
                </div>
            </c:if>
        </div>
    </div>

    <!-- Messages / Notifications Column -->
    <div class="col-lg-4 mb-4">
        <div class="card border-0 shadow-sm rounded-4 h-100 bg-body">
            <div class="card-body p-4">
                <h5 class="fw-bold mb-3 text-transparent bg-clip-text" style="background-image: linear-gradient(135deg, #4f46e5, #7c3aed); -webkit-background-clip: text; color: transparent;">
                    <i class="bi bi-bell-fill text-primary me-2"></i>Notifications & Messages
                </h5>
                <p class="text-muted small mb-4">Official updates from the Election Commission</p>
                
                <div class="overflow-auto" style="max-height: 480px;">
                    <ul class="list-group list-group-flush">
                        <c:forEach items="${smsLogs}" var="sms">
                            <li class="list-group-item px-0 py-3 bg-transparent border-bottom">
                                <div class="d-flex justify-content-between mb-2 align-items-center">
                                    <span class="badge bg-primary bg-opacity-10 text-primary rounded-pill small">${sms.electionTitle}</span>
                                    <small class="text-muted small"><fmt:formatDate value="${sms.sentAt}" pattern="MMM dd, HH:mm"/></small>
                                </div>
                                <p class="mb-0 small text-dark fw-medium" style="line-height: 1.4;">${sms.message}</p>
                            </li>
                        </c:forEach>
                        <c:if test="${empty smsLogs}">
                            <li class="list-group-item text-center text-muted py-5 bg-transparent border-0">
                                <i class="bi bi-chat-left-dots display-3 d-block mb-3 opacity-50 text-muted"></i>
                                No notifications received yet.
                            </li>
                        </c:if>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
