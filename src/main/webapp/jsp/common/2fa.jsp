<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:if test="${empty sessionScope.tempUser}">
    <c:redirect url="/auth?action=login"/>
</c:if>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Two-Factor Authentication - Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .auth-container {
            max-width: 400px;
            margin: 50px auto;
            padding: 30px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <jsp:include page="/jsp/common/header.jsp" />

    <div class="auth-container">
        <h2>Two-Factor Authentication</h2>
        <p>Please enter the 6-digit code from your authenticator app.</p>
        
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/verify-2fa" method="POST">
            <div class="form-group">
                <label for="code">Authentication Code</label>
                <input type="text" id="code" name="code" class="form-control" placeholder="123456" required autocomplete="off" autofocus maxlength="6">
            </div>
            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 15px;">Verify</button>
        </form>
    </div>

    <jsp:include page="/jsp/common/footer.jsp" />
</body>
</html>
