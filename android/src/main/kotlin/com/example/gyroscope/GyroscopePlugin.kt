package com.example.gyroscope


import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.view.Surface
import android.view.WindowManager
//import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar
//import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlin.math.asin
import kotlin.math.atan2
import kotlin.math.sqrt


/** GyroscopePlugin */
class GyroscopePlugin: FlutterPlugin, MethodCallHandler {
  private val METHOD_CHANNEL_NAME = "gyroscope"
  private val GYROSCOPE_CHANNEL_NAME = "gyroscope/"

  private var sensorManager: SensorManager? = null
  private var methodChannel: MethodChannel? = null
  private var gyroscopeChannel: EventChannel? = null

  private var gyroScopeStreamHandler: StreamHandlerImpl? = null
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val plugin = GyroscopePlugin()
      plugin.setupEventChannels(registrar.context(), registrar.messenger())
    }
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "gyroscope")
    channel.setMethodCallHandler(this)
    val context = flutterPluginBinding.applicationContext
    setupEventChannels(context, flutterPluginBinding.binaryMessenger)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "isSensorAvailable" -> result.success(sensorManager!!.getSensorList(call.arguments as Int).isNotEmpty())
      "setSensorUpdateInterval" -> setSensorUpdateInterval(call.argument<Int>("interval")!!)
      "onCancleSensor" -> onCancleSensor(call.arguments)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    teardownEventChannels()
  }

  private fun teardownEventChannels() {
    methodChannel!!.setMethodCallHandler(null)
    gyroscopeChannel!!.setStreamHandler(null)
  }
  private fun setupEventChannels(context: Context, messenger: BinaryMessenger) {
    sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

    methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)
    methodChannel!!.setMethodCallHandler(this)
    gyroscopeChannel = EventChannel(messenger, GYROSCOPE_CHANNEL_NAME)
    gyroScopeStreamHandler = StreamHandlerImpl(sensorManager!!, Sensor.TYPE_GAME_ROTATION_VECTOR)
    gyroscopeChannel!!.setStreamHandler(gyroScopeStreamHandler!!)

  }
  private fun setSensorUpdateInterval(interval: Int) {
    gyroScopeStreamHandler!!.setUpdateInterval(interval)
  }
  private fun onCancleSensor(arguments: Any?) {
    gyroScopeStreamHandler!!.onCancel(arguments)
  }
}
class StreamHandlerImpl(private val sensorManager: SensorManager, sensorType: Int, private var interval: Int = SensorManager.SENSOR_DELAY_NORMAL) :
        EventChannel.StreamHandler, SensorEventListener {
  private val sensor = sensorManager.getDefaultSensor(sensorType)
  private var eventSink: EventChannel.EventSink? = null

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    if (sensor != null) {
      eventSink = events
      sensorManager.registerListener(this, sensor, interval)
    }
  }

  override fun onCancel(arguments: Any?) {
    sensorManager.unregisterListener(this)
    eventSink = null
  }

  override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {

  }

  override fun onSensorChanged(event: SensorEvent?) {
    event ?: return
    val sensorValues = rotateVector(event.values)
    eventSink?.success(sensorValues)
  }

  // BONUS
  private fun rotateVector(rotationVector: FloatArray): DoubleArray? {
    var q0: Double
    val q1 = rotationVector[0].toDouble()
    val q2 = rotationVector[1].toDouble()
    val q3 = rotationVector[2].toDouble()
    if (rotationVector.size >= 4) {
      q0 = rotationVector[3].toDouble()
    } else {
      q0 = 1 - q1 * q1 - q2 * q2 - q3 * q3
      q0 = if (q0 > 0) sqrt(q0) else 0.0
    }
    val sqQ1 = 2 * q1 * q1
    val sqQ2 = 2 * q2 * q2
    val sqQ3 = 2 * q3 * q3
    val q1Q2 = 2 * q1 * q2
    val q3Q0 = 2 * q3 * q0
    val q1Q3 = 2 * q1 * q3
    val q2Q0 = 2 * q2 * q0
    val q2Q3 = 2 * q2 * q3
    val q1Q0 = 2 * q1 * q0
    return doubleArrayOf(
      atan2(q1Q2 - q3Q0, 1 - sqQ1 - sqQ3),
      asin(-(q2Q3 + q1Q0)),
      atan2(-(q1Q3 - q2Q0), 1 - sqQ1 - sqQ2)
    )
  }
  fun setUpdateInterval(interval: Int) {
    this.interval = interval
    if (eventSink != null) {
      sensorManager.unregisterListener(this)
      sensorManager.registerListener(this, sensor, interval)
    }
  }
}