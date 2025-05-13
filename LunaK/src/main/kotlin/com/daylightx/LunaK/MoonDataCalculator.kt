package com.daylightx.LunaK

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.encodeToString
import java.time.Instant
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import kotlin.math.*

/**
 * Simplified Moon Data Calculator
 * Based on algorithms from "Astronomical Algorithms" by Jean Meeus
 */
class MoonDataCalculator private constructor(
    private val latitude: Double,
    private val longitude: Double,
    private val elevation: Double,
    private val instant: Instant
) {
    companion object {
        fun builder() = Builder()

        // Constants for calculations
        private const val LUNAR_MONTH = 29.530588
        private const val J2000 = 2451545.0
        private const val DEG_TO_RAD = PI / 180.0
        private const val RAD_TO_DEG = 180.0 / PI
    }

    fun toJson(): String {
        val data = calculateAllData()
        return Json {
            prettyPrint = true
            explicitNulls = false
        }.encodeToString(data)
    }

    private fun calculateAllData(): MoonData {
        val jd = julianDate(instant)
        val t = (jd - J2000) / 36525.0

        // Calculate moon position
        val moonPos = calculateMoonPosition(t)
        val horizontal = equatorialToHorizontal(moonPos.ra, moonPos.dec, jd)

        // Calculate phase
        val phase = calculateMoonPhase(jd)
        val phaseData = getPhaseData(phase)

        // Calculate distance (simplified)
        val distance = 384400.0 * (1 + 0.0549 * cos(moonPos.anomaly))

        // Calculate rise/set times (simplified)
        val riseSet = calculateRiseSetTimes(jd)

        return MoonData(
            requestTime = instant.toString(),
            location = Location(
                latitude = latitude,
                longitude = longitude,
                elevation = elevation
            ),
            position = Position(
                azimuth = horizontal.azimuth,
                altitude = horizontal.altitude,
                rightAscension = moonPos.ra,
                declination = moonPos.dec,
                constellation = getConstellation(moonPos.ra, moonPos.dec)
            ),
            phase = Phase(
                phaseAngle = phase,
                phaseName = phaseData.name,
                illuminatedFraction = phaseData.illumination,
                illuminatedPercentage = phaseData.illumination * 100
            ),
            distance = Distance(
                kilometers = distance,
                astronomicalUnits = distance / 149597870.7,
                angularDiameterArcminutes = 2 * atan(1737.4 / distance) * RAD_TO_DEG * 60
            ),
            libration = LibrationData(
                longitude = 0.0, // Simplified
                latitude = 0.0,
                distance = distance
            ),
            times = Times(
                nextRise = riseSet.rise,
                nextSet = riseSet.set,
                nextTransit = null // Simplified
            ),
            ecliptic = EclipticCoordinates(
                longitude = 0.0, // Simplified
                latitude = 0.0
            ),
            visibility = if (horizontal.altitude > 0) "Above horizon" else "Below horizon"
        )
    }

    private fun julianDate(instant: Instant): Double {
        val epochSeconds = instant.epochSecond
        val epochDays = epochSeconds / 86400.0
        return epochDays + 2440587.5
    }

    private fun calculateMoonPosition(t: Double): MoonPosition {
        // Simplified moon position calculation
        val l = (218.316 + 481267.881 * t) % 360.0 // Mean longitude
        val m = (134.963 + 477198.867 * t) % 360.0 // Mean anomaly
        val f = (93.272 + 483202.017 * t) % 360.0  // Argument of latitude

        // Simplified longitude calculation
        val longitude = l + 6.289 * sin(m * DEG_TO_RAD)

        // Simplified right ascension and declination
        val ra = longitude / 15.0 // Hours
        val dec = 23.45 * sin(longitude * DEG_TO_RAD) // Degrees

        return MoonPosition(ra, dec, m * DEG_TO_RAD)
    }

    private fun equatorialToHorizontal(ra: Double, dec: Double, jd: Double): HorizontalCoordinates {
        val lst = localSiderealTime(jd)
        val ha = (lst - ra) * 15.0 * DEG_TO_RAD

        val decRad = dec * DEG_TO_RAD
        val latRad = latitude * DEG_TO_RAD

        val altitude = asin(sin(decRad) * sin(latRad) + cos(decRad) * cos(latRad) * cos(ha))
        val azimuth = atan2(
            sin(ha),
            cos(ha) * sin(latRad) - tan(decRad) * cos(latRad)
        )

        return HorizontalCoordinates(
            azimuth = ((azimuth * RAD_TO_DEG + 180.0) % 360.0),
            altitude = altitude * RAD_TO_DEG
        )
    }

    private fun localSiderealTime(jd: Double): Double {
        val t = (jd - J2000) / 36525.0
        var lst = 280.46061837 + 360.98564736629 * (jd - J2000) + t * t * (0.000387933 - t / 38710000)
        lst = (lst + longitude) % 360.0
        return lst / 15.0 // Convert to hours
    }

    private fun calculateMoonPhase(jd: Double): Double {
        val t = (jd - J2000) / 36525.0
        val d = jd - J2000

        // Simplified phase calculation
        val phaseDay = (d % LUNAR_MONTH) / LUNAR_MONTH
        return phaseDay * 360.0
    }

    private fun getPhaseData(phase: Double): PhaseInfo {
        val normalizedPhase = phase % 360.0
        val illumination = (1 + cos((normalizedPhase - 180.0) * DEG_TO_RAD)) / 2.0

        val name = when (normalizedPhase) {
            in 0.0..11.25, in 348.75..360.0 -> "New Moon"
            in 11.25..78.75 -> "Waxing Crescent"
            in 78.75..101.25 -> "First Quarter"
            in 101.25..168.75 -> "Waxing Gibbous"
            in 168.75..191.25 -> "Full Moon"
            in 191.25..258.75 -> "Waning Gibbous"
            in 258.75..281.25 -> "Last Quarter"
            else -> "Waning Crescent"
        }

        return PhaseInfo(name, illumination)
    }

    private fun calculateRiseSetTimes(jd: Double): RiseSetTimes {
        // Very simplified - would need more complex calculations for accuracy
        val formatter = DateTimeFormatter.ISO_INSTANT
        val baseTime = instant.plusSeconds(6 * 3600) // Approximate

        return RiseSetTimes(
            rise = formatter.format(baseTime),
            set = formatter.format(baseTime.plusSeconds(12 * 3600))
        )
    }

    private fun getConstellation(ra: Double, dec: Double): String {
        // Simplified constellation determination
        return when {
            ra < 2 -> "Pisces"
            ra < 4 -> "Aries"
            ra < 6 -> "Taurus"
            ra < 8 -> "Gemini"
            ra < 10 -> "Cancer"
            ra < 12 -> "Leo"
            ra < 14 -> "Virgo"
            ra < 16 -> "Libra"
            ra < 18 -> "Scorpius"
            ra < 20 -> "Sagittarius"
            ra < 22 -> "Capricornus"
            else -> "Aquarius"
        }
    }

    class Builder {
        private var latitude: Double? = null
        private var longitude: Double? = null
        private var elevation: Double = 0.0
        private var instant: Instant = Instant.now()

        fun latitude(lat: Double) = apply {
            require(lat in -90.0..90.0) { "Latitude must be between -90 and 90 degrees" }
            this.latitude = lat
        }

        fun longitude(lon: Double) = apply {
            require(lon in -180.0..180.0) { "Longitude must be between -180 and 180 degrees" }
            this.longitude = lon
        }

        fun elevation(meters: Double) = apply {
            this.elevation = meters
        }

        fun time(instant: Instant) = apply {
            this.instant = instant
        }

        fun time(zonedDateTime: ZonedDateTime) = apply {
            this.instant = zonedDateTime.toInstant()
        }

        fun now() = apply {
            this.instant = Instant.now()
        }

        fun build(): MoonDataCalculator {
            requireNotNull(latitude) { "Latitude must be specified" }
            requireNotNull(longitude) { "Longitude must be specified" }

            return MoonDataCalculator(
                latitude = latitude!!,
                longitude = longitude!!,
                elevation = elevation,
                instant = instant
            )
        }
    }
}

