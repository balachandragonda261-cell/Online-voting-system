<jsp:include page="/jsp/common/header.jsp" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="row mb-4">
    <div class="col-12">
        <h2 class="fw-bold"><i class="bi bi-clock-history me-2 text-primary"></i>Past Elections</h2>
        <p class="text-muted">Browse the history of past elections and view officially published results.</p>
    </div>
</div>

<div class="row">
    <c:set var="pastCount" value="0" />
    <c:forEach items="${elections}" var="election">
        <c:if test="${election.status == 'CLOSED' || election.status == 'DECLARED' || election.status == 'ARCHIVED'}">
            <c:set var="pastCount" value="${pastCount + 1}" />
            <div class="col-md-6 col-lg-4 mb-4">
                <div class="card h-100 border-secondary">
                    <div class="card-header bg-light d-flex justify-content-between align-items-center">
                        <span class="badge ${election.status == 'DECLARED' ? 'bg-warning text-dark border border-warning' : 'bg-secondary'}">
                            ${election.status == 'DECLARED' ? '<i class="bi bi-trophy-fill me-1"></i>RESULTS PUBLISHED' : 'VOTING CLOSED'}
                        </span>
                        <div>
                            <c:if test="${election.isPrivate()}">
                                <span class="badge bg-dark text-warning border border-warning me-1"><i class="bi bi-star-fill"></i> Private</span>
                            </c:if>
                            <small class="text-muted"><fmt:formatDate value="${election.endTime}" pattern="yyyy"/></small>
                        </div>
                    </div>
                    <div class="card-body">
                        <h5 class="card-title fw-bold text-truncate">${election.title}</h5>
                        <p class="card-text text-muted small" style="height: 40px; overflow: hidden;">${election.description}</p>
                        
                        <c:choose>
                            <c:when test="${election.status == 'DECLARED' && not empty election.winnerName}">
                                <div class="alert alert-warning text-center mb-4 py-2 border-warning" role="alert">
                                    <h6 class="alert-heading fw-bold mb-1"><i class="bi bi-star-fill text-warning me-1"></i> Winner Announced</h6>
                                    <p class="mb-0 fw-bold fs-5 text-dark">${election.winnerName}</p>
                                </div>
                                <div class="d-grid gap-2">
                                    <a href="${pageContext.request.contextPath}/voter/results?electionId=${election.id}" class="btn btn-outline-primary">View Full Results</a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-secondary text-center mb-4 py-3" role="alert">
                                    <i class="bi bi-hourglass-split fs-4 d-block mb-2 text-muted"></i>
                                    <p class="mb-0 fw-bold text-muted small">Results Pending Admin Review</p>
                                </div>
                                <div class="d-grid gap-2">
                                    <button class="btn btn-outline-secondary" disabled>Results Not Published Yet</button>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </c:if>
    </c:forEach>
    <c:if test="${pastCount == 0}">
        <div class="col-12">
            <div class="alert alert-secondary text-center py-5" role="alert">
                <i class="bi bi-archive display-3 d-block mb-3 text-muted opacity-50"></i>
                <h5 class="text-muted">No past elections found.</h5>
                <p class="mb-0">Completed elections will appear here.</p>
            </div>
        </div>
    </c:if>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
