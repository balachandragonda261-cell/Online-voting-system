<jsp:include page="/jsp/common/header.jsp" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="row mb-4">
    <div class="col-12">
        <h2 class="fw-bold">Admin Dashboard</h2>
        <p class="text-muted">Overview of the election system</p>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-4 mb-3">
        <div class="card bg-primary text-white h-100">
            <div class="card-body d-flex flex-column justify-content-center align-items-center">
                <i class="bi bi-box-seam display-4 mb-2"></i>
                <h5 class="card-title">Total Elections</h5>
                <h2 class="fw-bold m-0">${elections.size()}</h2>
            </div>
        </div>
    </div>
    <div class="col-md-4 mb-3">
        <div class="card bg-success text-white h-100">
            <div class="card-body d-flex flex-column justify-content-center align-items-center">
                <i class="bi bi-people display-4 mb-2"></i>
                <h5 class="card-title">Total Users</h5>
                <h2 class="fw-bold m-0">${users.size()}</h2>
            </div>
        </div>
    </div>
    <div class="col-md-4 mb-3">
        <div class="card bg-info text-white h-100">
            <div class="card-body d-flex flex-column justify-content-center align-items-center">
                <i class="bi bi-journal-text display-4 mb-2"></i>
                <h5 class="card-title">Audit Logs</h5>
                <h2 class="fw-bold m-0">${auditLogs.size()}</h2>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-lg-8 mb-4">
        <div class="card h-100">
            <div class="card-header d-flex justify-content-between align-items-center bg-transparent">
                <h5 class="mb-0 fw-bold">Recent Elections</h5>
                <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-sm btn-outline-primary">View All</a>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Title</th>
                                <th>Status</th>
                                <th>End Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${elections}" var="election" end="4">
                                <tr>
                                    <td>${election.title}</td>
                                    <td>
                                        <span class="badge 
                                            ${election.status == 'LIVE' ? 'bg-success' : 
                                              election.status == 'DRAFT' ? 'bg-secondary' : 
                                              election.status == 'CLOSED' ? 'bg-danger' : 'bg-primary'}">
                                            ${election.status}
                                        </span>
                                    </td>
                                    <td><fmt:formatDate value="${election.endTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty elections}">
                                <tr><td colspan="3" class="text-center text-muted py-3">No elections found.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <div class="col-lg-4 mb-4">
        <div class="card h-100">
            <div class="card-header bg-transparent">
                <h5 class="mb-0 fw-bold">Recent Audit Logs</h5>
            </div>
            <div class="card-body p-0">
                <ul class="list-group list-group-flush">
                    <c:forEach items="${auditLogs}" var="log" end="4">
                        <li class="list-group-item">
                            <div class="d-flex w-100 justify-content-between">
                                <h6 class="mb-1 text-truncate" style="max-width: 150px;">User ID: ${log.userId}</h6>
                                <small class="text-muted"><fmt:formatDate value="${log.timestamp}" pattern="MM/dd HH:mm"/></small>
                            </div>
                            <p class="mb-1 small">${log.action}</p>
                            <small class="text-muted">IP: ${log.ipAddress}</small>
                        </li>
                    </c:forEach>
                    <c:if test="${empty auditLogs}">
                        <li class="list-group-item text-center text-muted py-3">No logs found.</li>
                    </c:if>
                </ul>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
