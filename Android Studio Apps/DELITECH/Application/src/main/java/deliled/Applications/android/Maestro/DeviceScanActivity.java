package deliled.Applications.android.Maestro;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ListActivity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanResult;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import android.provider.Settings;
import android.util.Base64;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import static deliled.Applications.android.Maestro.MainActivity.Favoris;
import static deliled.Applications.android.Maestro.welcome.is_updated;

/**
 * Activity for scanning and displaying available Bluetooth LE devices.
 */
public class DeviceScanActivity extends ListActivity {
    //private final static  String TAG= DeviceScanActivity.class.getSimpleName();
    private LeDeviceListAdapter mLeDeviceListAdapter;
    private BluetoothAdapter mBluetoothAdapter;
    private boolean mScanning;
    private Handler mHandler;
    private String[] arrayMAC = new String[26];

    private static final int REQUEST_ENABLE_BT = 1;
    // Stops scanning after 10 seconds.
    private static final long SCAN_PERIOD = 10000;
    public static boolean change_mode = false;

    public String[] devices;

    public static JSONArray les_access;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        MainActivity.active = false;
        access_super_admin = true;
        getActionBar().setIcon(R.drawable.lumiair);
        arrayMAC[0] = "18:FE:34";
        arrayMAC[1] = "24:0A:C4";
        arrayMAC[2] = "24:B2:DE";
        arrayMAC[3] = "2C:3A:E8";
        arrayMAC[4] = "2C:F4:32";
        arrayMAC[5] = "30:AE:A4";
        arrayMAC[6] = "3C:71:BF";
        arrayMAC[7] = "54:5A:A6";
        arrayMAC[8] = "5C:CF:7F";
        arrayMAC[9] = "60:01:94";
        arrayMAC[10] = "68:C6:3A";
        arrayMAC[11] = "80:7D:3A";
        arrayMAC[12] = "84:0D:8E";
        arrayMAC[13] = "84:F3:EB";
        arrayMAC[14] = "90:97:D5";
        arrayMAC[15] = "A0:20:A6";
        arrayMAC[16] = "A4:7B:9D";
        arrayMAC[17] = "A4:CF:12";
        arrayMAC[18] = "AC:D0:74";
        arrayMAC[19] = "B4:E6:2D";
        arrayMAC[20] = "BC:DD:C2";
        arrayMAC[21] = "C4:4F:33";
        arrayMAC[22] = "CC:50:E3";
        arrayMAC[23] = "D8:A0:1D";
        arrayMAC[24] = "DC:4F:22";
        arrayMAC[25] = "EC:FA:BC";
        getActionBar().setTitle(R.string.title_devices);
        mHandler = new Handler();
        change_mode = false;

        new CountDownTimer(1000, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                if ((is_updated == 2 || is_updated == 3 || is_updated == 0)) {
                    Log.d("update", "checking is stopped ");
                    if (is_updated == 2) {
                        UPDATE();
                    }
                    cancel();
                }
            }

