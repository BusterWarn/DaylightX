package com.daylightx.LunaK

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.time.Instant

@SpringBootApplication
class LunaKApplication

fun main(args: Array<String>) {
    runApplication<LunaKApplication>(*args)
}

@RestController
class MoonController {

    @GetMapping("/")
    fun home(): Map<String, Any> {
        return mapOf(
            "service" to "LunaK Moon Data API",
            "version" to "1.0.0",
            "description" to "A comprehensive astronomical API that calculates real-time moon position, phase, and other lunar data for any location on Earth",
            "endpoints" to mapOf(
                "/" to "This documentation",
                "/moon" to "Calculate moon data for specific coordinates and time"
            ),
            "usage" to mapOf(
                "endpoint" to "/moon",
                "method" to "GET",
                "parameters" to listOf(
                    mapOf(
                        "name" to "latitude",
                        "type" to "double",
                        "required" to true,
                        "description" to "Latitude in decimal degrees (-90 to 90)",
                        "example" to 59.3293
                    ),
                    mapOf(
                        "name" to "longitude",
                        "type" to "double",
                        "required" to true,
                        "description" to "Longitude in decimal degrees (-180 to 180)",
                        "example" to 18.0686
                    ),
                    mapOf(
                        "name" to "time",
                        "type" to "string",
                        "required" to true,
                        "description" to "ISO 8601 timestamp (UTC)",
                        "example" to "2024-01-15T12:00:00Z"
                    ),
                    mapOf(
                        "name" to "elevation",
                        "type" to "double",
                        "required" to false,
                        "default" to 0.0,
                        "description" to "Elevation in meters above sea level",
                        "example" to 100.0
                    )
                )
            ),
            "examples" to listOf(
                mapOf(
                    "description" to "Current moon data for Stockholm",
                    "url" to "/moon?latitude=59.3293&longitude=18.0686&time=2024-01-15T12:00:00Z"
                ),
                mapOf(
                    "description" to "Moon data for NYC with elevation",
                    "url" to "/moon?latitude=40.7128&longitude=-74.0060&time=2024-01-15T12:00:00Z&elevation=10"
                ),
                mapOf(
                    "description" to "Moon data for Tokyo",
                    "url" to "/moon?latitude=35.6762&longitude=139.6503&time=2024-12-25T00:00:00Z"
                )
            ),
            "response_format" to mapOf(
                "description" to "JSON object containing comprehensive moon data",
                "fields" to listOf(
                    "requestTime: The time used for calculations",
                    "location: Coordinates and elevation",
                    "position: Azimuth, altitude, constellation",
                    "phase: Phase name and illumination percentage",
                    "distance: Distance in km and AU",
                    "libration: Lunar libration data",
                    "times: Next rise/set/transit times",
                    "ecliptic: Ecliptic coordinates",
                    "visibility: Current visibility status"
                )
            ),
            "sample_response" to mapOf(
                "requestTime" to "2024-01-15T12:00:00Z",
                "location" to mapOf(
                    "latitude" to 59.3293,
                    "longitude" to 18.0686,
                    "elevation" to 0.0
                ),
                "position" to mapOf(
                    "azimuth" to 235.67,
                    "altitude" to 42.3,
                    "constellation" to "Libra"
                ),
                "phase" to mapOf(
                    "phaseName" to "Waxing Gibbous",
                    "illuminatedPercentage" to 75.0
                ),
                "distance" to mapOf(
                    "kilometers" to 380000.0
                ),
                "visibility" to "Above horizon"
            ),
            "notes" to listOf(
                "All times are in UTC",
                "Azimuth: 0°=North, 90°=East, 180°=South, 270°=West",
                "Altitude: positive=above horizon, negative=below horizon",
                "Based on astronomical calculations by cosinekitty/astronomy library"
            ),
            "contact" to "support@daylightx.com"
        )
    }

    @GetMapping("/moon")
    fun calculateMoonData(
        @RequestParam latitude: Double,
        @RequestParam longitude: Double,
        @RequestParam time: String,
        @RequestParam(required = false, defaultValue = "0.0") elevation: Double
    ): String {
        return try {
            val instant = Instant.parse(time)
            MoonDataCalculator.builder()
                .latitude(latitude)
                .longitude(longitude)
                .elevation(elevation)
                .time(instant)
                .build()
                .toJson()
        } catch (e: Exception) {
            """
            {
                "error": "Invalid parameters",
                "message": "${e.message}",
                "example": "/moon?latitude=59.3293&longitude=18.0686&time=2024-01-15T12:00:00Z"
            }
            """.trimIndent()
        }
    }
}
