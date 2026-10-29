<jsp:include page="/jsp/common/header.jsp" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="mb-4">
    <a href="javascript:history.back()" class="btn btn-outline-secondary btn-sm mb-3">
        <i class="bi bi-arrow-left"></i> Back
    </a>
    <h2 class="fw-bold m-0">Election Results</h2>
    <p class="text-muted"><strong>${election.title}</strong> - Status: <span class="badge bg-secondary">${election.status}</span></p>
</div>

<div class="row">
    <!-- Summary Panel -->
    <div class="col-lg-4 mb-4">
        <div class="card h-100 shadow-sm border-0">
            <div class="card-body">
                <h5 class="fw-bold mb-4">Summary</h5>
                <div class="d-flex align-items-center mb-3">
                    <div class="flex-shrink-0 bg-primary bg-opacity-10 text-primary rounded p-3 me-3">
                        <i class="bi bi-people-fill fs-3"></i>
                    </div>
                    <div>
                        <p class="text-muted mb-0 small">Total Votes Cast</p>
                        <h3 class="fw-bold mb-0">${totalVotes}</h3>
                    </div>
                </div>
                
                <h6 class="fw-bold mt-4 mb-3">Leaderboard</h6>
                <ul class="list-group list-group-flush">
                    <c:set var="maxVotes" value="-1" />
                    <c:set var="winner" value="" />
                    
                    <c:forEach items="${candidates}" var="candidate">
                        <c:set var="votes" value="${voteCounts[candidate.id] != null ? voteCounts[candidate.id] : 0}" />
                        <c:set var="percentage" value="${totalVotes > 0 ? (votes * 100.0 / totalVotes) : 0}" />
                        
                        <c:choose>
                            <c:when test="${votes > maxVotes}">
                                <c:set var="maxVotes" value="${votes}" />
                                <c:set var="winner" value="${candidate.name}" />
                            </c:when>
                            <c:when test="${votes == maxVotes && maxVotes > 0}">
                                <c:set var="winner" value="${winner}, ${candidate.name}" />
                            </c:when>
                        </c:choose>

                        <li class="list-group-item px-0 py-3">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <span class="fw-medium text-truncate" style="max-width: 150px;">${candidate.name}</span>
                                <span class="badge bg-primary rounded-pill">${votes} votes</span>
                            </div>
                            <div class="progress" style="height: 8px;">
                                <div class="progress-bar" role="progressbar" style="width: ${percentage}%;" aria-valuenow="${percentage}" aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                            <div class="text-end mt-1"><small class="text-muted"><fmt:formatNumber type="number" minFractionDigits="1" maxFractionDigits="1" value="${percentage}"/>%</small></div>
                        </li>
                    </c:forEach>
                    <c:if test="${empty candidates}">
                        <li class="list-group-item text-center text-muted">No candidates found.</li>
                    </c:if>
                </ul>
                
                <c:if test="${totalVotes > 0 && maxVotes > 0}">
                    <div class="alert alert-success mt-4 mb-0">
                        <i class="bi bi-trophy-fill me-2"></i> Leading/Winner: <strong>${winner}</strong>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
    
    <!-- Charts -->
    <div class="col-lg-8">
        <div class="row">
            <div class="col-md-6 mb-4">
                <div class="card shadow-sm border-0 h-100">
                    <div class="card-body">
                        <h6 class="fw-bold mb-3 text-center">Vote Distribution (Pie)</h6>
                        <canvas id="pieChart" style="max-height: 300px;"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-6 mb-4">
                <div class="card shadow-sm border-0 h-100">
                    <div class="card-body">
                        <h6 class="fw-bold mb-3 text-center">Vote Distribution (Bar)</h6>
                        <canvas id="barChart" style="max-height: 300px;"></canvas>
                    </div>
                </div>
            </div>
        </div>
        
        <c:if test="${sessionScope.user.role == 'ADMIN'}">
            <div class="card shadow-sm border-0 d-print-none">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <h6 class="mb-0 text-muted"><i class="bi bi-file-earmark-pdf me-2"></i> Publish Result Report</h6>
                    <button class="btn btn-outline-danger btn-sm" onclick="window.print()">
                        <i class="bi bi-printer me-1"></i> Print / Save as PDF
                    </button>
                </div>
            </div>
        </c:if>
    </div>
</div>

<!-- Print Styles -->
<style>
    @media print {
        .d-print-none, header, footer, .btn, .navbar {
            display: none !important;
        }
        body {
            background-color: white;
            color: black;
            padding: 20px;
        }
        .card {
            border: 1px solid #ccc !important;
            box-shadow: none !important;
            margin-bottom: 20px;
        }
        h2 { text-align: center; margin-bottom: 30px; border-bottom: 2px solid black; padding-bottom: 10px; }
        .badge { color: black !important; background-color: transparent !important; border: 1px solid black; }
        #pieChart, #barChart { max-height: 200px !important; }
    }
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const bgColors = [
        'rgba(99, 102, 241, 0.7)', 'rgba(16, 185, 129, 0.7)',
        'rgba(245, 158, 11, 0.7)', 'rgba(239, 68, 68, 0.7)',
        'rgba(139, 92, 246, 0.7)', 'rgba(14, 165, 233, 0.7)'
    ];

    let pieChart, barChart;

    function initCharts(labels, data) {
        // Pie Chart
        const pieCtx = document.getElementById('pieChart').getContext('2d');
        pieChart = new Chart(pieCtx, {
            type: 'doughnut',
            data: { labels: labels, datasets: [{ data: data, backgroundColor: bgColors, borderWidth: 1 }] },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom' } } }
        });

        // Bar Chart
        const barCtx = document.getElementById('barChart').getContext('2d');
        barChart = new Chart(barCtx, {
            type: 'bar',
            data: { labels: labels, datasets: [{ label: 'Votes', data: data, backgroundColor: bgColors[0], borderRadius: 4 }] },
            options: { responsive: true, maintainAspectRatio: false, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }, plugins: { legend: { display: false } } }
        });
    }

    // Initial render from JSP data
    const initialLabels = [];
    const initialData = [];
    <c:forEach items="${candidates}" var="candidate">
        initialLabels.push("${candidate.name}");
        initialData.push(${voteCounts[candidate.id] != null ? voteCounts[candidate.id] : 0});
    </c:forEach>
    initCharts(initialLabels, initialData);

    // Live Polling every 5 seconds
    setInterval(async () => {
        try {
            const response = await fetch(`${pageContext.request.contextPath}/api/analytics/live?electionId=${election.id}`);
            if (response.ok) {
                const result = await response.json();
                
                const newLabels = result.candidates.map(c => c.name);
                const newData = result.candidates.map(c => c.votes);

                // Update charts
                pieChart.data.labels = newLabels;
                pieChart.data.datasets[0].data = newData;
                pieChart.update();

                barChart.data.labels = newLabels;
                barChart.data.datasets[0].data = newData;
                barChart.update();

                // Update DOM total votes
                document.querySelector('h3.fw-bold').innerText = result.totalVotes;
            }
        } catch (e) {
            console.error('Error fetching live analytics:', e);
        }
    }, 5000);
});
</script>

<jsp:include page="/jsp/common/footer.jsp" />
