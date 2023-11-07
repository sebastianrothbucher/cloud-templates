package sebastianrothbucher.controller

import jakarta.servlet.http.HttpServletRequest
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class DemoController {

    @GetMapping(value = arrayOf("/one"), produces = arrayOf("text/plain"))
    fun one(): String {
        return "one";
    }

    @GetMapping("/two")
    fun two(): Map<String, String> {
        return mapOf("content" to  "two");
    }

    @GetMapping(value = arrayOf("/three", "/three/**"))
    fun three(req: HttpServletRequest): Map<String, Any> {
        return mapOf(
            "method" to req.method,
            "path" to req.requestURI,
            "headers" to req.headerNames.toList().map { it to req.getHeader(it) }.toMap(),
            "query" to req.queryString,
        );
    }

}