<jsp:include page="/jsp/common/header.jsp" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2 class="fw-bold m-0">Manage Elections</h2>
    <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createElectionModal">
        <i class="bi bi-plus-lg me-1"></i> Create Election
    </button>
</div>

<div class="card">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Start Time</th>
                        <th>End Time</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${elections}" var="election">
                        <tr>
                            <td>${election.id}</td>
                            <td><strong>${election.title}</strong></td>
                            <td><fmt:formatDate value="${election.startTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                            <td><fmt:formatDate value="${election.endTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                            <td>
                                <span class="badge 
                                    ${election.status == 'LIVE' ? 'bg-success' : 
                                      election.status == 'DRAFT' ? 'bg-secondary' : 
                                      election.status == 'CLOSED' ? 'bg-danger' : 'bg-primary'}">
                                    ${election.status}
                                </span>
                            </td>
                            <td>
                                <div class="d-flex gap-2">
                                    <a href="${pageContext.request.contextPath}/admin/candidates?electionId=${election.id}" class="btn btn-sm btn-outline-primary"><i class="bi bi-people"></i> Candidates</a>
                                    <a href="${pageContext.request.contextPath}/admin/eligibility?electionId=${election.id}" class="btn btn-sm btn-outline-secondary"><i class="bi bi-person-check"></i> Eligibility</a>
                                    <a href="${pageContext.request.contextPath}/admin/sms?electionId=${election.id}" class="btn btn-sm btn-outline-warning"><i class="bi bi-chat-left-text-fill"></i> SMS Broadcast</a>
                                    
                                    <form action="${pageContext.request.contextPath}/admin/elections" method="post" class="m-0 p-0">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="updateElectionStatus">
                                        <input type="hidden" name="electionId" value="${election.id}">
                                        
                                        <c:choose>
                                            <c:when test="${election.status == 'DRAFT' || election.status == 'PUBLISHED'}">
                                                <button type="submit" name="status" value="LIVE" class="btn btn-sm btn-success fw-bold shadow-sm">
                                                    <i class="bi bi-play-circle me-1"></i> Start Voting
                                                </button>
                                            </c:when>
                                            <c:when test="${election.status == 'LIVE'}">
                                                <button type="submit" name="status" value="CLOSED" class="btn btn-sm btn-danger fw-bold shadow-sm">
                                                    <i class="bi bi-stop-circle me-1"></i> End Voting
                                                </button>
                                            </c:when>
                                        </c:choose>
                                    </form>
                                    
                                    <c:if test="${election.status == 'CLOSED'}">
                                        <a href="${pageContext.request.contextPath}/admin/offlineVotes?electionId=${election.id}" class="btn btn-sm btn-outline-dark fw-bold shadow-sm">
                                            <i class="bi bi-box-arrow-in-down"></i> Add Offline Votes
                                        </a>
                                        <form action="${pageContext.request.contextPath}/admin/elections" method="post" class="m-0 p-0">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                            <input type="hidden" name="action" value="declareWinner">
                                            <input type="hidden" name="electionId" value="${election.id}">
                                            <button type="submit" class="btn btn-sm btn-warning fw-bold shadow-sm text-dark">
                                                <i class="bi bi-megaphone-fill"></i> Publish Final Results
                                            </button>
                                        </form>
                                    </c:if>
                                    <c:if test="${election.status == 'DECLARED'}">
                                        <span class="badge bg-warning text-dark d-flex align-items-center"><i class="bi bi-trophy-fill me-1"></i> Winner Declared</span>
                                    </c:if>
                                    
                                    <form action="${pageContext.request.contextPath}/admin/elections" method="post" class="m-0 p-0" onsubmit="return confirm('Are you sure you want to permanently delete this election? All candidates and votes will be lost.');">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="deleteElection">
                                        <input type="hidden" name="electionId" value="${election.id}">
                                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete Election">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty elections}">
                        <tr><td colspan="6" class="text-center text-muted py-4">No elections created yet.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Create Election Modal -->
<div class="modal fade" id="createElectionModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Create New Election</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/elections" method="post">
                <div class="modal-body">
                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="createElection">
                    <div class="mb-3">
                        <label for="title" class="form-label">Election Title</label>
                        <input type="text" class="form-control" id="title" name="title" required>
                    </div>
                    <div class="mb-3">
                        <label for="description" class="form-label">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="startTime" class="form-label">Start Time</label>
                            <input type="datetime-local" class="form-control" id="startTime" name="startTime" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="endTime" class="form-label">End Time</label>
                            <input type="datetime-local" class="form-control" id="endTime" name="endTime" required>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Create</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
