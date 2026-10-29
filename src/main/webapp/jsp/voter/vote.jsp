<jsp:include page="/jsp/common/header.jsp" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="mb-4">
    <a href="${pageContext.request.contextPath}/voter/dashboard" class="btn btn-outline-secondary btn-sm mb-3">
        <i class="bi bi-arrow-left"></i> Back to Dashboard
    </a>
    <div class="text-center">
        <h2 class="fw-bold mb-2">${election.title}</h2>
        <p class="text-muted">${election.description}</p>
        <div class="alert alert-warning d-inline-block py-2">
            <i class="bi bi-exclamation-triangle me-2"></i> <strong>Important:</strong> You can only vote once. Please choose your candidate carefully.
        </div>
    </div>
</div>

<form action="${pageContext.request.contextPath}/voter/vote" method="post" id="voteForm">
    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
    <input type="hidden" name="action" value="castVote">
    <input type="hidden" name="electionId" value="${election.id}">
    
    <div class="row justify-content-center">
        <c:forEach items="${candidates}" var="candidate">
            <div class="col-md-6 col-lg-4 mb-4">
                <label class="card h-100 w-100 cursor-pointer" style="cursor: pointer;">
                    <input type="radio" name="candidateId" value="${candidate.id}" class="d-none" required onchange="highlightSelected(this)">
                    <div class="card-body text-center candidate-card border border-2 border-transparent rounded h-100 transition-all">
                        <img src="${pageContext.request.contextPath}${candidate.photoUrl}" alt="${candidate.name}" class="rounded-circle mb-3 shadow-sm" width="120" height="120" style="object-fit: cover;">
                        <h4 class="card-title fw-bold">${candidate.name}</h4>
                        <p class="card-text text-muted small mb-3">${candidate.manifesto}</p>
                        <div class="mt-auto">
                            <span class="btn btn-outline-primary w-100 select-btn">Select Candidate</span>
                        </div>
                    </div>
                </label>
            </div>
        </c:forEach>
    </div>

    <div class="text-center mt-4 mb-5">
        <button type="button" class="btn btn-primary btn-lg px-5 py-3 shadow-sm" id="preSubmitVoteBtn" disabled onclick="startBiometricScan()">
            <i class="bi bi-camera-video me-2"></i> Verify Identity & Vote
        </button>
        <!-- Hidden actual submit button -->
        <button type="submit" id="submitVoteBtn" class="d-none"></button>
    </div>
</form>

<!-- Biometric Verification Modal -->
<div class="modal fade" id="biometricModal" tabindex="-1" data-bs-backdrop="static" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0 shadow-lg" style="background-color: var(--card-bg);">
      <div class="modal-header bg-dark text-white border-0">
        <h5 class="modal-title"><i class="bi bi-person-bounding-box me-2"></i> Biometric KYC Verification</h5>
      </div>
      <div class="modal-body text-center p-5">
        <div id="scannerUI" style="position: relative; width: 200px; height: 200px; margin: 0 auto; border: 4px solid var(--primary-color); border-radius: 50%; overflow: hidden;" class="mb-4 shadow">
            <!-- Simulated Camera Feed -->
            <img src="https://ui-avatars.com/api/?name=${sessionScope.user.name}&background=random&size=200" alt="Face Feed" style="width: 100%; height: 100%; opacity: 0.8; filter: grayscale(50%);">
            
            <!-- Scanning Laser Animation -->
            <div id="scanLaser" style="position: absolute; top: 0; left: 0; width: 100%; height: 4px; background-color: #10b981; box-shadow: 0 0 10px #10b981; animation: scan 2s infinite ease-in-out;"></div>
        </div>
        <h4 id="scanStatus" class="fw-bold text-primary mb-2">Analyzing Facial Vectors...</h4>
        <p id="scanSubtext" class="text-muted small">Please look directly at the camera.</p>
        
        <div class="progress mt-4" style="height: 10px;">
          <div id="scanProgress" class="progress-bar progress-bar-striped progress-bar-animated bg-success" role="progressbar" style="width: 0%"></div>
        </div>
      </div>
    </div>
  </div>
</div>

<style>
    @keyframes scan {
        0%, 100% { top: 0; opacity: 0; }
        10% { opacity: 1; }
        50% { top: 100%; }
        90% { opacity: 1; }
    }
</style>

<script>
    function highlightSelected(radio) {
        // Reset all
        document.querySelectorAll('.candidate-card').forEach(card => {
            card.classList.remove('border-primary', 'bg-light');
            card.querySelector('.select-btn').classList.remove('btn-primary', 'text-white');
            card.querySelector('.select-btn').classList.add('btn-outline-primary');
            card.querySelector('.select-btn').innerText = 'Select Candidate';
        });

        // Highlight selected
        if (radio.checked) {
            const card = radio.nextElementSibling;
            card.classList.add('border-primary');
            card.querySelector('.select-btn').classList.remove('btn-outline-primary');
            card.querySelector('.select-btn').classList.add('btn-primary', 'text-white');
            card.querySelector('.select-btn').innerText = 'Selected';
            
            document.getElementById('preSubmitVoteBtn').disabled = false;
        }
    }

    function startBiometricScan() {
        const modal = new bootstrap.Modal(document.getElementById('biometricModal'));
        modal.show();

        const status = document.getElementById('scanStatus');
        const subtext = document.getElementById('scanSubtext');
        const progressBar = document.getElementById('scanProgress');
        const laser = document.getElementById('scanLaser');

        setTimeout(() => {
            progressBar.style.width = '35%';
            status.innerText = "Extracting Features...";
        }, 1000);

        setTimeout(() => {
            progressBar.style.width = '70%';
            status.innerText = "Matching with Database...";
            subtext.innerText = "Cross-referencing National ID hash...";
        }, 2500);

        setTimeout(() => {
            progressBar.style.width = '100%';
            laser.style.display = 'none';
            document.getElementById('scannerUI').style.borderColor = '#10b981';
            
            status.classList.remove('text-primary');
            status.classList.add('text-success');
            status.innerHTML = '<i class="bi bi-check-circle-fill"></i> Identity Verified';
            subtext.innerText = "Authorized to cast vote.";
            
            // Actually submit the form after successful "verification"
            setTimeout(() => {
                document.getElementById('submitVoteBtn').click();
            }, 1000);
            
        }, 4000);
    }
</script>

<jsp:include page="/jsp/common/footer.jsp" />
