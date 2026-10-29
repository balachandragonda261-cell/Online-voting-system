<jsp:include page="/jsp/common/header.jsp" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-outline-secondary btn-sm mb-2"><i class="bi bi-arrow-left"></i> Back</a>
        <h2 class="fw-bold m-0">Add Offline Votes</h2>
        <p class="text-muted">Election: <strong>${election.title}</strong></p>
    </div>
</div>

<div class="card shadow-sm border-0">
    <div class="card-body">
        <div class="alert alert-warning mb-4">
            <i class="bi bi-info-circle-fill me-2"></i> <strong>Hybrid Voting Mode:</strong> Enter the number of physical paper votes collected for each candidate below. These will be securely added to the digital online votes.
        </div>
        
        <form action="${pageContext.request.contextPath}/admin/offlineVotes" method="post">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="updateOfflineVotes">
            <input type="hidden" name="electionId" value="${election.id}">
            
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-4">
                    <thead class="table-light">
                        <tr>
                            <th>Candidate</th>
                            <th style="width: 250px;">Physical (Offline) Votes</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${candidates}" var="candidate">
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <c:if test="${not empty candidate.photoUrl}">
                                            <img src="${candidate.photoUrl}" alt="Photo" class="rounded-circle me-3 border" style="width: 40px; height: 40px; object-fit: cover;">
                                        </c:if>
                                        <c:if test="${empty candidate.photoUrl}">
                                            <div class="rounded-circle me-3 bg-secondary bg-opacity-10 d-flex justify-content-center align-items-center" style="width: 40px; height: 40px;">
                                                <i class="bi bi-person text-secondary fs-5"></i>
                                            </div>
                                        </c:if>
                                        <div>
                                            <strong>${candidate.name}</strong>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <input type="number" class="form-control" name="offline_votes_${candidate.id}" value="${candidate.offlineVotes}" min="0" required>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty candidates}">
                            <tr><td colspan="2" class="text-center py-4 text-muted">No candidates found for this election.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            
            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-outline-secondary px-4">Cancel</a>
                <button type="submit" class="btn btn-dark px-4"><i class="bi bi-save me-1"></i> Save Offline Votes</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
