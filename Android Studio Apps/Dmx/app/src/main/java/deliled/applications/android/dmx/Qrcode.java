package deliled.applications.android.dmx;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Vibrator;
import android.util.SparseArray;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import com.google.android.gms.vision.CameraSource;
import com.google.android.gms.vision.Detector;
import com.google.android.gms.vision.barcode.Barcode;
import com.google.android.gms.vision.barcode.BarcodeDetector;

import java.io.IOException;

public class Qrcode extends Activity {
    public static int CounterReading = 0;
    final int RequestCameraPermissionID = 1001;
    SurfaceView cameraView;
    TextView AccessState;
    CameraSource cameraSource;
    BarcodeDetector barcodeDetector;

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == RequestCameraPermissionID) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                if (ActivityCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                    return;
                }
                try {
                    cameraSource.start(cameraView.getHolder());
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scanqrcode);
        cameraView = findViewById(R.id.camerapreview);
        AccessState = findViewById(R.id.tewext);
        barcodeDetector = new BarcodeDetector.Builder(this).setBarcodeFormats(Barcode.QR_CODE).build();
        cameraSource = new CameraSource.Builder(this, barcodeDetector).setRequestedPreviewSize(640, 480).build();
        CounterReading = 0;
        cameraView.getHolder().addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(SurfaceHolder surfaceHolder) {
                if (ActivityCompat.checkSelfPermission(getApplicationContext(), android.Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                    //Request permission
                    ActivityCompat.requestPermissions(Qrcode.this,
                            new String[]{Manifest.permission.CAMERA}, RequestCameraPermissionID);
                    return;
                }
                try {
                    cameraSource.start(cameraView.getHolder());
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
            }

            @Override
            public void surfaceDestroyed(SurfaceHolder holder) {
                cameraSource.stop();
            }
        });

        barcodeDetector.setProcessor(new Detector.Processor<Barcode>() {
            @Override
            public void release() {
            }

            @Override
            public void receiveDetections(Detector.Detections<Barcode> detections) {
                final SparseArray<Barcode> qrcodes = detections.getDetectedItems();
                if (qrcodes.size() != 0) {
                    AccessState.post(new Runnable() {
                        @Override
                        public void run() {
                            //Create vibrate
                            Vibrator vibrator = (Vibrator) getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
                            vibrator.vibrate(1000);
                            String QrcodeReaded;
                            QrcodeReaded = qrcodes.valueAt(0).displayValue;
                            if (QrcodeReaded.contains("deliled_012_DMX_3C:AB:DF:EA:DD") & CounterReading == 0) {
                                String access = "accès autorisé";
                                AccessState.setText(access);
                                AccessState.setTextColor(getResources().getColor(R.color.Green));
                                CounterReading++;
                                final AlertDialog.Builder builder = new AlertDialog.Builder(Qrcode.this);
                                builder.setMessage("DMX_0132_A3D752 \n 3C:AB:CD:46:FD:0B")
                                        .setCancelable(false)
                                        .setTitle("Votre Robot UV-C :")
                                        .setPositiveButton("Valider", new DialogInterface.OnClickListener() {
                                            public void onClick(final DialogInterface dialog, final int id) {
                                                Intent intent1 = new Intent(getBaseContext(), SettingsDmx.class);
                                                dialog.cancel();
                                                startActivity(intent1);
                                            }
                                        })
                                        .setNegativeButton("Annuler", new DialogInterface.OnClickListener() {
                                            public void onClick(final DialogInterface dialog, final int id) {
                                                onBackPressed();
                                                dialog.cancel();
                                            }
                                        });
                                final AlertDialog alert = builder.create();
                                alert.show();
                            } else {
                                if (CounterReading == 0) {
                                    String access = "accès refusé";
                                    AccessState.setTextColor(getResources().getColor(R.color.Red));
                                    AccessState.setText(access);
                                }
                            }
                        }
                    });
                }
            }
        });
    }
}
