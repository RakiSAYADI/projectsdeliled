package com.example.cryptcode;

import android.Manifest;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.os.Build;
import android.os.Environment;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.google.zxing.WriterException;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import androidmads.library.qrgenearator.QRGContents;
import androidmads.library.qrgenearator.QRGEncoder;
import androidmads.library.qrgenearator.QRGSaver;

public class MainActivity extends AppCompatActivity {
Button crypting_me;
    QRGEncoder qrgEncoder;
    EditText your_text,my_text,your_key,your_iv;
    Bitmap bitmap;
    String inputValue;
    String folder_main = "QRCode";
    String savePath = Environment.getExternalStorageDirectory().getPath();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        your_key=findViewById(R.id.key_here);
        your_iv=findViewById(R.id.vector_init);
        crypting_me=findViewById(R.id.crypt_me);
        your_text=findViewById(R.id.message_here);
        my_text=findViewById(R.id.message_giving);
        if (isStoragePermissionGranted())
        {
            Toast.makeText(getApplicationContext(), "storage writing is authorised", Toast.LENGTH_LONG).show();
        }
        else
        {
            Toast.makeText(getApplicationContext(), "storage writing is not authorised", Toast.LENGTH_LONG).show();
        }
        crypting_me.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                try
                {
                    String iv=your_iv.getText().toString();
                    String message;
                    if (iv.matches(""))
                    {
                        message = encrypt(your_key.getText().toString(),your_text.getText().toString(),ivBytes);
                    }
                    else
                    {
                        byte[] bytes = your_iv.getText().toString().getBytes("UTF-8");
                        message = encrypt(your_key.getText().toString(),your_text.getText().toString(),bytes);
                    }
                    //String messaging =decrypt("deliled",message);
                    my_text.setText(message);
                    inputValue = my_text.getText().toString().trim();
                    if (inputValue.length() > 0)
                    {
                        WindowManager manager = (WindowManager) getSystemService(WINDOW_SERVICE);
                        Display display = manager.getDefaultDisplay();
                        Point point = new Point();
                        display.getSize(point);
                        int width = point.x;
                        int height = point.y;
                        int smallerDimension = width < height ? width : height;
                        smallerDimension = smallerDimension * 3 / 4;

                        qrgEncoder = new QRGEncoder(
                                inputValue, null,
                                QRGContents.Type.TEXT,
                                smallerDimension);
                        try
                        {
                            bitmap = qrgEncoder.encodeAsBitmap();
                            LinearLayout layout = new LinearLayout(getApplication().getApplicationContext());
                            layout.setOrientation(LinearLayout.VERTICAL);

                            final ImageView QRCODE = new ImageView(getApplication().getApplicationContext());
                            QRCODE.setImageBitmap(bitmap);
                            layout.addView(QRCODE);

                            final AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
                            builder.setTitle("QRCODE")
                                    .setCancelable(true)
                                    .setView(layout)
                                    .setNeutralButton("OK", new DialogInterface.OnClickListener() {
                                        public void onClick(final DialogInterface dialog, final int id) {
                                            boolean save;
                                            String result;
                                            try
                                            {
                                                File f = new File(savePath, folder_main);
                                                Log.i(TAG,f.getPath());
                                                if (!f.exists())
                                                {
                                                    if (f.mkdirs())
                                                    {
                                                        Log.i(TAG,"true");
                                                    }
                                                    else
                                                    {
                                                        Log.i(TAG,"false");
                                                    }
                                                }
                                                save = QRGSaver.save(f.getPath()+"/", your_text.getText().toString().trim(), bitmap, QRGContents.ImageType.IMAGE_JPEG);
                                                result = save ? "Image Saved" : "Image Not Saved";
                                                Toast.makeText(getApplicationContext(), result, Toast.LENGTH_LONG).show();
                                                if (save)
                                                {
                                                    Toast.makeText(getApplicationContext(), "the image is in : "+f.getPath(), Toast.LENGTH_LONG).show();
                                                }
                                            } catch (Exception e) {
                                                e.printStackTrace();
                                            }
                                           dialog.cancel();
                                        }
                                    });
                            final AlertDialog alert = builder.create();
                            alert.show();
                        }
                        catch (WriterException e)
                        {
                            Log.v(TAG, e.toString());
                        }
                    } else {
                        my_text.setError("Required");
                    }
                }
                catch (UnsupportedEncodingException e)
                {
                    e.printStackTrace();
                }
                catch (GeneralSecurityException e)
                {
                    e.printStackTrace();
                }
            }
        });


    }
    public  boolean isStoragePermissionGranted() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (checkSelfPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
                    == PackageManager.PERMISSION_GRANTED) {
                Log.v(TAG,"Permission is granted");
                return true;
            } else {

                Log.v(TAG,"Permission is revoked");
                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1);
                return false;
            }
        }
        else { //permission is automatically granted on sdk<23 upon installation
            Log.v(TAG,"Permission is granted");
            return true;
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

    private static SecretKeySpec generateKey(final String password) throws NoSuchAlgorithmException, UnsupportedEncodingException {
        final MessageDigest digest = MessageDigest.getInstance(HASH_ALGORITHM);
        byte[] bytes = password.getBytes("UTF-8");
        digest.update(bytes, 0, bytes.length);
        byte[] key = digest.digest();

        log("SHA-256 key ", key);

        SecretKeySpec secretKeySpec = new SecretKeySpec(key, "AES");
        return secretKeySpec;
    }


    /**
     * Encrypt and encode message using 256-bit AES with key generated from password.
     *
     *
     * @param password used to generated key
     * @param message the thing you want to encrypt assumed String UTF-8
     * @return Base64 encoded CipherText
     * @throws GeneralSecurityException if problems occur during encryption
     */
    public static String encrypt(final String password, String message,byte[] ivBytes)
            throws GeneralSecurityException
    {
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
     * @param key AES key typically 128, 192 or 256 bit
     * @param iv Initiation Vector
     * @param message in bytes (assumed it's already been decoded)
     * @return Encrypted cipher text (not encoded)
     * @throws GeneralSecurityException if something goes wrong during encryption
     */
    public static byte[] encrypt(final SecretKeySpec key, final byte[] iv, final byte[] message)
            throws GeneralSecurityException
    {
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
     * @param password used to generated key
     * @param base64EncodedCipherText the encrpyted message encoded with base64
     * @return message in Plain text (String UTF-8)
     * @throws GeneralSecurityException if there's an issue decrypting
     */
    public static String decrypt(final String password, String base64EncodedCipherText,byte[] ivBytes)
            throws GeneralSecurityException {

        try {
            final SecretKeySpec key = generateKey(password);

            log("base64EncodedCipherText", base64EncodedCipherText);
            byte[] decodedCipherText = Base64.decode(base64EncodedCipherText, Base64.NO_WRAP);
            log("decodedCipherText", decodedCipherText);

            byte[] decryptedBytes = decrypt(key, ivBytes, decodedCipherText);

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
     * @param key AES key typically 128, 192 or 256 bit
     * @param iv Initiation Vector
     * @param decodedCipherText in bytes (assumed it's already been decoded)
     * @return Decrypted message cipher text (not encoded)
     * @throws GeneralSecurityException if something goes wrong during encryption
     */
    public static byte[] decrypt(final SecretKeySpec key, final byte[] iv, final byte[] decodedCipherText)
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
     * @param bytes
     * @return
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
}
