#!/usr/bin/env kscript

import io.ktor.client.HttpClient
import io.ktor.client.call.call
import io.ktor.client.request.header
import io.ktor.client.response.readBytes
import io.ktor.http.HttpMethod
import kotlinx.coroutines.runBlocking

//DEPS io.ktor:ktor-client-core:1.2.5 io.ktor:ktor-client-apache:1.2.5

// working example without kscript and without deps
//#!/usr/bin/env java -jar /usr/local/Cellar/kotlin/1.3.50/libexec/lib/kotlin-compiler.jar -script

// wait for kotlin 1.3.60 to fix issue with missing runtime in scripts
//#!/usr/bin/env kotlinc -script

val client = HttpClient()

@UseExperimental(ExperimentalStdlibApi::class)
suspend fun getIP(): String = client.call("https://myip.is") {
    method = HttpMethod.Get
}.response.readBytes().decodeToString()

runBlocking { println(getIP()) }