// Data classes for calculations
private data class MoonPosition(val ra: Double, val dec: Double, val anomaly: Double)
private data class HorizontalCoordinates(val azimuth: Double, val altitude: Double)
private data class PhaseInfo(val name: String, val illumination: Double)
private data class RiseSetTimes(val rise: String, val set: String)

// Data classes for JSON serialization
@Serializable
data class MoonData(
    val requestTime: String,
    val location: Location,
    val position: Position,
    val phase: Phase,
    val distance: Distance,
    val libration: LibrationData,
    val times: Times,
    val ecliptic: EclipticCoordinates,
    val visibility: String
)

@Serializable
data class Location(
    val latitude: Double,
    val longitude: Double,
    val elevation: Double
)

@Serializable
data class Position(
    val azimuth: Double,
    val altitude: Double,
    val rightAscension: Double,
    val declination: Double,
    val constellation: String
)

@Serializable
data class Phase(
    val phaseAngle: Double,
    val phaseName: String,
    val illuminatedFraction: Double,
    val illuminatedPercentage: Double
)

@Serializable
data class Distance(
    val kilometers: Double,
    val astronomicalUnits: Double,
    val angularDiameterArcminutes: Double
)

@Serializable
data class LibrationData(
    val longitude: Double,
    val latitude: Double,
    val distance: Double
)

@Serializable
data class Times(
    val nextRise: String?,
    val nextSet: String?,
    val nextTransit: String?
)

@Serializable
data class EclipticCoordinates(
    val longitude: Double,
    val latitude: Double
)
