<jsp:include page="/jsp/common/header.jsp" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-outline-secondary btn-sm mb-2"><i class="bi bi-arrow-left"></i> Back</a>
        <h2 class="fw-bold m-0">Voter Eligibility</h2>
        <p class="text-muted">Election: <strong>${election.title}</strong></p>
    </div>
</div>

<div class="card shadow-sm border-0">
    <div class="card-body">
        <form action="${pageContext.request.contextPath}/admin/eligibility" method="post">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="updateEligibility">
            <input type="hidden" name="electionId" value="${election.id}">
            
            <div class="alert alert-info d-flex align-items-center mb-4">
                <i class="bi bi-shield-lock-fill fs-3 me-3"></i>
                <div class="flex-grow-1">
                    <h5 class="alert-heading mb-1 fw-bold">Election Access Control</h5>
                    <p class="mb-0 small">Control who is allowed to participate in this election.</p>
                </div>
                <div class="btn-group" role="group" aria-label="Election Privacy Toggle">
                    <input type="radio" class="btn-check" name="isPrivate" id="typePublic" value="false" ${!election.isPrivate() ? 'checked' : ''} autocomplete="off">
                    <label class="btn btn-outline-primary" for="typePublic"><i class="bi bi-globe me-1"></i> Public</label>
                  
                    <input type="radio" class="btn-check" name="isPrivate" id="typePrivate" value="true" ${election.isPrivate() ? 'checked' : ''} autocomplete="off">
                    <label class="btn btn-outline-primary" for="typePrivate"><i class="bi bi-lock-fill me-1"></i> Private</label>
                </div>
            </div>
            
            <div id="voterListContainer" class="table-responsive ${!election.isPrivate() ? 'opacity-50 pointer-event-none' : ''}">
                <div id="publicOverlay" class="${election.isPrivate() ? 'd-none' : ''} position-absolute w-100 h-100 d-flex justify-content-center align-items-center" style="background: rgba(255,255,255,0.7); z-index: 10;">
                    <div class="text-center p-3 bg-white border rounded shadow-sm">
                        <i class="bi bi-globe fs-2 text-primary d-block mb-2"></i>
                        <strong>Public Election</strong><br>
                        <small class="text-muted">All registered voters can participate.</small>
                    </div>
                </div>
                <table class="table table-hover align-middle mb-4 position-relative">
                    <thead class="table-light">
                        <tr>
                            <th style="width: 50px;">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="selectAll">
                                </div>
                            </th>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${voters}" var="voter">
                            <tr>
                                <td>
                                    <div class="form-check">
                                        <input class="form-check-input voter-checkbox" type="checkbox" name="voterIds" value="${voter.id}" 
                                            ${eligibleVoterIds.contains(voter.id) ? 'checked' : ''}>
                                    </div>
                                </td>
                                <td>${voter.id}</td>
                                <td><strong>${voter.name}</strong></td>
                                <td>${voter.email}</td>
                                <td>
                                    <span class="badge ${voter.status == 'APPROVED' ? 'bg-success' : 'bg-warning text-dark'}">${voter.status}</span>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty voters}">
                            <tr><td colspan="5" class="text-center py-4 text-muted">No voters found in the system.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            
            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                <button type="submit" class="btn btn-primary px-4"><i class="bi bi-save me-1"></i> Save Permissions</button>
            </div>
        </form>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const selectAll = document.getElementById('selectAll');
    const checkboxes = document.querySelectorAll('.voter-checkbox');
    
    // Check 'Select All' if all are initially checked
    if (checkboxes.length > 0 && document.querySelectorAll('.voter-checkbox:checked').length === checkboxes.length) {
        selectAll.checked = true;
    }

    selectAll.addEventListener('change', function() {
        checkboxes.forEach(cb => cb.checked = selectAll.checked);
    });
    
    checkboxes.forEach(cb => {
        cb.addEventListener('change', function() {
            if (!this.checked) selectAll.checked = false;
            else if (document.querySelectorAll('.voter-checkbox:checked').length === checkboxes.length) selectAll.checked = true;
        });
    });
    // Privacy Toggle Logic
    const typePublic = document.getElementById('typePublic');
    const typePrivate = document.getElementById('typePrivate');
    const voterListContainer = document.getElementById('voterListContainer');
    const publicOverlay = document.getElementById('publicOverlay');

    function updateView() {
        if (typePublic.checked) {
            voterListContainer.classList.add('opacity-50');
            publicOverlay.classList.remove('d-none');
            // Disable checkboxes so they aren't submitted or clicked
            checkboxes.forEach(cb => cb.disabled = true);
            selectAll.disabled = true;
        } else {
            voterListContainer.classList.remove('opacity-50');
            publicOverlay.classList.add('d-none');
            // Enable checkboxes
            checkboxes.forEach(cb => cb.disabled = false);
            selectAll.disabled = false;
        }
    }

    typePublic.addEventListener('change', updateView);
    typePrivate.addEventListener('change', updateView);
    
    // Initial call
    updateView();
});
</script>

<jsp:include page="/jsp/common/footer.jsp" />
