<jsp:include page="/jsp/common/header.jsp" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="mb-4">
    <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-outline-secondary btn-sm mb-3">
        <i class="bi bi-arrow-left"></i> Back to Elections
    </a>
    <div class="d-flex justify-content-between align-items-center">
        <div>
            <h2 class="fw-bold m-0">Candidates</h2>
            <p class="text-muted mb-0">Election: <strong>${election.title}</strong></p>
        </div>
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addCandidateModal">
            <i class="bi bi-person-plus me-1"></i> Add Candidate
        </button>
    </div>
</div>

<div class="row">
    <c:forEach items="${candidates}" var="candidate">
        <div class="col-md-4 mb-4">
            <div class="card h-100">
                <div class="card-body text-center">
                    <img src="${pageContext.request.contextPath}${candidate.photoUrl}" alt="${candidate.name}" class="rounded-circle mb-3" width="100" height="100" style="object-fit: cover; border: 3px solid var(--border-color);">
                    <h5 class="card-title fw-bold">${candidate.name}</h5>
                    <p class="card-text text-muted small mb-3">${candidate.manifesto}</p>
                    <div class="mt-auto">
                        <form action="${pageContext.request.contextPath}/admin/candidates" method="post" onsubmit="return confirm('Are you sure you want to remove this candidate?');">
                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                            <input type="hidden" name="action" value="removeCandidate">
                            <input type="hidden" name="electionId" value="${election.id}">
                            <input type="hidden" name="candidateId" value="${candidate.id}">
                            <button type="submit" class="btn btn-outline-danger btn-sm w-100">
                                <i class="bi bi-trash"></i> Remove Candidate
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </c:forEach>
    <c:if test="${empty candidates}">
        <div class="col-12">
            <div class="alert alert-secondary text-center" role="alert">
                No candidates have been added to this election yet.
            </div>
        </div>
    </c:if>
</div>

<!-- Add Candidate Modal -->
<div class="modal fade" id="addCandidateModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Add Candidate</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/candidates" method="post">
                <div class="modal-body">
                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="addCandidate">
                    <input type="hidden" name="electionId" value="${election.id}">
                    <div class="mb-3">
                        <label for="name" class="form-label">Candidate Name</label>
                        <input type="text" class="form-control" id="name" name="name" required>
                    </div>
                    <div class="mb-3">
                        <label for="manifesto" class="form-label">Manifesto (Short Description)</label>
                        <textarea class="form-control" id="manifesto" name="manifesto" rows="3" required></textarea>
                    </div>
                    <div class="alert alert-info py-2 small">
                        <i class="bi bi-info-circle me-1"></i> Photo and Symbol uploads are simulated and default images will be used for now.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add Candidate</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
