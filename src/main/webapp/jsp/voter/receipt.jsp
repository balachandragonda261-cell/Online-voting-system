<jsp:include page="/jsp/common/header.jsp" />

<div class="row justify-content-center mt-5">
    <div class="col-md-8 col-lg-6">
        <div class="card border-success border-2 shadow-sm">
            <div class="card-body text-center p-5">
                <div class="mb-4">
                    <i class="bi bi-check-circle-fill text-success" style="font-size: 5rem;"></i>
                </div>
                <h2 class="fw-bold mb-3">Vote Cast Successfully!</h2>
                <p class="lead text-muted mb-4">Your vote has been securely recorded.</p>
                
                <div class="bg-light p-4 rounded mb-4 text-start">
                    <h6 class="text-uppercase text-muted fw-bold mb-2">Vote Receipt ID:</h6>
                    <code class="fs-5 text-dark" style="word-break: break-all;">${receiptHash}</code>
                    
                    <div class="text-center mt-3">
                        <img src="https://chart.googleapis.com/chart?chs=200x200&cht=qr&chl=${receiptHash}" alt="QR Code Receipt" class="img-fluid border rounded shadow-sm" />
                    </div>

                    <p class="small text-muted mt-3 mb-0 text-center"><i class="bi bi-info-circle me-1"></i> Please save this ID or scan the QR Code. It is uniquely generated for your vote and ensures it was securely recorded on the blockchain ledger.</p>
                </div>

                <a href="${pageContext.request.contextPath}/voter/dashboard" class="btn btn-primary btn-lg px-5">Return to Dashboard</a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
