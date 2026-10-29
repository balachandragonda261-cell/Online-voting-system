<jsp:include page="/jsp/common/header.jsp" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2 class="fw-bold m-0">Manage Users</h2>
</div>

<div class="card">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Registered On</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${users}" var="user">
                        <tr>
                            <td>${user.id}</td>
                            <td><strong>${user.name}</strong></td>
                            <td>${user.email}</td>
                            <td><span class="badge bg-secondary">${user.role}</span></td>
                            <td>
                                <span class="badge 
                                    ${user.status == 'APPROVED' ? 'bg-success' : 
                                      user.status == 'PENDING' ? 'bg-warning text-dark' : 'bg-danger'}">
                                    ${user.status}
                                </span>
                            </td>
                            <td><fmt:formatDate value="${user.createdAt}" pattern="yyyy-MM-dd"/></td>
                            <td>
                                <c:if test="${user.role != 'ADMIN'}">
                                    <form action="${pageContext.request.contextPath}/admin/users" method="post" class="d-inline">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="updateUserStatus">
                                        <input type="hidden" name="userId" value="${user.id}">
                                        
                                        <c:if test="${user.status == 'PENDING' || user.status == 'REJECTED'}">
                                            <button type="submit" name="status" value="APPROVED" class="btn btn-sm btn-outline-success">Approve</button>
                                        </c:if>
                                        <c:if test="${user.status == 'PENDING' || user.status == 'APPROVED'}">
                                            <button type="submit" name="status" value="REJECTED" class="btn btn-sm btn-outline-danger">Reject</button>
                                        </c:if>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty users}">
                        <tr><td colspan="7" class="text-center text-muted py-4">No users found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
