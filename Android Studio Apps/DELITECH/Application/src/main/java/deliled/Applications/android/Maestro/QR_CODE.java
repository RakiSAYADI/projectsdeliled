package deliled.Applications.android.Maestro;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Vibrator;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import android.util.SparseArray;
import android.view.MenuItem;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.widget.TextView;

import com.google.android.gms.vision.CameraSource;
import com.google.android.gms.vision.Detector;
import com.google.android.gms.vision.barcode.Barcode;
import com.google.android.gms.vision.barcode.BarcodeDetector;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.GeneralSecurityException;

import static deliled.Applications.android.Maestro.DeviceScanActivity.ACCESS;
import static deliled.Applications.android.Maestro.DeviceScanActivity.access_saved;
import static deliled.Applications.android.Maestro.DeviceScanActivity.admin_compter;
import static deliled.Applications.android.Maestro.DeviceScanActivity.decrypt;
import static deliled.Applications.android.Maestro.DeviceScanActivity.les_access;
import static deliled.Applications.android.Maestro.DeviceScanActivity.mDevice;
import static deliled.Applications.android.Maestro.DeviceScanActivity.user_compter;

public class QR_CODE extends Activity {

    SurfaceView surfaceView;
    TextView textView;

    CameraSource cameraSource;
    BarcodeDetector barcodeDetector;

    final int RequestCameraPermissionID = 1001;
    public static int counter=0;

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        switch (requestCode) {
            case RequestCameraPermissionID: {
                if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    if (ActivityCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                        return;
                    }
                    try {
                        cameraSource.start(surfaceView.getHolder());
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
            break;
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.qr_code);
        getActionBar().setIcon(R.drawable.lumiair);
        getActionBar().setTitle("QR Scan");
        getActionBar().setDisplayHomeAsUpEnabled(true);
        surfaceView=findViewById(R.id.camerapreview);
        textView =findViewById(R.id.tewext);
        barcodeDetector =new BarcodeDetector.Builder(this).setBarcodeFormats(Barcode.QR_CODE).build();
        cameraSource = new CameraSource.Builder(this,barcodeDetector).setRequestedPreviewSize(640,480).build();
        counter=0;
        surfaceView.getHolder().addCallback(new SurfaceHolder.Callback()
        {
            @Override
            public void surfaceCreated(SurfaceHolder surfaceHolder)
            {
                if (ActivityCompat.checkSelfPermission(getApplicationContext(), android.Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                    //Request permission
                    ActivityCompat.requestPermissions(QR_CODE.this,
                            new String[]{Manifest.permission.CAMERA},RequestCameraPermissionID);
                    return;
                }
                try {
                    cameraSource.start(surfaceView.getHolder());
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            @Override
            public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {}

            @Override
            public void surfaceDestroyed(SurfaceHolder holder) {
                cameraSource.stop();
            }
        });

        barcodeDetector.setProcessor(new Detector.Processor<Barcode>()
        {
            @Override
            public void release() {}

            @Override
            public void receiveDetections(Detector.Detections<Barcode> detections)
            {
                final SparseArray<Barcode> qrcodes = detections.getDetectedItems();
                if(qrcodes.size() != 0)
                {
                    textView.post(new Runnable()
                    {
                        @Override
                        public void run()
                        {
                            //Create vibrate
                            Vibrator vibrator = (Vibrator)getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
                            vibrator.vibrate(1000);
                            String  ds="";
                            try
                            {
                                ds=decrypt("deliled",qrcodes.valueAt(0).displayValue);
                            }
                            catch (GeneralSecurityException e)
                            {
                                e.printStackTrace();
                            }

                            if (ds.contains("deliled")&
                                    (ds.contains("USER")|
                                            ds.contains("ADMIN"))&
                                    (ds.contains(mDevice.getAddress()))
                                    & counter == 0)
                            {
                                String access = "accès autorisé";
                                textView.setText(access);
                                if (access_saved)
                                {
                                    les_access.put(ds+"MA");
                                    JSONObject profile_1 = new JSONObject();
                                    try
                                    {
                                        profile_1.put("access",les_access);
                                        save("access.txt",profile_1.toString());
                                    }
                                    catch (JSONException e)
                                    {
                                        e.printStackTrace();
                                    }
                                }
                                if (ds.contains("USER"))
                                {
                                    ACCESS=false;
                                }
                                if (ds.contains("ADMIN"))
                                {
                                    ACCESS=true;
                                }
                                user_compter=0;
                                admin_compter=0;
                                final Intent intent = new Intent(QR_CODE.this, MainActivity.class);
                                intent.putExtra(MainActivity.EXTRAS_DEVICE_NAME, mDevice.getName());
                                intent.putExtra(MainActivity.EXTRAS_DEVICE_ADDRESS, mDevice.getAddress());
                                counter++;
                                startActivity(intent);
                            }
                            else
                            {
                                if(counter==0)
                                {
                                    String access = "accès refusé";
                                    textView.setText(access);
                                }
                            }
                            //Log.d("QRCODE", "QR CODE is = "+qrcodes.valueAt(0).displayValue );
                        }
                    });
                }
            }
        });
    }

    public void save(String FILE_NAME,String text) {
        FileOutputStream fos = null;
        try {
            fos = openFileOutput(FILE_NAME, MODE_PRIVATE);
            fos.write(text.getBytes());
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (fos != null) {
                try {
                    fos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    @Override
    public void onBackPressed() {
        Intent i = new Intent(QR_CODE.this, DeviceScanActivity.class);
        i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(i);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch(item.getItemId()) {
            case android.R.id.home:
                onBackPressed();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
