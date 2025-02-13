<%@ taglib prefix = "c" uri = "http://java.sun.com/jsp/jstl/core" %>
<%@ page import="org.mskcc.cbio.portal.util.GlobalProperties" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="org.json.simple.JSONObject" %>

<%
    String url = request.getRequestURL().toString();
    String baseUrl = url.substring(0, url.length() - request.getRequestURI().length()) + request.getContextPath();
    baseUrl = baseUrl.replace("https://", "").replace("http://", "");
    response.setHeader("Referrer-Policy", "origin-when-cross-origin");
    
    // to support posted query data (when data would exceed URL length)
    // write all post params to json on page where it can be consumed
    String paramsJsonString = "null";
    if (request.getMethod().equals("POST")) {
        Enumeration enumeration = request.getParameterNames();
        JSONObject paramsJson = new JSONObject();
        while (enumeration.hasMoreElements()) {
            String parameterName = (String) enumeration.nextElement();
            paramsJson.put(parameterName, request.getParameter(parameterName));
        }
        paramsJsonString = paramsJson.toString();
    }
    
%>


<!DOCTYPE html>
<html class="cbioportal-frontend">
<head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8"/>
        
    <c:if test = "${GlobalProperties.showSitemaps()==false}">
       <meta name="robots" content="noindex" />
    </c:if>
    
    <link rel="icon" href="/images/cbioportal_icon.png"/>
    <title>Fudan Data Portal for Cancer Genomics</title>
    
    <script>
        
        var postData = <%=paramsJsonString%>;
        
        window.frontendConfig = {
            configurationServiceUrl:"//" + '<%=baseUrl%>' +  "/config_service.jsp",
            appVersion:'<%=GlobalProperties.getAppVersion()%>',
            apiRoot: '//'+ '<%=baseUrl%>/', 
            baseUrl: '<%=baseUrl%>',
            basePath: '<%=request.getContextPath()%>',  
        };
        
        <%-- write configuration to page so we do not have to load it via service--%>
        <%@include file="./config_service.jsp" %>
        
        if (/localdev=true/.test(window.location.href)) {
            localStorage.setItem("localdev", "true");
        }
        if (/localdist=true/.test(window.location.href)) {
            localStorage.setItem("localdist", "true");
        }
        window.localdev = localStorage.localdev === 'true';
        window.localdist = localStorage.localdist === 'true';
        window.netlify = localStorage.netlify;
        
        if (window.localdev || window.localdist) {
            window.frontendConfig.frontendUrl = "//localhost:3000/"
            localStorage.setItem("e2etest", "true");
        } else if (window.netlify) {
            window.frontendConfig.frontendUrl = ['//',localStorage.netlify,'.netlify.app','/'].join('');
            localStorage.setItem("e2etest", "true");
        } else if('<%=GlobalProperties.getFrontendUrl()%>'){
            window.frontendConfig.frontendUrl = '<%=GlobalProperties.getFrontendUrl()%>';
        }

        if(!window.frontendConfig.frontendUrl) {
            window.frontendConfig.frontendUrl = '//' + '<%=baseUrl%>/';
        }

    </script>
     
    <script type="text/javascript" src="//<%=baseUrl%>/js/src/load-frontend.js?<%=GlobalProperties.getAppVersion()%>"></script>
          
    <script>
        window.frontendConfig.customTabs && window.frontendConfig.customTabs.forEach(function(tab){
            if (tab.pathsToJs) {
                tab.pathsToJs.forEach(function(src){
                    document.write('<scr'+'ipt type="text/javascript" src="'+ src +'"></sc'+'ript>');
                });
            }
        });
    </script>

    <script>
        loadAppStyles(window.frontendConfig);
    </script>
    
    <%@include file="./tracking_include.jsp" %>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.css" rel="stylesheet" />

</head>

<body>
    <script>
        loadReactApp(window.frontendConfig);
    </script>

    <div id="reactRoot"></div>
    <script>
        var _hmt = _hmt || [];
        (function() {
          var hm = document.createElement("script");
          hm.src = "https://hm.baidu.com/hm.js?aab9f43048b3553eabfd8eb96ec00360";
          var s = document.getElementsByTagName("script")[0]; 
          s.parentNode.insertBefore(hm, s);
        })();
    </script>
    <script>
      window.addEventListener('message', (event) => {
        const data = event.data;

        function interceptClickEvent(e) {
            var target = e.target || e.srcElement;
            if (target.tagName === 'A') {
                let url = new URL(target.getAttribute('href'));
        
                //put your logic here...
                if (url.hostname == 'data.3steps.cn') {
                    target.setAttribute('target', '_self');
                    console.log('interceptClickEvent: ', target)
                } else {
                    target.setAttribute('target', '_blank')
                    console.log('interceptClickEvent(Set _blank): ', target)
                }
            }
        };

        if (data.hideHeader) {
          let style = '.cbioportal-frontend .pageTopContainer { display: none !important; }'; 
          var css = document.createElement('style'); 
          css.type = 'text/css'; 
          css.appendChild(document.createTextNode(style)); 
          document.head.appendChild(css);

          //listen for link click events at the document level
          if (document.addEventListener) {
            document.addEventListener('click', interceptClickEvent);
          } else if (document.attachEvent) {
            document.attachEvent('onclick', interceptClickEvent);
          }
        }
      });
    </script>        
</body>
</html>