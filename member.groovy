import groovy.json.JsonOutput
import groovy.json.JsonSlurper

/**
 * 通过调用接口获取的数据添加到header中
 * 选择onRequest
 */
def jsonSlurper = new JsonSlurper()
//  入参构建
def token = request.headers.getFirst("token")
def sourceType = request.headers.getFirst("sourceType")

def transactionId = request.headers.getFirst("X-Gravitee-Transaction-Id")
if (null != token) {
    try {
        def requestData = ["mebId": 0, "clientInfo": null, "token": token, "sourceType": sourceType]
        def queryUrl = "http://xxxx"

        URL url = new URL(queryUrl)
        HttpURLConnection connection = (HttpURLConnection) url.openConnection()
        connection.setConnectTimeout(1000)
        connection.setReadTimeout(500)
        connection.setRequestMethod("POST")
        connection.setRequestProperty("Content-Type", "application/json")
        connection.setRequestProperty("Transaction-Trace-Id", transactionId)
        connection.setDoOutput(true)
        connection.connect()

        def out = new DataOutputStream(connection.getOutputStream())
        out.writeBytes(JsonOutput.toJson(requestData))
        out.flush()
        out.close()
        def resp = connection.content.text;
        if (null != resp) {
            def respData = jsonSlurper.parseText(resp)
            if (null != respData && respData.code == 0) {
                request.headers.mid = Long.toString(respData.mebId)
            }
        }
    } catch (Exception e) {

    }
}

