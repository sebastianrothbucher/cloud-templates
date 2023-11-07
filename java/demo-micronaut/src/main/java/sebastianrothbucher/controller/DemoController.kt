package sebastianrothbucher.controller

import io.micronaut.http.HttpRequest
import io.micronaut.http.annotation.Controller
import io.micronaut.http.annotation.Get
import io.micronaut.http.annotation.PathVariable

@Controller
class DemoController {

    @Get(value = "/one", produces = arrayOf("text/plain"))
    fun one(): String {
        return "one";
    }

    @Get("/two")
    fun two(): Map<String, String> {
        return mapOf("content" to  "two");
    }

    @Get(uris = arrayOf("/three", "/three/{four}", "/three/{four}/{five}"))
    fun three(req: HttpRequest<Any>, @PathVariable four: String?, @PathVariable five: String?): Map<String, Any> {
        return mapOf(
            "method" to req.method,
            "path" to req.path,
            "headers" to req.headers.iterator().asSequence().toList().map { it.key to it.value }.toMap(),
            "query" to req.parameters.iterator().asSequence().toList().map { it.key to it.value }.toMap(),
        );
    }

}