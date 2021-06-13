package edu.skku.map.assignment13;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.BatteryManager;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String channel = "edu.skku.map.assignment13/BatteryLevel";
    private static final String eventChannel = "edu.skku.map.assignment13/Accelerometer";

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), channel)
                .setMethodCallHandler(
                        ((call, result) -> {
                            if (call.method.equals("getBatteryLevel")) {
                                int batteryLevel = getBatteryLevel();
                                if (batteryLevel != -1) {
                                    result.success(batteryLevel);
                                }
                            } else {
                                result.notImplemented();
                            }
                        })
                );

        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), eventChannel)
                .setStreamHandler(
                        new AccelerometerStreamHandler()
                );
    }

    class AccelerometerStreamHandler implements EventChannel.StreamHandler {
        private Sensor sensor;
        private SensorManager sensorManager;
        private SensorEventListener sensorEventListener;
        private final float[] mRotationMatrix = new float[16];

        AccelerometerStreamHandler() {
            this.sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
            this.sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        }

        @Override
        public void onListen(Object arguments, EventChannel.EventSink events) {
            sensorEventListener = new SensorEventListener() {

                @Override
                public void onSensorChanged(SensorEvent sensorEvent) {
                    double x = (double) (Math.atan2(sensorEvent.values[0], sensorEvent.values[1]) / (Math.PI / 180));
                    double y = (double) (Math.atan2(sensorEvent.values[0], sensorEvent.values[2]) / (Math.PI / 180));
                    double z = (double) (Math.atan2(sensorEvent.values[1], sensorEvent.values[2]) / (Math.PI / 180));
                    double len = (double) Math.sqrt((Math.pow(x, 2) + Math.pow(y, 2) + Math.pow(z, 2)));
                    double[] sensorValues = new double[sensorEvent.values.length];
                    sensorValues[0] = x / (double) len;
                    sensorValues[1] = y / (double) len;
                    sensorValues[2] = z / (double) len;
                    events.success(sensorValues);
                }

                @Override
                public void onAccuracyChanged(Sensor sensor, int i) {

                }


            };
            sensorManager.registerListener(sensorEventListener, sensor, sensorManager.SENSOR_DELAY_NORMAL);
        }

        @Override
        public void onCancel(Object arguments) {
            sensorManager.unregisterListener(sensorEventListener);
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private int getBatteryLevel() {
        int batteryLevel = -1;
        BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        }
        return batteryLevel;
    }
}
