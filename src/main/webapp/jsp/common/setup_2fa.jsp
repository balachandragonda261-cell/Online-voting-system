<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/auth?action=login"/>
</c:if>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Set Up 2FA - Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .auth-container {
            max-width: 500px;
            margin: 50px auto;
            padding: 30px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
        }
        .qr-code {
            margin: 20px 0;
            padding: 10px;
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <jsp:include page="/jsp/common/header.jsp" />

    <div class="auth-container">
        <h2>Set Up Two-Factor Authentication</h2>
        <p>1. Download <b>Google Authenticator</b> or Authy on your phone.</p>
        <p>2. Scan the QR code below.</p>
        
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <c:if test="${not empty qrCodeUri}">
            <img src="${qrCodeUri}" alt="QR Code" class="qr-code" width="200" height="200"/>
        </c:if>
        
        <p>If you can't scan it, enter this secret manually: <br><strong>${secret}</strong></p>

        <p>3. Enter the 6-digit code to confirm.</p>
        <form action="${pageContext.request.contextPath}/setup-2fa" method="POST" style="text-align:left;">
            <div class="form-group">
                <label for="code">Authentication Code</label>
                <input type="text" id="code" name="code" class="form-control" placeholder="123456" required autocomplete="off" autofocus maxlength="6">
            </div>
            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 15px;">Enable 2FA</button>
        </form>
    </div>

    <jsp:include page="/jsp/common/footer.jsp" />
</body>
</html>
