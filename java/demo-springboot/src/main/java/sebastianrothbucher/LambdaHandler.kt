package sebastianrothbucher

import com.amazonaws.serverless.exceptions.ContainerInitializationException
import com.amazonaws.serverless.proxy.model.AwsProxyResponse
import com.amazonaws.serverless.proxy.spring.SpringBootLambdaContainerHandler
import com.amazonaws.serverless.proxy.spring.SpringBootProxyHandlerBuilder
import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestStreamHandler
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream

class LambdaHandler : RequestStreamHandler {

    private var handler: SpringBootLambdaContainerHandler<Any, AwsProxyResponse>? = null

    @Throws(ContainerInitializationException::class)
    constructor() {
        handler = SpringBootProxyHandlerBuilder<Any>()
                .defaultProxy()
                .asyncInit()
                .springBootApplication(Application::class.java)
                .buildAndInitialize()
    }

    @Throws(IOException::class)
    override fun handleRequest(inputStream: InputStream?, outputStream: OutputStream?, context: Context?) {
        handler!!.proxyStream(inputStream, outputStream, context)
    }
}