            @Override
            public void onFinish() {
                Log.d("update", "checking version ");
                start();
            }
        }.start();

        // Use this check to determine whether BLE is supported on the device.  Then you can
        // selectively disable BLE-related features.
        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            Toast.makeText(this, R.string.ble_not_supported, Toast.LENGTH_SHORT).show();
            finish();
        }

        // Initializes a Bluetooth adapter.  For API level 18 and above, get a reference to
        // BluetoothAdapter through BluetoothManager.
        final BluetoothManager bluetoothManager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        mBluetoothAdapter = bluetoothManager.getAdapter();

        // Checks if Bluetooth is supported on the device.
        if (mBluetoothAdapter == null) {
            Toast.makeText(this, R.string.error_bluetooth_not_supported, Toast.LENGTH_SHORT).show();
            finish();
        }

        if (access_super_admin) {
            reading_access();
        }


        final String PREFS_NAME = "MyPrefsFile";

        SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);

        if (settings.getBoolean("my_first_time", true)) {
            //the app is being launched for first time, do something
            //Toast.makeText(DeviceScanActivity.this, " First time ", Toast.LENGTH_SHORT).show();
            save("Favoris.txt", Favoris);
            save("access.txt", "{\"access\":[\"raki\"]}");
            Log.d("Comments", "First time");

            // first time task

            // record the fact that the app has been started at least once
            settings.edit().putBoolean("my_first_time", false).apply();
        }

        statusCheck();

    }

    public void reading_access() {
        //DEBUG_LOG_ENABLED=true;
        String message;
        String messga;
        try {
            message = encrypt("deliled", "deliled_01_ADMIN_84:0D:8E:2E:C2:C6");
            Log.d(TAG, "le message crypte 22 est = " + message);
            messga = decrypt("deliled", message);
            Log.d(TAG, "le message decrypte 22 est = " + messga);
            message = encrypt("deliled", "deliled_01_USER_84:0D:8E:2E:C2:C6");
            Log.d(TAG, "le message crypte 22 est = " + message);
            messga = decrypt("deliled", message);
            Log.d(TAG, "le message decrypte 22 est = " + messga);
        } catch (GeneralSecurityException e) {
            e.printStackTrace();
        }
    }

    private static final String TAG = "AESCrypt";

    //AESCrypt-ObjC uses CBC and PKCS7Padding
    private static final String AES_MODE = "AES/CBC/PKCS7Padding";
    private static final String CHARSET = "UTF-8";

    //AESCrypt-ObjC uses SHA-256 (and so a 256-bit key)
    private static final String HASH_ALGORITHM = "SHA-256";

    //AESCrypt-ObjC uses blank IV (not the best security, but the aim here is compatibility)
    private static final byte[] ivBytes = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

    //togglable log option (please turn off in live!)
    public static boolean DEBUG_LOG_ENABLED = false;

    private static SecretKeySpec generateKey(final String password) throws NoSuchAlgorithmException {
        final MessageDigest digest = MessageDigest.getInstance(HASH_ALGORITHM);
        byte[] bytes = password.getBytes(StandardCharsets.UTF_8);
        digest.update(bytes, 0, bytes.length);
        byte[] key = digest.digest();

        log("SHA-256 key ", key);

        return new SecretKeySpec(key, "AES");
    }


    /**
     * Encrypt and encode message using 256-bit AES with key generated from password.
     *
     * @param password used to generated key
     * @param message  the thing you want to encrypt assumed String UTF-8
     * @return Base64 encoded CipherText
     * @throws GeneralSecurityException if problems occur during encryption
     */
    public static String encrypt(final String password, String message)
            throws GeneralSecurityException {
        try {
            final SecretKeySpec key = generateKey(password);

            log("message", message);

            byte[] cipherText = encrypt(key, ivBytes, message.getBytes(CHARSET));

            //NO_WRAP is important as was getting \n at the end
            String encoded = Base64.encodeToString(cipherText, Base64.NO_WRAP);
            log("Base64.NO_WRAP", encoded);
            return encoded;
        } catch (UnsupportedEncodingException e) {
            if (DEBUG_LOG_ENABLED)
                Log.e(TAG, "UnsupportedEncodingException ", e);
            throw new GeneralSecurityException(e);
        }
    }


    /**
     * More flexible AES encrypt that doesn't encode
     *
     * @param key     AES key typically 128, 192 or 256 bit
     * @param iv      Initiation Vector
     * @param message in bytes (assumed it's already been decoded)
     * @return Encrypted cipher text (not encoded)
     * @throws GeneralSecurityException if something goes wrong during encryption
     */
    public static byte[] encrypt(final SecretKeySpec key, final byte[] iv, final byte[] message)
            throws GeneralSecurityException {
        final Cipher cipher = Cipher.getInstance(AES_MODE);
        IvParameterSpec ivSpec = new IvParameterSpec(iv);
        cipher.init(Cipher.ENCRYPT_MODE, key, ivSpec);
        byte[] cipherText = cipher.doFinal(message);

        log("cipherText", cipherText);

        return cipherText;
    }


    /**
     * Decrypt and decode ciphertext using 256-bit AES with key generated from password
     *
     * @param password                used to generated key
     * @param base64EncodedCipherText the encrpyted message encoded with base64
     * @return message in Plain text (String UTF-8)
     * @throws GeneralSecurityException if there's an issue decrypting
     */
    public static String decrypt(final String password, String base64EncodedCipherText)
            throws GeneralSecurityException {
        try {
            final SecretKeySpec key = generateKey(password);

            log("base64EncodedCipherText", base64EncodedCipherText);
            byte[] decodedCipherText = Base64.decode(base64EncodedCipherText, Base64.NO_WRAP);
            log("decodedCipherText", decodedCipherText);

            byte[] decryptedBytes = decrypts(key, ivBytes, decodedCipherText);

            log("decryptedBytes", decryptedBytes);
            String message = new String(decryptedBytes, CHARSET);
            log("message", message);


            return message;
        } catch (UnsupportedEncodingException e) {
            if (DEBUG_LOG_ENABLED)
                Log.e(TAG, "UnsupportedEncodingException ", e);

            throw new GeneralSecurityException(e);
        }
    }


    /**
     * More flexible AES decrypt that doesn't encode
     *
     * @param key               AES key typically 128, 192 or 256 bit
     * @param iv                Initiation Vector
     * @param decodedCipherText in bytes (assumed it's already been decoded)
     * @return Decrypted message cipher text (not encoded)
     * @throws GeneralSecurityException if something goes wrong during encryption
     */
    public static byte[] decrypts(final SecretKeySpec key, final byte[] iv, final byte[] decodedCipherText)
            throws GeneralSecurityException {
        final Cipher cipher = Cipher.getInstance(AES_MODE);
        IvParameterSpec ivSpec = new IvParameterSpec(iv);
        cipher.init(Cipher.DECRYPT_MODE, key, ivSpec);
        byte[] decryptedBytes = cipher.doFinal(decodedCipherText);

        log("decryptedBytes", decryptedBytes);

        return decryptedBytes;
    }


    private static void log(String what, byte[] bytes) {
        if (DEBUG_LOG_ENABLED)
            Log.d(TAG, what + "[" + bytes.length + "] [" + bytesToHex(bytes) + "]");
    }

    private static void log(String what, String value) {
        if (DEBUG_LOG_ENABLED)
            Log.d(TAG, what + "[" + value.length() + "] [" + value + "]");
    }


    /**
     * Converts byte array to hexidecimal useful for logging and fault finding
     *
     * @param bytes message in BYTES
     * @return message in STRING
     */
    private static String bytesToHex(byte[] bytes) {
        final char[] hexArray = {'0', '1', '2', '3', '4', '5', '6', '7', '8',
                '9', 'A', 'B', 'C', 'D', 'E', 'F'};
        char[] hexChars = new char[bytes.length * 2];
        int v;
        for (int j = 0; j < bytes.length; j++) {
            v = bytes[j] & 0xFF;
            hexChars[j * 2] = hexArray[v >>> 4];
            hexChars[j * 2 + 1] = hexArray[v & 0x0F];
        }
        return new String(hexChars);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main, menu);
        if (!mScanning) {
            menu.findItem(R.id.menu_stop).setVisible(false);
            menu.findItem(R.id.menu_scan).setVisible(true);
            menu.findItem(R.id.menu_refresh).setActionView(null);
        } else {
            menu.findItem(R.id.menu_stop).setVisible(true);
            menu.findItem(R.id.menu_scan).setVisible(false);
            menu.findItem(R.id.menu_refresh).setActionView(
                    R.layout.actionbar_indeterminate_progress);
        }
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.menu_scan:
                mLeDeviceListAdapter.clear();
                scanLeDevice(true);
                break;
            case R.id.menu_stop:
                if (access_super_admin) {
                    save("access.txt", "{\"access\":[\"raki\"]}");
                    Toast.makeText(DeviceScanActivity.this, " ACCESS reinitialisé ! ", Toast.LENGTH_SHORT).show();
                }
                scanLeDevice(false);
                break;
        }
        return true;
    }

    public void UPDATE() {
        final AlertDialog.Builder builder = new AlertDialog.Builder(getApplicationContext());
        builder.setMessage("Une nouvelle version d'application Lumi'Air est disponible sur playstore, veuillez le mettre à jour !")
                .setCancelable(true)
                .setTitle("Mise à jour")
                .setNeutralButton("OK", new DialogInterface.OnClickListener() {
                    public void onClick(final DialogInterface dialog, final int id) {
                        try {
                            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + DeviceScanActivity.this.getPackageName())));
                        } catch (android.content.ActivityNotFoundException anfe) {
                            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + DeviceScanActivity.this.getPackageName())));
                        }
                        dialog.cancel();
                    }
                });
        final AlertDialog alert = builder.create();
        alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_slide;
        alert.show();
    }

    public void statusCheck() {
        final LocationManager manager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);

        if (!manager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
            buildAlertMessageNoGps();
        }
        if (ActivityCompat.checkSelfPermission(getApplicationContext(), Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                && ActivityCompat.checkSelfPermission(getApplicationContext(), Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(DeviceScanActivity.this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 1);
        }
    }

    private void buildAlertMessageNoGps() {
        final AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("Votre GPS semble être désactivé, voulez-vous l'activer ?")
                .setCancelable(false)
                .setTitle("Configuration d'acces :")
                .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                    public void onClick(final DialogInterface dialog, final int id) {
                        startActivity(new Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS));
                    }
                })
                .setNegativeButton("Non", new DialogInterface.OnClickListener() {
                    public void onClick(final DialogInterface dialog, final int id) {
                        dialog.cancel();
                        finish();
                    }
                });
        final AlertDialog alert = builder.create();
        alert.show();
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Ensures Bluetooth is enabled on the device.  If Bluetooth is not currently enabled,
        // fire an intent to display a dialog asking the user to grant permission to enable it.
        MainActivity.active = false;
        change_mode = false;
        if (!mBluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
        }
        MainActivity.mGattCharacteristics = null;
        // Initializes list view adapter.
        mLeDeviceListAdapter = new LeDeviceListAdapter();
        setListAdapter(mLeDeviceListAdapter);
        bluetoothLeScanner = mBluetoothAdapter.getBluetoothLeScanner();
        scanLeDevice(true);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // User chose not to enable Bluetooth.
        if (requestCode == REQUEST_ENABLE_BT && resultCode == Activity.RESULT_CANCELED) {
            finish();
            return;
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    protected void onPause() {
        super.onPause();
        scanLeDevice(false);
        mLeDeviceListAdapter.clear();
    }

    public static BluetoothDevice mDevice;
    public static Boolean access_saved = false;
    public static Boolean ACCESS = false;
    public static int user_compter = 0;
    public static int admin_compter = 0;
    public AlertDialog alert;
    public Boolean first_Access = true;
    public static Boolean access_super_admin;

    @Override
    protected void onListItemClick(ListView l, final View v, int position, long id) {
        final BluetoothDevice device = mLeDeviceListAdapter.getDevice(position);
        mDevice = device;
        read_text_json();
        if (device == null) return;
        mScanning = false;
        bluetoothLeScanner.stopScan(mLeScanCallback);
        user_compter = 0;
        admin_compter = 0;
        first_Access = true;
        v.setBackgroundColor(ContextCompat.getColor(this, R.color.Orange_deliled));
        if (access_super_admin) {
            final Intent intent = new Intent(DeviceScanActivity.this, MainActivity.class);
            intent.putExtra(MainActivity.EXTRAS_DEVICE_NAME, device.getName());
            intent.putExtra(MainActivity.EXTRAS_DEVICE_ADDRESS, device.getAddress());
            ACCESS = true;
            startActivity(intent);
        } else {
            for (int i = 0; i < devices.length; i++) {
                if (devices[i].contains(mDevice.getAddress()) & (devices[i].contains("MA"))) {
                    first_Access = false;
                    if (devices[i].contains("USER")) {
                        ACCESS = false;
                        user_compter++;
                    }
                    if (devices[i].contains("ADMIN")) {
                        ACCESS = true;
                        admin_compter++;
                    }
                    if (!(admin_compter == 0) & (!(user_compter == 0)) & (devices[i].contains(mDevice.getAddress()))) {
                        final AlertDialog.Builder builder = new AlertDialog.Builder(this);
                        builder.setMessage("Voulez-vous vous connecter en tant qu'Utilisateur ou Administrateur ?")
                                .setCancelable(false)
                                .setTitle("Connexion")
                                .setPositiveButton("Administrateur", new DialogInterface.OnClickListener() {
                                    public void onClick(final DialogInterface dialog, final int id) {
                                        final Intent intent = new Intent(DeviceScanActivity.this, MainActivity.class);
                                        intent.putExtra(MainActivity.EXTRAS_DEVICE_NAME, device.getName());
                                        intent.putExtra(MainActivity.EXTRAS_DEVICE_ADDRESS, device.getAddress());
                                        ACCESS = true;
                                        startActivity(intent);
                                        dialog.cancel();
                                    }
                                })
                                .setNegativeButton("Utilisateur ", new DialogInterface.OnClickListener() {
                                    public void onClick(final DialogInterface dialog, final int id) {
                                        final Intent intent = new Intent(DeviceScanActivity.this, MainActivity.class);
                                        intent.putExtra(MainActivity.EXTRAS_DEVICE_NAME, device.getName());
                                        intent.putExtra(MainActivity.EXTRAS_DEVICE_ADDRESS, device.getAddress());
                                        ACCESS = false;
                                        startActivity(intent);
                                        dialog.cancel();
                                    }
                                });
                        final AlertDialog alert = builder.create();
                        alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_phone;
                        alert.show();
                        user_compter = 0;
                        admin_compter = 0;
                    }
                }
            }
            for (int i = 0; i < devices.length; i++) {
                if (((!(admin_compter == 0) | (!(user_compter == 0))) | !(user_compter == admin_compter)) & devices[i].contains(mDevice.getAddress())) {
                    first_Access = false;
                    final Intent intent = new Intent(DeviceScanActivity.this, MainActivity.class);
                    intent.putExtra(MainActivity.EXTRAS_DEVICE_NAME, device.getName());
                    intent.putExtra(MainActivity.EXTRAS_DEVICE_ADDRESS, device.getAddress());
                    startActivity(intent);
                }
            }
            for (int i = 0; i < devices.length; i++) {
                if (!(devices[i].contains(mDevice.getAddress())) & first_Access) {
                    final AlertDialog.Builder builder = new AlertDialog.Builder(this);
                    builder.setMessage("Voulez-vous activer le scan de QR-CODE à chaque connexion ?")
                            .setCancelable(false)
                            .setTitle("QR CODE")
                            .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                                public void onClick(final DialogInterface dialog, final int id) {
                                    access_saved = false;
                                    final Intent intent = new Intent(DeviceScanActivity.this, QR_CODE.class);
                                    startActivity(intent);
                                    dialog.cancel();
                                }
                            })
                            .setNegativeButton("Non", new DialogInterface.OnClickListener() {
                                public void onClick(final DialogInterface dialog, final int id) {
                                    access_saved = true;
                                    final Intent intent = new Intent(DeviceScanActivity.this, QR_CODE.class);
                                    startActivity(intent);
                                    dialog.cancel();
                                }
                            });
                    alert = builder.create();
                    alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_phone;
                    alert.show();
                }
            }
        }
    }

    private BluetoothLeScanner bluetoothLeScanner;

    private void scanLeDevice(final boolean enable) {
        if (enable) {
            // Stops scanning after a pre-defined scan period.
            mHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    mScanning = false;
                    bluetoothLeScanner.stopScan(mLeScanCallback);
                    invalidateOptionsMenu();
                }
            }, SCAN_PERIOD);
            mScanning = true;
            bluetoothLeScanner.startScan(mLeScanCallback);
        } else {
            mScanning = false;
            bluetoothLeScanner.stopScan(mLeScanCallback);
        }
        invalidateOptionsMenu();
    }

    private void errorToast() {
        Toast.makeText(this, "Draw over other app permission not available. Can't start the application without the permission.", Toast.LENGTH_LONG).show();
    }

    @Override
    public void onBackPressed() {
        if (Settings.canDrawOverlays(this)) {
            startService(new Intent(getApplicationContext(), FloatingWidgetService.class).putExtra("activity_background", true));
            finish();
        } else {
            errorToast();
        }
        Intent a = new Intent(Intent.ACTION_MAIN);
        a.addCategory(Intent.CATEGORY_HOME);
        a.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(a);
    }

    // Adapter for holding devices found through scanning.
    private class LeDeviceListAdapter extends BaseAdapter {
        private ArrayList<BluetoothDevice> mLeDevices;
        private LayoutInflater mInflator;

        private LeDeviceListAdapter() {
            super();
            mLeDevices = new ArrayList<>();
            mInflator = DeviceScanActivity.this.getLayoutInflater();
        }

        private void addDevice(BluetoothDevice device) {
            if (!mLeDevices.contains(device)) {
                mLeDevices.add(device);
            }
        }

        private BluetoothDevice getDevice(int position) {
            return mLeDevices.get(position);
        }

        public void clear() {
            mLeDevices.clear();
        }

        @Override
        public int getCount() {
            return mLeDevices.size();
        }

        @Override
        public Object getItem(int i) {
            return mLeDevices.get(i);
        }

        @Override
        public long getItemId(int i) {
            return i;
        }

        @Override
        public View getView(int i, View view, ViewGroup viewGroup) {
            ViewHolder viewHolder;
            // General ListView optimization code.
            if (view == null) {
                view = mInflator.inflate(R.layout.listitem_device, null);
                viewHolder = new ViewHolder();
                viewHolder.deviceAddress = view.findViewById(R.id.device_address);
                viewHolder.deviceName = view.findViewById(R.id.device_name);
                view.setTag(viewHolder);
            } else {
                viewHolder = (ViewHolder) view.getTag();
            }

            BluetoothDevice device = mLeDevices.get(i);
            final String deviceName = device.getName();
            if (deviceName != null && deviceName.length() > 0) {
                viewHolder.deviceName.setText(deviceName);
                viewHolder.deviceAddress.setText(device.getAddress());
                return view;
            } else {
                viewHolder.deviceName.setText(R.string.unknown_device);
                viewHolder.deviceAddress.setText(device.getAddress());
                return view;
            }
        }
    }

    public void read_text_json() {
        if (!fileExists(getApplicationContext(), "access.txt")) {
            save("access.txt", "{\"access\":[\"raki\"]}");
        }
        String les_profiles = load("access.txt");
        try {
            JSONObject access = new JSONObject(les_profiles);
            les_access = access.getJSONArray("access");
            String[] list_of_devices = new String[les_access.length()];
            for (int i = 0; i < les_access.length(); i++) {
                list_of_devices[i] = les_access.getString(i);
            }
            devices = list_of_devices;
        } catch (Throwable t) {
            Log.e("My App", "Could not parse malformed access ");
        }
    }

    public boolean fileExists(Context context, String filename) {
        File file = context.getFileStreamPath(filename);
        if (file == null || !file.exists()) {
            return false;
        } else {
            return true;
        }
    }

    public void save(String FILE_NAME, String text) {
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

    public String load(String FILE_NAME) {
        FileInputStream fis = null;

        try {
            fis = openFileInput(FILE_NAME);
            InputStreamReader isr = new InputStreamReader(fis);
            BufferedReader br = new BufferedReader(isr);
            StringBuilder sb = new StringBuilder();
            String text;

            while ((text = br.readLine()) != null) {
                sb.append(text).append("\n");
            }
            return sb.toString();

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (fis != null) {
                try {
                    fis.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return null;
    }

    int i;
    // Device scan callback.
    private ScanCallback mLeScanCallback = new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, final ScanResult result) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    for (i = 0; i <= 25; i++) {
                        if (result.getDevice().getAddress().contains(arrayMAC[i])) {
                            mLeDeviceListAdapter.addDevice(result.getDevice());
                            mLeDeviceListAdapter.notifyDataSetChanged();
                        }
                    }
                    //Log.i("SCAN","device name is = "+device.getName()+ " and address is = "+device.getAddress());
                }
            });
        }
    };

    static class ViewHolder {
        TextView deviceName;
        TextView deviceAddress;
    }
}